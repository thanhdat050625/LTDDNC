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

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('Staff System Back Button Integration Tests', () {
    testWidgets('Pressing back at /pos triggers exit confirmation dialog', (tester) async {
      bool exitTriggered = false;
      final authBloc = _StaffTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createStaffRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/pos',
        exitOnPaths: {'/pos', '/login'},
        onExitApp: () {
          exitTriggered = true;
        },
      )..init();
      addTearDown(backHandler.dispose);
      addTearDown(authBloc.close);

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await pumpApp(tester);

      // Press back on POS (Ticket Sale)
      final handled = await tester.binding.handlePopRoute();
      await pumpApp(tester);
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn thoát ứng dụng không?'), findsOneWidget);

      // Cancel
      await tester.tap(find.text('Hủy'));
      await pumpApp(tester);
      expect(find.text('Thoát ứng dụng'), findsNothing);
      expect(exitTriggered, isFalse);

      // Confirm exit
      await tester.binding.handlePopRoute();
      await pumpApp(tester);
      await tester.tap(find.text('Thoát'));
      await pumpApp(tester);
      expect(exitTriggered, isTrue);
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
        defaultRootPath: '/pos',
        exitOnPaths: {'/pos', '/login'},
        onExitApp: () {
          exitTriggered = true;
        },
      )..init();
      addTearDown(backHandler.dispose);
      addTearDown(authBloc.close);

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await pumpApp(tester);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');

      // Press back on Login screen
      final handled = await tester.binding.handlePopRoute();
      await pumpApp(tester);
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Thoát'));
      await pumpApp(tester);
      expect(exitTriggered, isTrue);
    });

    testWidgets('Navigating from /pos to other destinations returns to /pos on back', (tester) async {
      final authBloc = _StaffTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createStaffRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/pos',
        exitOnPaths: {'/pos', '/login'},
      )..init();
      addTearDown(backHandler.dispose);
      addTearDown(authBloc.close);

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await pumpApp(tester);

      // Go to /showtimes-occupancy then /profile
      router.go('/showtimes-occupancy');
      await pumpApp(tester);
      router.go('/profile');
      await pumpApp(tester);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/profile');

      // 1. Back: /profile -> /showtimes-occupancy
      var handled = await tester.binding.handlePopRoute();
      await pumpApp(tester);
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/showtimes-occupancy');

      // 2. Back: /showtimes-occupancy -> /pos
      handled = await tester.binding.handlePopRoute();
      await pumpApp(tester);
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/pos');

      // 3. Back on /pos: shows exit dialog
      handled = await tester.binding.handlePopRoute();
      await pumpApp(tester);
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await pumpApp(tester);
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
        defaultRootPath: '/pos',
        exitOnPaths: {'/pos', '/login'},
      )..init();
      addTearDown(backHandler.dispose);
      addTearDown(authBloc.close);

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await pumpApp(tester);

      // Open drawer from scaffold
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await pumpApp(tester);

      // Press back: drawer closes
      final handled = await tester.binding.handlePopRoute();
      await pumpApp(tester);
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsNothing);
    });

    testWidgets('After logout from /pos to /login, back button shows exit dialog immediately', (tester) async {
      final authBloc = _StaffTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createStaffRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/pos',
        exitOnPaths: {'/pos', '/login'},
      )..init();
      addTearDown(backHandler.dispose);
      addTearDown(authBloc.close);

      await tester.pumpWidget(buildStaffTestApp(router: router, authBloc: authBloc));
      await pumpApp(tester);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/pos');

      // Logout
      authBloc.emit(AuthUnauthenticated());
      await pumpApp(tester);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');

      // Press back on /login
      final handled = await tester.binding.handlePopRoute();
      await pumpApp(tester);
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);
    });
  });
}
