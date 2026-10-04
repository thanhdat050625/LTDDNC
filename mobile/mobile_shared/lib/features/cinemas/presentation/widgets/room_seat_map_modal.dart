import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/cinema_model.dart';
import '../../../../models/seat_model.dart';
import '../../../../theme/cineplex_colors.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_empty_view.dart';
import '../../../../widgets/app_error_view.dart';
import '../../../../widgets/app_loading.dart';
import '../../../../widgets/seat_widget.dart';
import '../../data/repositories/cinema_management_repository.dart';

class RoomSeatMapModal extends StatefulWidget {
  final RoomModel room;
  final CinemaManagementRepository repository;

  const RoomSeatMapModal({
    super.key,
    required this.room,
    required this.repository,
  });

  static Future<void> show(
    BuildContext context,
    RoomModel room,
    CinemaManagementRepository repo,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoomSeatMapModal(room: room, repository: repo),
    );
  }

  @override
  State<RoomSeatMapModal> createState() => _RoomSeatMapModalState();
}

class _RoomSeatMapModalState extends State<RoomSeatMapModal> {
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _errorMessage;
  List<SeatModel> _seats = [];

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final seats = await widget.repository.getRoomSeats(widget.room.id);
      if (mounted) {
        setState(() {
          _seats = seats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateSeats() async {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          l10n.generateSeatsBtn,
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.generateSeatsConfirm,
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      await widget.repository.generateRoomSeats(widget.room.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.generateSeatsSuccess),
            backgroundColor: colors.success,
          ),
        );
        await _loadSeats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.cardBorder)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.room.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: colors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.room.roomType,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: colors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.room.totalSeats} ${l10n.seatUnit} • ${widget.room.rows}x${widget.room.columns}',
                            style: TextStyle(fontSize: 12, color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x, color: colors.textSecondary, size: 20),
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      padding: const EdgeInsets.all(8),
                      tooltip: l10n.cancel,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: _buildBody(context, colors, l10n),
          ),

          // Footer Action Bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.paddingOf(context).bottom + 10),
            decoration: BoxDecoration(
              color: colors.card,
              border: Border(top: BorderSide(color: colors.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: l10n.generateSeatsBtn,
                    icon: LucideIcons.sparkles,
                    isLoading: _isGenerating,
                    onPressed: _generateSeats,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CineplexColors colors, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: AppLoading());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppErrorView(
            message: _errorMessage!,
            onRetry: _loadSeats,
          ),
        ),
      );
    }

    if (_seats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppEmptyView(
            icon: LucideIcons.layoutGrid,
            title: l10n.seatLayoutTitle,
            message: l10n.noData,
            actionLabel: l10n.generateSeatsBtn,
            onAction: _generateSeats,
          ),
        ),
      );
    }

    // Group seats by row
    final Map<String, List<SeatModel>> rowMap = {};
    for (final seat in _seats) {
      rowMap.putIfAbsent(seat.row, () => []).add(seat);
    }
    final sortedRows = rowMap.keys.toList()..sort();
    for (final row in sortedRows) {
      rowMap[row]!.sort((a, b) => a.column.compareTo(b.column));
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        // Screen Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.1),
                      colors.primary,
                      colors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.screenLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Interactive Seat Grid
        Expanded(
          child: InteractiveViewer(
            constrained: false,
            minScale: 0.5,
            maxScale: 2.5,
            boundaryMargin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sortedRows.map((rowName) {
                  final rowSeats = rowMap[rowName]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row Label Left
                        Container(
                          width: 22,
                          alignment: Alignment.center,
                          child: Text(
                            rowName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Seat row
                        ...rowSeats.map((seat) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: SeatWidget(
                              seat: seat,
                              size: 28,
                              showColumnOnly: true,
                            ),
                          );
                        }),
                        const SizedBox(width: 6),
                        // Row Label Right
                        Container(
                          width: 22,
                          alignment: Alignment.center,
                          child: Text(
                            rowName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Seat Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SeatLegend(
            items: const [
              SeatLegendType.standard,
              SeatLegendType.vip,
              SeatLegendType.couple,
            ],
            spacing: 16,
          ),
        ),
      ],
    );
  }
}
