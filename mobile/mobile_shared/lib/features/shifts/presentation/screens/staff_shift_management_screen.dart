import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class StaffShiftManagementScreen extends StatefulWidget {
  final Widget? drawer;

  const StaffShiftManagementScreen({super.key, this.drawer});

  @override
  State<StaffShiftManagementScreen> createState() => _StaffShiftManagementScreenState();
}

class _StaffShiftManagementScreenState extends State<StaffShiftManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffShiftManagementCubit>().loadInitialData();
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$day/$m/$y';
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

  Color _getRoleColor(String role, BuildContext context) {
    switch (role) {
      case 'TICKET_COUNTER':
        return const Color(0xFFF59E0B); // Amber
      case 'SCANNER_GATE':
        return const Color(0xFF10B981); // Emerald
      case 'CONCESSION':
        return const Color(0xFFEC4899); // Pink
      default:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  void _showAssignDialog(
    BuildContext context,
    StaffShiftManagementLoaded state, {
    int? preselectedShiftId,
    StaffScheduleModel? existingSchedule,
  }) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AssignShiftDialog(
        shifts: state.shifts,
        cinemas: state.cinemas,
        staffList: state.staffList,
        initialCinemaId: state.selectedCinemaId,
        initialDate: state.selectedDate,
        existingSchedule: existingSchedule,
      ),
    );

    if (result != null && mounted) {
      final cubit = context.read<StaffShiftManagementCubit>();
      final l10n = AppLocalizations.of(context)!;
      if (existingSchedule != null) {
        final success = await cubit.updateSchedule(existingSchedule.id, result);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shiftUpdateSuccess)),
          );
        }
      } else {
        final success = await cubit.createSchedule(
          staffId: result['staffId'] as int,
          cinemaId: result['cinemaId'] as int,
          shiftId: result['shiftId'] as int,
          workDate: result['workDate'] as String,
          assignedRole: result['assignedRole'] as String,
          note: result['note'] as String?,
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shiftAssignSuccess)),
          );
        }
      }
    }
  }

  void _confirmDelete(BuildContext context, StaffScheduleModel schedule) async {
    final l10n = AppLocalizations.of(context)!;
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
        IconButton(
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: l10n.retry,
          onPressed: () => context.read<StaffShiftManagementCubit>().loadInitialData(),
        ),
      ],
      floatingActionButton: BlocBuilder<StaffShiftManagementCubit, StaffShiftManagementState>(
        builder: (context, state) {
          if (state is! StaffShiftManagementLoaded) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(LucideIcons.plus),
            label: Text(l10n.shiftAssignNew),
            onPressed: () => _showAssignDialog(context, state),
          );
        },
      ),
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
              padding: EdgeInsets.all(theme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BỘ LỌC RẠP CHIẾU & NGÀY ---
                  Container(
                    padding: EdgeInsets.all(theme.spacingMd),
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
                            Icon(LucideIcons.building, size: 20, color: theme.primary),
                            SizedBox(width: theme.spacingSm),
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
                        Divider(color: theme.divider, height: theme.spacingLg),

                        // Chọn Ngày (Prev, DatePicker, Next)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.chevronLeft),
                              color: theme.textSecondary,
                              onPressed: () {
                                final prev = loadedState.selectedDate.subtract(const Duration(days: 1));
                                context.read<StaffShiftManagementCubit>().selectDate(prev);
                              },
                            ),
                            InkWell(
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
                              child: Row(
                                children: [
                                  Icon(LucideIcons.calendar, size: 18, color: theme.primary),
                                  SizedBox(width: theme.spacingSm),
                                  Text(
                                    _formatDate(loadedState.selectedDate),
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(LucideIcons.chevronDown, size: 16, color: theme.textSecondary),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.chevronRight),
                              color: theme.textSecondary,
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

                  SizedBox(height: theme.spacingLg),

                  // --- DANH SÁCH CA LÀM VIỆC & NHÂN VIÊN ---
                  if (loadedState.shifts.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(theme.spacingLg),
                        child: Text(l10n.noData, style: TextStyle(color: theme.textSecondary)),
                      ),
                    )
                  else
                    ...loadedState.shifts.map((shift) {
                      final schedulesInShift = loadedState.schedules
                          .where((s) => s.shiftId == shift.id)
                          .toList();

                      return Container(
                        margin: EdgeInsets.only(bottom: theme.spacingLg),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(theme.radiusLg),
                          border: Border.all(color: theme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shift Header
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: theme.spacingMd,
                                vertical: theme.spacingSm,
                              ),
                              decoration: BoxDecoration(
                                color: theme.surfaceVariant,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusLg)),
                              ),
                              child: Row(
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
                                          '${shift.startTime} - ${shift.endTime}',
                                          style: textTheme.labelMedium?.copyWith(
                                            color: theme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: theme.spacingSm),
                                      Text(
                                        shift.name,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${schedulesInShift.length} nhân viên',
                                    style: textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                                  ),
                                ],
                              ),
                            ),

                            // Danh sách nhân viên trong ca
                            if (schedulesInShift.isEmpty)
                              Padding(
                                padding: EdgeInsets.all(theme.spacingLg),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        l10n.shiftEmptyList,
                                        style: textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                                      ),
                                      SizedBox(height: theme.spacingSm),
                                      OutlinedButton.icon(
                                        icon: const Icon(LucideIcons.userPlus, size: 16),
                                        label: Text(l10n.shiftAssignNew),
                                        onPressed: () => _showAssignDialog(
                                          context,
                                          loadedState,
                                          preselectedShiftId: shift.id,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                  final roleColor = _getRoleColor(schedule.assignedRole, context);

                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: theme.spacingMd,
                                      vertical: 4.0,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: theme.primary.withValues(alpha: 0.2),
                                      child: Text(
                                        schedule.staffName.isNotEmpty ? schedule.staffName[0].toUpperCase() : 'S',
                                        style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      schedule.staffName,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: roleColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(theme.radiusSm),
                                              ),
                                              child: Text(
                                                _getRoleLabel(schedule.assignedRole, l10n),
                                                style: textTheme.labelSmall?.copyWith(
                                                  color: roleColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                                              SizedBox(width: theme.spacingSm),
                                              Expanded(
                                                child: Text(
                                                  schedule.note!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: theme.textSecondary,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(LucideIcons.pencil, size: 18, color: theme.textSecondary),
                                          onPressed: () => _showAssignDialog(
                                            context,
                                            loadedState,
                                            existingSchedule: schedule,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(LucideIcons.trash2, size: 18, color: theme.error),
                                          onPressed: () => _confirmDelete(context, schedule),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 80), // Chừa khoảng trống cho FAB
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
