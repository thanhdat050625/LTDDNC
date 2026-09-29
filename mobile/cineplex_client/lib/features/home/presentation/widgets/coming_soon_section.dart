import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/movie/presentation/widgets/movie_card.dart';

class ComingSoonSection extends StatelessWidget {
  final List<MovieModel> movies;
  const ComingSoonSection({super.key, required this.movies});

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
              Text(l10n.comingSoon, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
              child: MovieCard(movie: movies[index], isComingSoon: true),
            ),
          ),
        ),
      ],
    );
  }
}
