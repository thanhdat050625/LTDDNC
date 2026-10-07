import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class RoomFormScreen extends StatefulWidget {
  final int cinemaId;
  final RoomModel? room;

  const RoomFormScreen({super.key, required this.cinemaId, this.room});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  String _roomType = 'STANDARD';
  String _status = 'ACTIVE';

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    if (r != null) {
      _roomType = r.roomType;
      _status = r.status;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<RoomFormCubit>().submit(
        isEdit: widget.room != null,
        roomId: widget.room?.id,
        cinemaId: widget.cinemaId,
        data: {
          'name': _nameCtrl.text.trim(),
          'roomType': _roomType,
          'status': _status,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.room != null;

    return AppScaffold(
      title: isEdit ? l10n.editRoom : l10n.addRoom,
      showBackButton: true,
      body: BlocConsumer<RoomFormCubit, RoomFormState>(
        listener: (context, state) {
          if (state is RoomFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? l10n.updateSuccess : l10n.addSuccess),
                backgroundColor: theme.success,
              ),
            );
            context.pop();
          } else if (state is RoomFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: theme.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RoomFormSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _nameCtrl,
                          label: '${l10n.roomName} *',
                          hintText: l10n.roomName,
                          validator: (val) => val == null || val.trim().isEmpty ? l10n.fillRequiredFields : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _roomType,
                          decoration: InputDecoration(
                            labelText: l10n.roomType,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: [
                            DropdownMenuItem(value: 'STANDARD', child: Text(l10n.roomTypeStandard)),
                            DropdownMenuItem(value: 'VIP', child: Text(l10n.roomTypeVIP)),
                            DropdownMenuItem(value: 'IMAX', child: Text(l10n.roomTypeIMAX)),
                            DropdownMenuItem(value: '4DX', child: Text(l10n.roomType4DX)),
                          ],
                          onChanged: isLoading ? null : (val) => setState(() => _roomType = val!),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _status,
                          decoration: InputDecoration(
                            labelText: l10n.statusLabel,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: [
                            DropdownMenuItem(value: 'ACTIVE', child: Text(l10n.roomStatusActive)),
                            DropdownMenuItem(value: 'INACTIVE', child: Text(l10n.roomStatusInactive)),
                            DropdownMenuItem(value: 'MAINTENANCE', child: Text(l10n.roomStatusMaintenance)),
                          ],
                          onChanged: isLoading ? null : (val) => setState(() => _status = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: isEdit ? l10n.saveChanges : l10n.addRoom,
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
