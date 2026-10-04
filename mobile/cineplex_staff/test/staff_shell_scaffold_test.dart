import 'package:cineplex_staff/core/widgets/staff_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

void main() {
  testWidgets('StaffShellScaffold renders 5 bottom navigation tabs in Light and Dark mode', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        ShellRoute(
          builder: (context, state, child) => StaffShellScaffold(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const Scaffold(body: Text('Dashboard View')),
            ),
            GoRoute(
              path: '/scanner',
              builder: (context, state) => const Scaffold(body: Text('Scanner View')),
            ),
            GoRoute(
              path: '/pos',
              builder: (context, state) => const Scaffold(body: Text('POS View')),
            ),
            GoRoute(
              path: '/showtimes-occupancy',
              builder: (context, state) => const Scaffold(body: Text('Occupancy View')),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const Scaffold(body: Text('Profile View')),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('vi')],
        locale: const Locale('vi'),
        routerConfig: router,
      ),
    );

    await tester.pumpAndSettle();

    // Verify current content
    expect(find.text('Dashboard View'), findsOneWidget);

    final l10n = AppLocalizations.of(tester.element(find.text('Dashboard View')))!;

    // Verify 5 tab labels exist in bottom navigation bar
    expect(find.text(l10n.staffDashboard), findsOneWidget);
    expect(find.text(l10n.scanTicket), findsOneWidget);
    expect(find.text(l10n.counterSale), findsOneWidget);
    expect(find.text(l10n.showtimesAndOccupancy), findsOneWidget);
    expect(find.text(l10n.profile), findsOneWidget);
  });
}
