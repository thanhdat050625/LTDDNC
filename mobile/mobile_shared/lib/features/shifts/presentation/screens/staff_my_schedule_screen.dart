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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER CHUYỂN TUẦN ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft, size: 18),
                          color: theme.textSecondary,
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                          padding: EdgeInsets.zero,
                          onPressed: () => context.read<StaffMyScheduleCubit>().previousWeek(),
                        ),
                        InkWell(
                          onTap: () => context.read<StaffMyScheduleCubit>().currentWeek(),
                          child: Text(
                            '${_formatDate(loadedState.weekStartDate)} - ${_formatDate(weekEnd)}',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.chevronRight, size: 18),
                          color: theme.textSecondary,
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                          padding: EdgeInsets.zero,
                          onPressed: () => context.read<StaffMyScheduleCubit>().nextWeek(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // --- THANH LỊCH 7 NGÀY TRONG TUẦN ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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
                              padding: const EdgeInsets.symmetric(vertical: 5),
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
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${d.day}',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : (isToday ? theme.primary : theme.textPrimary),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Shift indicator dot
                                  Container(
                                    width: 5,
                                    height: 5,
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

                  const SizedBox(height: 10),

                  // --- DANH SÁCH CA LÀM CỦA NGÀY ĐƯỢC CHỌN ---
                  Text(
                    'Ca làm việc ngày ${_formatDate(loadedState.selectedDate)}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  if (schedulesForDate.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                        border: Border.all(color: theme.border),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(LucideIcons.calendarX, size: 32, color: theme.textSecondary),
                            const SizedBox(height: 6),
                            Text(
                              l10n.shiftEmptyList,
                              style: textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...schedulesForDate.map((schedule) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: theme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(theme.radiusSm),
                                  ),
                                  child: Text(
                                    '${schedule.startTime} - ${schedule.endTime}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: theme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    schedule.shiftName,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.textPrimary,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            Divider(color: theme.divider, height: 10),

                            // Cinema
                            Row(
                              children: [
                                Icon(LucideIcons.building, size: 14, color: theme.textSecondary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    schedule.cinemaName,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: theme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Note (if any)
                            if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(LucideIcons.fileText, size: 13, color: theme.textSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      schedule.note!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: theme.textSecondary,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Assigned By
                            if (schedule.assignedByName != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(LucideIcons.userCheck, size: 12, color: theme.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${l10n.shiftAssignedBy}: ${schedule.assignedByName}',
                                    style: textTheme.labelSmall?.copyWith(color: theme.textMuted, fontSize: 10.5),
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
