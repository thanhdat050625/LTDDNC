import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

enum ScanStatusType { valid, alreadyUsed, invalid }

class ScanResultSheet extends StatelessWidget {
  final ScanStatusType status;
  final String? movieTitle;
  final String? roomName;
  final String? cinemaName;
  final String? showtime;
  final String? seatLabel;
  final String? customerName;
  final String? ticketCode;
  final String? bookingCode;
  final String? message;
  final DateTime? checkinTime;
  final VoidCallback onScanNext;
  final VoidCallback onClose;

  const ScanResultSheet({
    super.key,
    required this.status,
    this.movieTitle,
    this.roomName,
    this.cinemaName,
    this.showtime,
    this.seatLabel,
    this.customerName,
    this.ticketCode,
    this.bookingCode,
    this.message,
    this.checkinTime,
    required this.onScanNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final Color statusColor;
    final IconData statusIcon;
    final String statusBadgeText;

    switch (status) {
      case ScanStatusType.valid:
        statusColor = theme.success;
        statusIcon = LucideIcons.circleCheck;
        statusBadgeText = l10n.ticketValid;
        break;
      case ScanStatusType.alreadyUsed:
        statusColor = theme.warning;
        statusIcon = LucideIcons.triangleAlert;
        statusBadgeText = l10n.ticketAlreadyChecked;
        break;
      case ScanStatusType.invalid:
        statusColor = theme.error;
        statusIcon = LucideIcons.circleX;
        statusBadgeText = l10n.ticketInvalid;
        break;
    }

    final formattedTime = checkinTime != null
        ? FormatUtils.formatDateTime(checkinTime!)
        : FormatUtils.formatDateTime(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: status == ScanStatusType.alreadyUsed
                  ? statusColor
                  : statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: status == ScanStatusType.alreadyUsed
                    ? statusColor
                    : statusColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusIcon,
                  color: status == ScanStatusType.alreadyUsed
                      ? const Color(0xFF111827)
                      : statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    statusBadgeText,
                    style: TextStyle(
                      color: status == ScanStatusType.alreadyUsed
                          ? const Color(0xFF111827)
                          : statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Message (if invalid or warning)
          if (message != null && message!.isNotEmpty) ...[
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: status == ScanStatusType.alreadyUsed
                    ? theme.textPrimary
                    : theme.error,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Ticket Details Card (when movie info exists)
          if (movieTitle != null && movieTitle!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Title & Room
                  Text(
                    movieTitle!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.film,
                        size: 14,
                        color: theme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${roomName != null ? l10n.roomPrefix(roomName!) : l10n.defaultRoom} • ${cinemaName ?? 'Cineplex'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (showtime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: theme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            showtime!,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Divider(color: theme.borderSubtle, height: 1),
                  const SizedBox(height: 10),

                  // Seat & Customer Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.seatNumber,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              seatLabel ?? '--',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (customerName != null && customerName!.isNotEmpty)
                        const SizedBox(width: 12),
                      if (customerName != null && customerName!.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.customer,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                customerName!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Metadata row (Ticket Code & Timestamp)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (ticketCode != null && ticketCode!.isNotEmpty) ...[
                  Expanded(
                    child: Text(
                      '${l10n.ticketNumber}: $ticketCode',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    '${l10n.checkinTimeLabel}: $formattedTime',
                    style: TextStyle(fontSize: 11, color: theme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Actions
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textSecondary,
                    side: BorderSide(color: theme.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.close),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onScanNext,
                  icon: const Icon(LucideIcons.scanLine, size: 18),
                  label: Text(
                    l10n.scanNextTicket,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
