import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MovieListItem extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const MovieListItem({
    super.key,
    required this.movie,
    required this.onTap,
    required this.onEdit,
  });

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'NOW_SHOWING':
        return l10n.statusNowShowing;
      case 'COMING_SOON':
        return l10n.statusComingSoon;
      case 'STOPPED':
        return l10n.statusStopped;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, CineplexColors theme) {
    switch (status) {
      case 'NOW_SHOWING':
        return theme.success;
      case 'COMING_SOON':
        return theme.info;
      case 'STOPPED':
        return theme.textMuted;
      default:
        return theme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor(movie.status, theme);
    final statusLabel = _getStatusLabel(movie.status, l10n);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(theme.radiusMd)),
              child: Hero(
                tag: 'poster_${movie.id}',
                child: AppCachedImage(
                  imageUrl: movie.posterUrl ?? '',
                  width: 76,
                  height: 104,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.clock, size: 13, color: theme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          l10n.durationMinutes(movie.durationMinutes),
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      movie.genre.isNotEmpty ? movie.genre : '-',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Status badge & Edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.edit3, size: 18, color: theme.accent),
                          onPressed: onEdit,
                          tooltip: l10n.editMovieTitle,
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
