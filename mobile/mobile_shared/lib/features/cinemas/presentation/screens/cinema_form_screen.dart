import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class CinemaFormScreen extends StatefulWidget {
  final CinemaModel? cinema;

  const CinemaFormScreen({super.key, this.cinema});

  @override
  State<CinemaFormScreen> createState() => _CinemaFormScreenState();
}

class _CinemaFormScreenState extends State<CinemaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  String _status = 'ACTIVE';

  @override
  void initState() {
    super.initState();
    final c = widget.cinema;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    if (c != null) _status = c.status;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<CinemaFormCubit>().submit(
        isEdit: widget.cinema != null,
        cinemaId: widget.cinema?.id,
        data: {
          'name': _nameCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'status': _status,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final isEdit = widget.cinema != null;

    return AppScaffold(
      title: isEdit ? AppLocalizations.of(context)!.editCinema : AppLocalizations.of(context)!.addCinema,
      showBackButton: true,
      body: BlocConsumer<CinemaFormCubit, CinemaFormState>(
        listener: (context, state) {
          if (state is CinemaFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEdit ? AppLocalizations.of(context)!.updateSuccess : AppLocalizations.of(context)!.addSuccess)),
            );
            context.pop();
          } else if (state is CinemaFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: TextStyle(color: theme.error))),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CinemaFormSubmitting;

          return SingleChildScrollView(
            padding: EdgeInsets.all(theme.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _nameCtrl,
                    label: '${AppLocalizations.of(context)!.cinemaName} *',
                    hintText: AppLocalizations.of(context)!.cinemaName,
                    validator: (val) => val == null || val.isEmpty ? AppLocalizations.of(context)!.fillRequiredFields : null,
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _addressCtrl,
                    label: AppLocalizations.of(context)!.address,
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _phoneCtrl,
                    label: AppLocalizations.of(context)!.phone,
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _emailCtrl,
                    label: AppLocalizations.of(context)!.email,
                  ),
                  SizedBox(height: theme.spacingMd),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _status,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.statusLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                    ),
                    items: ['ACTIVE', 'INACTIVE', 'MAINTENANCE']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: isLoading ? null : (val) => setState(() => _status = val!),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: AppButton(
                      text: isEdit ? AppLocalizations.of(context)!.saveChanges : AppLocalizations.of(context)!.addCinema,
                      onPressed: isLoading ? null : _submit,
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
