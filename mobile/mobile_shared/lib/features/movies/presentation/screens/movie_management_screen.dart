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
          // Core Operational KPI Cards
          BlocBuilder<MovieManagementCubit, MovieManagementState>(
            buildWhen: (prev, curr) => curr is MovieManagementLoaded,
            builder: (context, state) {
              if (state is! MovieManagementLoaded) {
                return const SizedBox.shrink();
              }
              return _buildKpiSection(context, state);
            },
          ),

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
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                      itemCount: movies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return MovieListItem(
                          movie: movie,
                          onTap: () {
                            _reloadAfterPush(
                              context.push('/movies/${movie.id}', extra: movie),
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

  Widget _buildKpiSection(BuildContext context, MovieManagementLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CineplexColors.of(context);
    final all = state.allMovies;
    final totalCount = all.length;
    final nowShowingCount = all.where((m) => m.status.toUpperCase() == 'NOW_SHOWING').length;
    final comingSoonCount = all.where((m) => m.status.toUpperCase() == 'COMING_SOON').length;
    final stoppedCount = all.where((m) => m.status.toUpperCase() == 'STOPPED').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.3,
        children: [
          _buildKpiCard(
            context,
            title: l10n.movieTotal,
            count: totalCount,
            icon: LucideIcons.film,
            accentColor: theme.primary,
            isSelected: state.selectedStatus == null,
            onTap: () => context.read<MovieManagementCubit>().filterByStatus(null),
          ),
          _buildKpiCard(
            context,
            title: l10n.statusNowShowing,
            count: nowShowingCount,
            icon: LucideIcons.playCircle,
            accentColor: theme.success,
            isSelected: state.selectedStatus == 'NOW_SHOWING',
            onTap: () => context.read<MovieManagementCubit>().filterByStatus('NOW_SHOWING'),
          ),
          _buildKpiCard(
            context,
            title: l10n.statusComingSoon,
            count: comingSoonCount,
            icon: LucideIcons.calendarClock,
            accentColor: theme.info,
            isSelected: state.selectedStatus == 'COMING_SOON',
            onTap: () => context.read<MovieManagementCubit>().filterByStatus('COMING_SOON'),
          ),
          _buildKpiCard(
            context,
            title: l10n.statusStopped,
            count: stoppedCount,
            icon: LucideIcons.archive,
            accentColor: theme.textMuted,
            isSelected: state.selectedStatus == 'STOPPED',
            onTap: () => context.read<MovieManagementCubit>().filterByStatus('STOPPED'),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = CineplexColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : theme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : theme.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: accentColor, size: 14),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? accentColor : theme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              maxLines: 1,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
