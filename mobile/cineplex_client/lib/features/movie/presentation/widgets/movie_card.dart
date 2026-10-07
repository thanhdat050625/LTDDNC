import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final bool isComingSoon;

  const MovieCard({super.key, required this.movie, this.isComingSoon = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);

    return InkWell(
      onTap: () {
        context.push('/movies/${movie.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: 'poster_${movie.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppCachedImage(
                      imageUrl: movie.posterUrl ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isComingSoon && movie.releaseDate != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        FormatUtils.formatDate(movie.releaseDate!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.clock, size: 14, color: colors.textSecondary),
              const SizedBox(width: 4),
              Text(
                l10n.durationMinutes(movie.durationMinutes),
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              if (movie.ageLimit != null && movie.ageLimit! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${movie.ageLimit}+',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
