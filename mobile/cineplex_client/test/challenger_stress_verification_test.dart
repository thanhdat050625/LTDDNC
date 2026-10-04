import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'package:cineplex_client/features/auth/presentation/screens/login_screen.dart';
import 'package:cineplex_client/features/home/presentation/widgets/promotion_banner.dart';
import 'package:cineplex_client/features/payment/data/models/payment_model.dart';
import 'package:cineplex_client/features/payment/data/repositories/payment_repository.dart';
import 'package:cineplex_client/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:cineplex_client/features/payment/presentation/screens/checkout_screen.dart';
import 'package:cineplex_client/features/ticket/presentation/widgets/ticket_card.dart';

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

// --- Fakes & Mocks ---
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

class FakeStressPaymentRepository extends PaymentRepository {
  final CheckoutPrepareModel prepareModel;
  FakeStressPaymentRepository(super.dioClient, this.prepareModel);

  @override
  Future<CheckoutPrepareModel> prepareCheckout(String bookingId) async => prepareModel;
  @override
  Future<PaymentResponseModel> checkout(String bookingId, String method) async =>
      PaymentResponseModel(bookingId: bookingId, payUrl: 'https://pay.example.com', paymentRequired: true);
  @override
  Future<PaymentStatusModel> getPaymentStatus(String bookingId) async =>
      PaymentStatusModel(bookingId: bookingId, bookingCode: prepareModel.bookingCode, status: 'PAID');
}

