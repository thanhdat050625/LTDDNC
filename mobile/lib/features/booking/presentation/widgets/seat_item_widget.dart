import 'package:flutter/material.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';
import 'package:cineplex_mobile/features/booking/data/models/seat_model.dart';

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
    Color seatColor = _getSeatColor();
    
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

  Color _getSeatColor() {
    if (isSelected) return AppColors.seatSelected;
    switch (seat.status) {
      case SeatStatus.booked: return AppColors.seatBooked;
      case SeatStatus.held: return AppColors.seatHeld;
      case SeatStatus.maintenance: return Colors.grey;
      case SeatStatus.available:
      default:
        return seat.isCouple ? AppColors.seatCouple : AppColors.seatStandard;
    }
  }
}
