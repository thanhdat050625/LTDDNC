import 'package:flutter/material.dart';
import 'package:cineplex_client/core/theme/app_colors.dart';
import 'package:cineplex_client/core/utils/format_utils.dart';

class BookingTimerWidget extends StatelessWidget {
  final int secondsRemaining;

  const BookingTimerWidget({
    super.key,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = secondsRemaining < 60;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isWarning ? AppColors.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWarning ? AppColors.primary : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: isWarning ? AppColors.primary : Theme.of(context).iconTheme.color,
          ),
          const SizedBox(width: 8),
          Text(
            FormatUtils.formatCountdown(secondsRemaining),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isWarning ? AppColors.primary : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
