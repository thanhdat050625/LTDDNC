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
    final colors = CineplexColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.textSecondary.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(showtime.publicStartTime),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                showtime.format,
                style: TextStyle(
                  fontSize: 10,
                  color: colors.primary,
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
                  color: showtime.availableSeats == 0 ? colors.error : colors.textSecondary,
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
