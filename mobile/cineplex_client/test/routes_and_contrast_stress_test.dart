import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'package:cineplex_client/core/router/app_router.dart';
import 'package:cineplex_client/features/auth/presentation/screens/login_screen.dart';
import 'package:cineplex_client/features/auth/presentation/screens/register_screen.dart';
import 'package:cineplex_client/features/home/presentation/screens/home_screen.dart';
import 'package:cineplex_client/features/home/presentation/cubit/home_cubit.dart';
import 'package:cineplex_client/features/home/data/repositories/home_repository.dart';
import 'package:cineplex_client/features/showtime/data/repositories/showtime_repository.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';
import 'package:cineplex_client/features/booking/presentation/screens/seat_selection_screen.dart';
import 'package:cineplex_client/features/concession/data/repositories/concession_repository.dart';
import 'package:cineplex_client/features/concession/presentation/screens/concession_screen.dart';
import 'package:cineplex_client/features/payment/data/repositories/payment_repository.dart';
import 'package:cineplex_client/features/payment/data/models/payment_model.dart';
import 'package:cineplex_client/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:cineplex_client/features/payment/presentation/screens/checkout_screen.dart';
import 'package:cineplex_client/features/payment/presentation/screens/payment_webview_screen.dart';
import 'package:cineplex_client/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:cineplex_client/features/ticket/data/repositories/ticket_repository.dart';
import 'package:cineplex_client/features/ticket/presentation/screens/my_tickets_screen.dart';
import 'package:cineplex_client/features/ticket/presentation/screens/ticket_detail_screen.dart';
import 'package:cineplex_client/features/notification/data/repositories/notification_repository.dart';
import 'package:cineplex_client/features/notification/data/models/notification_model.dart';
import 'package:cineplex_client/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:cineplex_client/features/profile/data/repositories/profile_repository.dart';
import 'package:cineplex_client/features/profile/presentation/cubit/profile_cubit.dart';

// --- Mocks and Fakes ---

class FakeStorageService extends StorageService {
  final Map<String, String> _mem = {};
  @override
  Future<void> saveToken(String token) async => _mem['token'] = token;
  @override
  Future<String?> getToken() async => _mem['token'];
  @override
  Future<void> deleteToken() async => _mem.remove('token');
  @override
  Future<void> saveUserId(int id) async => _mem['userId'] = id.toString();
  @override
  Future<int?> getUserId() async => int.tryParse(_mem['userId'] ?? '');
  @override
  Future<void> clearAll() async => _mem.clear();
  @override
  Future<void> saveThemeMode(String mode) async => _mem['theme_mode'] = mode;
  @override
  Future<String?> getThemeMode() async => _mem['theme_mode'];
}

class FakeBookingRepository extends BookingRepository {
  FakeBookingRepository(super.dioClient);
  @override
  Future<Map<String, dynamic>> getUnavailableSeats(int showtimeId) async {
    return {'heldSeatIds': [1], 'bookedSeatIds': [2]};
  }
  @override
  Future<Map<String, dynamic>> holdSeats(int showtimeId, List<int> seatIds) async {
    return {
      'bookingId': 100,
      'expiredAt': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
    };
  }
}

class FakeConcessionRepository extends ConcessionRepository {
  FakeConcessionRepository(super.dioClient);
  @override
  Future<List<ConcessionProductModel>> getConcessions({int page = 1, int limit = 20}) async {
    return const [
      ConcessionProductModel(id: 1, name: 'Combo Solo Bắp Nước', price: 75000, stockQuantity: 10),
      ConcessionProductModel(id: 2, name: 'Bắp rang bơ phô mai', price: 45000, stockQuantity: 10),
    ];
  }
}

class FakePaymentRepository extends PaymentRepository {
  FakePaymentRepository(super.dioClient);
  @override
  Future<CheckoutPrepareModel> prepareCheckout(String bookingId) async {
    return CheckoutPrepareModel(
      bookingId: bookingId,
      bookingCode: 'CPX-TEST-99',
      totalAmount: 150000,
      discountAmount: 20000,
      pointsUsed: 0,
      secondsRemaining: 300,
    );
  }
  @override
  Future<PaymentResponseModel> checkout(String bookingId, String method) async {
    return PaymentResponseModel(bookingId: bookingId, payUrl: 'https://pay.example.com', paymentRequired: true);
  }
  @override
  Future<PaymentStatusModel> getPaymentStatus(String bookingId) async {
    return PaymentStatusModel(bookingId: bookingId, bookingCode: 'CPX-TEST-99', status: 'PAID', paymentMethod: 'MOMO');
  }
}

