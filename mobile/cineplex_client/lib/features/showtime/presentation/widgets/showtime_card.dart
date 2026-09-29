import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeCard extends StatelessWidget {
  final ShowtimeModel showtime;
  final VoidCallback onTap;

  const ShowtimeCard({
    super.key,
    required this.showtime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(showtime.publicStartTime),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                showtime.format,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (showtime.totalSeats > 0) ...[
              const SizedBox(height: 6),
              Text(
                l10n.availableSeatsCount(showtime.availableSeats, showtime.totalSeats),
                style: TextStyle(
                  fontSize: 11,
                  color: showtime.availableSeats == 0 ? Colors.red : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
