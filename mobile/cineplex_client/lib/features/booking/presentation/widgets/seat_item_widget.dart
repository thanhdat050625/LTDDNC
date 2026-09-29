import 'package:flutter/material.dart';
import 'package:cineplex_client/core/theme/cineplex_colors.dart';
import 'package:cineplex_client/features/booking/data/models/seat_model.dart';

class SeatItemWidget extends StatelessWidget {
  final SeatModel seat;
  final bool isSelected;
  final VoidCallback onTap;

  const SeatItemWidget({
    super.key,
    required this.seat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CineplexColors>()!;
    Color seatColor = _getSeatColor(colors);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        width: seat.isCouple ? 80 : 36,
        height: 36,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: seatColor.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              )
          ],
        ),
        child: Center(
          child: Text(
            seat.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getSeatColor(CineplexColors colors) {
    if (isSelected) return colors.seatSelected;
    switch (seat.status) {
      case SeatStatus.booked: return colors.seatBooked;
      case SeatStatus.held: return colors.seatHeld;
      case SeatStatus.maintenance: return Colors.grey;
      case SeatStatus.available:
      default:
        return seat.isCouple ? colors.seatCouple : colors.seatStandard;
    }
  }
}
