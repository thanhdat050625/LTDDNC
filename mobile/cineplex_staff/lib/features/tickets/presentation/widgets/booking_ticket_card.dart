import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class BookingTicketCard extends StatelessWidget {
  final BookingDetailModel booking;
  final VoidCallback onTap;

  const BookingTicketCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CineplexColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final bStatus = booking.status.toUpperCase();
    final isPaid =
        bStatus == 'CONFIRMED' || bStatus == 'PAID' || bStatus == 'SUCCESS';
    final isPending =
        bStatus == 'PENDING' || bStatus == 'WAITING' || bStatus == 'PROCESSING';

    final statusBg = isPaid
        ? colors.success.withValues(alpha: 0.15)
        : isPending
        ? colors.warning.withValues(alpha: 0.15)
        : colors.surfaceVariant;
    final statusColor = isPaid
        ? colors.success
        : isPending
        ? colors.warning
        : colors.textMuted;
    final statusText = isPaid
        ? l10n.ticketStatusConfirmed
        : isPending
        ? l10n.ticketStatusPending
        : l10n.ticketStatusCancelled;

    // Collect seat labels
    final seatLabels = booking.tickets
        .map((t) => t.seatLabel ?? t.seatId)
        .where((s) => s.isNotEmpty)
        .join(', ');

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Booking Code & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.ticket,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    booking.bookingCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Movie Title
          Text(
            booking.movieTitle ?? l10n.movieInfo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Showtime & Room
          Row(
            children: [
              Icon(LucideIcons.clock, size: 13, color: colors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${(booking.startTime != null && DateTime.tryParse(booking.startTime!) != null) ? FormatUtils.formatDateTime(DateTime.parse(booking.startTime!).toLocal()) : (booking.startTime ?? '--')} • ${booking.roomName ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Seats
          if (seatLabels.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  LucideIcons.armchair,
                  size: 13,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${l10n.ticketSeatLabel}: $seatLabels',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          Divider(color: colors.borderSubtle, height: 16),

          // Bottom: Customer & Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.customerName ??
                      (booking.staffName != null
                          ? 'Staff: ${booking.staffName}'
                          : l10n.ticketSaleAtCounter),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ),
              Text(
                FormatUtils.formatCurrency(booking.totalAmount),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
