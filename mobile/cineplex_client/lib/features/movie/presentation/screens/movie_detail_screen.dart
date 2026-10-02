import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
      create: (context) => MovieDetailCubit(context.read<MovieRepository>())..loadMovie(movieId),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
          builder: (context, state) {
            if (state is MovieDetailLoading || state is MovieDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MovieDetailError) {
              return RefreshIndicator(
                onRefresh: () => context.read<MovieDetailCubit>().loadMovie(movieId),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                    Center(child: Text(state.message)),
                  ],
                ),
              );
            }
            if (state is MovieDetailLoaded) {
              final movie = state.movie;
              final l10n = AppLocalizations.of(context)!;
              final releaseDate = movie.releaseDate != null ? DateFormat.yMMMd().format(movie.releaseDate!) : '';
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => context.read<MovieDetailCubit>().loadMovie(movieId),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                      SliverAppBar(
                        expandedHeight: 400,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: 'poster_${movie.id}',
                                child: AppCachedImage(imageUrl: movie.posterUrl ?? '', fit: BoxFit.cover),
                              ),
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
                                    icon: const Icon(LucideIcons.playCircle, size: 64, color: Colors.white),
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
                                  _buildChip('${movie.durationMinutes}m', context, icon: LucideIcons.clock),
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
