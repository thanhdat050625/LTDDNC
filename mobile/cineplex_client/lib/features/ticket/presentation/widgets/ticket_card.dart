import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class TicketCard extends StatelessWidget {
  final BookingDetailModel booking;

  const TicketCard({super.key, required this.booking});

  String _localizeStatus(String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return l10n.bookingStatusPaid;
      case 'PENDING':
        return l10n.bookingStatusPending;
      case 'CANCELLED':
      case 'CANCELED':
        return l10n.bookingStatusCancelled;
      case 'EXPIRED':
        return l10n.bookingStatusExpired;
      case 'CONFIRMED':
        return l10n.bookingStatusConfirmed;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);
    final isPaid = booking.status.toUpperCase() == 'PAID';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/my-tickets/${booking.id}', extra: booking);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPaid ? colors.primary.withValues(alpha: 0.12) : colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: isPaid ? colors.primary : colors.iconSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.movieTitle ?? '${l10n.orderCode}: ${booking.bookingCode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.cinemaName ?? l10n.appName} • ${booking.roomName ?? l10n.screeningRoom}',
                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          FormatUtils.formatCurrency(booking.totalAmount.toInt()),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? colors.success.withValues(alpha: 0.12)
                                  : colors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _localizeStatus(booking.status, l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isPaid ? colors.success : colors.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 20, color: colors.iconSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
