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
    final theme = Theme.of(context).extension<CineplexColors>()!;

    return AppScaffold(
      title: 'Quản lý Phim', // Should use l10n.movieManagement in real implementation
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
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _searchController,
                    hintText: 'Tìm kiếm tên phim...',
                    prefixIcon: LucideIcons.search,
                    onChanged: (val) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        context.read<MovieManagementCubit>().searchMovies(val);
                      });
                    },
                  ),
                ),
                SizedBox(width: theme.spacingMd),
                Container(
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                  ),
                  child: IconButton(
                    icon: Icon(LucideIcons.filter, color: theme.textPrimary),
                    onPressed: () {
                      // Show filter bottom sheet
                    },
                  ),
                ),
              ],
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
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(child: Text(state.message, style: TextStyle(color: theme.error))),
                      ],
                    );
                  }

                  if (state is MovieManagementLoaded) {
                    final movies = state.movies;
                    if (movies.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          Center(child: Text(AppLocalizations.of(context)!.noData)),
                        ],
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: movies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return MovieListItem(
                          movie: movie,
                          onTap: () {
                            // Navigate to detail
                            context.push('/movies/${movie.id}');
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
