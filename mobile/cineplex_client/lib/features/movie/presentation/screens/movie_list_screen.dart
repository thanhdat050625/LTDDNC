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
  final List<String> _genres = ['All', 'Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi'];

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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

          return Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _genres.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final genre = _genres[index];
                    final isSelected = genre == 'All' ? currentGenre == null : genre == currentGenre;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(genre),
                        selected: isSelected,
                        onSelected: (val) {
                          context.read<MovieListCubit>().filterByGenre(genre == 'All' ? null : genre);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: isError
                    ? Center(child: Text((state).message))
                    : isLoading && movies.isEmpty
                        ? GridView.builder(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) => const ShimmerSkeleton(width: double.infinity, height: double.infinity),
                          )
                        : GridView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: movies.length + (hasMore ? 2 : 0),
                            itemBuilder: (context, index) {
                              if (index >= movies.length) {
                                return const ShimmerSkeleton(width: double.infinity, height: double.infinity);
                              }
                              return StaggeredItem(
                                index: index,
                                child: MovieCard(movie: movies[index]),
                              );
                            },
                          ),
              )
            ],
          );
        },
      ),
    );
  }
}
