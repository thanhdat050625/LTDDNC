import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

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
    final theme = Theme.of(context).extension<CineplexColors>()!;
    
    return AppScaffold(
      title: widget.cinema != null 
          ? '${widget.cinema!.name} - ${AppLocalizations.of(context)!.manageRooms}'
          : AppLocalizations.of(context)!.manageRooms,
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
              return const Center(child: CircularProgressIndicator());
            } else if (state is RoomManagementError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(child: Text(state.message, style: TextStyle(color: theme.error))),
                ],
              );
            } else if (state is RoomManagementLoaded) {
              final rooms = state.rooms;
              if (rooms.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(child: Text(AppLocalizations.of(context)!.noRooms)),
                  ],
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final r = rooms[index];
                  return RoomListItem(
                    room: r,
                    onEdit: () => _reloadAfterPush(context.push('/cinemas/${widget.cinemaId}/rooms/${r.id}/edit', extra: r)),
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          backgroundColor: theme.surface,
                          title: Text(AppLocalizations.of(context)!.confirmDelete),
                          content: Text(AppLocalizations.of(context)!.confirmDeleteRoom),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dCtx);
                                context.read<RoomManagementCubit>().deleteRoom(r.id, widget.cinemaId);
                              },
                              child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: theme.error)),
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
