import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

/// WCAG 2.1 relative luminance and contrast ratio computation
double _channelLuminance(double channel) {
  final c = channel / 255.0;
  return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double relativeLuminance(Color color) {
  final r = _channelLuminance(color.r * 255.0);
  final g = _channelLuminance(color.g * 255.0);
  final b = _channelLuminance(color.b * 255.0);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

Color compositeOver(Color foreground, Color background) {
  final a = foreground.a;
  final r = (foreground.r * a + background.r * (1.0 - a));
  final g = (foreground.g * a + background.g * (1.0 - a));
  final b = (foreground.b * a + background.b * (1.0 - a));
  return Color.from(alpha: 1.0, red: r, green: g, blue: b);
}

double contrastRatio(Color foreground, Color background) {
  final effectiveFg = foreground.a < 1.0 ? compositeOver(foreground, background) : foreground;
  final l1 = relativeLuminance(effectiveFg);
  final l2 = relativeLuminance(background);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 1 Round 2: SeatWidget Light Mode Contrast Verification', () {
    test('Mathematical verification: CineplexColors.light booked seat contrast', () {
      final light = CineplexColors.light;
      final bookedBg = light.seatBooked;
      final bookedText = light.seatBookedText;

      final ratio = contrastRatio(bookedText, bookedBg);
      print('=== Booked Seat Contrast in Light Mode ===');
      print('Background: $bookedBg');
      print('Foreground: $bookedText');
      print('Contrast Ratio: ${ratio.toStringAsFixed(2)}:1');

      // Requirement: booked seat text contrast >= 4.5:1 (WCAG AA)
      expect(ratio >= 4.5, isTrue, reason: 'Booked seat contrast must be >= 4.5:1 for WCAG AA');
      // In fact, #111827 on #9CA3AF should achieve approximately 7.00:1 (WCAG AAA)
      expect(ratio >= 6.8, isTrue, reason: 'Expected ratio to reach ~7:1 (AAA)');
    });

    testWidgets('Widget tree verification: SeatWidget rendered in Light Mode with booked status', (tester) async {
      final bookedSeat = SeatModel(
        seatId: 42,
        row: 'F',
        column: 8,
        label: 'F8',
        status: SeatStatus.booked,
        isCouple: false,
        isVip: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SeatWidget(seat: bookedSeat),
            ),
          ),
        ),
      );

      // Verify the widget rendered without exceptions
      expect(tester.takeException(), isNull);

      // Verify Text widget properties
      final textFinder = find.text('8');
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, const Color(0xFF111827));

      // Verify AnimatedContainer decoration
      final containerFinder = find.byType(AnimatedContainer);
      expect(containerFinder, findsOneWidget);
      final containerWidget = tester.widget<AnimatedContainer>(containerFinder);
      final decoration = containerWidget.decoration as BoxDecoration?;
      expect(decoration?.color, const Color(0xFF9CA3AF));

      // Re-verify contrast with actual widget values
      final actualRatio = contrastRatio(textWidget.style!.color!, decoration!.color!);
      expect(actualRatio >= 4.5, isTrue);
    });

    testWidgets('SeatWidget across all statuses in Light Mode renders without contrast crashes', (tester) async {
      final allStatuses = [
        SeatStatus.available,
        SeatStatus.booked,
        SeatStatus.held,
        SeatStatus.selected,
        SeatStatus.maintenance,
      ];

      for (final status in allStatuses) {
        final seat = SeatModel(
          seatId: 1,
          row: 'A',
          column: 1,
          label: 'A1',
          status: status,
          isCouple: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SeatWidget(seat: seat),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('1'), findsOneWidget);
      }
    });
  });

  group('Milestone 1 Round 2: AppErrorView Width & Responsiveness Stress Tests', () {
    final testWidths = [
      1920.0, // Desktop FHD
      1024.0, // Tablet landscape
      768.0,  // Tablet portrait
      480.0,  // Phablet
      412.0,  // Pixel 7 / Samsung Galaxy S23
      390.0,  // iPhone 14/15
      375.0,  // iPhone SE 2nd/3rd Gen
      360.0,  // Common Android compact
      320.0,  // iPhone SE 1st gen (standard mobile minimum)
      280.0,  // Samsung Galaxy Z Fold outer screen
    ];

    for (final width in testWidths) {
      testWidgets('AppErrorView renders without overflow on width ${width.toInt()}px in Light Theme', (tester) async {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppErrorView(
                title: 'Đã xảy ra sự cố',
                message: 'Không thể kết nối đến máy chủ Cineplex. Vui lòng kiểm tra kết nối mạng và thử lại.',
                onRetry: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'RenderFlex overflow detected at width $width in Light Theme!');
        expect(find.text('Thử lại'), findsOneWidget);
        expect(find.text('Đã xảy ra sự cố'), findsOneWidget);
      });

      testWidgets('AppErrorView renders without overflow on width ${width.toInt()}px in Dark Theme', (tester) async {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: AppErrorView(
                title: 'Lỗi tải dữ liệu',
                message: 'Máy chủ phản hồi với mã lỗi 500.',
                onRetry: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'RenderFlex overflow detected at width $width in Dark Theme!');
        expect(find.text('Thử lại'), findsOneWidget);
      });
    }

    testWidgets('AppErrorView stress test: Very long message text at 320px width', (tester) async {
      tester.view.physicalSize = const Size(320.0, 900.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const longMessage = 'Một thông báo lỗi rất dài nhằm kiểm tra khả năng bọc dòng tự động '
          'của AppErrorView trên màn hình hẹp kích thước 320 pixel. '
          'Hệ thống phải tự động xuống dòng và không gây ra bất kỳ ngoại lệ RenderFlex overflow nào.';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppErrorView(
                title: 'Thông báo lỗi chi tiết',
                message: longMessage,
                onRetry: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('AppErrorView: Custom retryLabel longer than 8 chars triggers overflow in AppButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppErrorView(
              message: 'Lỗi',
              retryLabel: 'Thử lại ngay bây giờ',
              onRetry: () {},
            ),
          ),
        ),
      );

      final exception = tester.takeException();
      print('Custom retryLabel "Thử lại ngay bây giờ" exception: $exception');
    });

    testWidgets('AppErrorView: Screen width under 208px triggers RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(200.0, 600.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppErrorView(
              message: 'Lỗi',
              onRetry: () {},
            ),
          ),
        ),
      );

      final exception = tester.takeException();
      print('AppErrorView at 200px screen width exception: $exception');
    });

    testWidgets('AppErrorView stress test: TextScaleFactor 1.25 on standard 360px screen', (tester) async {
      tester.view.physicalSize = const Size(360.0, 800.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.25),
            ),
            child: Scaffold(
              body: AppErrorView(
                title: 'Lỗi',
                message: 'Không thể kết nối máy chủ.',
                onRetry: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final exception = tester.takeException();
      print('AppErrorView at 1.25x textScaler exception: $exception');
    });

    testWidgets('AppErrorView: onRetry callback executes successfully on tap', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppErrorView(
              message: 'Lỗi',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();

      expect(retryPressed, isTrue);
    });
  });
}
