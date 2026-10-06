import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_client/features/movie/presentation/widgets/movie_card.dart';
import 'package:cineplex_client/features/movie/presentation/cubit/movie_list_cubit.dart';
import 'package:cineplex_client/features/movie/data/repositories/movie_repository.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieListCubit(context.read<MovieRepository>())..loadMovies(),
      child: const _MovieListScreenContent(),
    );
  }
}

class _MovieListScreenContent extends StatefulWidget {
  const _MovieListScreenContent();
  @override
  State<_MovieListScreenContent> createState() => _MovieListScreenContentState();
}

class _MovieListScreenContentState extends State<_MovieListScreenContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<({String? key, String label})> _getStatuses(AppLocalizations l10n) => [
    (key: null, label: l10n.movieAll),
    (key: 'NOW_SHOWING', label: l10n.movieNowShowing),
    (key: 'COMING_SOON', label: l10n.movieComingSoon),
  ];

  List<({String? key, String label})> _getGenres(AppLocalizations l10n) => [
    (key: null, label: l10n.genreAll),
    (key: 'Action', label: l10n.genreAction),
    (key: 'Comedy', label: l10n.genreComedy),
    (key: 'Drama', label: l10n.genreDrama),
    (key: 'Horror', label: l10n.genreHorror),
    (key: 'Sci-Fi', label: l10n.genreSciFi),
    (key: 'Animation', label: l10n.genreAnimation),
    (key: 'Romance', label: l10n.genreRomance),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MovieListCubit>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<MovieListCubit>().searchMovies(value);
      }
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {});
    _debounceTimer?.cancel();
    context.read<MovieListCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = CineplexColors.of(context);
    final statuses = _getStatuses(l10n);
    final genres = _getGenres(l10n);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.movies),
      ),
      body: BlocBuilder<MovieListCubit, MovieListState>(
        builder: (context, state) {
          final currentGenre = (state is MovieListLoaded) ? state.genre : null;
          final currentStatus = (state is MovieListLoaded) ? state.status : null;
          final movies = (state is MovieListLoaded) ? state.movies : [];
          final isLoading = state is MovieListLoading;
          final isError = state is MovieListError;
          final hasMore = (state is MovieListLoaded) && state.hasMore;
          final bottomPadding = MediaQuery.of(context).padding.bottom + 16;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l10n.movieSearchHint,
                      hintStyle: TextStyle(
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colors.textSecondary,
                                size: 18,
                              ),
                              onPressed: _onClearSearch,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Filter 1: Status Chips
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: statuses.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final item = statuses[index];
                    final isSelected = item.key == currentStatus;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(item.label),
                        selected: isSelected,
                        onSelected: (_) {
                          context.read<MovieListCubit>().filterByStatus(item.key);
                        },
                        selectedColor: colors.primary,
                        backgroundColor: colors.surfaceVariant,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : colors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: isSelected ? colors.primary : colors.borderSubtle,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Filter 2: Genre Chips
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final item = genres[index];
                    final isSelected = item.key == currentGenre;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(item.label),
                        selected: isSelected,
                        onSelected: (_) {
                          context.read<MovieListCubit>().filterByGenre(item.key);
                        },
                        selectedColor: colors.primary.withValues(alpha: 0.85),
                        backgroundColor: colors.surfaceVariant,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : colors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSelected ? colors.primary : colors.borderSubtle,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 4),

              // Movie List / Grid / Empty / Loading / Error
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<MovieListCubit>().loadMovies(),
                  color: colors.primary,
                  child: isError
                      ? AppErrorView(
                          message: state.message,
                          onRetry: () => context.read<MovieListCubit>().loadMovies(),
                        )
                      : isLoading && movies.isEmpty
                          ? GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: 6,
                              itemBuilder: (context, index) => const ShimmerSkeleton(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : movies.isEmpty
                              ? AppEmptyView(
                                  icon: (_searchController.text.isNotEmpty || currentStatus != null || currentGenre != null)
                                      ? Icons.search_off_rounded
                                      : Icons.movie_outlined,
                                  title: (_searchController.text.isNotEmpty || currentStatus != null || currentGenre != null)
                                      ? l10n.movieNoResults
                                      : l10n.noMovies,
                                )
                              : GridView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  controller: _scrollController,
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.65,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: movies.length + (hasMore ? 2 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= movies.length) {
                                      return const ShimmerSkeleton(
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                    }
                                    return StaggeredItem(
                                      index: index,
                                      child: MovieCard(movie: movies[index]),
                                    );
                                  },
                                ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
