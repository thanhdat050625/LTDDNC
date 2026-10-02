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
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final isEdit = widget.room != null;

    return AppScaffold(
      title: isEdit ? AppLocalizations.of(context)!.editRoom : AppLocalizations.of(context)!.addRoom,
      showBackButton: true,
      body: BlocConsumer<RoomFormCubit, RoomFormState>(
        listener: (context, state) {
          if (state is RoomFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEdit ? AppLocalizations.of(context)!.updateSuccess : AppLocalizations.of(context)!.addSuccess)),
            );
            context.pop();
          } else if (state is RoomFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: TextStyle(color: theme.error))),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RoomFormSubmitting;

          return SingleChildScrollView(
            padding: EdgeInsets.all(theme.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _nameCtrl,
                    label: '${AppLocalizations.of(context)!.roomName} *',
                    validator: (val) => val == null || val.isEmpty ? AppLocalizations.of(context)!.fillRequiredFields : null,
                  ),
                  SizedBox(height: theme.spacingMd),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _roomType,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.roomType,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                    ),
                    items: ['STANDARD', 'VIP', 'IMAX', '4DX']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: isLoading ? null : (val) => setState(() => _roomType = val!),
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
                      text: isEdit ? AppLocalizations.of(context)!.saveChanges : AppLocalizations.of(context)!.addRoom,
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
