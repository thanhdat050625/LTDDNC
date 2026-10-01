import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:mobile_shared/features/movies/presentation/widgets/movie_list_item.dart';

class MovieManagementScreen extends StatefulWidget {
  final Widget? drawer;
  const MovieManagementScreen({super.key, this.drawer});

  @override
  State<MovieManagementScreen> createState() => _MovieManagementScreenState();
}

class _MovieManagementScreenState extends State<MovieManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Dummy data for now. In reality, you'd use a Bloc/Cubit to fetch from MovieRepository.
  final List<MovieModel> _movies = [
    MovieModel(
      id: 1,
      title: 'Mai',
      genre: 'Tâm lý, Tình cảm',
      durationMinutes: 131,
      posterUrl: 'https://image.tmdb.org/t/p/w500/1.jpg',
      status: 'SHOWING',
    ),
    MovieModel(
      id: 2,
      title: 'Đào, Phở và Piano',
      genre: 'Lịch sử, Chiến tranh',
      durationMinutes: 120,
      posterUrl: 'https://image.tmdb.org/t/p/w500/2.jpg',
      status: 'SHOWING',
    ),
    MovieModel(
      id: 3,
      title: 'Dune: Part Two',
      genre: 'Hành động, Viễn tưởng',
      durationMinutes: 166,
      posterUrl: 'https://image.tmdb.org/t/p/w500/3.jpg',
      status: 'HIDDEN',
    ),
  ];

  @override
  void dispose() {
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
          // Navigate to add new movie form
          context.push('/movies/new');
        },
        backgroundColor: theme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: EdgeInsets.all(theme.spacingLg),
            color: theme.surface,
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _searchController,
                    hintText: 'Tìm kiếm tên phim...',
                    prefixIcon: LucideIcons.search,
                    onChanged: (val) {
                      // Trigger search
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
            child: ListView.separated(
              padding: EdgeInsets.all(theme.spacingLg),
              itemCount: _movies.length,
              separatorBuilder: (_, __) => SizedBox(height: theme.spacingMd),
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return MovieListItem(
                  movie: movie,
                  onTap: () {
                    // Navigate to detail
                    context.push('/movies/${movie.id}');
                  },
                  onEdit: () {
                    // Navigate to edit form
                    context.push('/movies/${movie.id}/edit');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