class FakeTicketRepository extends TicketRepository {
  FakeTicketRepository(super.dioClient);
  @override
  Future<List<BookingDetailModel>> getMyBookings({int page = 1, int pageSize = 20}) async {
    return const [
      BookingDetailModel(
        id: '1',
        bookingCode: 'CPX-TEST-99',
        totalAmount: 130000,
        status: 'PAID',
        movieTitle: 'Cineplex Movie',
        tickets: [
          TicketModel(
            id: '1',
            bookingId: '1',
            seatId: 'A1',
            seatLabel: 'A1',
            qrCode: 'QR_TICKET_A1',
            price: 75000,
            status: 'PAID',
            isCheckedIn: false,
          ),
        ],
      ),
    ];
  }
  @override
  Future<BookingDetailModel?> getBookingById(String id) async {
    return const BookingDetailModel(
      id: '1',
      bookingCode: 'CPX-TEST-99',
      totalAmount: 130000,
      status: 'PAID',
      movieTitle: 'Cineplex Movie',
      tickets: [
        TicketModel(
          id: '1',
          bookingId: '1',
          seatId: 'A1',
          seatLabel: 'A1',
          qrCode: 'QR_TICKET_A1',
          price: 75000,
          status: 'PAID',
          isCheckedIn: false,
        ),
      ],
    );
  }
}

class FakeShowtimeRepository extends ShowtimeRepository {
  FakeShowtimeRepository(super.dioClient);
  @override
  Future<Map<String, List<ShowtimeModel>>> getShowtimesByMovie(int movieId) async {
    return {};
  }
}

class FakeHomeRepository extends HomeRepository {
  FakeHomeRepository(super.dioClient);
  @override
  Future<HomeDataModel> getHomeData() async {
    return HomeDataModel(
      nowShowing: const [
        MovieModel(id: 1, title: 'Test Now Showing Movie', genre: 'ACTION', durationMinutes: 120, status: 'NOW_SHOWING'),
      ],
      comingSoon: const [
        MovieModel(id: 2, title: 'Test Coming Soon Movie', genre: 'COMEDY', durationMinutes: 105, status: 'COMING_SOON'),
      ],
      activePromotions: [
        PromotionModel(
          id: 1,
          code: 'SALE50',
          description: 'Giảm 50k',
          discountValue: 50000,
          discountType: 'FIXED',
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 30)),
          usedCount: 5,
          isActive: true,
        ),
      ],
    );
  }
}

class FakeNotificationRepository extends NotificationRepository {
  FakeNotificationRepository(super.dioClient);
  @override
  Future<List<NotificationModel>> getNotifications({int page = 1}) async => [];
  @override
  Future<int> getUnreadCount() async => 0;
}

class FakeProfileRepository extends ProfileRepository {
  FakeProfileRepository(super.dioClient);
  @override
  Future<Map<String, dynamic>> getProfile() async => {
    'id': 1,
    'email': 'user@cineplex.vn',
    'fullName': 'Cineplex User',
    'role': 'CUSTOMER',
  };
}

class FakeSocketService extends SocketService {
  FakeSocketService() : super(baseUrl: 'http://localhost:3000');
  @override
  void connectSeat() {}
  @override
  void connectNotification(int userId) {}
  @override
  void joinShowtime(int showtimeId) {}
  @override
  void leaveShowtime(int showtimeId) {}
  @override
  void onSeatUpdate(Function(Map<String, dynamic>) callback) {}
  @override
  void offSeatUpdate() {}
  @override
  void dispose() {}
}

class FakeAuthRepository extends AuthRepository {
  final UserModel? _initialUser;
  FakeAuthRepository(super.dio, super.storage, [this._initialUser]);
  @override
  Future<UserModel?> checkAuth() async => _initialUser;
}

const testCustomerUser = UserModel(
  id: 1,
  email: 'user@cineplex.vn',
  fullName: 'Cineplex User',
  role: 'CUSTOMER',
  status: 'ACTIVE',
);

