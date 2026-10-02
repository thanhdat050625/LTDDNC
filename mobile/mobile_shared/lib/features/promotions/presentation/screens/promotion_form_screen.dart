import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class PromotionFormScreen extends StatefulWidget {
  final PromotionModel? promotion;

  const PromotionFormScreen({super.key, this.promotion});

  @override
  State<PromotionFormScreen> createState() => _PromotionFormScreenState();
}

class _PromotionFormScreenState extends State<PromotionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _discountValueCtrl;
  late TextEditingController _maxUsageCtrl;
  String _discountType = 'PERCENTAGE';
  bool _isActive = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    final p = widget.promotion;
    _codeCtrl = TextEditingController(text: p?.code ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _discountValueCtrl = TextEditingController(text: p?.discountValue.toString() ?? '');
    _maxUsageCtrl = TextEditingController(text: p?.maxUsage?.toString() ?? '');
    if (p != null) {
      _discountType = p.discountType;
      _isActive = p.isActive;
      _startDate = p.startDate;
      _endDate = p.endDate;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _discountValueCtrl.dispose();
    _maxUsageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<PromotionFormCubit>().submit(
        isEdit: widget.promotion != null,
        promotionId: widget.promotion?.id,
        data: {
          'code': _codeCtrl.text.trim().toUpperCase(),
          'description': _descCtrl.text.trim(),
          'discountType': _discountType,
          'discountValue': num.parse(_discountValueCtrl.text.trim()),
          'startDate': _startDate.toIso8601String(),
          'endDate': _endDate.toIso8601String(),
          'maxUsage': _maxUsageCtrl.text.trim().isEmpty ? null : int.parse(_maxUsageCtrl.text.trim()),
          'isActive': _isActive,
        },
      );
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final isEdit = widget.promotion != null;

    return AppScaffold(
      title: isEdit ? AppLocalizations.of(context)!.editPromotion : AppLocalizations.of(context)!.addPromotion,
      showBackButton: true,
      body: BlocConsumer<PromotionFormCubit, PromotionFormState>(
        listener: (context, state) {
          if (state is PromotionFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEdit ? AppLocalizations.of(context)!.updateSuccess : AppLocalizations.of(context)!.addSuccess)),
            );
            context.pop();
          } else if (state is PromotionFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: TextStyle(color: theme.error))),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PromotionFormSubmitting;

          return SingleChildScrollView(
            padding: EdgeInsets.all(theme.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _codeCtrl,
                    label: '${AppLocalizations.of(context)!.promoCode} *',
                    hintText: AppLocalizations.of(context)!.promoCode,
                    validator: (val) => val == null || val.isEmpty ? AppLocalizations.of(context)!.fillRequiredFields : null,
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _descCtrl,
                    label: AppLocalizations.of(context)!.promoDescription,
                  ),
                  SizedBox(height: theme.spacingMd),
                  Text(AppLocalizations.of(context)!.discountType, style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _discountType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.textSecondary)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: [
                      DropdownMenuItem(value: 'PERCENTAGE', child: Text(AppLocalizations.of(context)!.percentage)),
                      DropdownMenuItem(value: 'FIXED_AMOUNT', child: Text(AppLocalizations.of(context)!.fixedAmount)),
                    ],
                    onChanged: (val) => setState(() => _discountType = val!),
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _discountValueCtrl,
                    label: '\${AppLocalizations.of(context)!.discountValue} *',
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? AppLocalizations.of(context)!.fillRequiredFields : null,
                  ),
                  SizedBox(height: theme.spacingMd),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.startDate,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(FormatUtils.formatDate(_startDate)),
                          ),
                        ),
                      ),
                      SizedBox(width: theme.spacingMd),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.endDate,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(FormatUtils.formatDate(_endDate)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _maxUsageCtrl,
                    label: AppLocalizations.of(context)!.maxUsage,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: theme.spacingMd),
                  SwitchListTile(
                    title: const Text('Trạng thái'),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SizedBox(height: theme.spacingLg),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: AppLocalizations.of(context)!.save,
                      onPressed: _submit,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
