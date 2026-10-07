import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../widgets/room_seat_map_modal.dart';

class RoomManagementScreen extends StatefulWidget {
  final int cinemaId;
  final CinemaModel? cinema;

  const RoomManagementScreen({super.key, required this.cinemaId, this.cinema});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RoomManagementCubit>().loadRooms(widget.cinemaId);
  }

  Future<void> _reloadAfterPush(Future<Object?> future) async {
    await future;
    if (mounted) {
      context.read<RoomManagementCubit>().loadRooms(widget.cinemaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return AppScaffold(
      title: widget.cinema != null 
          ? '${widget.cinema!.name} - ${l10n.manageRooms}'
          : l10n.manageRooms,
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.plus),
          tooltip: l10n.addRoom,
          onPressed: () => _reloadAfterPush(context.push('/cinemas/${widget.cinemaId}/rooms/new')),
        ),
      ],
      body: Column(
        children: [
          // 4 Core Operational KPI Cards
          BlocBuilder<RoomManagementCubit, RoomManagementState>(
            buildWhen: (prev, curr) => curr is RoomManagementLoaded,
            builder: (context, state) {
              if (state is! RoomManagementLoaded) {
                return const SizedBox.shrink();
              }
              return _buildKpiSection(context, state);
            },
          ),

          // Room List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<RoomManagementCubit>().loadRooms(widget.cinemaId),
              child: BlocBuilder<RoomManagementCubit, RoomManagementState>(
                builder: (context, state) {
                  if (state is RoomManagementLoading) {
                    return const Center(child: AppLoading());
                  } else if (state is RoomManagementError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: AppErrorView(
                          message: state.message,
                          onRetry: () => context.read<RoomManagementCubit>().loadRooms(widget.cinemaId),
                        ),
                      ),
                    );
                  } else if (state is RoomManagementLoaded) {
                    final rooms = state.rooms;
                    if (rooms.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: AppEmptyView(
                            icon: LucideIcons.doorOpen,
                            title: l10n.noRooms,
                            message: l10n.noData,
                            actionLabel: l10n.addRoom,
                            onAction: () => _reloadAfterPush(context.push('/cinemas/${widget.cinemaId}/rooms/new')),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: rooms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final r = rooms[index];
                        return RoomListItem(
                          room: r,
                          onViewSeats: () {
                            RoomSeatMapModal.show(
                              context,
                              r,
                              CinemaManagementRepository(context.read<DioClient>()),
                            );
                          },
                          onEdit: () => _reloadAfterPush(
                            context.push('/cinemas/${widget.cinemaId}/rooms/${r.id}/edit', extra: r),
                          ),
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                backgroundColor: theme.surface,
                                title: Text(l10n.confirmDelete),
                                content: Text(l10n.confirmDeleteRoom),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: Text(l10n.cancel, style: TextStyle(color: theme.textSecondary)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(dCtx);
                                      context.read<RoomManagementCubit>().deleteRoom(r.id, widget.cinemaId);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(l10n.delete),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context, RoomManagementLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CineplexColors.of(context);
    final all = state.allRooms;
    final totalCount = all.length;
    final activeCount = all.where((r) => r.status.toUpperCase() == 'ACTIVE').length;
    final maintenanceCount = all.where((r) => r.status.toUpperCase() == 'MAINTENANCE').length;
    final inactiveCount = all.where((r) => r.status.toUpperCase() == 'INACTIVE').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.3,
        children: [
          _buildKpiCard(
            context,
            title: l10n.roomTotal,
            count: totalCount,
            icon: LucideIcons.doorOpen,
            accentColor: theme.primary,
            isSelected: state.selectedStatus == null,
            onTap: () => context.read<RoomManagementCubit>().filterByStatus(null),
          ),
          _buildKpiCard(
            context,
            title: l10n.roomStatusActive,
            count: activeCount,
            icon: LucideIcons.checkCircle,
            accentColor: theme.success,
            isSelected: state.selectedStatus == 'ACTIVE',
            onTap: () => context.read<RoomManagementCubit>().filterByStatus('ACTIVE'),
          ),
          _buildKpiCard(
            context,
            title: l10n.roomStatusMaintenance,
            count: maintenanceCount,
            icon: LucideIcons.wrench,
            accentColor: theme.warning,
            isSelected: state.selectedStatus == 'MAINTENANCE',
            onTap: () => context.read<RoomManagementCubit>().filterByStatus('MAINTENANCE'),
          ),
          _buildKpiCard(
            context,
            title: l10n.roomStatusInactive,
            count: inactiveCount,
            icon: LucideIcons.pauseCircle,
            accentColor: theme.textMuted,
            isSelected: state.selectedStatus == 'INACTIVE',
            onTap: () => context.read<RoomManagementCubit>().filterByStatus('INACTIVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = CineplexColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : theme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : theme.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: accentColor, size: 14),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? accentColor : theme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              maxLines: 1,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