class MockAuthBloc extends AuthBloc {
  MockAuthBloc() : super(AuthRepository(DioClient(FakeStorageService()), FakeStorageService())) {
    emit(AuthUnauthenticated());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Requirement 3: Empirical Contrast Ratios Verification (WCAG AA >= 4.5:1)', () {
    test('1. PromotionBanner: Dark text #111827 contrast against both gradient colors', () {
      const textColor = Color(0xFF111827);
      const gradientStart = Color(0xFFF59E0B);
      const gradientEnd = AppColors.accent; // Color(0xFFE58E26)

      final contrastStart = calculateContrastRatio(textColor, gradientStart);
      final contrastEnd = calculateContrastRatio(textColor, gradientEnd);

      expect(contrastStart, greaterThanOrEqualTo(4.5),
          reason: 'PromotionBanner text contrast against gradient start must be >= 4.5:1, got $contrastStart');
      expect(contrastEnd, greaterThanOrEqualTo(4.5),
          reason: 'PromotionBanner text contrast against gradient end must be >= 4.5:1, got $contrastEnd');
      expect(contrastEnd, greaterThanOrEqualTo(6.0),
          reason: 'PromotionBanner should comfortably exceed 6.0:1 (actual: $contrastEnd)');
    });

    test('2. Login Screen Forgot-Password Link: Contrast in Light and Dark Mode', () {
      const darkColors = CineplexColors.dark;
      const lightColors = CineplexColors.light;

      // In Dark Mode: colors.secondary (#3A86FF) on dark surface (#1E1E24) and dark background (#121212)
      final darkForgotColor = darkColors.secondary;
      final contrastDarkOnSurface = calculateContrastRatio(darkForgotColor, darkColors.surface);
      final contrastDarkOnBackground = calculateContrastRatio(darkForgotColor, darkColors.background);

      expect(contrastDarkOnSurface, greaterThanOrEqualTo(4.5),
          reason: 'Forgot-password text contrast on dark surface must be >= 4.5:1, got $contrastDarkOnSurface');
      expect(contrastDarkOnBackground, greaterThanOrEqualTo(4.5),
          reason: 'Forgot-password text contrast on dark background must be >= 4.5:1, got $contrastDarkOnBackground');

      // In Light Mode: colors.primary (#E50914) on light surface (white) and light background (#F9FAFB)
      final lightForgotColor = lightColors.primary;
      final contrastLightOnSurface = calculateContrastRatio(lightForgotColor, lightColors.surface);
      final contrastLightOnBackground = calculateContrastRatio(lightForgotColor, lightColors.background);

      expect(contrastLightOnSurface, greaterThanOrEqualTo(4.5),
          reason: 'Forgot-password text contrast on light surface must be >= 4.5:1, got $contrastLightOnSurface');
      expect(contrastLightOnBackground, greaterThanOrEqualTo(4.5),
          reason: 'Forgot-password text contrast on light background must be >= 4.5:1, got $contrastLightOnBackground');
    });

    test('3. Checkout Screen Discount Text: Contrast in Light and Dark Mode', () {
      const darkColors = CineplexColors.dark;
      const lightColors = CineplexColors.light;

      // In Dark Mode: darkColors.success on dark surface (#1E1E24)
      final darkDiscountColor = darkColors.success;
      final contrastDark = calculateContrastRatio(darkDiscountColor, darkColors.surface);

      expect(contrastDark, greaterThanOrEqualTo(4.5),
          reason: 'Checkout discount text in dark mode must be >= 4.5:1, got $contrastDark');
      expect(contrastDark, greaterThanOrEqualTo(7.0),
          reason: 'Checkout discount text in dark mode achieves WCAG AAA >= 7.0:1 (actual: $contrastDark)');

      // In Light Mode: const Color(0xFF15803D) on white card/surface
      const lightDiscountColor = Color(0xFF15803D);
      final contrastLight = calculateContrastRatio(lightDiscountColor, lightColors.surface);

      expect(contrastLight, greaterThanOrEqualTo(4.5),
          reason: 'Checkout discount text in light mode must be >= 4.5:1, got $contrastLight');
    });
  });

  group('Requirement 2: Stress Verification on AppButton and TicketCard', () {
    testWidgets('1. AppButton with constrained widths (80px, 100px, 120px) has ZERO overflow', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final widthsToTest = [80.0, 100.0, 120.0, 180.0, 300.0, 320.0];
        final labelsToTest = [
          'OK',
          'Tiếp tục',
          'Mô phỏng thanh toán thành công',
          'Một nút bấm có tiêu đề rất dài để thử nghiệm overflow khả năng co giãn',
        ];

        for (final width in widthsToTest) {
          for (final label in labelsToTest) {
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.darkTheme,
                home: Scaffold(
                  body: Center(
                    child: AppButton(
                      width: width,
                      text: label,
                      icon: Icons.check,
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();
          }
        }
      } finally {
        FlutterError.onError = oldHandler;
      }
      tester.takeException();

      final overflows = errorDetails.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
      expect(overflows, isEmpty, reason: 'AppButton verified: zero RenderFlex overflow across narrow widths');
    });

    testWidgets('2. TicketCard with standard realistic booking on 320px viewport has ZERO overflow', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        tester.view.physicalSize = const Size(320, 640) * tester.view.devicePixelRatio;
        addTearDown(() => tester.view.resetPhysicalSize());

        const booking = BookingDetailModel(
          id: '1',
          bookingCode: 'CPX-TEST-99',
          movieTitle: 'Avengers: Secret Wars',
          cinemaName: 'Cineplex Landmark 81',
          roomName: 'Phòng 01',
          totalAmount: 180000,
          status: 'PAID',
          tickets: [],
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: TicketCard(booking: booking),
              ),
            ),
          ),
        );
        await tester.pump();
      } finally {
        FlutterError.onError = oldHandler;
      }
      tester.takeException();

      final overflows = errorDetails.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
      expect(overflows, isEmpty, reason: 'TicketCard verified: zero RenderFlex overflow on standard 320px viewport');
    });
  });

  group('Empirical RenderFlex Stress Verification (Zero Overflows on Mobile Viewports)', () {
    testWidgets('1. CheckoutScreen has zero overflow across 320px, 360px, and 390px viewports', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final viewportsToTest = [
          const Size(320, 640), // iPhone SE
          const Size(360, 640), // Standard Android
          const Size(390, 844), // iPhone 12/13/14
        ];

        final storage = FakeStorageService();
        final dio = DioClient(storage);
        const typicalPrepareModel = CheckoutPrepareModel(
          bookingId: '202',
          bookingCode: 'CPX-TEST-99',
          totalAmount: 180000,
          discountAmount: 20000,
          pointsUsed: 0,
          secondsRemaining: 300,
        );
        final paymentRepo = FakeStressPaymentRepository(dio, typicalPrepareModel);

        for (final vp in viewportsToTest) {
          tester.view.physicalSize = vp * tester.view.devicePixelRatio;

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
                    BlocProvider<AuthBloc>(create: (_) => MockAuthBloc()),
                    BlocProvider<PaymentCubit>(create: (_) => PaymentCubit(paymentRepo)..prepareCheckout('202')),
                  ],
                  child: const CheckoutScreen(bookingId: '202'),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
        }
      } finally {
        FlutterError.onError = oldHandler;
        tester.view.resetPhysicalSize();
      }
      tester.takeException();

      final overflows = errorDetails.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
      expect(overflows, isEmpty,
          reason: 'CheckoutScreen verified: zero RenderFlex overflows across 320px, 360px, and 390px viewports');
    });

    testWidgets('2. LoginScreen bottom register row and remember-me row have zero overflow on mobile viewports', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        final viewportsToTest = [
          const Size(320, 568), // iPhone SE
          const Size(360, 640), // Standard Android
          const Size(390, 844), // iPhone 12/13/14
        ];

        for (final vp in viewportsToTest) {
          tester.view.physicalSize = vp * tester.view.devicePixelRatio;

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [Locale('vi')],
              locale: const Locale('vi'),
              home: BlocProvider<AuthBloc>(
                create: (_) => MockAuthBloc(),
                child: const LoginScreen(),
              ),
            ),
          );
          await tester.pump();
        }
      } finally {
        FlutterError.onError = oldHandler;
        tester.view.resetPhysicalSize();
      }
      tester.takeException();

      final overflows = errorDetails.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
      expect(overflows, isEmpty,
          reason: 'LoginScreen verified: zero RenderFlex overflows across 320px, 360px, and 390px viewports');
    });

    testWidgets('3. PromotionBanner has zero overflow with realistic multi-line descriptive text', (tester) async {
      final List<FlutterErrorDetails> errorDetails = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errorDetails.add(details);

      try {
        tester.view.physicalSize = const Size(320, 640) * tester.view.devicePixelRatio;

        final promoList = [
          PromotionModel(
            id: 1,
            code: 'SIEU_GIAM_GIA_50K',
            description: 'Giảm giá 50,000đ cho khách hàng thân thiết mua vé đôi cuối tuần',
            discountValue: 50000,
            discountType: 'FIXED',
            startDate: DateTime.now().subtract(const Duration(days: 1)),
            endDate: DateTime.now().add(const Duration(days: 30)),
            usedCount: 1,
            isActive: true,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            home: Scaffold(
              body: PromotionBanner(promotions: promoList),
            ),
          ),
        );
        await tester.pump();
      } finally {
        FlutterError.onError = oldHandler;
        tester.view.resetPhysicalSize();
      }
      tester.takeException();

      final overflows = errorDetails.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
      expect(overflows, isEmpty,
          reason: 'PromotionBanner verified: zero RenderFlex overflows with multi-line description');
    });
  });
}
