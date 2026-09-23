import 'package:flutter/material.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';
import 'package:cineplex_mobile/features/movie/data/models/movie_model.dart';
import 'package:cineplex_mobile/features/movie/presentation/widgets/movie_card.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';

class NowShowingSection extends StatelessWidget {
  final List<MovieModel> movies;
  const NowShowingSection({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.nowShowing, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text(l10n.seeAll, style: const TextStyle(color: AppColors.secondary)),
              )
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 150,
              child: MovieCard(movie: movies[index]),
            ),
          ),
        ),
      ],
    );
  }
}
