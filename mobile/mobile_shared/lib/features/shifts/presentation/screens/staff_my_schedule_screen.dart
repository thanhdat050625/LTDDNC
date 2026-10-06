import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class StaffMyScheduleScreen extends StatefulWidget {
  final Widget? drawer;

  const StaffMyScheduleScreen({super.key, this.drawer});

  @override
  State<StaffMyScheduleScreen> createState() => _StaffMyScheduleScreenState();
}

class _StaffMyScheduleScreenState extends State<StaffMyScheduleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffMyScheduleCubit>().loadSchedule();
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'TICKET_COUNTER':
        return const Color(0xFFF59E0B);
      case 'SCANNER_GATE':
        return const Color(0xFF10B981);
      case 'CONCESSION':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.shiftMySchedule,
      drawer: widget.drawer,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: l10n.retry,
          onPressed: () => context.read<StaffMyScheduleCubit>().loadSchedule(),
        ),
      ],
      body: BlocConsumer<StaffMyScheduleCubit, StaffMyScheduleState>(
        listener: (context, state) {
          if (state is StaffMyScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: theme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is StaffMyScheduleLoading || state is StaffMyScheduleInitial) {
            return const Center(child: AppLoading());
          }

          if (state is StaffMyScheduleError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<StaffMyScheduleCubit>().loadSchedule(),
            );
          }

          final loadedState = state as StaffMyScheduleLoaded;
          final weekEnd = loadedState.weekStartDate.add(const Duration(days: 6));
          final today = DateTime.now();

          // 7 days of the selected week
          final List<DateTime> daysOfWeek = List.generate(
            7,
            (i) => loadedState.weekStartDate.add(Duration(days: i)),
          );
          final schedulesForDate = loadedState.schedulesForSelectedDate;

          return RefreshIndicator(
            onRefresh: () => context.read<StaffMyScheduleCubit>().loadSchedule(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(theme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER CHUYỂN TUẦN ---
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: theme.spacingMd, vertical: theme.spacingSm),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft),
                          color: theme.textSecondary,
                          onPressed: () => context.read<StaffMyScheduleCubit>().previousWeek(),
                        ),
                        InkWell(
                          onTap: () => context.read<StaffMyScheduleCubit>().currentWeek(),
                          child: Column(
                            children: [
                              Text(
                                '${_formatDate(loadedState.weekStartDate)} - ${_formatDate(weekEnd)}',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.textPrimary,
                                ),
                              ),
                              Text(
                                l10n.shiftCurrentWeek,
                                style: textTheme.bodySmall?.copyWith(color: theme.primary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.chevronRight),
                          color: theme.textSecondary,
                          onPressed: () => context.read<StaffMyScheduleCubit>().nextWeek(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: theme.spacingMd),

                  // --- THANH LỊCH 7 NGÀY TRONG TUẦN ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: daysOfWeek.map((d) {
                        final isSelected = d.year == loadedState.selectedDate.year &&
                            d.month == loadedState.selectedDate.month &&
                            d.day == loadedState.selectedDate.day;
                        final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
                        final hasShift = loadedState.hasScheduleOn(d);

                        return Expanded(
                          child: InkWell(
                            onTap: () => context.read<StaffMyScheduleCubit>().selectDate(d),
                            borderRadius: BorderRadius.circular(theme.radiusSm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(theme.radiusSm),
                                border: isToday && !isSelected
                                    ? Border.all(color: theme.primary, width: 1.5)
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _getDayName(d.weekday),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : (isToday ? theme.primary : theme.textSecondary),
                                      fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${d.day}',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : (isToday ? theme.primary : theme.textPrimary),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Shift indicator dot
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: hasShift
                                          ? (isSelected ? Colors.white : theme.accent)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: theme.spacingLg),

                  // --- DANH SÁCH CA LÀM CỦA NGÀY ĐƯỢC CHỌN ---
                  Text(
                    'Ca làm việc ngày ${_formatDate(loadedState.selectedDate)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  SizedBox(height: theme.spacingSm),

                  if (schedulesForDate.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                        border: Border.all(color: theme.border),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(LucideIcons.calendarX, size: 40, color: theme.textSecondary),
                            SizedBox(height: theme.spacingSm),
                            Text(
                              l10n.shiftEmptyList,
                              style: textTheme.bodyMedium?.copyWith(color: theme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...schedulesForDate.map((schedule) {
                      final roleColor = _getRoleColor(schedule.assignedRole);

                      return Container(
                        margin: EdgeInsets.only(bottom: theme.spacingMd),
                        padding: EdgeInsets.all(theme.spacingMd),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                          border: Border.all(color: theme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shift name & time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(theme.radiusSm),
                                      ),
                                      child: Text(
                                        '${schedule.startTime} - ${schedule.endTime}',
                                        style: textTheme.labelMedium?.copyWith(
                                          color: theme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: theme.spacingSm),
                                    Text(
                                      schedule.shiftName,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: roleColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(theme.radiusSm),
                                  ),
                                  child: Text(
                                    _getRoleLabel(schedule.assignedRole, l10n),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: roleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Divider(color: theme.divider, height: theme.spacingLg),

                            // Cinema
                            Row(
                              children: [
                                Icon(LucideIcons.building, size: 16, color: theme.textSecondary),
                                SizedBox(width: theme.spacingSm),
                                Expanded(
                                  child: Text(
                                    schedule.cinemaName,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: theme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Note (if any)
                            if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                              SizedBox(height: theme.spacingSm),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(LucideIcons.fileText, size: 16, color: theme.textSecondary),
                                  SizedBox(width: theme.spacingSm),
                                  Expanded(
                                    child: Text(
                                      schedule.note!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: theme.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Assigned By
                            if (schedule.assignedByName != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(LucideIcons.userCheck, size: 14, color: theme.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${l10n.shiftAssignedBy}: ${schedule.assignedByName}',
                                    style: textTheme.labelSmall?.copyWith(color: theme.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
