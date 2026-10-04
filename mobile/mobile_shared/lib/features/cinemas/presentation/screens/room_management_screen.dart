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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _reloadAfterPush(context.push('/cinemas/${widget.cinemaId}/rooms/new')),
        backgroundColor: theme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
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
    );
  }
}
