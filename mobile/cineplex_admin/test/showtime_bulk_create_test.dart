import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class FakeShowtimeRepo implements ShowtimeManagementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  Map<String, dynamic>? lastSubmittedPayload;

  @override
  Future<Map<String, dynamic>> bulkCreateShowtime(
      Map<String, dynamic> data) async {
    lastSubmittedPayload = data;
    return {
      'successCount': 5,
      'failedCount': 1,
      'createdShowtimes': [],
      'failedSlots': [
        {'date': '07/10/2026, 09:00:00', 'reason': 'Phòng kẹt lịch'}
      ]
    };
  }
}

class FakeMovieRepo implements MovieManagementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<MovieModel>> getAllMovies({
    int page = 1,
    int pageSize = 100,
    String sortBy = 'id',
    List<String> genres = const [],
  }) async {
    return [
      const MovieModel(
        id: 1,
        title: 'Avatar 3',
        genre: 'Sci-Fi',
        durationMinutes: 180,
        status: 'ACTIVE',
      ),
    ];
  }
}

class FakeCinemaRepo implements CinemaManagementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<CinemaModel>> getAllCinemas() async {
    return [
      const CinemaModel(
        id: 10,
        name: 'Cineplex Landmark',
        address: 'Hà Nội',
        phone: '0901234567',
        email: 'landmark@cineplex.vn',
        status: 'ACTIVE',
      ),
    ];
  }

  @override
  Future<List<RoomModel>> getRoomsByCinemaId(int cinemaId) async {
    return [
      const RoomModel(
        id: 101,
        cinemaId: 10,
        name: 'Screen 1',
        roomType: 'STANDARD',
        status: 'ACTIVE',
        totalSeats: 100,
        rows: 10,
        columns: 10,
        isCouple: false,
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeShowtimeRepo fakeShowtimeRepo;
  late FakeMovieRepo fakeMovieRepo;
  late FakeCinemaRepo fakeCinemaRepo;
  late ShowtimeBulkCreateCubit cubit;

  setUp(() {
    fakeShowtimeRepo = FakeShowtimeRepo();
    fakeMovieRepo = FakeMovieRepo();
    fakeCinemaRepo = FakeCinemaRepo();
    cubit = ShowtimeBulkCreateCubit(
      fakeShowtimeRepo,
      fakeMovieRepo,
      fakeCinemaRepo,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ShowtimeBulkCreateCubit', () {
    test('loadDependencies loads movies and cinemas and emits DepsLoaded',
        () async {
      await cubit.loadDependencies();
      expect(cubit.state, isA<ShowtimeBulkCreateDepsLoaded>());
      final loaded = cubit.state as ShowtimeBulkCreateDepsLoaded;
      expect(loaded.movies.length, 1);
      expect(loaded.cinemas.length, 1);
    });

    test('submit calls repository and emits Success', () async {
      final payload = {
        'movieId': 1,
        'cinemaId': 10,
        'startDate': '2026-10-06',
        'endDate': '2026-10-07',
        'timeSlots': ['09:00', '14:00'],
        'format': 'FORMAT_2D',
      };
      await cubit.submit(payload);
      expect(cubit.state, isA<ShowtimeBulkCreateSuccess>());
      final success = cubit.state as ShowtimeBulkCreateSuccess;
      expect(success.successCount, 5);
      expect(success.failedCount, 1);
      expect(fakeShowtimeRepo.lastSubmittedPayload, payload);
    });
  });

  group('ShowtimeBulkCreateScreen', () {
    testWidgets('renders bulk create screen with all controls and preview',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('vi'),
          home: BlocProvider<ShowtimeBulkCreateCubit>.value(
            value: cubit,
            child: const ShowtimeBulkCreateScreen(),
          ),
        ),
      );

      // Pump to finish async loadDependencies
      await tester.pumpAndSettle();

      // Check title and labels
      expect(find.text('Tạo Lịch Chiếu Hàng Loạt'), findsOneWidget);
      expect(find.text('Khung giờ chiếu'), findsOneWidget);
      expect(find.text('Xem trước'), findsOneWidget);
      expect(find.text('Tạo lịch hàng loạt'), findsOneWidget);
    });
  });
}
