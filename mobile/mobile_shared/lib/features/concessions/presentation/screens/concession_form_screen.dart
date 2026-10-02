import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionFormScreen extends StatefulWidget {
  final ConcessionProductModel? concession;

  const ConcessionFormScreen({super.key, this.concession});

  @override
  State<ConcessionFormScreen> createState() => _ConcessionFormScreenState();
}

class _ConcessionFormScreenState extends State<ConcessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.concession;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _priceCtrl = TextEditingController(text: c?.price.toString() ?? '');
    _stockCtrl = TextEditingController(text: c?.stockQuantity.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ConcessionFormCubit>().submit(
        isEdit: widget.concession != null,
        concessionId: widget.concession?.id,
        data: {
          'name': _nameCtrl.text.trim(),
          'price': num.parse(_priceCtrl.text.trim()),
          'stockQuantity': int.parse(_stockCtrl.text.trim()),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final isEdit = widget.concession != null;

    return AppScaffold(
      title: isEdit ? AppLocalizations.of(context)!.editProduct : AppLocalizations.of(context)!.addProduct,
      showBackButton: true,
      body: BlocConsumer<ConcessionFormCubit, ConcessionFormState>(
        listener: (context, state) {
          if (state is ConcessionFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEdit ? AppLocalizations.of(context)!.updateSuccess : AppLocalizations.of(context)!.addSuccess)),
            );
            context.pop();
          } else if (state is ConcessionFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: TextStyle(color: theme.error))),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ConcessionFormSubmitting;

          return SingleChildScrollView(
            padding: EdgeInsets.all(theme.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _nameCtrl,
                    label: '${AppLocalizations.of(context)!.productName} *',
                    hintText: AppLocalizations.of(context)!.productName,
                    validator: (val) => val == null || val.isEmpty ? AppLocalizations.of(context)!.fillRequiredFields : null,
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _priceCtrl,
                    label: '${AppLocalizations.of(context)!.priceLabel} *',
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? AppLocalizations.of(context)!.fillRequiredFields : null,
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _stockCtrl,
                    label: '${AppLocalizations.of(context)!.stockQuantity} *',
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? AppLocalizations.of(context)!.fillRequiredFields : null,
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
