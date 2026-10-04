import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

void main() {
  group('CineplexColors & AppTheme Tokens', () {
    test('Dark and Light theme extensions are correctly configured', () {
      final dark = CineplexColors.dark;
      final light = CineplexColors.light;

      expect(dark.isDark, isTrue);
      expect(light.isDark, isFalse);

      // Contrast tokens
      expect(dark.background, const Color(0xFF121212));
      expect(light.background, const Color(0xFFF9FAFB));

      // Light mode booked seat contrast
      expect(light.seatBooked, const Color(0xFF9CA3AF));
      expect(light.seatText, Colors.white);
      expect(light.seatBookedText, const Color(0xFF111827));

      // AppTheme extensions
      expect(AppTheme.darkTheme.extension<CineplexColors>(), isNotNull);
      expect(AppTheme.lightTheme.extension<CineplexColors>(), isNotNull);
    });

    test('AppColors helpers and seat constants match design tokens', () {
      expect(AppColors.getCinematicGradient(true), AppColors.darkCinematicGradient);
      expect(AppColors.getCinematicGradient(false), AppColors.lightCinematicGradient);
      expect(AppColors.seatBookedLight, const Color(0xFF9CA3AF));
    });
  });

  group('ThemeCubit', () {
    test('Defaults to dark mode and toggles seamlessly', () async {
      final cubit = ThemeCubit();
      expect(cubit.state, ThemeMode.dark);
      expect(cubit.isDarkMode, isTrue);

      await cubit.toggleTheme();
      expect(cubit.state, ThemeMode.light);
      expect(cubit.isDarkMode, isFalse);

      await cubit.setThemeMode(ThemeMode.system);
      expect(cubit.state, ThemeMode.system);

      await cubit.close();
    });
  });

  group('SeatModel', () {
    test('Maintains backwards compatibility while supporting VIP and types', () {
      final standardSeat = SeatModel(
        seatId: 1,
        row: 'A',
        column: 1,
        label: 'A1',
        status: SeatStatus.available,
        isCouple: false,
      );
      expect(standardSeat.type, SeatType.standard);
      expect(standardSeat.isVip, isFalse);

      final vipSeat = SeatModel(
        seatId: 2,
        row: 'B',
        column: 1,
        label: 'B1',
        status: SeatStatus.available,
        isCouple: false,
        isVip: true,
      );
      expect(vipSeat.type, SeatType.vip);
      expect(vipSeat.isVip, isTrue);

      final coupleSeat = SeatModel(
        seatId: 3,
        row: 'C',
        column: 1,
        label: 'C1',
        status: SeatStatus.available,
        isCouple: true,
      );
      expect(coupleSeat.type, SeatType.couple);
      expect(coupleSeat.isCouple, isTrue);
    });
  });

  group('Shared Widgets Rendering', () {
    testWidgets('AppErrorView renders with localized default fallback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppErrorView(
              message: 'Lỗi kết nối máy chủ',
            ),
          ),
        ),
      );

      expect(find.text('Lỗi kết nối máy chủ'), findsOneWidget);
    });

    testWidgets('AppEmptyView renders title and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppEmptyView(
              title: 'Không có phim nào',
              message: 'Vui lòng quay lại sau',
            ),
          ),
        ),
      );

      expect(find.text('Không có phim nào'), findsOneWidget);
      expect(find.text('Vui lòng quay lại sau'), findsOneWidget);
    });

    testWidgets('SeatWidget renders correctly with interaction', (tester) async {
      bool tapped = false;
      final seat = SeatModel(
        seatId: 10,
        row: 'D',
        column: 5,
        label: 'D5',
        status: SeatStatus.available,
        isCouple: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SeatWidget(
              seat: seat,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      await tester.tap(find.byType(SeatWidget));
      expect(tapped, isTrue);
    });

    testWidgets('SeatLegend renders all items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SeatLegend(showAll: true),
          ),
        ),
      );

      expect(find.byType(SeatLegend), findsOneWidget);
    });

    testWidgets('SeatWidget semantics labels consume AppLocalizations correctly', (tester) async {
      final statuses = [
        (SeatStatus.available, 'Trống'),
        (SeatStatus.booked, 'Đã đặt'),
        (SeatStatus.held, 'Đang giữ'),
        (SeatStatus.selected, 'Đang chọn'),
        (SeatStatus.maintenance, 'Bảo trì'),
      ];

      for (final item in statuses) {
        final status = item.$1;
        final expectedText = item.$2;
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

        final semanticsFinder = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'A1 $expectedText',
        );
        expect(semanticsFinder, findsOneWidget, reason: 'Status $status should have semantics label "A1 $expectedText"');
      }
    });

    testWidgets('SeatWidget text colors adhere to high contrast in Light Mode', (tester) async {
      final bookedSeat = SeatModel(
        seatId: 1,
        row: 'B',
        column: 2,
        label: 'B2',
        status: SeatStatus.booked,
        isCouple: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SeatWidget(seat: bookedSeat),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('2'));
      expect(textWidget.style?.color, const Color(0xFF111827));
    });

    testWidgets('ShimmerSkeleton safely renders without CineplexColors extension', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ShimmerSkeleton(width: 100, height: 20),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });

    testWidgets('AppErrorView with onRetry renders without RenderFlex overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppErrorView(
              message: 'Lỗi tải dữ liệu',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Thử lại'), findsOneWidget);
    });
  });
}
