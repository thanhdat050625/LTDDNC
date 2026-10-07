import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'package:cineplex_client/features/auth/presentation/screens/login_screen.dart';
import 'package:cineplex_client/features/auth/presentation/screens/register_screen.dart';
import 'package:cineplex_client/features/home/presentation/screens/home_screen.dart';
import 'package:cineplex_client/features/home/presentation/cubit/home_cubit.dart';
import 'package:cineplex_client/features/home/data/repositories/home_repository.dart';
import 'package:cineplex_client/features/payment/presentation/screens/checkout_screen.dart';
import 'package:cineplex_client/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:cineplex_client/features/payment/data/repositories/payment_repository.dart';
import 'package:cineplex_client/features/payment/data/models/payment_model.dart';
import 'package:cineplex_client/features/ticket/presentation/screens/my_tickets_screen.dart';
import 'package:cineplex_client/features/ticket/presentation/cubit/my_tickets_cubit.dart';
import 'package:cineplex_client/features/ticket/data/repositories/ticket_repository.dart';

// ============================================================================
// ISO/IEC 61966-2-1 WCAG 2.1 Luminance and Contrast Mathematical Formulae
// ============================================================================

double _channelToLuminance(double channel) {
  if (channel <= 0.03928) {
    return channel / 12.92;
  }
  return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

double computeRelativeLuminance(Color color) {
  final r = _channelToLuminance(color.r);
  final g = _channelToLuminance(color.g);
  final b = _channelToLuminance(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double computeContrast(Color fg, Color bg) {
  final l1 = computeRelativeLuminance(fg);
  final l2 = computeRelativeLuminance(bg);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

// ============================================================================
// Mocks and Fakes for Client App
// ============================================================================

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

class FakeHomeRepo extends HomeRepository {
  FakeHomeRepo(super.dioClient);
  @override
  Future<HomeDataModel> getHomeData() async {
    return HomeDataModel(
      nowShowing: const [
        MovieModel(id: 1, title: 'Đào, Phở và Piano', genre: 'DRAMA', durationMinutes: 100, status: 'NOW_SHOWING'),
        MovieModel(id: 2, title: 'Mai - Trấn Thành', genre: 'ROMANCE', durationMinutes: 131, status: 'NOW_SHOWING'),
      ],
      comingSoon: const [
        MovieModel(id: 3, title: 'Kung Fu Panda 4', genre: 'ANIMATION', durationMinutes: 94, status: 'COMING_SOON'),
      ],
      activePromotions: [
        PromotionModel(
          id: 1,
          code: 'VICTORY50',
          description: 'Giảm giá 50.000đ cho mọi đơn vé trên app Cineplex',
          discountValue: 50000,
          discountType: 'FIXED',
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 30)),
          usedCount: 0,
          isActive: true,
        ),
      ],
    );
  }
}

class FakePaymentRepo extends PaymentRepository {
  FakePaymentRepo(super.dioClient);
  @override
  Future<CheckoutPrepareModel> prepareCheckout(String bookingId) async {
    return const CheckoutPrepareModel(
      bookingId: '202',
      bookingCode: 'CPX-M5-VICTORY',
      totalAmount: 160000,
      discountAmount: 20000,
      pointsUsed: 0,
      secondsRemaining: 300,
    );
  }
}

class FakeTicketRepo extends TicketRepository {
  FakeTicketRepo(super.dioClient);
  @override
  Future<List<BookingDetailModel>> getMyBookings({int page = 1, int pageSize = 20}) async {
    return const [
      BookingDetailModel(
        id: '1',
        bookingCode: 'CPX-M5-VICTORY',
        totalAmount: 140000,
        status: 'PAID',
        movieTitle: 'Đào, Phở và Piano',
        cinemaName: 'Cineplex Vincom Đồng Khởi',
        roomName: 'Phòng VIP 01',
        tickets: [
          TicketModel(
            id: '1',
            bookingId: '1',
            seatId: 'F5',
            seatLabel: 'F5',
            qrCode: 'QR_F5_M5',
            price: 70000,
            status: 'PAID',
            isCheckedIn: false,
          ),
          TicketModel(
            id: '2',
            bookingId: '1',
            seatId: 'F6',
            seatLabel: 'F6',
            qrCode: 'QR_F6_M5',
            price: 70000,
            status: 'PAID',
            isCheckedIn: false,
          ),
        ],
      ),
    ];
  }
}

class MockAuthBloc extends AuthBloc {
  MockAuthBloc() : super(AuthRepository(DioClient(FakeStorageService()), FakeStorageService())) {
    emit(const AuthAuthenticated(UserModel(
      id: 1,
      email: 'client.victory@cineplex.vn',
      fullName: 'Khách Hàng Chiến Thắng',
      role: 'CUSTOMER',
      status: 'ACTIVE',
    )));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final storage = FakeStorageService();
  final dio = DioClient(storage);
  final homeRepo = FakeHomeRepo(dio);
  final paymentRepo = FakePaymentRepo(dio);
  final ticketRepo = FakeTicketRepo(dio);

  group('Milestone 5 Grand Challenger: Client Screen Viewport Stress (320px, 360px, 390px)', () {
    const viewports = [
      Size(320, 640), // iPhone SE 1st gen
      Size(360, 800), // Compact Android
      Size(390, 844), // iPhone 12/13/14
    ];

    Widget buildClientHarness({
      required Widget child,
      ThemeMode mode = ThemeMode.dark,
    }) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<HomeRepository>.value(value: homeRepo),
          RepositoryProvider<PaymentRepository>.value(value: paymentRepo),
          RepositoryProvider<TicketRepository>.value(value: ticketRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => MockAuthBloc()),
            BlocProvider<HomeCubit>(create: (_) => HomeCubit(homeRepo)..load()),
            BlocProvider<PaymentCubit>(create: (_) => PaymentCubit(paymentRepo)..prepareCheckout('202')),
            BlocProvider<MyTicketsCubit>(create: (_) => MyTicketsCubit(ticketRepo)..loadMyTickets()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('vi'),
            home: child,
          ),
        ),
      );
    }

    for (final size in viewports) {
      testWidgets('Client LoginScreen zero overflow on ${size.width}px in Light and Dark', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(buildClientHarness(mode: mode, child: const LoginScreen()));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          }
        } finally {
          FlutterError.onError = oldOnError;
        }

        final overflows = errors.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
        expect(overflows, isEmpty, reason: 'LoginScreen zero overflow on ${size.width}px');
      });

      testWidgets('Client RegisterScreen zero overflow on ${size.width}px in Light and Dark', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(buildClientHarness(mode: mode, child: const RegisterScreen()));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          }
        } finally {
          FlutterError.onError = oldOnError;
        }

        final overflows = errors.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
        expect(overflows, isEmpty, reason: 'RegisterScreen zero overflow on ${size.width}px');
      });

      testWidgets('Client HomeScreen zero overflow on ${size.width}px in Light and Dark', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(buildClientHarness(mode: mode, child: const HomeScreen()));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          }
        } finally {
          FlutterError.onError = oldOnError;
        }

        final overflows = errors.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
        expect(overflows, isEmpty, reason: 'HomeScreen zero overflow on ${size.width}px');
      });

      testWidgets('Client CheckoutScreen zero overflow on ${size.width}px in Light and Dark', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(buildClientHarness(mode: mode, child: const CheckoutScreen(bookingId: '202')));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          }
        } finally {
          FlutterError.onError = oldOnError;
        }

        final overflows = errors.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
        expect(overflows, isEmpty, reason: 'CheckoutScreen zero overflow on ${size.width}px');
      });

      testWidgets('Client MyTicketsScreen zero overflow on ${size.width}px in Light and Dark', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(buildClientHarness(mode: mode, child: const MyTicketsScreen()));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          }
        } finally {
          FlutterError.onError = oldOnError;
        }

        final overflows = errors.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
        expect(overflows, isEmpty, reason: 'MyTicketsScreen zero overflow on ${size.width}px');
      });
    }
  });

  group('Milestone 5 Grand Challenger: Client Specific Contrast Verifications', () {
    test('Promotion banner dark text on gradient background passes WCAG AA >= 4.5:1', () {
      const bannerText = Color(0xFF111827);
      const gradientStart = Color(0xFFF59E0B);
      const gradientEnd = Color(0xFFE58E26);

      final ratioStart = computeContrast(bannerText, gradientStart);
      final ratioEnd = computeContrast(bannerText, gradientEnd);

      debugPrint('[CLIENT CONTRAST] Promo banner text on gradient start: ${ratioStart.toStringAsFixed(2)}:1');
      debugPrint('[CLIENT CONTRAST] Promo banner text on gradient end: ${ratioEnd.toStringAsFixed(2)}:1');

      expect(ratioStart, greaterThanOrEqualTo(4.5));
      expect(ratioEnd, greaterThanOrEqualTo(4.5));
    });

    test('Checkout discount badge text in Light and Dark Mode passes WCAG AA >= 4.5:1', () {
      // In Light Mode: #15803D on white card
      final lightRatio = computeContrast(const Color(0xFF15803D), Colors.white);
      // In Dark Mode: dark.success (#22C55E) on dark surface (#1E1E24)
      final darkRatio = computeContrast(CineplexColors.dark.success, CineplexColors.dark.surface);

      debugPrint('[CLIENT CONTRAST] Checkout discount in Light: ${lightRatio.toStringAsFixed(2)}:1');
      debugPrint('[CLIENT CONTRAST] Checkout discount in Dark: ${darkRatio.toStringAsFixed(2)}:1');

      expect(lightRatio, greaterThanOrEqualTo(4.5));
      expect(darkRatio, greaterThanOrEqualTo(4.5));
    });
  });
}
