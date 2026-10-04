import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

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

Color alphaComposite(Color fg, Color bg) {
  final a = fg.a;
  final invA = 1.0 - a;
  return Color.from(
    alpha: 1.0,
    red: (fg.r * a + bg.r * invA).clamp(0.0, 1.0),
    green: (fg.g * a + bg.g * invA).clamp(0.0, 1.0),
    blue: (fg.b * a + bg.b * invA).clamp(0.0, 1.0),
  );
}

double computeContrast(Color fg, Color bg) {
  final effectiveFg = fg.a < 1.0 ? alphaComposite(fg, bg) : fg;
  final l1 = computeRelativeLuminance(effectiveFg);
  final l2 = computeRelativeLuminance(bg);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 5 Grand Challenger: Mathematical Contrast Certification', () {
    test('1. Light Mode Core Typography Tokens Contrast (WCAG AA >= 4.5:1)', () {
      const light = CineplexColors.light;

      final textPrimaryOnBg = computeContrast(light.textPrimary, light.background);
      final textPrimaryOnSurface = computeContrast(light.textPrimary, light.surface);
      final textPrimaryOnVariant = computeContrast(light.textPrimary, light.surfaceVariant);
      final textPrimaryOnCard = computeContrast(light.textPrimary, light.card);

      final textSecondaryOnBg = computeContrast(light.textSecondary, light.background);
      final textSecondaryOnSurface = computeContrast(light.textSecondary, light.surface);
      final textSecondaryOnCard = computeContrast(light.textSecondary, light.card);

      final textMutedOnSurface = computeContrast(light.textMuted, light.surface);

      debugPrint('[M5 CONTRAST] Light textPrimary on bg: ${textPrimaryOnBg.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Light textPrimary on surface: ${textPrimaryOnSurface.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Light textPrimary on variant: ${textPrimaryOnVariant.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Light textSecondary on surface: ${textSecondaryOnSurface.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Light textSecondary on bg: ${textSecondaryOnBg.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Light textMuted on surface: ${textMutedOnSurface.toStringAsFixed(2)}:1');

      expect(textPrimaryOnBg, greaterThanOrEqualTo(4.5), reason: 'Light textPrimary on bg passes WCAG AA');
      expect(textPrimaryOnSurface, greaterThanOrEqualTo(4.5), reason: 'Light textPrimary on surface passes WCAG AA');
      expect(textPrimaryOnVariant, greaterThanOrEqualTo(4.5), reason: 'Light textPrimary on variant passes WCAG AA');
      expect(textPrimaryOnCard, greaterThanOrEqualTo(4.5), reason: 'Light textPrimary on card passes WCAG AA');

      expect(textSecondaryOnBg, greaterThanOrEqualTo(4.5), reason: 'Light textSecondary on bg passes WCAG AA');
      expect(textSecondaryOnSurface, greaterThanOrEqualTo(4.5), reason: 'Light textSecondary on surface passes WCAG AA');
      expect(textSecondaryOnCard, greaterThanOrEqualTo(4.5), reason: 'Light textSecondary on card passes WCAG AA');

      expect(textMutedOnSurface, greaterThanOrEqualTo(4.5), reason: 'Light textMuted on surface passes WCAG AA');
    });

    test('2. Dark Mode Core Typography Tokens Contrast (WCAG AA >= 4.5:1)', () {
      const dark = CineplexColors.dark;

      final textPrimaryOnBg = computeContrast(dark.textPrimary, dark.background);
      final textPrimaryOnSurface = computeContrast(dark.textPrimary, dark.surface);
      final textPrimaryOnVariant = computeContrast(dark.textPrimary, dark.surfaceVariant);
      final textPrimaryOnCard = computeContrast(dark.textPrimary, dark.card);

      final textSecondaryOnBg = computeContrast(dark.textSecondary, dark.background);
      final textSecondaryOnSurface = computeContrast(dark.textSecondary, dark.surface);
      final textSecondaryOnCard = computeContrast(dark.textSecondary, dark.card);

      final textMutedOnBg = computeContrast(dark.textMuted, dark.background);
      final textMutedOnSurface = computeContrast(dark.textMuted, dark.surface);

      debugPrint('[M5 CONTRAST] Dark textPrimary on bg: ${textPrimaryOnBg.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Dark textPrimary on surface: ${textPrimaryOnSurface.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Dark textPrimary on variant: ${textPrimaryOnVariant.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Dark textSecondary on surface: ${textSecondaryOnSurface.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Dark textSecondary on bg: ${textSecondaryOnBg.toStringAsFixed(2)}:1');
      debugPrint('[M5 CONTRAST] Dark textMuted on surface: ${textMutedOnSurface.toStringAsFixed(2)}:1');

      expect(textPrimaryOnBg, greaterThanOrEqualTo(4.5), reason: 'Dark textPrimary on bg passes WCAG AA');
      expect(textPrimaryOnSurface, greaterThanOrEqualTo(4.5), reason: 'Dark textPrimary on surface passes WCAG AA');
      expect(textPrimaryOnVariant, greaterThanOrEqualTo(4.5), reason: 'Dark textPrimary on variant passes WCAG AA');
      expect(textPrimaryOnCard, greaterThanOrEqualTo(4.5), reason: 'Dark textPrimary on card passes WCAG AA');

      expect(textSecondaryOnBg, greaterThanOrEqualTo(4.5), reason: 'Dark textSecondary on bg passes WCAG AA');
      expect(textSecondaryOnSurface, greaterThanOrEqualTo(4.5), reason: 'Dark textSecondary on surface passes WCAG AA');
      expect(textSecondaryOnCard, greaterThanOrEqualTo(4.5), reason: 'Dark textSecondary on card passes WCAG AA');

      expect(textMutedOnBg, greaterThanOrEqualTo(4.5), reason: 'Dark textMuted on bg passes WCAG AA');
      expect(textMutedOnSurface, greaterThanOrEqualTo(4.5), reason: 'Dark textMuted on surface passes WCAG AA');
    });

    test('3. Interactive Button & Brand Tokens Contrast (WCAG AA >= 3.0:1)', () {
      const light = CineplexColors.light;
      const dark = CineplexColors.dark;

      // Primary brand button: White on #E50914
      final lightPrimaryButton = computeContrast(Colors.white, light.primary);
      final darkPrimaryButton = computeContrast(Colors.white, dark.primary);

      debugPrint('[M5 CONTRAST] White on primary: ${lightPrimaryButton.toStringAsFixed(2)}:1');

      expect(lightPrimaryButton, greaterThanOrEqualTo(3.0), reason: 'Primary button meets WCAG AA interactive/large');
      expect(darkPrimaryButton, greaterThanOrEqualTo(3.0), reason: 'Primary button meets WCAG AA interactive/large');

      // Secondary brand button: White on #3A86FF
      final lightSecondaryButton = computeContrast(Colors.white, light.secondary);
      expect(lightSecondaryButton, greaterThanOrEqualTo(3.0), reason: 'Secondary button meets WCAG AA interactive');
    });

    test('4. All Seat Category Tokens & Foreground Contrast Audit', () {
      const light = CineplexColors.light;
      const dark = CineplexColors.dark;

      // Selected Seat: #22C55E with #111827 dark text
      const selectedDarkText = Color(0xFF111827);
      final selectedRatio = computeContrast(selectedDarkText, light.seatSelected);
      debugPrint('[M5 SEAT CONTRAST] Selected seat (#111827 on #22C55E): ${selectedRatio.toStringAsFixed(2)}:1');
      expect(selectedRatio, greaterThanOrEqualTo(4.5), reason: 'Selected seat text passes WCAG AA >= 4.5:1');

      // Held Seat: #F59E0B with #111827 dark text
      const heldDarkText = Color(0xFF111827);
      final heldRatio = computeContrast(heldDarkText, light.seatHeld);
      debugPrint('[M5 SEAT CONTRAST] Held seat (#111827 on #F59E0B): ${heldRatio.toStringAsFixed(2)}:1');
      expect(heldRatio, greaterThanOrEqualTo(4.5), reason: 'Held seat text passes WCAG AA >= 4.5:1');

      // Standard Seat: #718096 with white text
      final standardRatio = computeContrast(Colors.white, light.seatStandard);
      debugPrint('[M5 SEAT CONTRAST] Standard seat (white on #718096): ${standardRatio.toStringAsFixed(2)}:1');
      expect(standardRatio, greaterThanOrEqualTo(3.0), reason: 'Standard seat passes UI component contrast');

      // VIP Seat: #E50914 with white text
      final vipRatio = computeContrast(Colors.white, light.seatVIP);
      debugPrint('[M5 SEAT CONTRAST] VIP seat (white on #E50914): ${vipRatio.toStringAsFixed(2)}:1');
      expect(vipRatio, greaterThanOrEqualTo(3.0), reason: 'VIP seat passes UI component contrast');

      // Couple Seat: #D946EF with white text
      final coupleRatio = computeContrast(Colors.white, light.seatCouple);
      debugPrint('[M5 SEAT CONTRAST] Couple seat (white on #D946EF): ${coupleRatio.toStringAsFixed(2)}:1');
      expect(coupleRatio, greaterThanOrEqualTo(3.0), reason: 'Couple seat passes UI component contrast');

      // Booked Seat in Light Mode: #9CA3AF with #111827 dark text
      final bookedLightRatio = computeContrast(light.seatBookedText, light.seatBooked);
      debugPrint('[M5 SEAT CONTRAST] Booked seat Light (#111827 on #9CA3AF): ${bookedLightRatio.toStringAsFixed(2)}:1');
      expect(bookedLightRatio, greaterThanOrEqualTo(4.5), reason: 'Booked seat in light mode passes WCAG AA >= 4.5:1');

      // Booked Seat in Dark Mode: #374151
      expect(dark.seatBooked, equals(const Color(0xFF374151)));
    });
  });

  group('Milestone 5 Grand Challenger: Adversarial Viewport Stress (320px, 360px, 390px)', () {
    const viewports = [
      Size(320, 640), // iPhone SE 1st gen
      Size(360, 800), // Compact Android
      Size(390, 844), // Standard iPhone
    ];

    Widget testHarness({
      required Widget child,
      ThemeMode mode = ThemeMode.light,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: Scaffold(body: child),
      );
    }

    for (final size in viewports) {
      testWidgets('AppButton zero overflow on ${size.width}px in Light and Dark Mode', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(testHarness(
              mode: mode,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppButton(text: 'Xác nhận đặt vé xem phim ngay bây giờ', onPressed: () {}),
                    const SizedBox(height: 10),
                    AppButton(text: 'Nút ngắn', width: 80, onPressed: () {}),
                    const SizedBox(height: 10),
                    AppButton(text: 'Nút siêu hẹp', width: 60, onPressed: () {}),
                    const SizedBox(height: 10),
                    AppButton(text: 'Đang xử lý thanh toán', isLoading: true, onPressed: () {}),
                    const SizedBox(height: 10),
                    AppButton(text: 'Nút có icon và chữ dài', icon: Icons.movie, onPressed: () {}),
                    const SizedBox(height: 10),
                    AppButton(text: 'Nút viền ngoài Outlined', isOutlined: true, onPressed: () {}),
                  ],
                ),
              ),
            ));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          }
        } finally {
          FlutterError.onError = oldOnError;
        }

        final overflows = errors.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
        expect(overflows, isEmpty, reason: 'Zero RenderFlex overflow on AppButton at ${size.width}px');
      });

      testWidgets('AppTextField zero overflow on ${size.width}px in Light and Dark Mode', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(testHarness(
              mode: mode,
              child: const SingleChildScrollView(
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Email tài khoản quản trị viên hệ thống Cineplex',
                      hint: 'Nhập email đầy đủ định dạng @cineplex.vn',
                      prefixIcon: Icons.email_outlined,
                    ),
                    SizedBox(height: 10),
                    AppTextField(
                      label: 'Mật khẩu bảo mật cấp cao',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                  ],
                ),
              ),
            ));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          }
        } finally {
          FlutterError.onError = oldOnError;
        }

        final overflows = errors.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
        expect(overflows, isEmpty, reason: 'Zero RenderFlex overflow on AppTextField at ${size.width}px');
      });

      testWidgets('AppEmptyView and AppErrorView zero overflow on ${size.width}px', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(testHarness(
              mode: mode,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppEmptyView(
                      title: 'Chưa có lịch sử giao dịch nào được ghi nhận',
                      message: 'Quý khách vui lòng chọn suất chiếu và đặt vé để trải nghiệm các bộ phim bom tấn tại Cineplex.',
                      actionLabel: 'Đặt vé ngay',
                      onAction: () {},
                    ),
                    const Divider(),
                    AppErrorView(
                      title: 'Không thể kết nối đến máy chủ Cineplex Backend',
                      message: 'Vui lòng kiểm tra lại kết nối mạng Internet hoặc thử lại sau vài phút. Mã lỗi: ERR_NETWORK_TIMEOUT_504.',
                      retryLabel: 'Thử lại ngay bây giờ',
                      onRetry: () {},
                    ),
                  ],
                ),
              ),
            ));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          }
        } finally {
          FlutterError.onError = oldOnError;
        }

        final overflows = errors.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
        expect(overflows, isEmpty, reason: 'Zero RenderFlex overflow on Empty/Error views at ${size.width}px');
      });

      testWidgets('SeatWidget & SeatLegend zero overflow on ${size.width}px', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(testHarness(
              mode: mode,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const SeatLegend(showAll: true),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        SeatWidget(
                          seat: const SeatModel(seatId: 1, row: 'A', column: 1, label: 'A1', isCouple: false, status: SeatStatus.available),
                          onTap: () {},
                        ),
                        SeatWidget(
                          seat: const SeatModel(seatId: 2, row: 'B', column: 2, label: 'B2', isCouple: false, isVip: true, status: SeatStatus.available),
                          onTap: () {},
                        ),
                        SeatWidget(
                          seat: const SeatModel(seatId: 3, row: 'C', column: 3, label: 'C3', isCouple: true, status: SeatStatus.available),
                          onTap: () {},
                        ),
                        SeatWidget(
                          seat: const SeatModel(seatId: 4, row: 'D', column: 4, label: 'D4', isCouple: false, status: SeatStatus.selected),
                          isSelected: true,
                          onTap: () {},
                        ),
                        const SeatWidget(
                          seat: SeatModel(seatId: 5, row: 'E', column: 5, label: 'E5', isCouple: false, status: SeatStatus.held),
                        ),
                        const SeatWidget(
                          seat: SeatModel(seatId: 6, row: 'F', column: 6, label: 'F6', isCouple: false, status: SeatStatus.booked),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          }
        } finally {
          FlutterError.onError = oldOnError;
        }

        final overflows = errors.where((e) => e.toString().contains('A RenderFlex overflowed')).toList();
        expect(overflows, isEmpty, reason: 'Zero RenderFlex overflow on Seat widgets at ${size.width}px');
      });
    }
  });
}
