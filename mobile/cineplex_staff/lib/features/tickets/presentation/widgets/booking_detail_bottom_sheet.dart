import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class BookingDetailBottomSheet extends StatelessWidget {
  final BookingDetailModel booking;

  const BookingDetailBottomSheet({super.key, required this.booking});

  static Future<void> show(BuildContext context, BookingDetailModel booking) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingDetailBottomSheet(booking: booking),
    );
  }

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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ticketDetailTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        '${l10n.ticketBookingCode}: ${booking.bookingCode}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: colors.iconSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(color: colors.borderSubtle, height: 1),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Info Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (booking.posterUrl != null &&
                          booking.posterUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AppCachedImage(
                            imageUrl: booking.posterUrl!,
                            width: 64,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 64,
                          height: 90,
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            LucideIcons.film,
                            color: colors.iconSecondary,
                          ),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.movieTitle ?? l10n.movieInfo,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${booking.cinemaName ?? 'Cineplex'} • ${booking.roomName ?? ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.startTime != null &&
                                      DateTime.tryParse(booking.startTime!) !=
                                          null
                                  ? FormatUtils.formatDateTime(
                                      DateTime.parse(booking.startTime!)
                                          .toLocal(),
                                    )
                                  : (booking.startTime ?? '--'),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Customer & Staff info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          label: l10n.ticketCustomerName,
                          value:
                              booking.customerName ?? l10n.ticketSaleAtCounter,
                        ),
                        if (booking.customerPhone != null &&
                            booking.customerPhone!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _buildInfoRow(
                            context,
                            label: l10n.phone,
                            value: booking.customerPhone!,
                          ),
                        ],
                        if (booking.staffName != null &&
                            booking.staffName!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _buildInfoRow(
                            context,
                            label: l10n.staffName,
                            value: booking.staffName!,
                          ),
                        ],
                        if (booking.createdAt != null) ...[
                          const SizedBox(height: 6),
                          _buildInfoRow(
                            context,
                            label: l10n.ticketShowtimeLabel,
                            value:
                                (booking.createdAt != null &&
                                    DateTime.tryParse(booking.createdAt!) !=
                                        null)
                                ? FormatUtils.formatDateTime(
                                    DateTime.parse(booking.createdAt!)
                                        .toLocal(),
                                  )
                                : (booking.createdAt ?? '--'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tickets List
                  Text(
                    '${l10n.ticketSeatLabel} (${booking.tickets.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (booking.tickets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '--',
                        style: TextStyle(color: colors.textMuted, fontSize: 13),
                      ),
                    )
                  else
                    ...booking.tickets.map((t) {
                      final isChecked = t.isCheckedIn;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.seatLabel ?? t.seatId,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.qrCode,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    FormatUtils.formatCurrency(t.price),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? colors.success.withValues(alpha: 0.15)
                                    : colors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isChecked
                                        ? LucideIcons.check
                                        : LucideIcons.circle,
                                    size: 11,
                                    color: isChecked
                                        ? colors.success
                                        : colors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isChecked
                                        ? l10n.ticketCheckedInStatus
                                        : l10n.ticketNotCheckedInStatus,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isChecked
                                          ? colors.success
                                          : colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 16),

                  // Concessions (if any)
                  if (booking.concessions.isNotEmpty) ...[
                    Text(
                      l10n.ticketConcessionsLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...booking.concessions.map((c) {
                      final name =
                          c['product']?['name'] ??
                          c['concessionProduct']?['name'] ??
                          c['name'] ??
                          'Combo';
                      final qty = c['quantity'] ?? 1;
                      final price = c['unitPrice'] ?? c['price'] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$name x$qty',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                            ),
                            Text(
                              FormatUtils.formatCurrency(
                                (price as num) * (qty as num),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // Payment Summary
                  Divider(color: colors.borderSubtle),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalAmount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        FormatUtils.formatCurrency(booking.totalAmount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (booking.paymentMethod != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.ticketPaymentStatus,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colors.textMuted,
                          ),
                        ),
                        Text(
                          '${booking.paymentMethod} • ${isPaid ? l10n.ticketStatusConfirmed : (isPending ? l10n.ticketStatusPending : l10n.ticketStatusCancelled)}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isPaid
                                ? colors.success
                                : (isPending
                                      ? colors.warning
                                      : colors.textMuted),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SafeArea(top: false, child: SizedBox(height: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final colors = Theme.of(context).extension<CineplexColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12.5, color: colors.textMuted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
