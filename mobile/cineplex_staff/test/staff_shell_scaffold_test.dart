import 'package:cineplex_staff/core/widgets/staff_shell_scaffold.dart';
import 'package:cineplex_staff/features/home/presentation/widgets/staff_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserModel?> checkAuth() async {
    return const UserModel(
      id: 2,
      email: 'staff@cineplex.vn',
      fullName: 'Nhân Viên Rạp',
      role: 'STAFF',
      status: 'ACTIVE',
    );
  }
}

class _TestAuthBloc extends AuthBloc {
  _TestAuthBloc() : super(_FakeAuthRepository()) {
    emit(
      const AuthAuthenticated(
        UserModel(
          id: 2,
          email: 'staff@cineplex.vn',
          fullName: 'Nhân Viên Rạp',
          role: 'STAFF',
          status: 'ACTIVE',
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'StaffShellScaffold renders child directly without bottom navigation bar',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                StaffShellScaffold(child: child),
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) =>
                    const Scaffold(body: Text('Dashboard View')),
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

      // Verify current content is rendered directly
      expect(find.text('Dashboard View'), findsOneWidget);

      // Verify no bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
    },
  );

  testWidgets(
    'StaffDrawer renders header, navigation items, theme switcher, and logout',
    (tester) async {
      final authBloc = _TestAuthBloc();
      final themeCubit = ThemeCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            home: const Scaffold(
              drawer: StaffDrawer(),
              body: Text('Home Screen'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open Drawer via swipe or openDrawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(StaffDrawer)),
      )!;

      // Verify User Header with Staff Badge
      expect(find.text('Nhân Viên Rạp'), findsOneWidget);
      expect(find.text('staff@cineplex.vn'), findsOneWidget);
      expect(find.text(l10n.staffBadge), findsOneWidget);

      // Verify Top Navigation Destinations
      expect(find.text(l10n.staffDashboard), findsOneWidget);
      expect(find.text(l10n.scanTicket), findsOneWidget);
      expect(find.text(l10n.counterSale), findsOneWidget);
      expect(find.text(l10n.ticketManagement), findsOneWidget);

      // Verify Remaining Management Items (scroll ListView to ensure visibility)
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text(l10n.manageMovies), findsOneWidget);
      expect(find.text(l10n.manageShowtimes), findsOneWidget);
      expect(find.text(l10n.manageCinemas), findsOneWidget);
      expect(find.text(l10n.showtimesAndOccupancy), findsOneWidget);
      expect(find.text(l10n.managePromotions), findsOneWidget);
      expect(find.text(l10n.manageConcessions), findsOneWidget);
      expect(find.text(l10n.adminSettings), findsOneWidget);

      // Verify Theme Switcher and Logout
      expect(find.text(l10n.themeModeDark), findsOneWidget);
      expect(find.text(l10n.logout), findsOneWidget);
    },
  );
}
