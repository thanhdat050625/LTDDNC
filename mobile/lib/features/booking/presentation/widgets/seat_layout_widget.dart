import 'package:flutter/material.dart';
import 'package:cineplex_mobile/features/booking/data/models/seat_model.dart';
import 'package:cineplex_mobile/features/booking/presentation/widgets/seat_item_widget.dart';

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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: sortedRows.map((row) {
              final rowList = rowSeats[row]!..sort((a, b) => a.column.compareTo(b.column));
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      row,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...rowList.map((seat) => SeatItemWidget(
                    seat: seat,
                    isSelected: selectedSeatIds.contains(seat.seatId),
                    onTap: () => onSeatTap(seat.seatId),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
