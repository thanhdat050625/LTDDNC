import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MovieManagementScreen extends StatefulWidget {
  final Widget? drawer;
  const MovieManagementScreen({super.key, this.drawer});

  @override
  State<MovieManagementScreen> createState() => _MovieManagementScreenState();
}

class _MovieManagementScreenState extends State<MovieManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<MovieManagementCubit>().loadMovies();
  }

  // Reload when returning from MovieFormScreen
  Future<void> _reloadAfterPush(Future<Object?> future) async {
    await future;
    if (mounted) {
      context.read<MovieManagementCubit>().loadMovies();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.movieManagement,
      drawer: widget.drawer,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _reloadAfterPush(context.push('/movies/new'));
        },
        backgroundColor: theme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            color: theme.surface,
            child: AppTextField(
              controller: _searchController,
              hintText: l10n.searchMoviesPlaceholder,
              prefixIcon: LucideIcons.search,
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  context.read<MovieManagementCubit>().searchMovies(val);
                });
              },
            ),
          ),
          
          // Movie List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<MovieManagementCubit>().loadMovies(),
              child: BlocBuilder<MovieManagementCubit, MovieManagementState>(
                builder: (context, state) {
                  if (state is MovieManagementLoading) {
                    return const AppLoading();
                  }
                  
                  if (state is MovieManagementError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: AppErrorView(
                          message: state.message,
                          onRetry: () => context.read<MovieManagementCubit>().loadMovies(),
                        ),
                      ),
                    );
                  }

                  if (state is MovieManagementLoaded) {
                    final movies = state.movies;
                    if (movies.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: AppEmptyView(
                            icon: LucideIcons.film,
                            title: l10n.noData,
                            message: l10n.searchMoviesPlaceholder,
                            actionLabel: l10n.addMovieTitle,
                            onAction: () => _reloadAfterPush(context.push('/movies/new')),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: movies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return MovieListItem(
                          movie: movie,
                          onTap: () {
                            _reloadAfterPush(
                              context.push('/movies/${movie.id}/edit', extra: movie),
                            );
                          },
                          onEdit: () {
                            _reloadAfterPush(
                              context.push('/movies/${movie.id}/edit', extra: movie),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
