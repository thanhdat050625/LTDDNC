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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            if (showtime.movie?.posterUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(theme.radiusSm),
                child: AppCachedImage(
                  imageUrl: showtime.movie!.posterUrl!,
                  width: 52,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 10),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showtime.movie?.title ?? AppLocalizations.of(context)!.unknownMovie,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 14, color: theme.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(showtime.publicStartTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.monitorPlay, size: 14, color: theme.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        showtime.room?.name ?? AppLocalizations.of(context)!.emptyRoom,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          showtime.format,
                          style: TextStyle(color: theme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // Status & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(showtime.status, theme).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(showtime.status, context),
                          style: TextStyle(
                            color: _getStatusColor(showtime.status, theme),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(LucideIcons.edit3, size: 20, color: theme.accent),
                            onPressed: onEdit,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(4),
                          ),
                          IconButton(
                            icon: Icon(LucideIcons.trash2, size: 20, color: theme.error),
                            onPressed: onDelete,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(4),
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

  Color _getStatusColor(String status, CineplexColors theme) {
    switch (status) {
      case 'SCHEDULED': return theme.info;
      case 'BOOKING': return theme.success;
      case 'FULL': return theme.warning;
      case 'CANCELLED': return theme.error;
      case 'COMPLETED': return theme.textSecondary;
      default: return theme.textSecondary;
    }
  }

  String _getStatusText(String status, BuildContext context) {
    switch (status) {
      case 'SCHEDULED': return AppLocalizations.of(context)!.statusScheduled;
      case 'BOOKING': return AppLocalizations.of(context)!.statusBooking;
      case 'FULL': return AppLocalizations.of(context)!.statusFull;
      case 'CANCELLED': return AppLocalizations.of(context)!.statusCancelled;
      case 'COMPLETED': return AppLocalizations.of(context)!.statusCompleted;
      default: return status;
    }
  }
}
