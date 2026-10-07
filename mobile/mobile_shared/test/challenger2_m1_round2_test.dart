import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

class EmpiricalMockStorageService extends StorageService {
  String? savedMode;
  final List<String> saveHistory = [];
  bool shouldThrowOnGet = false;
  bool shouldThrowOnSave = false;
  Duration getDelay = Duration.zero;
  Duration saveDelay = Duration.zero;

  EmpiricalMockStorageService({this.savedMode});

  @override
  Future<void> saveThemeMode(String mode) async {
    if (saveDelay > Duration.zero) {
      await Future.delayed(saveDelay);
    }
    if (shouldThrowOnSave) {
      throw Exception('Empirical mock storage write error');
    }
    saveHistory.add(mode);
    savedMode = mode;
  }

  @override
  Future<String?> getThemeMode() async {
    if (getDelay > Duration.zero) {
      await Future.delayed(getDelay);
    }
    if (shouldThrowOnGet) {
      throw Exception('Empirical mock storage read error');
    }
    return savedMode;
  }
}

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

double contrastRatio(Color fg, Color bg) {
  final l1 = relativeLuminance(fg);
  final l2 = relativeLuminance(bg);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Empirical Challenge 1: ThemeCubit Rapid Toggling & _isInitialized Guard', () {
    test('Rapid consecutive toggles before delayed storage load resolves (even count)', () async {
      final storage = EmpiricalMockStorageService(savedMode: 'light')
        ..getDelay = const Duration(milliseconds: 60);

      final cubit = ThemeCubit(storage);
      expect(cubit.state, ThemeMode.dark);

      // Perform 10 rapid toggles sequentially: dark -> light -> dark ... 10 times -> dark
      for (int i = 0; i < 10; i++) {
        await cubit.toggleTheme();
      }
      expect(cubit.state, ThemeMode.dark);

      // Wait for delayed storage read to complete
      await Future.delayed(const Duration(milliseconds: 80));

      // Guard check: _isInitialized was set to true on the first toggle,
      // so delayed load of 'light' must NOT overwrite the current state.
      expect(cubit.state, ThemeMode.dark);
      expect(cubit.isDarkMode, isTrue);
      await cubit.close();
    });

    test('Rapid consecutive toggles before delayed storage load resolves (odd count)', () async {
      final storage = EmpiricalMockStorageService(savedMode: 'dark')
        ..getDelay = const Duration(milliseconds: 60);

      final cubit = ThemeCubit(storage);
      expect(cubit.state, ThemeMode.dark);

      // Perform 5 rapid toggles: dark -> light -> dark -> light -> dark -> light
      for (int i = 0; i < 5; i++) {
        await cubit.toggleTheme();
      }
      expect(cubit.state, ThemeMode.light);

      // Wait for storage read to finish
      await Future.delayed(const Duration(milliseconds: 80));

      // Guard check: State must remain ThemeMode.light, not overwritten by storage 'dark'
      expect(cubit.state, ThemeMode.light);
      expect(cubit.isDarkMode, isFalse);
      await cubit.close();
    });

    test('setThemeMode with SAME initial mode (ThemeMode.dark) sets _isInitialized and blocks delayed load', () async {
      // Storage has 'light', but user immediately explicitly picks dark (same as initial state)
      final storage = EmpiricalMockStorageService(savedMode: 'light')
        ..getDelay = const Duration(milliseconds: 60);

      final cubit = ThemeCubit(storage);
      expect(cubit.state, ThemeMode.dark);

      // Call setThemeMode(ThemeMode.dark) - same as current state!
      await cubit.setThemeMode(ThemeMode.dark);

      // Wait for storage to resolve
      await Future.delayed(const Duration(milliseconds: 80));

      // Guard check: User explicit choice must be preserved
      expect(cubit.state, ThemeMode.dark);
      expect(cubit.isDarkMode, isTrue);
      await cubit.close();
    });

    test('Rapid concurrent unawaited toggles do not crash or corrupt state', () async {
      final storage = EmpiricalMockStorageService(savedMode: 'light')
        ..getDelay = const Duration(milliseconds: 50);

      final cubit = ThemeCubit(storage);

      // Fire 6 unawaited toggle calls in immediate succession
      cubit.toggleTheme(); // -> light
      cubit.toggleTheme(); // -> dark
      cubit.toggleTheme(); // -> light
      cubit.toggleTheme(); // -> dark
      cubit.toggleTheme(); // -> light
      cubit.toggleTheme(); // -> dark

      // State changes synchronously up to first await
      expect(cubit.state, ThemeMode.dark);

      await Future.delayed(const Duration(milliseconds: 80));

      expect(cubit.state, ThemeMode.dark);
      await cubit.close();
    });

    test('Closing cubit while _loadSavedTheme is pending does not throw unhandled exception', () async {
      final storage = EmpiricalMockStorageService(savedMode: 'light')
        ..getDelay = const Duration(milliseconds: 50);

      final cubit = ThemeCubit(storage);
      // Immediately close before storage read resolves
      await cubit.close();

      // Wait for delayed storage read to finish in background
      await Future.delayed(const Duration(milliseconds: 80));

      // Test passes if no uncaught asynchronous exception was thrown in zone
      expect(cubit.isClosed, isTrue);
    });

    test('Storage read exception does not crash cubit and leaves _isInitialized true', () async {
      final storage = EmpiricalMockStorageService()
        ..shouldThrowOnGet = true
        ..getDelay = const Duration(milliseconds: 20);

      final cubit = ThemeCubit(storage);
      expect(cubit.state, ThemeMode.dark);

      await Future.delayed(const Duration(milliseconds: 40));
      expect(cubit.state, ThemeMode.dark);

      // Subsequent toggles work normally
      await cubit.toggleTheme();
      expect(cubit.state, ThemeMode.light);
      await cubit.close();
    });

    test('Null storage service allows seamless toggling and mode setting', () async {
      final cubit = ThemeCubit(null);
      expect(cubit.state, ThemeMode.dark);

      await cubit.toggleTheme();
      expect(cubit.state, ThemeMode.light);

      await cubit.setThemeMode(ThemeMode.system);
      expect(cubit.state, ThemeMode.system);

      await cubit.close();
    });

    test('Storage write error does not block state emission in setThemeMode', () async {
      final storage = EmpiricalMockStorageService(savedMode: 'dark')
        ..shouldThrowOnSave = true;

      final cubit = ThemeCubit(storage);
      await Future.delayed(const Duration(milliseconds: 10));

      // setThemeMode emits mode first, then awaits storage
      expect(
        () async => await cubit.setThemeMode(ThemeMode.light),
        throwsA(isA<Exception>()),
      );

      // State was already updated to light before the save threw
      expect(cubit.state, ThemeMode.light);
      await cubit.close();
    });
  });

  group('Empirical Challenge 2: CineplexColors.of Fallback Semantics', () {
    testWidgets('CineplexColors.of in unextended ThemeData.light() resolves to CineplexColors.light', (tester) async {
      late CineplexColors colors;
      late CineplexColors contextColors;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(), // Zero ThemeExtensions attached
          home: Builder(
            builder: (ctx) {
              colors = CineplexColors.of(ctx);
              contextColors = ctx.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors, CineplexColors.light);
      expect(contextColors, CineplexColors.light);
      expect(colors.isDark, isFalse);
      expect(colors.background, const Color(0xFFF9FAFB));
      expect(colors.surface, const Color(0xFFFFFFFF));
      expect(colors.textPrimary, const Color(0xFF111827));
      expect(colors.seatBookedText, const Color(0xFF111827));
    });

    testWidgets('CineplexColors.of in unextended ThemeData.dark() resolves to CineplexColors.dark', (tester) async {
      late CineplexColors colors;
      late CineplexColors contextColors;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(), // Zero ThemeExtensions attached
          home: Builder(
            builder: (ctx) {
              colors = CineplexColors.of(ctx);
              contextColors = ctx.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors, CineplexColors.dark);
      expect(contextColors, CineplexColors.dark);
      expect(colors.isDark, isTrue);
      expect(colors.background, const Color(0xFF121212));
      expect(colors.surface, const Color(0xFF1E1E24));
      expect(colors.textPrimary, Colors.white);
      expect(colors.seatBookedText, Colors.white38);
    });

    testWidgets('CineplexColors.of in custom ThemeData with Brightness.light resolves to CineplexColors.light', (tester) async {
      late CineplexColors colors;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          home: Builder(
            builder: (ctx) {
              colors = CineplexColors.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors.isDark, isFalse);
      expect(colors, CineplexColors.light);
    });

    testWidgets('CineplexColors.of in custom ThemeData with Brightness.dark resolves to CineplexColors.dark', (tester) async {
      late CineplexColors colors;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          home: Builder(
            builder: (ctx) {
              colors = CineplexColors.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors.isDark, isTrue);
      expect(colors, CineplexColors.dark);
    });

    testWidgets('CineplexColors.of in AppTheme returns the injected extension instance', (tester) async {
      late CineplexColors lightExt;
      late CineplexColors darkExt;

      await tester.pumpWidget(
        Theme(
          data: AppTheme.lightTheme,
          child: Builder(
            builder: (ctx) {
              lightExt = CineplexColors.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        Theme(
          data: AppTheme.darkTheme,
          child: Builder(
            builder: (ctx) {
              darkExt = CineplexColors.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(lightExt.isDark, isFalse);
      expect(darkExt.isDark, isTrue);
      expect(lightExt, AppTheme.lightTheme.extension<CineplexColors>());
      expect(darkExt, AppTheme.darkTheme.extension<CineplexColors>());
    });

    testWidgets('All shared widgets render safely in unextended ThemeData.light()', (tester) async {
      final dummySeat = SeatModel(
        seatId: 1,
        row: 'A',
        column: 1,
        label: 'A1',
        status: SeatStatus.booked,
        isCouple: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light(), // No CineplexColors extension!
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const AppCard(child: Text('Card')),
                  AppTextField(label: 'Label', hintText: 'Hint'),
                  AppErrorView(message: 'Error message', onRetry: () {}),
                  const AppEmptyView(title: 'Title', message: 'Message'),
                  AppButton(text: 'Button', onPressed: () {}),
                  SeatWidget(seat: dummySeat),
                  const SeatLegend(),
                  const ShimmerSkeleton(width: 100, height: 20),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Card'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
    });

    testWidgets('All shared widgets render safely in unextended ThemeData.dark()', (tester) async {
      final dummySeat = SeatModel(
        seatId: 2,
        row: 'B',
        column: 2,
        label: 'B2',
        status: SeatStatus.available,
        isCouple: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.dark(), // No CineplexColors extension!
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const AppCard(child: Text('Card Dark')),
                  AppTextField(label: 'Label Dark', hintText: 'Hint Dark'),
                  AppErrorView(message: 'Error dark message', onRetry: () {}),
                  const AppEmptyView(title: 'Dark Title', message: 'Dark Message'),
                  AppButton(text: 'Dark Button', onPressed: () {}),
                  SeatWidget(seat: dummySeat),
                  const SeatLegend(),
                  const ShimmerSkeleton(width: 100, height: 20),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Card Dark'), findsOneWidget);
      expect(find.text('Dark Button'), findsOneWidget);
    });

    test('WCAG contrast mathematical validation for light and dark fallback tokens', () {
      final light = CineplexColors.light;
      final dark = CineplexColors.dark;

      // Light mode contrast checks
      final lightTextOnBg = contrastRatio(light.textPrimary, light.background);
      final lightSecOnBg = contrastRatio(light.textSecondary, light.background);
      final lightBookedText = contrastRatio(light.seatBookedText, light.seatBooked);

      expect(lightTextOnBg >= 7.0, isTrue, reason: 'Light textPrimary on background meets WCAG AAA ($lightTextOnBg >= 7.0)');
      expect(lightSecOnBg >= 4.5, isTrue, reason: 'Light textSecondary on background meets WCAG AA ($lightSecOnBg >= 4.5)');
      expect(lightBookedText >= 4.5, isTrue, reason: 'Light seatBookedText on seatBooked meets WCAG AA ($lightBookedText >= 4.5)');

      // Dark mode contrast checks
      final darkTextOnBg = contrastRatio(dark.textPrimary, dark.background);
      final darkSecOnBg = contrastRatio(dark.textSecondary, dark.background);

      expect(darkTextOnBg >= 7.0, isTrue, reason: 'Dark textPrimary on background meets WCAG AAA ($darkTextOnBg >= 7.0)');
      expect(darkSecOnBg >= 4.5, isTrue, reason: 'Dark textSecondary on background meets WCAG AA ($darkSecOnBg >= 4.5)');
    });
  });
}
