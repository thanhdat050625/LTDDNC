import 'package:cineplex_mobile/core/api/dio_client.dart';
import 'package:cineplex_mobile/features/movie/data/models/movie_model.dart';

class MovieRepository {
  final DioClient _dio;
  MovieRepository(this._dio);

  final List<MovieModel> _mockMovies = [
    MovieModel(
      id: 1,
      title: 'Dune: Part Two',
      genre: 'Sci-Fi',
      durationMinutes: 166,
      director: 'Denis Villeneuve',
      cast: 'Timothée Chalamet, Zendaya',
      releaseDate: DateTime(2024, 3, 1),
      description: 'Paul Atreides unites with Chani and the Fremen while on a warpath of revenge against the conspirators who destroyed his family.',
      language: 'English',
      ageLimit: 13,
      posterUrl: 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2JGqqUT1O.jpg',
      status: 'NOW_SHOWING',
    ),
    MovieModel(
      id: 2,
      title: 'Kung Fu Panda 4',
      genre: 'Animation',
      durationMinutes: 94,
      director: 'Mike Mitchell',
      cast: 'Jack Black, Awkwafina',
      releaseDate: DateTime(2024, 3, 8),
      description: 'After Po is tapped to become the Spiritual Leader of the Valley of Peace, he needs to find and train a new Dragon Warrior.',
      language: 'English',
      ageLimit: 0,
      posterUrl: 'https://image.tmdb.org/t/p/w500/kDp1vUBnMpe8ak4rjgl3cLELqjU.jpg',
      status: 'NOW_SHOWING',
    ),
    MovieModel(
      id: 3,
      title: 'Godzilla x Kong: The New Empire',
      genre: 'Action',
      durationMinutes: 115,
      director: 'Adam Wingard',
      cast: 'Rebecca Hall, Brian Tyree Henry',
      releaseDate: DateTime(2024, 3, 29),
      description: 'Following their explosive showdown, Godzilla and Kong must reunite against a colossal undiscovered threat hidden within our world.',
      language: 'English',
      ageLimit: 13,
      posterUrl: 'https://image.tmdb.org/t/p/w500/tMefBSflR6PGQLvLuPEHZot49f.jpg',
      status: 'NOW_SHOWING',
    ),
    MovieModel(
      id: 4,
      title: 'Civil War',
      genre: 'Action',
      durationMinutes: 109,
      director: 'Alex Garland',
      cast: 'Kirsten Dunst, Wagner Moura',
      releaseDate: DateTime(2024, 4, 12),
      description: 'A journey across a dystopian future America, following a team of military-embedded journalists as they race against time.',
      language: 'English',
      ageLimit: 16,
      posterUrl: 'https://image.tmdb.org/t/p/w500/sh7Rg8Er3tFcN9BpKIPOMvALgZd.jpg',
      status: 'NOW_SHOWING',
    ),
    MovieModel(
      id: 5,
      title: 'Inside Out 2',
      genre: 'Animation',
      durationMinutes: 100,
      director: 'Kelsey Mann',
      cast: 'Amy Poehler, Phyllis Smith',
      releaseDate: DateTime(2024, 6, 14),
      description: 'Follows Riley, in her teenage years, encountering new emotions.',
      language: 'English',
      ageLimit: 0,
      posterUrl: 'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
      status: 'NOW_SHOWING',
    ),
    MovieModel(
      id: 6,
      title: 'Deadpool & Wolverine',
      genre: 'Action',
      durationMinutes: 127,
      director: 'Shawn Levy',
      cast: 'Ryan Reynolds, Hugh Jackman',
      releaseDate: DateTime(2024, 7, 26),
      description: 'Wolverine is recovering from his injuries when he crosses paths with the loudmouth Deadpool. They team up to defeat a common enemy.',
      language: 'English',
      ageLimit: 18,
      posterUrl: 'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
      status: 'COMING_SOON',
    ),
  ];

  Future<({List<MovieModel> movies, int totalPages})> getAllMovies(
      int page, int pageSize, {String? genre}) async {
    // Giả lập delay API 1.5 giây để thấy rõ hiệu ứng Shimmer Skeleton
    await Future.delayed(const Duration(milliseconds: 1500));
    
    List<MovieModel> filtered = _mockMovies;
    if (genre != null && genre.isNotEmpty && genre != 'All') {
      filtered = _mockMovies.where((m) => m.genre == genre).toList();
    }
    
    return (movies: filtered, totalPages: 1);
  }

  Future<MovieModel> getMovieDetail(int id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockMovies.firstWhere((m) => m.id == id, orElse: () => _mockMovies.first);
  }
}
