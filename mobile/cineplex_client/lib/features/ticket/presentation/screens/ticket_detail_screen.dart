import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_shared/mobile_shared.dart';

class TicketDetailScreen extends StatelessWidget {
  final BookingDetailModel booking;

  const TicketDetailScreen({super.key, required this.booking});

  String _formatDateTime(String? raw, String locale) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('HH:mm - EEEE, dd/MM/yyyy', locale).format(dt);
    } catch (_) {
      return raw;
    }
  }

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
    final locale = Localizations.localeOf(context).languageCode;

    final qrTickets = booking.tickets.where((t) => t.qrCode.isNotEmpty).toList();
    final seatsString = booking.tickets
        .map((t) => t.seatLabel ?? t.seatId)
        .where((s) => s.isNotEmpty)
        .join(', ');
    final isPaid = booking.status.toUpperCase() == 'PAID';

    return AppScaffold(
      title: l10n.ticketDetail,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Movie Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.movieTitle ?? l10n.defaultMovieTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    booking.format ?? l10n.ticketFormat2D,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${booking.cinemaName ?? l10n.appName} - ${booking.roomName ?? l10n.screeningRoom}',
                                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: colors.primary),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateTime(booking.startTime, locale),
                        style: TextStyle(fontSize: 13, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QR Codes Section (Real QR using qr_flutter)
            Text(
              l10n.qrCode,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.primary),
            ),
            const SizedBox(height: 10),

            if (qrTickets.isNotEmpty) ...[
              ...qrTickets.map((ticket) {
                final isCheckedIn = ticket.isCheckedIn;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.seatStandard}: ${ticket.seatLabel ?? ticket.seatId}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCheckedIn
                                  ? colors.success.withValues(alpha: 0.12)
                                  : colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isCheckedIn ? l10n.checkedIn : l10n.notCheckedIn,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isCheckedIn ? colors.success : colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: ticket.qrCode,
                          version: QrVersions.auto,
                          size: 160.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ticket.qrCode,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: colors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Center(
                  child: Text(
                    l10n.qrCodeAvailableAfterPayment,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Order Details Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: l10n.orderCode,
                    value: booking.bookingCode,
                    colors: colors,
                  ),
                  if (seatsString.isNotEmpty) ...[
                    Divider(height: 16, color: colors.divider),
                    _buildDetailRow(
                      label: l10n.seatInfo,
                      value: seatsString,
                      colors: colors,
                    ),
                  ],
                  if (booking.concessions.isNotEmpty) ...[
                    Divider(height: 16, color: colors.divider),
                    _buildDetailRow(
                      label: l10n.concessions,
                      value: booking.concessions
                          .map((c) => '${c['quantity'] ?? 1}x ${c['concession']?['name'] ?? l10n.concessionCombo}')
                          .join(', '),
                      colors: colors,
                    ),
                  ],
                  Divider(height: 16, color: colors.divider),
                  _buildDetailRow(
                    label: l10n.orderStatus,
                    value: _localizeStatus(booking.status, l10n),
                    colors: colors,
                    valueColor: isPaid ? colors.success : colors.error,
                  ),
                  Divider(height: 16, color: colors.divider),
                  _buildDetailRow(
                    label: l10n.totalAmount,
                    value: FormatUtils.formatCurrency(booking.totalAmount.toInt()),
                    colors: colors,
                    isBold: true,
                    valueColor: colors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required CineplexColors colors,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
