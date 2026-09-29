import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cineplex_mobile/core/widgets/app_scaffold.dart';
import 'package:cineplex_mobile/features/ticket/data/models/ticket_model.dart';
import 'package:cineplex_mobile/core/utils/format_utils.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';

class TicketDetailScreen extends StatelessWidget {
  final BookingDetailModel booking;

  const TicketDetailScreen({super.key, required this.booking});

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('HH:mm - EEEE, dd/MM/yyyy', 'vi').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final qrTickets = booking.tickets.where((t) => t.qrCode.isNotEmpty).toList();
    final seatsString = booking.tickets
        .map((t) => t.seatLabel ?? t.seatId)
        .where((s) => s.isNotEmpty)
        .join(', ');

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
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
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
                              booking.movieTitle ?? 'Cineplex Movie',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    booking.format ?? '2D',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${booking.cinemaName ?? 'Cineplex'} - ${booking.roomName ?? 'Phòng chiếu'}',
                                  style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
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
                      Icon(Icons.access_time, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateTime(booking.startTime),
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 10),

            if (qrTickets.isNotEmpty) ...[
              ...qrTickets.map((ticket) {
                final isCheckedIn = ticket.isCheckedIn;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.seatStandard}: ${ticket.seatLabel ?? ticket.seatId}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCheckedIn
                                  ? colorScheme.secondaryContainer
                                  : colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isCheckedIn ? l10n.checkedIn : l10n.notCheckedIn,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isCheckedIn
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onPrimaryContainer,
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
                              color: Colors.black.withOpacity(0.08),
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
                          color: colorScheme.onSurfaceVariant,
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
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Mã QR chỉ khả dụng sau khi đơn hàng được thanh toán thành công.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Order Details Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Mã đơn hàng',
                    value: booking.bookingCode,
                    colorScheme: colorScheme,
                  ),
                  if (seatsString.isNotEmpty) ...[
                    const Divider(height: 16),
                    _buildDetailRow(
                      label: l10n.seatInfo,
                      value: seatsString,
                      colorScheme: colorScheme,
                    ),
                  ],
                  if (booking.concessions.isNotEmpty) ...[
                    const Divider(height: 16),
                    _buildDetailRow(
                      label: 'Bắp nước',
                      value: booking.concessions
                          .map((c) => '${c['quantity'] ?? 1}x ${c['concession']?['name'] ?? 'Combo'}')
                          .join(', '),
                      colorScheme: colorScheme,
                    ),
                  ],
                  const Divider(height: 16),
                  _buildDetailRow(
                    label: 'Trạng thái',
                    value: booking.status,
                    colorScheme: colorScheme,
                    valueColor: booking.status == 'PAID' ? colorScheme.primary : colorScheme.error,
                  ),
                  const Divider(height: 16),
                  _buildDetailRow(
                    label: 'Tổng tiền',
                    value: FormatUtils.formatCurrency(booking.totalAmount.toInt()),
                    colorScheme: colorScheme,
                    isBold: true,
                    valueColor: colorScheme.primary,
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
    required ColorScheme colorScheme,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
