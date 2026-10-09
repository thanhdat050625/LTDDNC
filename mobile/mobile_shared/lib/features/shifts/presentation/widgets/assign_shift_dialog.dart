import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class AssignShiftDialog extends StatefulWidget {
  final List<ShiftModel> shifts;
  final List<CinemaModel> cinemas;
  final List<UserModel> staffList;
  final int? initialCinemaId;
  final int? initialShiftId;
  final DateTime initialDate;
  final StaffScheduleModel? existingSchedule;
  final DateTime Function()? nowProvider;

  const AssignShiftDialog({
    super.key,
    required this.shifts,
    required this.cinemas,
    required this.staffList,
    this.initialCinemaId,
    this.initialShiftId,
    required this.initialDate,
    this.existingSchedule,
    this.nowProvider,
  });

  @override
  State<AssignShiftDialog> createState() => _AssignShiftDialogState();
}

class _AssignShiftDialogState extends State<AssignShiftDialog> {
  late int? _selectedStaffId;
  final Set<int> _selectedStaffIds = {};
  late int? _selectedCinemaId;
  late int? _selectedShiftId;
  late DateTime _selectedDate;
  String _selectedRole = 'GENERAL';
  final TextEditingController _noteController = TextEditingController();
  final bool _isSubmitting = false;

  DateTime _getNow() {
    return widget.nowProvider != null ? widget.nowProvider!() : DateTime.now();
  }

  bool _isShiftAllowed(ShiftModel shift, DateTime date) {
    final now = _getNow();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(now.year, now.month, now.day);
    if (dateOnly.isBefore(todayOnly)) return false;
    if (dateOnly.isAfter(todayOnly)) return true;
    final parts = shift.startTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final shiftStart = DateTime(date.year, date.month, date.day, hour, minute);
    return shiftStart.isAfter(now);
  }

  List<ShiftModel> get _availableShifts {
    return widget.shifts.where((s) => _isShiftAllowed(s, _selectedDate)).toList();
  }

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
      if (widget.staffList.isNotEmpty) {
        _selectedStaffIds.add(widget.staffList.first.id);
      }
      _selectedCinemaId = widget.initialCinemaId ?? (widget.cinemas.isNotEmpty ? widget.cinemas.first.id : null);
      _selectedDate = widget.initialDate;
      final available = _availableShifts;
      if (widget.initialShiftId != null && available.any((shift) => shift.id == widget.initialShiftId)) {
        _selectedShiftId = widget.initialShiftId;
      } else {
        _selectedShiftId = available.isNotEmpty ? available.first.id : null;
      }
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

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existingSchedule != null;

    return Dialog(
      backgroundColor: theme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(theme.radiusLg)),
      child: Container(
        width: 480,
        padding: EdgeInsets.all(theme.spacingMd),
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
                      Icon(LucideIcons.calendarPlus, color: theme.primary, size: 20),
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
                    icon: Icon(LucideIcons.x, color: theme.textSecondary, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Divider(color: theme.divider, height: 16),

              // Chọn Nhân viên
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? l10n.shiftSelectStaff : l10n.shiftSelectMultipleStaff,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isEditing) ...[
                    const SizedBox(width: 8),
                    Text(
                      l10n.shiftSelectedStaffCount(_selectedStaffIds.length),
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              if (isEditing)
                DropdownButtonFormField<int>(
                  initialValue: _selectedStaffId,
                  isExpanded: true,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(color: theme.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: null,
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 130),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.border),
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    color: theme.surfaceVariant.withValues(alpha: 0.25),
                  ),
                  child: widget.staffList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(l10n.shiftNoStaffAssigned, style: TextStyle(color: theme.textSecondary)),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: widget.staffList.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: theme.divider),
                          itemBuilder: (context, idx) {
                            final user = widget.staffList[idx];
                            final isSelected = _selectedStaffIds.contains(user.id);
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedStaffIds.remove(user.id);
                                  } else {
                                    _selectedStaffIds.add(user.id);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: isSelected,
                                        activeColor: theme.primary,
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              _selectedStaffIds.add(user.id);
                                            } else {
                                              _selectedStaffIds.remove(user.id);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        user.fullName,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: theme.textPrimary,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      user.email,
                                      style: textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              const SizedBox(height: 10),

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
                isExpanded: true,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              if (_availableShifts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    l10n.shiftNoAvailableShifts,
                    style: textTheme.bodySmall?.copyWith(color: theme.error),
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  key: ValueKey('shift_${_selectedDate.year}_${_selectedDate.month}_${_selectedDate.day}_$_selectedShiftId'),
                  initialValue: _selectedShiftId,
                  isExpanded: true,
                  dropdownColor: theme.surface,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: theme.spacingMd, vertical: theme.spacingSm),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                  ),
                  items: _availableShifts.map((shift) {
                    return DropdownMenuItem<int>(
                      value: shift.id,
                      child: Text(
                        '${shift.name} (${shift.startTime} - ${shift.endTime})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(color: theme.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedShiftId = val),
                ),
              const SizedBox(height: 10),

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
                        final now = _getNow();
                        final todayStart = DateTime(now.year, now.month, now.day);
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate.isBefore(todayStart) ? todayStart : _selectedDate,
                          firstDate: todayStart,
                          lastDate: todayStart.add(const Duration(days: 90)),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                            final available = widget.shifts.where((s) => _isShiftAllowed(s, picked)).toList();
                            if (_selectedShiftId != null && !available.any((s) => s.id == _selectedShiftId)) {
                              _selectedShiftId = available.isNotEmpty ? available.first.id : null;
                            }
                          });
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
              const SizedBox(height: 10),

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
              const SizedBox(height: 14),

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
                    onPressed: _isSubmitting ||
                            _selectedCinemaId == null ||
                            _selectedShiftId == null ||
                            _availableShifts.isEmpty ||
                            !_availableShifts.any((s) => s.id == _selectedShiftId) ||
                            (isEditing ? _selectedStaffId == null : _selectedStaffIds.isEmpty)
                        ? null
                        : () {
                            Navigator.of(context).pop({
                              if (isEditing)
                                'staffId': _selectedStaffId
                              else
                                'staffIds': _selectedStaffIds.toList(),
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