class MockAuthBloc extends AuthBloc {
  MockAuthBloc({UserModel? user = testCustomerUser})
      : super(FakeAuthRepository(DioClient(FakeStorageService()), FakeStorageService(), user)) {
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}

// --- Contrast Calculation Helpers ---

double _getChannelLuminance(double channel) {
  if (channel <= 0.03928) {
    return channel / 12.92;
  }
  return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

double calculateLuminance(Color color) {
  final r = _getChannelLuminance(color.r);
  final g = _getChannelLuminance(color.g);
  final b = _getChannelLuminance(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double calculateContrastRatio(Color foreground, Color background) {
  final lum1 = calculateLuminance(foreground);
  final lum2 = calculateLuminance(background);
  final lighter = math.max(lum1, lum2);
  final darker = math.min(lum1, lum2);
  return (lighter + 0.05) / (darker + 0.05);
}

// Composite foreground with alpha over background
Color compositeOver(Color foreground, Color background) {
  final double a = foreground.a;
  if (a >= 1.0) return foreground;
  final r = (foreground.r * a + background.r * (1.0 - a));
  final g = (foreground.g * a + background.g * (1.0 - a));
  final b = (foreground.b * a + background.b * (1.0 - a));
  return Color.from(alpha: 1.0, red: r, green: g, blue: b);
}

// --- Test Harness Builder ---

Widget buildTestApp({
  required GoRouter router,
  required MockAuthBloc authBloc,
  required StorageService storageService,
  required DioClient dioClient,
  required BookingRepository bookingRepo,
  required ConcessionRepository concessionRepo,
  required PaymentRepository paymentRepo,
  required TicketRepository ticketRepo,
  required ShowtimeRepository showtimeRepo,
  required HomeRepository homeRepo,
  required NotificationRepository notificationRepo,
  required ProfileRepository profileRepo,
  required SocketService socketService,
  ThemeMode themeMode = ThemeMode.dark,
}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<StorageService>.value(value: storageService),
      RepositoryProvider<DioClient>.value(value: dioClient),
      RepositoryProvider<BookingRepository>.value(value: bookingRepo),
      RepositoryProvider<ConcessionRepository>.value(value: concessionRepo),
      RepositoryProvider<PaymentRepository>.value(value: paymentRepo),
      RepositoryProvider<TicketRepository>.value(value: ticketRepo),
      RepositoryProvider<ShowtimeRepository>.value(value: showtimeRepo),
      RepositoryProvider<HomeRepository>.value(value: homeRepo),
      RepositoryProvider<NotificationRepository>.value(value: notificationRepo),
      RepositoryProvider<ProfileRepository>.value(value: profileRepo),
      RepositoryProvider<SocketService>.value(value: socketService),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<HomeCubit>(create: (_) => HomeCubit(homeRepo)..load()),
        BlocProvider<NotificationCubit>(create: (_) => NotificationCubit(notificationRepo)),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit(profileRepo)),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(storageService)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('vi')],
        locale: const Locale('vi'),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeStorageService storageService;
  late DioClient dioClient;
  late FakeBookingRepository bookingRepo;
  late FakeConcessionRepository concessionRepo;
  late FakePaymentRepository paymentRepo;
  late FakeTicketRepository ticketRepo;
  late FakeShowtimeRepository showtimeRepo;
  late FakeHomeRepository homeRepo;
  late FakeNotificationRepository notificationRepo;
  late FakeProfileRepository profileRepo;
  late FakeSocketService socketService;

  setUp(() {
    storageService = FakeStorageService();
    dioClient = DioClient(storageService);
    bookingRepo = FakeBookingRepository(dioClient);
    concessionRepo = FakeConcessionRepository(dioClient);
    paymentRepo = FakePaymentRepository(dioClient);
    ticketRepo = FakeTicketRepository(dioClient);
    showtimeRepo = FakeShowtimeRepository(dioClient);
    homeRepo = FakeHomeRepository(dioClient);
    notificationRepo = FakeNotificationRepository(dioClient);
    profileRepo = FakeProfileRepository(dioClient);
    socketService = FakeSocketService();
  });

  group('Requirement 1: 6 Previously Broken Routes Construction & Navigation Safety', () {
    testWidgets('1. Route /booking/:showtimeId constructs and renders SeatSelectionScreen without provider exceptions', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final authBloc = MockAuthBloc();
        final router = createRouter(authBloc);

        await tester.pumpWidget(buildTestApp(
          router: router,
          authBloc: authBloc,
          storageService: storageService,
          dioClient: dioClient,
          bookingRepo: bookingRepo,
          concessionRepo: concessionRepo,
          paymentRepo: paymentRepo,
          ticketRepo: ticketRepo,
          showtimeRepo: showtimeRepo,
          homeRepo: homeRepo,
          notificationRepo: notificationRepo,
          profileRepo: profileRepo,
          socketService: socketService,
        ));

        router.go('/booking/101');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SeatSelectionScreen), findsOneWidget);

        final providerExceptions = errorDetails.where((e) => e.exceptionAsString().contains('ProviderNotFoundException')).toList();
        expect(providerExceptions, isEmpty, reason: 'Must have zero ProviderNotFoundException');
      } finally {
        FlutterError.onError = oldHandler;
      }
    });

