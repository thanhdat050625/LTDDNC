import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeListItem extends StatelessWidget {
  final ShowtimeModel showtime;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShowtimeListItem({
    super.key,
    required this.showtime,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _getFormatLabel(String format, AppLocalizations l10n) {
    final f = format.toUpperCase();
    if (f.contains('3D')) return l10n.format3D;
    if (f.contains('IMAX')) return l10n.formatIMAX;
    if (f.contains('4DX')) return l10n.format4DX;
    return l10n.format2D;
  }

  Color _getFormatColor(String format, CineplexColors theme) {
    final f = format.toUpperCase();
    if (f.contains('3D')) return const Color(0xFF8B5CF6);
    if (f.contains('IMAX')) return const Color(0xFFF59E0B);
    if (f.contains('4DX')) return const Color(0xFF10B981);
    return theme.info;
  }

  Color _getStatusColor(String status, CineplexColors theme) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return theme.info;
      case 'ACTIVE':
      case 'BOOKING':
        return theme.success;
      case 'FULL':
        return theme.warning;
      case 'CANCELLED':
        return theme.error;
      case 'COMPLETED':
        return theme.textSecondary;
      default:
        return theme.textSecondary;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return l10n.statusScheduled;
      case 'ACTIVE':
      case 'BOOKING':
        return l10n.statusBooking;
      case 'FULL':
        return l10n.statusFull;
      case 'CANCELLED':
        return l10n.statusCancelled;
      case 'COMPLETED':
        return l10n.statusCompleted;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor(showtime.status, theme);
    final formatColor = _getFormatColor(showtime.format, theme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(theme.radiusSm),
              child:
                  (showtime.movie?.posterUrl != null &&
                      showtime.movie!.posterUrl!.isNotEmpty)
                  ? AppCachedImage(
                      imageUrl: showtime.movie!.posterUrl!,
                      width: 54,
                      height: 76,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 54,
                      height: 76,
                      decoration: BoxDecoration(
                        color: theme.surfaceVariant,
                        borderRadius: BorderRadius.circular(theme.radiusSm),
                      ),
                      child: Icon(
                        Icons.movie_outlined,
                        size: 24,
                        color: theme.textSecondary,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showtime.movie?.title ?? l10n.unknownMovie,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 13,
                        color: theme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy • HH:mm')
                            .format(showtime.publicStartTime),
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.monitorPlay,
                        size: 13,
                        color: theme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          showtime.room?.name ?? l10n.emptyRoom,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: formatColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: formatColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          _getFormatLabel(showtime.format, l10n),
                          style: TextStyle(
                            color: formatColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Status & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          _getStatusText(showtime.status, l10n),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              LucideIcons.edit3,
                              size: 18,
                              color: theme.accent,
                            ),
                            onPressed: onEdit,
                            tooltip: l10n.editShowtime,
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            padding: const EdgeInsets.all(8),
                          ),
                          IconButton(
                            icon: Icon(
                              LucideIcons.trash2,
                              size: 18,
                              color: theme.error,
                            ),
                            onPressed: onDelete,
                            tooltip: l10n.delete,
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            padding: const EdgeInsets.all(8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
