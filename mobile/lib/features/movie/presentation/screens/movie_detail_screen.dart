import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';
import 'package:cineplex_mobile/core/widgets/app_cached_image.dart';
import 'package:cineplex_mobile/core/widgets/app_button.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';
import 'package:cineplex_mobile/features/movie/presentation/widgets/movie_info_section.dart';
import 'package:cineplex_mobile/features/movie/presentation/cubit/movie_detail_cubit.dart';
import 'package:cineplex_mobile/features/movie/data/repositories/movie_repository.dart';
import 'package:intl/intl.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDetailCubit(context.read<MovieRepository>())..loadMovie(movieId),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
          builder: (context, state) {
            if (state is MovieDetailLoading || state is MovieDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MovieDetailError) {
              return Center(child: Text(state.message));
            }
            if (state is MovieDetailLoaded) {
              final movie = state.movie;
              final l10n = AppLocalizations.of(context)!;
              final releaseDate = movie.releaseDate != null ? DateFormat.yMMMd().format(movie.releaseDate!) : '';
              return Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 400,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppCachedImage(imageUrl: movie.posterUrl ?? '', fit: BoxFit.cover),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Theme.of(context).colorScheme.background],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              if (movie.trailerUrl != null && movie.trailerUrl!.isNotEmpty)
                                Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                                    onPressed: () async {
                                      final uri = Uri.parse(movie.trailerUrl!);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movie.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (movie.genre.isNotEmpty) _buildChip(movie.genre, context),
                                  _buildChip('${movie.durationMinutes}m', context, icon: Icons.access_time),
                                  if (movie.ageLimit != null) _buildChip('${movie.ageLimit}+', context, color: AppColors.primary),
                                  if (movie.language != null) _buildChip(movie.language!, context),
                                ],
                              ),
                              const SizedBox(height: 24),
                              MovieInfoSection(
                                director: movie.director ?? '',
                                cast: movie.cast ?? '',
                                language: movie.language ?? '',
                                releaseDate: releaseDate,
                              ),
                              const SizedBox(height: 24),
                              Text(l10n.description, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 8),
                              Text(movie.description ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), height: 1.5)),
                              const SizedBox(height: 100), 
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      color: Theme.of(context).colorScheme.surface,
                      child: SafeArea(
                        top: false,
                        child: AppButton(
                          text: l10n.bookNow,
                          onPressed: () {
                            context.push('/showtimes/${movie.id}');
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label, BuildContext context, {IconData? icon, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: color != null ? Border.all(color: color) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 12, color: color ?? Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