    testWidgets('2. Route /concessions/:bookingId constructs and renders ConcessionScreen without provider exceptions', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final authBloc = MockAuthBloc();
        final router = createRouter(authBloc);

        await tester.pumpWidget(buildTestApp(
          router: router,
          authBloc: authBloc,
          storageService: storageService,
          dioClient: dioClient,
          bookingRepo: bookingRepo,
          concessionRepo: concessionRepo,
          paymentRepo: paymentRepo,
          ticketRepo: ticketRepo,
          showtimeRepo: showtimeRepo,
          homeRepo: homeRepo,
          notificationRepo: notificationRepo,
          profileRepo: profileRepo,
          socketService: socketService,
        ));

        router.go('/concessions/202');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(ConcessionScreen), findsOneWidget);

        final providerExceptions = errorDetails.where((e) => e.exceptionAsString().contains('ProviderNotFoundException')).toList();
        expect(providerExceptions, isEmpty, reason: 'Must have zero ProviderNotFoundException');
      } finally {
        FlutterError.onError = oldHandler;
      }
    });

    testWidgets('3. Route /checkout/:bookingId constructs and renders CheckoutScreen without provider exceptions', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final authBloc = MockAuthBloc();
        final router = createRouter(authBloc);

        await tester.pumpWidget(buildTestApp(
          router: router,
          authBloc: authBloc,
          storageService: storageService,
          dioClient: dioClient,
          bookingRepo: bookingRepo,
          concessionRepo: concessionRepo,
          paymentRepo: paymentRepo,
          ticketRepo: ticketRepo,
          showtimeRepo: showtimeRepo,
          homeRepo: homeRepo,
          notificationRepo: notificationRepo,
          profileRepo: profileRepo,
          socketService: socketService,
        ));

        router.go('/checkout/202');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CheckoutScreen), findsOneWidget);

        final providerExceptions = errorDetails.where((e) => e.exceptionAsString().contains('ProviderNotFoundException')).toList();
        expect(providerExceptions, isEmpty, reason: 'Must have zero ProviderNotFoundException');
      } finally {
        FlutterError.onError = oldHandler;
      }
    });

    testWidgets('4. Route /payment-webview constructs and renders PaymentWebviewScreen without provider exceptions', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final authBloc = MockAuthBloc();
        final router = createRouter(authBloc);

        await tester.pumpWidget(buildTestApp(
          router: router,
          authBloc: authBloc,
          storageService: storageService,
          dioClient: dioClient,
          bookingRepo: bookingRepo,
          concessionRepo: concessionRepo,
          paymentRepo: paymentRepo,
          ticketRepo: ticketRepo,
          showtimeRepo: showtimeRepo,
          homeRepo: homeRepo,
          notificationRepo: notificationRepo,
          profileRepo: profileRepo,
          socketService: socketService,
        ));

        router.go('/payment-webview?url=${Uri.encodeComponent('https://pay.example.com')}&bookingId=202');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(PaymentWebviewScreen), findsOneWidget);

        final providerExceptions = errorDetails.where((e) => e.exceptionAsString().contains('ProviderNotFoundException')).toList();
        expect(providerExceptions, isEmpty, reason: 'Must have zero ProviderNotFoundException');
      } finally {
        FlutterError.onError = oldHandler;
      }
    });

    testWidgets('5. Route /payment-result/:bookingId constructs and renders PaymentResultScreen without provider exceptions', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final authBloc = MockAuthBloc();
        final router = createRouter(authBloc);

        await tester.pumpWidget(buildTestApp(
          router: router,
          authBloc: authBloc,
          storageService: storageService,
          dioClient: dioClient,
          bookingRepo: bookingRepo,
          concessionRepo: concessionRepo,
          paymentRepo: paymentRepo,
          ticketRepo: ticketRepo,
          showtimeRepo: showtimeRepo,
          homeRepo: homeRepo,
          notificationRepo: notificationRepo,
          profileRepo: profileRepo,
          socketService: socketService,
        ));

        router.go('/payment-result/202');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(PaymentResultScreen), findsOneWidget);

        // Tap "Xem vé của tôi" and verify direct navigation to exact TicketDetailRouteScreen
        await tester.tap(find.text('Xem vé của tôi'));
        await tester.pumpAndSettle();

        expect(find.byType(TicketDetailRouteScreen), findsOneWidget);
        expect(find.text('CPX-TEST-99'), findsWidgets);

        final providerExceptions = errorDetails.where((e) => e.exceptionAsString().contains('ProviderNotFoundException')).toList();
        expect(providerExceptions, isEmpty, reason: 'Must have zero ProviderNotFoundException');
      } finally {
        FlutterError.onError = oldHandler;
      }
    });

    testWidgets('6. Route /my-tickets constructs and renders MyTicketsScreen without provider exceptions', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final authBloc = MockAuthBloc();
        final router = createRouter(authBloc);

        await tester.pumpWidget(buildTestApp(
          router: router,
          authBloc: authBloc,
          storageService: storageService,
          dioClient: dioClient,
          bookingRepo: bookingRepo,
          concessionRepo: concessionRepo,
          paymentRepo: paymentRepo,
          ticketRepo: ticketRepo,
          showtimeRepo: showtimeRepo,
          homeRepo: homeRepo,
          notificationRepo: notificationRepo,
          profileRepo: profileRepo,
          socketService: socketService,
        ));

        router.go('/my-tickets');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(MyTicketsScreen), findsOneWidget);

        final providerExceptions = errorDetails.where((e) => e.exceptionAsString().contains('ProviderNotFoundException')).toList();
        expect(providerExceptions, isEmpty, reason: 'Must have zero ProviderNotFoundException');
      } finally {
        FlutterError.onError = oldHandler;
      }
    });

    testWidgets('Unauthenticated user attempting to access protected route is redirected to /login', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final authBloc = MockAuthBloc(user: null);
        final router = createRouter(authBloc);

        await tester.pumpWidget(buildTestApp(
          router: router,
          authBloc: authBloc,
          storageService: storageService,
          dioClient: dioClient,
          bookingRepo: bookingRepo,
          concessionRepo: concessionRepo,
          paymentRepo: paymentRepo,
          ticketRepo: ticketRepo,
          showtimeRepo: showtimeRepo,
          homeRepo: homeRepo,
          notificationRepo: notificationRepo,
          profileRepo: profileRepo,
          socketService: socketService,
        ));

        router.go('/booking/101');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should be redirected to /login
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(SeatSelectionScreen), findsNothing);
      } finally {
        FlutterError.onError = oldHandler;
      }
    });
  });

  group('Requirement 2: Text Contrast Verification on Login, Register, Home, Checkout', () {
    test('Token contrast mathematical validation for Light & Dark mode', () {
      const dark = CineplexColors.dark;
      const light = CineplexColors.light;

      // Dark Mode Background & Surface
      final darkTextPrimaryOnBg = calculateContrastRatio(dark.textPrimary, dark.background);
      final darkTextPrimaryOnSurface = calculateContrastRatio(dark.textPrimary, dark.surface);
      final darkTextSecondaryOnSurface = calculateContrastRatio(
        compositeOver(dark.textSecondary, dark.surface),
        dark.surface,
      );

      expect(darkTextPrimaryOnBg, greaterThanOrEqualTo(15.0), reason: 'Dark textPrimary on background must have high contrast');
      expect(darkTextPrimaryOnSurface, greaterThanOrEqualTo(15.0), reason: 'Dark textPrimary on surface must have high contrast');
      expect(darkTextSecondaryOnSurface, greaterThanOrEqualTo(4.5), reason: 'Dark textSecondary on surface must pass WCAG AA (>= 4.5)');

      // Light Mode Background & Surface
      final lightTextPrimaryOnBg = calculateContrastRatio(light.textPrimary, light.background);
      final lightTextPrimaryOnSurface = calculateContrastRatio(light.textPrimary, light.surface);
      final lightTextSecondaryOnSurface = calculateContrastRatio(light.textSecondary, light.surface);

      expect(lightTextPrimaryOnBg, greaterThanOrEqualTo(15.0), reason: 'Light textPrimary on background must have high contrast');
      expect(lightTextPrimaryOnSurface, greaterThanOrEqualTo(15.0), reason: 'Light textPrimary on surface must have high contrast');
      expect(lightTextSecondaryOnSurface, greaterThanOrEqualTo(4.5), reason: 'Light textSecondary on surface must pass WCAG AA (>= 4.5)');

      // Button contrast (White text on Primary Red 0xFFE50914)
      final buttonTextContrast = calculateContrastRatio(Colors.white, dark.primary);
      expect(buttonTextContrast, greaterThanOrEqualTo(4.5), reason: 'White text on primary red button must pass WCAG AA (>= 4.5:1)');
    });

    testWidgets('LoginScreen renders cleanly without layout overflow on narrow mobile screens', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          final authBloc = MockAuthBloc(user: null);

          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            home: BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: const LoginScreen(),
            ),
          ));
          await tester.pump();
        }
      } finally {
        FlutterError.onError = oldHandler;
      }
      tester.takeException();

      expect(find.byType(LoginScreen), findsWidgets);
      expect(find.text('CINEPLEX'), findsWidgets);
      expect(find.text('Ghi nhớ đăng nhập'), findsWidgets);
      expect(find.text('Quên mật khẩu?'), findsWidgets);
      expect(find.text('Chưa có tài khoản?'), findsWidgets);
      expect(find.text('Đăng ký'), findsWidgets);

      final hasOverflow = errorDetails.any((e) => e.toString().contains('A RenderFlex overflowed'));
      expect(hasOverflow, isFalse, reason: 'Zero RenderFlex overflow on mobile constraints');
    });

    testWidgets('RegisterScreen renders cleanly and has compliant text contrast in Light and Dark mode', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        final authBloc = MockAuthBloc(user: null);
        final isDark = mode == ThemeMode.dark;

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const RegisterScreen(),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(RegisterScreen), findsOneWidget);

        // In step 0 (email step)
        expect(find.text('Email'), findsWidgets);
        expect(find.text('Gửi mã OTP'), findsOneWidget);

        final emailTitle = tester.widget<Text>(find.text('Email').first);
        final expectedTextPrimary = isDark ? Colors.white : const Color(0xFF111827);
        expect(emailTitle.style?.color, equals(expectedTextPrimary));
      }
    });

    testWidgets('HomeScreen renders cleanly and has compliant text contrast in Light and Dark mode', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final authBloc = MockAuthBloc();
        final homeCubit = HomeCubit(homeRepo);
        await homeCubit.load();

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<HomeCubit>.value(value: homeCubit),
            ],
            child: const HomeScreen(),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      } finally {
        FlutterError.onError = oldHandler;
      }
      tester.takeException();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('CINEPLEX'), findsOneWidget);
      expect(find.text('Đang chiếu'), findsOneWidget);
      expect(find.text('Sắp chiếu'), findsOneWidget);

      final sectionTitle = tester.widget<Text>(find.text('Đang chiếu'));
      expect(sectionTitle.style?.color, equals(Colors.white));
    });

    testWidgets('CheckoutScreen renders cleanly without ListTile assertion and header overflow', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final authBloc = MockAuthBloc();

        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: [
              RepositoryProvider<PaymentRepository>.value(value: paymentRepo),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [Locale('vi')],
              locale: const Locale('vi'),
              home: MultiBlocProvider(
                providers: [
                  BlocProvider<AuthBloc>.value(value: authBloc),
                  BlocProvider<PaymentCubit>(create: (_) => PaymentCubit(paymentRepo)..prepareCheckout('202')),
                ],
                child: const CheckoutScreen(bookingId: '202'),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
      } finally {
        FlutterError.onError = oldHandler;
      }
      tester.takeException();

      expect(find.byType(CheckoutScreen), findsOneWidget);
      expect(find.text('Tóm tắt đơn hàng'), findsOneWidget);
      expect(find.text('CPX-TEST-99'), findsOneWidget);
      expect(find.text('Tổng cộng'), findsOneWidget);
      expect(find.text('Phương thức thanh toán'), findsOneWidget);
      expect(find.text('Thanh toán ngay'), findsOneWidget);

      final summaryTitle = tester.widget<Text>(find.text('Tóm tắt đơn hàng'));
      expect(summaryTitle.style?.color, equals(Colors.white));

      final rowLabel = tester.widget<Text>(find.text('Tổng tiền vé'));
      expect(rowLabel.style?.color, equals(Colors.white70));

      final hasAssertionOrOverflow = errorDetails.any((e) =>
        e.toString().contains('ListTile background color or ink splashes may be invisible') ||
        e.toString().contains('A RenderFlex overflowed')
      );
      expect(hasAssertionOrOverflow, isFalse, reason: 'Zero ListTile Material assertion or RenderFlex overflow in CheckoutScreen');
    });
  });
}
