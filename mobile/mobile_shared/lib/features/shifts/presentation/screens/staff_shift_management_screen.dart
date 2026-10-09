import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class StaffShiftManagementScreen extends StatefulWidget {
  final Widget? drawer;
  final DateTime Function()? nowProvider;

  const StaffShiftManagementScreen({
    super.key,
    this.drawer,
    this.nowProvider,
  });

  @override
  State<StaffShiftManagementScreen> createState() => _StaffShiftManagementScreenState();
}

class _StaffShiftManagementScreenState extends State<StaffShiftManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffShiftManagementCubit>().loadInitialData();
  }

  DateTime _getNow() {
    return widget.nowProvider != null ? widget.nowProvider!() : DateTime.now();
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$day/$m/$y';
  }

  bool _isShiftModifiable(DateTime selectedDate, ShiftModel shift) {
    final now = _getNow();
    final dateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final todayOnly = DateTime(now.year, now.month, now.day);

    if (dateOnly.isBefore(todayOnly)) {
      return false;
    }

    if (dateOnly.isAfter(todayOnly)) {
      return true;
    }

    // Hôm nay: chỉ cho phép chỉnh, thêm, xóa từ ca kế tiếp (giờ bắt đầu > giờ hiện tại)
    final parts = shift.startTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final shiftStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour, minute);

    return shiftStart.isAfter(now);
  }

  void _showAssignDialog(
    BuildContext context,
    StaffShiftManagementLoaded state, {
    int? preselectedShiftId,
    StaffScheduleModel? existingSchedule,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (existingSchedule != null) {
      final shift = state.shifts.where((s) => s.id == existingSchedule.shiftId).firstOrNull;
      if (shift != null && !_isShiftModifiable(state.selectedDate, shift)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shiftCannotModifyPastOrCurrent)),
        );
        return;
      }
    } else if (preselectedShiftId != null) {
      final shift = state.shifts.where((s) => s.id == preselectedShiftId).firstOrNull;
      if (shift != null && !_isShiftModifiable(state.selectedDate, shift)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shiftCannotModifyPastOrCurrent)),
        );
        return;
      }
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AssignShiftDialog(
        shifts: state.shifts,
        cinemas: state.cinemas,
        staffList: state.staffList,
        schedules: state.schedules,
        initialCinemaId: state.selectedCinemaId,
        initialShiftId: preselectedShiftId,
        initialDate: state.selectedDate,
        existingSchedule: existingSchedule,
        nowProvider: widget.nowProvider,
      ),
    );

    if (result != null && mounted) {
      final cubit = context.read<StaffShiftManagementCubit>();
      final l10n = AppLocalizations.of(context)!;
      if (existingSchedule != null && result.containsKey('staffId')) {
        final success = await cubit.updateSchedule(existingSchedule.id, result);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shiftUpdateSuccess)),
          );
        }
      } else {
        final shiftIds = (result['shiftIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? <int>[];
        final staffIds = (result['staffIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? <int>[];
        final dates = (result['dates'] as List<dynamic>?)?.map((e) => e as String).toList() ?? <String>[];
        final initialShiftIds = (result['initialShiftIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? <int>[];
        final initialStaffIds = (result['initialStaffIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? <int>[];

        final success = await cubit.syncSchedules(
          cinemaId: result['cinemaId'] as int,
          shiftIds: shiftIds,
          staffIds: staffIds,
          dates: dates,
          initialShiftIds: initialShiftIds,
          initialStaffIds: initialStaffIds,
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shiftUpdateSuccess)),
          );
        }
      }
    }
  }

  void _confirmDelete(
    BuildContext context,
    StaffScheduleModel schedule, {
    ShiftModel? shift,
    DateTime? selectedDate,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (shift != null && selectedDate != null && !_isShiftModifiable(selectedDate, shift)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.shiftCannotModifyPastOrCurrent)),
      );
      return;
    }

    final theme = CineplexColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(l10n.shiftDelete, style: TextStyle(color: theme.textPrimary)),
        content: Text(l10n.shiftDeleteConfirm, style: TextStyle(color: theme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<StaffShiftManagementCubit>().deleteSchedule(schedule.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shiftDeleteSuccess)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.shiftManagement,
      drawer: widget.drawer,
      actions: [
        BlocBuilder<StaffShiftManagementCubit, StaffShiftManagementState>(
          builder: (context, state) {
            return IconButton(
              icon: const Icon(LucideIcons.plus),
              tooltip: l10n.shiftAssignNew,
              onPressed: state is StaffShiftManagementLoaded
                  ? () => _showAssignDialog(context, state)
                  : null,
            );
          },
        ),
      ],
      body: BlocConsumer<StaffShiftManagementCubit, StaffShiftManagementState>(
        listener: (context, state) {
          if (state is StaffShiftManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: theme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is StaffShiftManagementLoading || state is StaffShiftManagementInitial) {
            return const Center(child: AppLoading());
          }

          if (state is StaffShiftManagementError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<StaffShiftManagementCubit>().loadInitialData(),
            );
          }

          final loadedState = state as StaffShiftManagementLoaded;

          return RefreshIndicator(
            onRefresh: () => context.read<StaffShiftManagementCubit>().loadInitialData(
                  cinemaId: loadedState.selectedCinemaId,
                  date: loadedState.selectedDate,
                ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BỘ LỌC RẠP CHIẾU & NGÀY (GỌN GÀNG) ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(color: theme.border),
                    ),
                    child: Column(
                      children: [
                        // Chọn Rạp
                        Row(
                          children: [
                            Icon(LucideIcons.building, size: 18, color: theme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  dropdownColor: theme.surface,
                                  value: loadedState.selectedCinemaId,
                                  items: loadedState.cinemas.map((c) {
                                    return DropdownMenuItem<int>(
                                      value: c.id,
                                      child: Text(
                                        c.name,
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      context.read<StaffShiftManagementCubit>().selectCinema(val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(color: theme.divider, height: 6),

                        // Chọn Ngày & Nút Hôm nay
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.chevronLeft, size: 18),
                              color: theme.textSecondary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () {
                                final prev = loadedState.selectedDate.subtract(const Duration(days: 1));
                                context.read<StaffShiftManagementCubit>().selectDate(prev);
                              },
                            ),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(theme.radiusSm),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: loadedState.selectedDate,
                                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                    lastDate: DateTime.now().add(const Duration(days: 90)),
                                  );
                                  if (picked != null && mounted) {
                                    context.read<StaffShiftManagementCubit>().selectDate(picked);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.calendar, size: 16, color: theme.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDate(loadedState.selectedDate),
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(LucideIcons.chevronDown, size: 14, color: theme.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.chevronRight, size: 18),
                              color: theme.textSecondary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () {
                                final next = loadedState.selectedDate.add(const Duration(days: 1));
                                context.read<StaffShiftManagementCubit>().selectDate(next);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- DANH SÁCH CA LÀM VIỆC & NHÂN VIÊN ---
                  if (loadedState.shifts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(l10n.noData, style: TextStyle(color: theme.textSecondary)),
                      ),
                    )
                  else
                    ...loadedState.shifts.map((shift) {
                      final schedulesInShift = loadedState.schedules
                          .where((s) => s.shiftId == shift.id)
                          .toList();
                      final isModifiable = _isShiftModifiable(loadedState.selectedDate, shift);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                          border: Border.all(color: theme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shift Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: theme.surfaceVariant.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusMd)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.primary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(theme.radiusSm),
                                          ),
                                          child: Text(
                                            '${shift.startTime} - ${shift.endTime}',
                                            style: textTheme.labelSmall?.copyWith(
                                              color: theme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            shift.name,
                                            style: textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Nút "+ Thêm nhân viên" hoặc nhãn "Chỉ xem" trên header ca
                                  if (isModifiable)
                                    InkWell(
                                      onTap: () => _showAssignDialog(
                                        context,
                                        loadedState,
                                        preselectedShiftId: shift.id,
                                      ),
                                      borderRadius: BorderRadius.circular(theme.radiusSm),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: theme.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(theme.radiusSm),
                                          border: Border.all(color: theme.primary.withValues(alpha: 0.35)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(LucideIcons.userPlus, size: 12, color: theme.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              l10n.shiftAddStaff,
                                              style: textTheme.labelSmall?.copyWith(
                                                color: theme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: theme.surfaceVariant.withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(theme.radiusSm),
                                        border: Border.all(color: theme.borderSubtle),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(LucideIcons.lock, size: 11, color: theme.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            l10n.shiftReadOnly,
                                            style: textTheme.labelSmall?.copyWith(
                                              color: theme.textSecondary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Dải hiển thị số lượng nhân viên trong ca
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: theme.divider)),
                                color: theme.surfaceVariant.withValues(alpha: 0.15),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: theme.card,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: theme.borderSubtle),
                                    ),
                                    child: Text(
                                      l10n.shiftStaffCount(schedulesInShift.length),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: theme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Danh sách nhân viên trong ca (Ultra-dense)
                            if (schedulesInShift.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.users, size: 15, color: theme.textSecondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.shiftEmptyList,
                                        style: textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                                      ),
                                    ),
                                    if (isModifiable)
                                      OutlinedButton.icon(
                                        icon: const Icon(LucideIcons.userPlus, size: 12),
                                        label: Text(l10n.shiftAssignNew, style: const TextStyle(fontSize: 11)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          minimumSize: const Size(0, 26),
                                        ),
                                        onPressed: () => _showAssignDialog(
                                          context,
                                          loadedState,
                                          preselectedShiftId: shift.id,
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: schedulesInShift.length,
                                separatorBuilder: (_, __) => Divider(color: theme.divider, height: 1),
                                itemBuilder: (context, index) {
                                  final schedule = schedulesInShift[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 13,
                                          backgroundColor: theme.primary.withValues(alpha: 0.18),
                                          backgroundImage: (schedule.staffAvatar != null && schedule.staffAvatar!.trim().isNotEmpty)
                                              ? CachedNetworkImageProvider(schedule.staffAvatar!.trim())
                                              : null,
                                          onBackgroundImageError: (schedule.staffAvatar != null && schedule.staffAvatar!.trim().isNotEmpty)
                                              ? (_, __) {}
                                              : null,
                                          child: (schedule.staffAvatar == null || schedule.staffAvatar!.trim().isEmpty)
                                              ? Text(
                                                  schedule.staffName.isNotEmpty ? schedule.staffName[0].toUpperCase() : 'S',
                                                  style: TextStyle(
                                                    color: theme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                schedule.staffName,
                                                style: textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.textPrimary,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  schedule.note!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: theme.textSecondary,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 10.5,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (isModifiable) ...[
                                          IconButton(
                                            icon: Icon(LucideIcons.pencil, size: 15, color: theme.textSecondary),
                                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                            padding: EdgeInsets.zero,
                                            onPressed: () => _showAssignDialog(
                                              context,
                                              loadedState,
                                              existingSchedule: schedule,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(LucideIcons.trash2, size: 15, color: theme.error),
                                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                            padding: EdgeInsets.zero,
                                            onPressed: () => _confirmDelete(
                                              context,
                                              schedule,
                                              shift: shift,
                                              selectedDate: loadedState.selectedDate,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    }),

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
