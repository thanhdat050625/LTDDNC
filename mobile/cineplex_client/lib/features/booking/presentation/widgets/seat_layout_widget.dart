import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';

class SeatLayoutWidget extends StatelessWidget {
  final List<SeatModel> seats;
  final List<int> selectedSeatIds;
  final Function(int) onSeatTap;
  final int rows;
  final int columns;

  const SeatLayoutWidget({
    super.key,
    required this.seats,
    required this.selectedSeatIds,
    required this.onSeatTap,
    required this.rows,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) return const SizedBox.shrink();

    // Group seats by row
    final Map<String, List<SeatModel>> rowSeats = {};
    for (final seat in seats) {
      if (!rowSeats.containsKey(seat.row)) {
        rowSeats[seat.row] = [];
      }
      rowSeats[seat.row]!.add(seat);
    }

    final sortedRows = rowSeats.keys.toList()..sort();
    final theme = Theme.of(context);

    return InteractiveViewer(
      minScale: 0.6,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.all(40),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sortedRows.map((row) {
                  final rowList = rowSeats[row]!..sort((a, b) => a.column.compareTo(b.column));
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            row,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...rowList.map((seat) => SeatWidget(
                          seat: seat,
                          isSelected: selectedSeatIds.contains(seat.seatId),
                          onTap: () => onSeatTap(seat.seatId),
                          size: 32.0,
                        )),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 24,
                          child: Text(
                            row,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
      ),
    );
  }
}

