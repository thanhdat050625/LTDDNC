import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MockMovieRepository implements MovieManagementRepository {
  final List<MovieModel> movies;
  MockMovieRepository(this.movies);

  @override
  Future<List<MovieModel>> getAllMovies({
    int page = 1,
    int pageSize = 50,
    String sortBy = 'id',
    List<String> genres = const [],
  }) async => movies;

  @override
  Future<MovieModel> getMovieDetail(int id) async =>
      movies.firstWhere((m) => m.id == id);

  @override
  Future<MovieModel> createMovie(
    Map<String, dynamic> data,
    String? posterPath,
  ) async => throw UnimplementedError();

  @override
  Future<MovieModel> updateMovie(
    int id,
    Map<String, dynamic> data,
    String? posterPath,
  ) async => throw UnimplementedError();
}

void main() {
  group('MovieManagementScreen Layout & FAB Overlap Tests', () {
    final sampleMovies = [
      const MovieModel(
        id: 1,
        title: 'Avatar: The Way of Water',
        genre: 'Sci-Fi',
        durationMinutes: 192,
        status: 'NOW_SHOWING',
      ),
      const MovieModel(
        id: 2,
        title: 'Dune: Part Two',
        genre: 'Adventure',
        durationMinutes: 166,
        status: 'NOW_SHOWING',
      ),
      const MovieModel(
        id: 3,
        title: 'Deadpool & Wolverine',
        genre: 'Action',
        durationMinutes: 127,
        status: 'COMING_SOON',
      ),
      const MovieModel(
        id: 4,
        title: 'Oppenheimer',
        genre: 'Drama',
        durationMinutes: 180,
        status: 'STOPPED',
      ),
    ];

    Widget createScreen(List<MovieModel> movies) {
      final repo = MockMovieRepository(movies);
      final cubit = MovieManagementCubit(repo);

      return MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('vi')],
        locale: const Locale('vi'),
        home: BlocProvider<MovieManagementCubit>.value(
          value: cubit,
          child: const MovieManagementScreen(),
        ),
      );
    }

    testWidgets(
      'TC-MOV-001: 4 statistic cards nằm TRÊN thanh tìm kiếm (Header -> 4 KPI -> Search -> Movie list)',
      (tester) async {
        await tester.pumpWidget(createScreen(sampleMovies));
        await tester.pumpAndSettle();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(MovieManagementScreen)),
        )!;

        // Find KPI cards GridView and Search Bar
        final kpiTotalCard = find.text(l10n.movieTotal);
        final searchBar = find.byType(AppTextField);

        expect(kpiTotalCard, findsOneWidget);
        expect(searchBar, findsOneWidget);

        final kpiY = tester.getTopLeft(kpiTotalCard).dy;
        final searchY = tester.getTopLeft(searchBar).dy;

        // Verify KPI cards are above the Search bar
        expect(
          kpiY < searchY,
          isTrue,
          reason:
              'KPI cards (y=$kpiY) must be located above Search bar (y=$searchY)',
        );
      },
    );

    testWidgets(
      'TC-MOV-002: Search movie hoạt động chính xác với dữ liệu phim',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createScreen(sampleMovies));
        await tester.pumpAndSettle();

        expect(find.text('Avatar: The Way of Water'), findsOneWidget);
        expect(find.text('Dune: Part Two'), findsOneWidget);
        expect(find.text('Oppenheimer'), findsOneWidget);

        // Search for "Avatar"
        final searchField = find.byType(AppTextField);
        await tester.enterText(searchField, 'Avatar');
        // Wait for debounce (400ms)
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Avatar found, others filtered out
        expect(find.text('Avatar: The Way of Water'), findsOneWidget);
        expect(find.text('Dune: Part Two'), findsNothing);
        expect(find.text('Oppenheimer'), findsNothing);
      },
    );

    testWidgets(
      'TC-MOV-003 & TC-MOV-004: ListView có bottom padding 96px để FAB không che Edit action phim cuối',
      (tester) async {
        await tester.pumpWidget(createScreen(sampleMovies));
        await tester.pumpAndSettle();

        // Find ListView
        final listViewFinder = find.byType(ListView);
        expect(listViewFinder, findsOneWidget);

        final listView = tester.widget<ListView>(listViewFinder);
        final padding = listView.padding as EdgeInsets;

        // Verify bottom padding >= 96px for FAB clearance
        expect(
          padding.bottom >= 96,
          isTrue,
          reason:
              'ListView bottom padding (${padding.bottom}) must be >= 96 to clear the FloatingActionButton',
        );

        // Verify FAB exists
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Verify Edit icon exists for items
        expect(find.byIcon(LucideIcons.edit3), findsWidgets);
      },
    );
  });
}
