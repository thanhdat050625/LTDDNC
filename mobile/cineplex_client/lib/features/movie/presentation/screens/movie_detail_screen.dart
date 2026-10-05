import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cineplex_client/features/movie/presentation/widgets/movie_info_section.dart';
import 'package:cineplex_client/features/movie/presentation/cubit/movie_detail_cubit.dart';
import 'package:cineplex_client/features/movie/data/repositories/movie_repository.dart';
import 'package:intl/intl.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MovieDetailCubit(context.read<MovieRepository>())..loadMovie(movieId),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colors = CineplexColors.of(context);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
              builder: (context, state) {
                if (state is MovieDetailLoading ||
                    state is MovieDetailInitial) {
                  return const Center(child: AppLoading());
                }
                if (state is MovieDetailError) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<MovieDetailCubit>().loadMovie(movieId),
                  );
                }
                if (state is MovieDetailLoaded) {
                  final movie = state.movie;
                  final l10n = AppLocalizations.of(context)!;
                  final releaseDate = movie.releaseDate != null
                      ? DateFormat.yMMMd().format(movie.releaseDate!)
                      : '';
                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () =>
                            context.read<MovieDetailCubit>().loadMovie(movieId),
                        color: colors.primary,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverAppBar(
                              expandedHeight: 400,
                              pinned: true,
                              backgroundColor: theme.scaffoldBackgroundColor,
                              iconTheme: IconThemeData(
                                color: colors.textPrimary,
                              ),
                              flexibleSpace: FlexibleSpaceBar(
                                background: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Hero(
                                      tag: 'poster_${movie.id}',
                                      child: AppCachedImage(
                                        imageUrl: movie.posterUrl ?? '',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            theme.scaffoldBackgroundColor
                                                .withValues(alpha: 0.6),
                                            theme.scaffoldBackgroundColor,
                                          ],
                                          stops: const [0.4, 0.8, 1.0],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    if (movie.trailerUrl != null &&
                                        movie.trailerUrl!.isNotEmpty)
                                      Center(
                                        child: IconButton(
                                          icon: Icon(
                                            LucideIcons.playCircle,
                                            size: 64,
                                            color: colors.primary,
                                          ),
                                          onPressed: () {
                                            TrailerPlayerScreen.open(
                                              context,
                                              trailerUrl: movie.trailerUrl!,
                                              title: movie.title,
                                              genre: movie.genre,
                                              durationMinutes:
                                                  movie.durationMinutes,
                                              description: movie.description,
                                            );
                                          },
                                        ),
                                      ),
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
                                    Text(
                                      movie.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (movie.genre.isNotEmpty)
                                          _buildChip(movie.genre, colors),
                                        _buildChip(
                                          l10n.durationMinutes(
                                            movie.durationMinutes,
                                          ),
                                          colors,
                                          icon: LucideIcons.clock,
                                        ),
                                        if (movie.ageLimit != null && movie.ageLimit! > 0)
                                          _buildChip(
                                            '${movie.ageLimit}+',
                                            colors,
                                            color: colors.primary,
                                          ),
                                        if (movie.language != null)
                                          _buildChip(movie.language!, colors),
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
                                    Text(
                                      l10n.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      movie.description ?? '',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.card,
                            border: Border(
                              top: BorderSide(color: colors.borderSubtle),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadowColor,
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
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
          );
        },
      ),
    );
  }

  Widget _buildChip(
    String label,
    CineplexColors colors, {
    IconData? icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color ?? colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
