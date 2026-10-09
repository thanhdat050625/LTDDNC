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

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
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
    final theme = CineplexColors.of(context);
    switch (role) {
      case 'TICKET_COUNTER':
        return theme.warning;
      case 'SCANNER_GATE':
        return theme.success;
      case 'CONCESSION':
        return theme.accent;
      default:
        return theme.info;
    }
  }

  Widget _buildRoleCountChip(String label, int count, Color color, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
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
        initialShiftId: preselectedShiftId,
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
        final staffIds = (result['staffIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
            (result['staffId'] != null ? [result['staffId'] as int] : <int>[]);
        final success = await cubit.createMultipleSchedules(
          staffIds: staffIds,
          cinemaId: result['cinemaId'] as int,
          shiftId: result['shiftId'] as int,
          workDate: result['workDate'] as String,
          assignedRole: result['assignedRole'] as String,
          note: result['note'] as String?,
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shiftAssignMultipleSuccess(staffIds.length))),
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
                            if (!_isToday(loadedState.selectedDate)) ...[
                              InkWell(
                                onTap: () => context.read<StaffShiftManagementCubit>().selectDate(DateTime.now()),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: theme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    l10n.shiftToday,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: theme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
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

                      final ticketCount = schedulesInShift.where((s) => s.assignedRole == 'TICKET_COUNTER').length;
                      final scannerCount = schedulesInShift.where((s) => s.assignedRole == 'SCANNER_GATE').length;
                      final concessionCount = schedulesInShift.where((s) => s.assignedRole == 'CONCESSION').length;
                      final generalCount = schedulesInShift.where((s) => s.assignedRole == 'GENERAL').length;

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
                                  // Nút "+ Thêm nhân viên" trên header ca
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
                                  ),
                                ],
                              ),
                            ),

                            // Tóm tắt số lượng & vị trí trong ca (Role Breakdown Strip)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: theme.divider)),
                                color: theme.surfaceVariant.withValues(alpha: 0.15),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
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
                                  if (ticketCount > 0)
                                    _buildRoleCountChip(l10n.shiftRoleTicketCounter, ticketCount, theme.warning, textTheme),
                                  if (scannerCount > 0)
                                    _buildRoleCountChip(l10n.shiftRoleScannerGate, scannerCount, theme.success, textTheme),
                                  if (concessionCount > 0)
                                    _buildRoleCountChip(l10n.shiftRoleConcession, concessionCount, theme.accent, textTheme),
                                  if (generalCount > 0)
                                    _buildRoleCountChip(l10n.shiftRoleGeneral, generalCount, theme.info, textTheme),
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
                                  final roleColor = _getRoleColor(schedule.assignedRole, context);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 13,
                                          backgroundColor: roleColor.withValues(alpha: 0.18),
                                          child: Text(
                                            schedule.staffName.isNotEmpty ? schedule.staffName[0].toUpperCase() : 'S',
                                            style: TextStyle(
                                              color: roleColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
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
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: roleColor.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                                                      ),
                                                      child: Text(
                                                        _getRoleLabel(schedule.assignedRole, l10n),
                                                        style: textTheme.labelSmall?.copyWith(
                                                          color: roleColor,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 10,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
