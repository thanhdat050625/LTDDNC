import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_staff/router/staff_router.dart';
import 'package:cineplex_staff/features/scanner/data/repositories/staff_repository.dart';
import 'package:cineplex_staff/features/scanner/presentation/cubit/staff_cubit.dart';

class _FakeAuthRepo extends AuthRepository {
  _FakeAuthRepo(StorageService storage) : super(DioClient(storage), storage);

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

class _FakeStorage extends StorageService {
  @override
  Future<String?> getToken() async => 'fake-token';
  @override
  Future<void> saveToken(String token) async {}
  @override
  Future<void> deleteToken() async {}
}

class _StaffTestAuthBloc extends AuthBloc {
  _StaffTestAuthBloc() : super(_FakeAuthRepo(_FakeStorage())) {
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

class _UnauthTestAuthBloc extends AuthBloc {
  _UnauthTestAuthBloc() : super(_FakeAuthRepo(_FakeStorage())) {
    emit(AuthUnauthenticated());
  }
}

Widget buildStaffTestApp({
  required GoRouter router,
  required AuthBloc authBloc,
}) {
  final storage = _FakeStorage();
  final dio = DioClient(storage);
  final staffRepo = StaffRepository(dio);

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<StorageService>.value(value: storage),
      RepositoryProvider<DioClient>.value(value: dio),
      RepositoryProvider<AuthRepository>.value(value: _FakeAuthRepo(storage)),
      RepositoryProvider<StaffRepository>.value(value: staffRepo),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<StaffCubit>(create: (_) => StaffCubit(staffRepo)),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(storage)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('vi')],
        locale: const Locale('vi'),
      ),
    ),
  );
}

void main() {
  group('Staff System Back Button Integration Tests', () {
    testWidgets('Pressing back at /dashboard triggers exit confirmation dialog', (tester) async {
      bool exitTriggered = false;
      final authBloc = _StaffTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createStaffRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/dashboard',
        exitOnPaths: {'/dashboard', '/login'},
        onExitApp: () {
          exitTriggered = true;
        },
      )..init();

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Press back on Dashboard
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn thoát ứng dụng không?'), findsOneWidget);

      // Cancel
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsNothing);
      expect(exitTriggered, isFalse);

      // Confirm exit
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thoát'));
      await tester.pumpAndSettle();
      expect(exitTriggered, isTrue);

      backHandler.dispose();
      authBloc.close();
    });

    testWidgets('Pressing back at /login for unauthenticated staff shows exit dialog', (tester) async {
      bool exitTriggered = false;
      final authBloc = _UnauthTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createStaffRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/dashboard',
        exitOnPaths: {'/dashboard', '/login'},
        onExitApp: () {
          exitTriggered = true;
        },
      )..init();

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');

      // Press back on Login screen
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Thoát'));
      await tester.pumpAndSettle();
      expect(exitTriggered, isTrue);

      backHandler.dispose();
      authBloc.close();
    });

    testWidgets('Navigating from /dashboard to other destinations returns to /dashboard on back', (tester) async {
      final authBloc = _StaffTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createStaffRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/dashboard',
        exitOnPaths: {'/dashboard', '/login'},
      )..init();

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Go to /showtimes-occupancy then /profile
      router.go('/showtimes-occupancy');
      await tester.pumpAndSettle();
      router.go('/profile');
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/profile');

      // 1. Back: /profile -> /showtimes-occupancy
      var handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/showtimes-occupancy');

      // 2. Back: /showtimes-occupancy -> /dashboard
      handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/dashboard');

      // 3. Back on /dashboard: shows exit dialog
      handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      backHandler.dispose();
      authBloc.close();
    });

    testWidgets('Open StaffDrawer is closed on back press without exiting', (tester) async {
      final authBloc = _StaffTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createStaffRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/dashboard',
        exitOnPaths: {'/dashboard', '/login'},
      )..init();

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Open drawer from scaffold
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Press back: drawer closes
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsNothing);

      backHandler.dispose();
      authBloc.close();
    });

    testWidgets('After logout from /dashboard to /login, back button shows exit dialog immediately', (tester) async {
      final authBloc = _StaffTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createStaffRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/dashboard',
        exitOnPaths: {'/dashboard', '/login'},
      )..init();

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/dashboard');

      // Logout
      authBloc.emit(AuthUnauthenticated());
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');

      // Press back on /login
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      backHandler.dispose();
      authBloc.close();
    });
  });
}
