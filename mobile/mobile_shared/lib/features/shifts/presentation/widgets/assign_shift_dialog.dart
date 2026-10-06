import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class AssignShiftDialog extends StatefulWidget {
  final List<ShiftModel> shifts;
  final List<CinemaModel> cinemas;
  final List<UserModel> staffList;
  final int? initialCinemaId;
  final DateTime initialDate;
  final StaffScheduleModel? existingSchedule;

  const AssignShiftDialog({
    super.key,
    required this.shifts,
    required this.cinemas,
    required this.staffList,
    this.initialCinemaId,
    required this.initialDate,
    this.existingSchedule,
  });

  @override
  State<AssignShiftDialog> createState() => _AssignShiftDialogState();
}

class _AssignShiftDialogState extends State<AssignShiftDialog> {
  late int? _selectedStaffId;
  late int? _selectedCinemaId;
  late int? _selectedShiftId;
  late DateTime _selectedDate;
  String _selectedRole = 'TICKET_COUNTER';
  final TextEditingController _noteController = TextEditingController();
  final bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existingSchedule;
    if (s != null) {
      _selectedStaffId = s.staffId;
      _selectedCinemaId = s.cinemaId;
      _selectedShiftId = s.shiftId;
      _selectedDate = DateTime.tryParse(s.workDate) ?? widget.initialDate;
      _selectedRole = s.assignedRole;
      _noteController.text = s.note ?? '';
    } else {
      _selectedStaffId = widget.staffList.isNotEmpty ? widget.staffList.first.id : null;
      _selectedCinemaId = widget.initialCinemaId ?? (widget.cinemas.isNotEmpty ? widget.cinemas.first.id : null);
      _selectedShiftId = widget.shifts.isNotEmpty ? widget.shifts.first.id : null;
      _selectedDate = widget.initialDate;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _getRoleLabel(String role, AppLocalizations l10n) {
    switch (role) {
      case 'TICKET_COUNTER':
        return l10n.shiftRoleTicketCounter;
      case 'SCANNER_GATE':
        return l10n.shiftRoleScannerGate;
      case 'CONCESSION':
        return l10n.shiftRoleConcession;
      default:
        return l10n.shiftRoleGeneral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existingSchedule != null;

    final roles = ['TICKET_COUNTER', 'SCANNER_GATE', 'CONCESSION', 'GENERAL'];

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(theme.radiusLg)),
      child: Container(
        width: 480,
        padding: EdgeInsets.all(theme.spacingLg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.calendarPlus, color: theme.primary, size: 22),
                      SizedBox(width: theme.spacingSm),
                      Text(
                        isEditing ? l10n.shiftEdit : l10n.shiftAssignNew,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: theme.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Divider(color: theme.divider, height: theme.spacingLg),

              // Chọn Nhân viên
              Text(
                l10n.shiftSelectStaff,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _selectedStaffId,
                dropdownColor: theme.surface,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: theme.spacingMd, vertical: theme.spacingSm),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                ),
                items: widget.staffList.map((user) {
                  return DropdownMenuItem<int>(
                    value: user.id,
                    child: Text(
                      '${user.fullName} (${user.email})',
                      style: textTheme.bodyMedium?.copyWith(color: theme.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: isEditing ? null : (val) => setState(() => _selectedStaffId = val),
              ),
              SizedBox(height: theme.spacingMd),

              // Chọn Cụm rạp
              Text(
                l10n.shiftSelectCinema,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _selectedCinemaId,
                dropdownColor: theme.surface,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: theme.spacingMd, vertical: theme.spacingSm),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                ),
                items: widget.cinemas.map((cinema) {
                  return DropdownMenuItem<int>(
                    value: cinema.id,
                    child: Text(
                      cinema.name,
                      style: textTheme.bodyMedium?.copyWith(color: theme.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCinemaId = val),
              ),
              SizedBox(height: theme.spacingMd),

              // Chọn Ca làm việc
              Text(
                l10n.shiftSelectShift,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _selectedShiftId,
                dropdownColor: theme.surface,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: theme.spacingMd, vertical: theme.spacingSm),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                ),
                items: widget.shifts.map((shift) {
                  return DropdownMenuItem<int>(
                    value: shift.id,
                    child: Text(
                      '${shift.name} (${shift.startTime} - ${shift.endTime})',
                      style: textTheme.bodyMedium?.copyWith(color: theme.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedShiftId = val),
              ),
              SizedBox(height: theme.spacingMd),

              // Chọn Vị trí phân công
              Text(
                l10n.shiftSelectRole,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                dropdownColor: theme.surface,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: theme.spacingMd, vertical: theme.spacingSm),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(
                      _getRoleLabel(role, l10n),
                      style: textTheme.bodyMedium?.copyWith(color: theme.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val ?? 'GENERAL'),
              ),
              SizedBox(height: theme.spacingMd),

              // Chọn Ngày
              Text(
                l10n.shiftSelectDate,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: isEditing
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: theme.spacingMd, vertical: theme.spacingSm),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.border),
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(_selectedDate),
                        style: textTheme.bodyMedium?.copyWith(color: theme.textPrimary),
                      ),
                      Icon(LucideIcons.calendar, size: 18, color: theme.textSecondary),
                    ],
                  ),
                ),
              ),
              SizedBox(height: theme.spacingMd),

              // Ghi chú
              Text(
                l10n.shiftNote,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                maxLines: 2,
                style: textTheme.bodyMedium?.copyWith(color: theme.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.shiftNoteHint,
                  hintStyle: textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                ),
              ),
              SizedBox(height: theme.spacingLg),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel, style: TextStyle(color: theme.textSecondary)),
                  ),
                  SizedBox(width: theme.spacingSm),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                    ),
                    onPressed: _isSubmitting || _selectedStaffId == null || _selectedCinemaId == null || _selectedShiftId == null
                        ? null
                        : () {
                            Navigator.of(context).pop({
                              'staffId': _selectedStaffId,
                              'cinemaId': _selectedCinemaId,
                              'shiftId': _selectedShiftId,
                              'workDate': _formatDate(_selectedDate),
                              'assignedRole': _selectedRole,
                              'note': _noteController.text.trim(),
                            });
                          },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
