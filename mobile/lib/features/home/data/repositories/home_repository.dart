import 'package:cineplex_mobile/core/api/dio_client.dart';
import 'package:cineplex_mobile/features/home/data/models/home_data_model.dart';
import 'package:cineplex_mobile/features/movie/data/models/movie_model.dart';

class HomeRepository {
  final DioClient _dio;
  HomeRepository(this._dio);

  Future<HomeDataModel> getHomeData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final mockMoviesNowShowing = [
      MovieModel(
        id: 1,
        title: 'Dune: Part Two',
        genre: 'Sci-Fi',
        durationMinutes: 166,
        releaseDate: DateTime(2024, 3, 1),
        posterUrl: 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2JGqqUT1O.jpg',
        status: 'NOW_SHOWING',
      ),
      MovieModel(
        id: 2,
        title: 'Kung Fu Panda 4',
        genre: 'Animation',
        durationMinutes: 94,
        releaseDate: DateTime(2024, 3, 8),
        posterUrl: 'https://image.tmdb.org/t/p/w500/kDp1vUBnMpe8ak4rjgl3cLELqjU.jpg',
        status: 'NOW_SHOWING',
      ),
      MovieModel(
        id: 3,
        title: 'Godzilla x Kong',
        genre: 'Action',
        durationMinutes: 115,
        releaseDate: DateTime(2024, 3, 29),
        posterUrl: 'https://image.tmdb.org/t/p/w500/tMefBSflR6PGQLvLuPEHZot49f.jpg',
        status: 'NOW_SHOWING',
      ),
    ];

    final mockMoviesComingSoon = [
      MovieModel(
        id: 6,
        title: 'Deadpool & Wolverine',
        genre: 'Action',
        durationMinutes: 127,
        releaseDate: DateTime(2024, 7, 26),
        posterUrl: 'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
        status: 'COMING_SOON',
      ),
    ];

    return HomeDataModel(
      nowShowing: mockMoviesNowShowing,
      comingSoon: mockMoviesComingSoon,
      activePromotions: const [
        PromotionModel(id: 1, code: 'SUMMER2024', description: 'Giảm 20% combo bắp nước'),
      ],
    );
  }
}
