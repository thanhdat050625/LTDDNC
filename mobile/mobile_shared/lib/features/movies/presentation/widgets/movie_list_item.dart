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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    // final l10n = AppLocalizations.of(context)!; // Will use later for L10n if needed

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
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
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(theme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16, // headlineSmall is usually large, we override size to fit card, or use titleMedium with w800
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: theme.spacingSm),
                    Row(
                      children: [
                        Icon(LucideIcons.clock, size: 14, color: theme.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          '${movie.durationMinutes} phút',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: theme.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      movie.genre ?? '',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: theme.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: theme.spacingMd),
                    
                    // Status badge & Edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (movie.status == 'SHOWING' ? theme.success : theme.textSecondary).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            movie.status == 'SHOWING' ? 'Đang chiếu' : movie.status,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: movie.status == 'SHOWING' ? theme.success : theme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.edit3, size: 20, color: theme.accent),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
