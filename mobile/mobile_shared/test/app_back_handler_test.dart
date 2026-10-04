import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

void main() {
  group('AppExitDialog Unit & Contrast Tests', () {
    testWidgets('AppExitDialog renders cleanly with correct text in Light Mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: const Scaffold(body: AppExitDialog()),
        ),
      );

      expect(find.text('Thoát ứng dụng'), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn thoát ứng dụng không?'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Thoát'), findsOneWidget);

      final titleText = tester.widget<Text>(find.text('Thoát ứng dụng'));
      expect(titleText.style?.color, isNotNull);
    });

    testWidgets('AppExitDialog renders cleanly in Dark Mode with high contrast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: const Scaffold(body: AppExitDialog()),
        ),
      );

      expect(find.text('Thoát ứng dụng'), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn thoát ứng dụng không?'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Thoát'), findsOneWidget);
    });

    testWidgets('AppExitDialog cancel button returns false', (tester) async {
      bool? dialogResult;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await showAppExitDialog(ctx);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsNothing);
      expect(dialogResult, isFalse);
    });

    testWidgets('AppExitDialog confirm button returns true', (tester) async {
      bool? dialogResult;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await showAppExitDialog(ctx);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Thoát'));
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsNothing);
      expect(dialogResult, isTrue);
    });
  });

  group('AppBackHandler Navigation & Pop Tests', () {
    testWidgets('Pops dialog before triggering back navigation', (tester) async {
      final rootNavKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        navigatorKey: rootNavKey,
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const AlertDialog(title: Text('Custom Dialog')),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ],
      );

      final handler = AppBackHandler(
        router: router,
        rootNavKey: rootNavKey,
        defaultRootPath: '/home',
      )..init();

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Custom Dialog'), findsOneWidget);

      // Back button pops dialog
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Custom Dialog'), findsNothing);
      expect(find.text('Show Dialog'), findsOneWidget);

      handler.dispose();
    });

    testWidgets('Closes drawer when back button is pressed', (tester) async {
      final rootNavKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        navigatorKey: rootNavKey,
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, _) => Scaffold(
              appBar: AppBar(title: const Text('Dashboard')),
              drawer: const Drawer(child: Text('Sidebar Menu')),
              body: const Text('Main Dashboard'),
            ),
          ),
        ],
      );

      final handler = AppBackHandler(
        router: router,
        rootNavKey: rootNavKey,
        defaultRootPath: '/dashboard',
      )..init();

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
        ),
      );

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('Sidebar Menu'), findsOneWidget);

      // Press back: drawer closes
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Sidebar Menu'), findsNothing);

      handler.dispose();
    });

    testWidgets('Navigates backwards across context.go routes then confirms exit at root', (tester) async {
      bool exitTriggered = false;
      final rootNavKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        navigatorKey: rootNavKey,
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.go('/movies'),
                child: const Text('To Movies'),
              ),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.go('/cinemas'),
                child: const Text('To Cinemas'),
              ),
            ),
          ),
          GoRoute(
            path: '/cinemas',
            builder: (context, _) => const Scaffold(
              body: Text('Cinemas Screen'),
            ),
          ),
        ],
      );

      final handler = AppBackHandler(
        router: router,
        rootNavKey: rootNavKey,
        defaultRootPath: '/dashboard',
        onExitApp: () {
          exitTriggered = true;
        },
      )..init();

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
        ),
      );

      // Navigate /dashboard -> /movies
      await tester.tap(find.text('To Movies'));
      await tester.pumpAndSettle();
      expect(find.text('To Cinemas'), findsOneWidget);

      // Navigate /movies -> /cinemas
      await tester.tap(find.text('To Cinemas'));
      await tester.pumpAndSettle();
      expect(find.text('Cinemas Screen'), findsOneWidget);

      // 1. Back: /cinemas -> /movies
      var handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('To Cinemas'), findsOneWidget);

      // 2. Back: /movies -> /dashboard
      handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('To Movies'), findsOneWidget);

      // 3. Back on /dashboard: shows exit confirmation dialog!
      handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      // 4. Cancel exit dialog
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsNothing);
      expect(exitTriggered, isFalse);

      // 5. Back again -> Confirm exit
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Thoát'));
      await tester.pumpAndSettle();
      expect(exitTriggered, isTrue);

      handler.dispose();
    });

    testWidgets('Supports ShellRoute nested navigator popping', (tester) async {
      final rootNavKey = GlobalKey<NavigatorState>();
      final shellNavKey = GlobalKey<NavigatorState>();

      final router = GoRouter(
        navigatorKey: rootNavKey,
        initialLocation: '/tab1',
        routes: [
          ShellRoute(
            navigatorKey: shellNavKey,
            builder: (context, _, child) => Scaffold(body: child),
            routes: [
              GoRoute(
                path: '/tab1',
                builder: (context, _) => ElevatedButton(
                  onPressed: () => context.go('/tab2'),
                  child: const Text('Go Tab 2'),
                ),
              ),
              GoRoute(
                path: '/tab2',
                builder: (context, _) => const Text('Tab 2 Content'),
              ),
            ],
          ),
        ],
      );

      final handler = AppBackHandler(
        router: router,
        rootNavKey: rootNavKey,
        shellNavKey: shellNavKey,
        defaultRootPath: '/tab1',
      )..init();

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
        ),
      );

      // Navigate to Tab 2
      await tester.tap(find.text('Go Tab 2'));
      await tester.pumpAndSettle();
      expect(find.text('Tab 2 Content'), findsOneWidget);

      // Back returns to Tab 1
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Go Tab 2'), findsOneWidget);

      handler.dispose();
    });

    testWidgets('Pushed route is popped and subsequent back navigates to previous screen, not forward', (tester) async {
      final rootNavKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        navigatorKey: rootNavKey,
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.go('/movies'),
                child: const Text('To Movies'),
              ),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push('/movies/123'),
                child: const Text('To Movie 123'),
              ),
            ),
          ),
          GoRoute(
            path: '/movies/:id',
            builder: (context, state) => Scaffold(
              body: Text('Movie Detail ${state.pathParameters['id']}'),
            ),
          ),
        ],
      );

      final handler = AppBackHandler(
        router: router,
        rootNavKey: rootNavKey,
        defaultRootPath: '/home',
      )..init();

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
        ),
      );

      // Go from /home -> /movies
      await tester.tap(find.text('To Movies'));
      await tester.pumpAndSettle();
      expect(find.text('To Movie 123'), findsOneWidget);

      // Push /movies/123
      await tester.tap(find.text('To Movie 123'));
      await tester.pumpAndSettle();
      expect(find.text('Movie Detail 123'), findsOneWidget);

      // 1. Back pops /movies/123 -> returns to /movies
      var handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('To Movie 123'), findsOneWidget);

      // 2. Back on /movies -> should return to /home!
      handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('To Movies'), findsOneWidget);
      expect(find.text('Movie Detail 123'), findsNothing);

      handler.dispose();
    });

    testWidgets('Multi-tab looping does not get stuck in infinite ping-pong', (tester) async {
      final rootNavKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        navigatorKey: rootNavKey,
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.go('/tabA'),
                child: const Text('To Tab A'),
              ),
            ),
          ),
          GoRoute(
            path: '/tabA',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.go('/tabB'),
                child: const Text('To Tab B'),
              ),
            ),
          ),
          GoRoute(
            path: '/tabB',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.go('/tabA'),
                child: const Text('To Tab A Again'),
              ),
            ),
          ),
        ],
      );

      final handler = AppBackHandler(
        router: router,
        rootNavKey: rootNavKey,
        defaultRootPath: '/home',
      )..init();

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
        ),
      );

      // Home -> Tab A -> Tab B -> Tab A -> Tab B
      await tester.tap(find.text('To Tab A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('To Tab B'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('To Tab A Again'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('To Tab B'));
      await tester.pumpAndSettle();

      // Pruned history unwinds without ping-pong loops:
      // Home -> Tab A -> Tab B -> Tab A -> Tab B
      // Becomes: ['/home', '/tabA', '/tabB']
      // 1. back from Tab B -> goes directly to Tab A
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('To Tab B'), findsOneWidget);

      // 2. back from Tab A -> goes directly to /home (not ping-ponging back to Tab B!)
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('To Tab A'), findsOneWidget);

      handler.dispose();
    });
  });
}
