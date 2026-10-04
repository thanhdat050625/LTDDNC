import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeOccupancyScreen extends StatefulWidget {
  const ShowtimeOccupancyScreen({super.key});

  @override
  State<ShowtimeOccupancyScreen> createState() => _ShowtimeOccupancyScreenState();
}

class _ShowtimeOccupancyScreenState extends State<ShowtimeOccupancyScreen> {
  int _selectedDateIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CineplexColors.of(context);

    final dates = [
      l10n.today,
      l10n.tomorrow,
      '05/10',
      '06/10',
      '07/10',
    ];

    return AppScaffold(
      title: l10n.showtimesAndOccupancy,
      body: Column(
        children: [
          // Horizontal Date Picker
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(bottom: BorderSide(color: theme.borderSubtle)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(dates.length, (index) {
                  final isSelected = index == _selectedDateIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(dates[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedDateIndex = index);
                      },
                      selectedColor: theme.primary,
                      backgroundColor: theme.surface,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : theme.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? theme.primary : theme.borderSubtle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Room Timeline Cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _buildRoomCard(
                  context: context,
                  theme: theme,
                  l10n: l10n,
                  roomName: '${l10n.roomPrefix('01')} (IMAX)',
                  capacity: 120,
                  booked: 92,
                  movie: 'Mai',
                  format: 'IMAX 2D',
                  time: '14:30 - 16:45',
                  status: l10n.roomStatusScreening,
                  statusColor: theme.success,
                  progress: 0.65,
                ),
                _buildRoomCard(
                  context: context,
                  theme: theme,
                  l10n: l10n,
                  roomName: '${l10n.roomPrefix('02')} (Standard)',
                  capacity: 100,
                  booked: 63,
                  movie: 'Dune: Part Two',
                  format: l10n.format2DSubtitle,
                  time: '15:15 - 18:00',
                  status: l10n.roomStatusPreparing,
                  statusColor: theme.warning,
                  progress: 0.15,
                ),
                _buildRoomCard(
                  context: context,
                  theme: theme,
                  l10n: l10n,
                  roomName: '${l10n.roomPrefix('03')} (VIP)',
                  capacity: 48,
                  booked: 40,
                  movie: 'Kung Fu Panda 4',
                  format: l10n.format3DDubbed,
                  time: '16:00 - 17:35',
                  status: l10n.roomStatusReady,
                  statusColor: theme.info,
                  progress: 0.0,
                ),
                _buildRoomCard(
                  context: context,
                  theme: theme,
                  l10n: l10n,
                  roomName: '${l10n.roomPrefix('04')} (Standard)',
                  capacity: 90,
                  booked: 15,
                  movie: 'Godzilla x Kong',
                  format: l10n.format2DDubbed,
                  time: '18:15 - 20:10',
                  status: l10n.roomStatusReady,
                  statusColor: theme.info,
                  progress: 0.0,
                ),
                _buildRoomCard(
                  context: context,
                  theme: theme,
                  l10n: l10n,
                  roomName: '${l10n.roomPrefix('05')} (VIP)',
                  capacity: 36,
                  booked: 36,
                  movie: l10n.movieExhuma,
                  format: l10n.format2DSubtitle,
                  time: '13:00 - 15:15',
                  status: l10n.roomStatusCleaning,
                  statusColor: theme.textSecondary,
                  progress: 1.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard({
    required BuildContext context,
    required CineplexColors theme,
    required AppLocalizations l10n,
    required String roomName,
    required int capacity,
    required int booked,
    required String movie,
    required String format,
    required String time,
    required String status,
    required Color statusColor,
    required double progress,
  }) {
    final occupancyPercent = ((booked / capacity) * 100).round();
    final occupancyColor = occupancyPercent >= 90
        ? theme.error
        : (occupancyPercent >= 70 ? theme.warning : theme.success);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Room Name & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  roomName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Movie Info & Format
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$format • $time',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Screening Runtime Progress
          if (progress > 0 && progress < 1.0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: theme.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Occupancy Meter & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(LucideIcons.users, size: 14, color: occupancyColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$booked/$capacity ${l10n.seatUnit} ($occupancyPercent%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: occupancyColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: () => _showQuickSeatMap(context, roomName, movie, capacity, booked),
                icon: const Icon(LucideIcons.layoutGrid, size: 14),
                label: Text(l10n.viewSeatMap, style: const TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primary,
                  side: BorderSide(color: theme.primary.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickSeatMap(
    BuildContext context,
    String roomName,
    String movie,
    int capacity,
    int booked,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => _QuickSeatMapModal(
        roomName: roomName,
        movie: movie,
        capacity: capacity,
        booked: booked,
      ),
    );
  }
}

class _QuickSeatMapModal extends StatelessWidget {
  final String roomName;
  final String movie;
  final int capacity;
  final int booked;

  const _QuickSeatMapModal({
    required this.roomName,
    required this.movie,
    required this.capacity,
    required this.booked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final available = capacity - booked;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      movie,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Screen Curve
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.primary, width: 3),
              ),
            ),
            child: Text(
              l10n.screen,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Seat Grid Preview (8 rows x 10 cols)
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(8, (rowIndex) {
                    final rowLetter = String.fromCharCode(65 + rowIndex);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            child: Text(
                              rowLetter,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.textSecondary,
                              ),
                            ),
                          ),
                          ...List.generate(10, (colIndex) {
                            final seatNum = rowIndex * 10 + colIndex;
                            final isBooked = seatNum < booked;
                            final isVIP = rowIndex >= 4 && rowIndex <= 6;

                            final seatColor = isBooked
                                ? theme.seatBooked
                                : (isVIP ? theme.seatVIP : theme.seatStandard);

                            return Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              decoration: BoxDecoration(
                                color: seatColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  '${colIndex + 1}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isBooked ? theme.seatBookedText : theme.seatText,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(theme.seatStandard, l10n.seatStandard, theme),
              const SizedBox(width: 12),
              _buildLegend(theme.seatVIP, l10n.seatVIP, theme),
              const SizedBox(width: 12),
              _buildLegend(theme.seatBooked, l10n.seatBooked, theme),
            ],
          ),
          const SizedBox(height: 12),

          // Counters summary
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  l10n.availableCountLabel(available),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.success,
                  ),
                ),
                Text(
                  l10n.bookedCountLabel(booked),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.seatBooked,
                  ),
                ),
                Text(
                  l10n.totalCountLabel(capacity),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label, CineplexColors theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: theme.textSecondary),
        ),
      ],
    );
  }
}
