import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class AssignShiftDialog extends StatefulWidget {
  final List<ShiftModel> shifts;
  final List<CinemaModel> cinemas;
  final List<UserModel> staffList;
  final List<StaffScheduleModel> schedules;
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
    this.schedules = const [],
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
  final Set<int> _initialStaffIds = {};

  late int? _selectedCinemaId;
  final Set<int> _selectedShiftIds = {};
  final Set<int> _initialShiftIds = {};

  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _initialStartDate;
  late DateTime _initialEndDate;

  String _selectedRole = 'GENERAL';
  final bool _isSubmitting = false;

  bool _setEquals(Set<int> a, Set<int> b) => a.length == b.length && a.containsAll(b);

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
    return widget.shifts.where((s) => _isShiftAllowed(s, _startDate)).toList();
  }

  List<UserModel> get _cinemaStaffList {
    if (_selectedCinemaId == null) return widget.staffList;
    return widget.staffList.where((u) {
      if (widget.existingSchedule != null && u.id == widget.existingSchedule!.staffId) {
        return true;
      }
      final userCinemaId = u.cinemaId ?? u.cinema?.id;
      return userCinemaId == _selectedCinemaId;
    }).toList();
  }

  void _syncInitialStaffFromReality() {
    _initialStaffIds.clear();
    final dateStr = _formatDate(_startDate);
    final inReality = widget.schedules.where((s) {
      final matchesCinema = _selectedCinemaId == null || s.cinemaId == _selectedCinemaId;
      final matchesShift = _selectedShiftIds.contains(s.shiftId);
      final matchesDate = s.workDate == dateStr || s.workDate.startsWith(dateStr);
      return matchesCinema && matchesShift && matchesDate;
    }).map((s) => s.staffId).toSet();

    _initialStaffIds.addAll(inReality);
    _selectedStaffIds.clear();
    _selectedStaffIds.addAll(inReality);
  }

  bool get _isSelectionChanged {
    if (_selectedShiftIds.isEmpty) return false;
    final staffSame = _setEquals(_selectedStaffIds, _initialStaffIds);
    final shiftsSame = _setEquals(_selectedShiftIds, _initialShiftIds);
    final datesSame = _startDate == _initialStartDate && _endDate == _initialEndDate;
    return !(staffSame && shiftsSame && datesSame);
  }

  List<String> get _dateRangeList {
    final dates = <String>[];
    var cur = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day);
    while (!cur.isAfter(end)) {
      dates.add(_formatDate(cur));
      cur = DateTime(cur.year, cur.month, cur.day + 1);
    }
    return dates;
  }

  @override
  void initState() {
    super.initState();
    final s = widget.existingSchedule;
    if (s != null) {
      _selectedStaffId = s.staffId;
      _selectedCinemaId = s.cinemaId;
      _selectedShiftIds.add(s.shiftId);
      _initialShiftIds.add(s.shiftId);
      _startDate = DateTime.tryParse(s.workDate) ?? widget.initialDate;
      _endDate = _startDate;
      _initialStartDate = _startDate;
      _initialEndDate = _endDate;
      _selectedRole = s.assignedRole;
      _initialStaffIds.add(s.staffId);
      _selectedStaffIds.add(s.staffId);
    } else {
      _selectedCinemaId = widget.initialCinemaId ?? (widget.cinemas.isNotEmpty ? widget.cinemas.first.id : null);
      _startDate = widget.initialDate;
      _endDate = widget.initialDate;
      _initialStartDate = _startDate;
      _initialEndDate = _endDate;

      if (widget.initialShiftId != null) {
        _selectedShiftIds.add(widget.initialShiftId!);
      } else {
        final available = _availableShifts;
        if (available.isNotEmpty) {
          _selectedShiftIds.add(available.first.id);
        }
      }
      _initialShiftIds.addAll(_selectedShiftIds);

      final allowedStaff = _cinemaStaffList;
      _selectedStaffId = allowedStaff.isNotEmpty ? allowedStaff.first.id : null;

      _syncInitialStaffFromReality();
    }
  }

  @override
  void dispose() {
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

    final currentCinema = widget.cinemas.where((c) => c.id == _selectedCinemaId).firstOrNull;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        if (currentCinema != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(LucideIcons.mapPin, size: 14, color: theme.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  currentCinema.name,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: theme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
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
                      l10n.shiftSelectStaff,
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
                  items: _cinemaStaffList.map((user) {
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
                  child: _cinemaStaffList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(l10n.shiftNoStaffAssigned, style: TextStyle(color: theme.textSecondary)),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _cinemaStaffList.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: theme.divider),
                          itemBuilder: (context, idx) {
                            final user = _cinemaStaffList[idx];
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
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: theme.primary.withValues(alpha: 0.18),
                                      backgroundImage: (user.avatar != null && user.avatar!.trim().isNotEmpty)
                                          ? CachedNetworkImageProvider(user.avatar!.trim())
                                          : null,
                                      onBackgroundImageError: (user.avatar != null && user.avatar!.trim().isNotEmpty)
                                          ? (_, __) {}
                                          : null,
                                      child: (user.avatar == null || user.avatar!.trim().isEmpty)
                                          ? Text(
                                              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'S',
                                              style: TextStyle(
                                                color: theme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            )
                                          : null,
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

              // Chọn Ca làm việc
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.shiftSelectShift,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.shiftSelectedShiftCount(_selectedShiftIds.length),
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.border),
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  color: theme.surfaceVariant.withValues(alpha: 0.25),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.shifts.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: theme.divider),
                  itemBuilder: (context, idx) {
                    final shift = widget.shifts[idx];
                    final isAllowed = _isShiftAllowed(shift, _startDate);
                    final isSelected = _selectedShiftIds.contains(shift.id);

                    return InkWell(
                      onTap: !isAllowed
                          ? null
                          : () {
                              setState(() {
                                if (isSelected) {
                                  _selectedShiftIds.remove(shift.id);
                                } else {
                                  _selectedShiftIds.add(shift.id);
                                }
                                if (!isEditing) {
                                  _syncInitialStaffFromReality();
                                }
                              });
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isSelected,
                                activeColor: theme.primary,
                                onChanged: !isAllowed
                                    ? null
                                    : (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedShiftIds.add(shift.id);
                                          } else {
                                            _selectedShiftIds.remove(shift.id);
                                          }
                                          if (!isEditing) {
                                            _syncInitialStaffFromReality();
                                          }
                                        });
                                      },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                shift.name,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isAllowed ? theme.textPrimary : theme.textSecondary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              '${shift.startTime} - ${shift.endTime}',
                              style: textTheme.bodySmall?.copyWith(
                                color: isAllowed ? theme.textSecondary : theme.textSecondary.withValues(alpha: 0.5),
                              ),
                            ),
                            if (!isAllowed) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: theme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.shiftReadOnly,
                                  style: TextStyle(color: theme.error, fontSize: 9.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Chọn Ngày làm việc
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
                        final picked = await showDateRangePicker(
                          context: context,
                          initialDateRange: DateTimeRange(
                            start: _startDate.isBefore(todayStart) ? todayStart : _startDate,
                            end: _endDate.isBefore(todayStart) ? todayStart : _endDate,
                          ),
                          firstDate: todayStart,
                          lastDate: todayStart.add(const Duration(days: 90)),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked.start;
                            _endDate = picked.end;
                            if (!isEditing) {
                              _syncInitialStaffFromReality();
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
                        _startDate == _endDate
                            ? _formatDate(_startDate)
                            : '${_formatDate(_startDate)}  →  ${_formatDate(_endDate)}',
                        style: textTheme.bodyMedium?.copyWith(color: theme.textPrimary),
                      ),
                      Icon(LucideIcons.calendar, size: 18, color: theme.textSecondary),
                    ],
                  ),
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
                            _selectedShiftIds.isEmpty ||
                            !_isSelectionChanged
                        ? null
                        : () {
                            Navigator.of(context).pop({
                              if (isEditing)
                                'staffId': _selectedStaffId
                              else ...{
                                'shiftIds': _selectedShiftIds.toList(),
                                'staffIds': _selectedStaffIds.toList(),
                                'dates': _dateRangeList,
                                'initialShiftIds': _initialShiftIds.toList(),
                                'initialStaffIds': _initialStaffIds.toList(),
                              },
                              'cinemaId': _selectedCinemaId,
                              'workDate': _formatDate(_startDate),
                              'assignedRole': _selectedRole,
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
