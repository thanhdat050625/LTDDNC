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
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MovieListCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = CineplexColors.of(context);
    final genres = _getGenres(l10n);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.movies),
      ),
      body: BlocBuilder<MovieListCubit, MovieListState>(
        builder: (context, state) {
          final currentGenre = (state is MovieListLoaded) ? state.genre : null;
          final movies = (state is MovieListLoaded) ? state.movies : [];
          final isLoading = state is MovieListLoading;
          final isError = state is MovieListError;
          final hasMore = (state is MovieListLoaded) && state.hasMore;
          final bottomPadding = MediaQuery.of(context).padding.bottom + 16;

          return Column(
            children: [
              SizedBox(
                height: 50,
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
                        onSelected: (val) {
                          context.read<MovieListCubit>().filterByGenre(item.key);
                        },
                        selectedColor: colors.primary,
                        backgroundColor: colors.surfaceVariant,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : colors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? colors.primary : colors.borderSubtle,
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
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
                                  icon: Icons.movie_outlined,
                                  title: l10n.noMovies,
                                )
                              : GridView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  controller: _scrollController,
                                  padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
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
