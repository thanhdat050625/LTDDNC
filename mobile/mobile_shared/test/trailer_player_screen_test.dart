import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestScreen({
    required ThemeMode mode,
    required String trailerUrl,
    required String title,
    String? genre,
    int? durationMinutes,
    String? description,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('vi')],
      locale: const Locale('vi'),
      home: TrailerPlayerScreen(
        trailerUrl: trailerUrl,
        title: title,
        genre: genre,
        durationMinutes: durationMinutes,
        description: description,
      ),
    );
  }

  group('TrailerPlayerScreen UI & Orientation Tests', () {
    testWidgets(
      'renders video player, title, metadata and fullscreen toggle in Light Mode',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestScreen(
            mode: ThemeMode.light,
            trailerUrl: 'https://youtu.be/QdtPQ0wV53M',
            title: 'Lật Mặt 7: Một Điều Ước',
            genre: 'Gia đình, Tâm lý',
            durationMinutes: 138,
            description: 'Câu chuyện cảm động về gia đình...',
          ),
        );

        // Verify title and header icons
        expect(find.text('Lật Mặt 7: Một Điều Ước'), findsNWidgets(2));
        expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);
        expect(find.byIcon(LucideIcons.maximize), findsOneWidget);

        // Verify metadata
        expect(find.text('Gia đình, Tâm lý'), findsOneWidget);
        expect(find.text('Câu chuyện cảm động về gia đình...'), findsOneWidget);
      },
    );

    testWidgets('renders cleanly with high contrast in Dark Mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestScreen(
          mode: ThemeMode.dark,
          trailerUrl: 'https://youtu.be/QdtPQ0wV53M',
          title: 'Mai',
          genre: 'Tâm lý, Tình cảm',
          durationMinutes: 131,
        ),
      );

      expect(find.text('Mai'), findsNWidgets(2));
      expect(find.text('Tâm lý, Tình cảm'), findsOneWidget);
      expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);
      expect(find.byIcon(LucideIcons.maximize), findsOneWidget);
    });

    testWidgets('toggles fullscreen layout cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestScreen(
          mode: ThemeMode.dark,
          trailerUrl: 'https://youtu.be/QdtPQ0wV53M',
          title: 'Mai',
        ),
      );

      // Tap maximize to enter fullscreen
      await tester.tap(find.byIcon(LucideIcons.maximize));
      await tester.pump();

      // In fullscreen, minimize icon appears and portrait header disappears
      expect(find.byIcon(LucideIcons.minimize), findsOneWidget);

      // Tap minimize to exit fullscreen
      await tester.tap(find.byIcon(LucideIcons.minimize));
      await tester.pump();

      // Back to normal mode without any overflow
      expect(find.byIcon(LucideIcons.maximize), findsOneWidget);
    });

    testWidgets('stress-test narrow mobile and wide viewports with zero RenderFlex overflow', (tester) async {
      final viewports = [
        const Size(320, 568),
        const Size(360, 640),
        const Size(390, 844),
        const Size(412, 915),
        const Size(800, 360), // landscape
      ];

      for (final vp in viewports) {
        tester.view.physicalSize = vp * 2.0;
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          buildTestScreen(
            mode: ThemeMode.dark,
            trailerUrl: 'https://youtu.be/QdtPQ0wV53M',
            title: 'Lật Mặt 7: Một Điều Ước',
            genre: 'Gia đình, Hài',
            durationMinutes: 138,
            description: 'Nội dung tóm tắt phim gia đình cảm động...',
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull, reason: 'Must have zero RenderFlex overflow on viewport $vp');
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
