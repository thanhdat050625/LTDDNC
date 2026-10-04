import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_admin/router/admin_router.dart';
import 'package:cineplex_admin/features/statistics/data/repositories/statistics_repository.dart';
import 'package:cineplex_admin/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:cineplex_admin/features/users/data/repositories/user_management_repository.dart';
import 'package:cineplex_admin/features/users/presentation/cubit/user_management_cubit.dart';

class _FakeAuthRepo extends AuthRepository {
  _FakeAuthRepo(StorageService storage) : super(DioClient(storage), storage);

  @override
  Future<UserModel?> checkAuth() async {
    return const UserModel(
      id: 1,
      email: 'admin@cineplex.vn',
      fullName: 'Quản Trị Viên',
      role: 'ADMIN',
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

class _AdminTestAuthBloc extends AuthBloc {
  _AdminTestAuthBloc() : super(_FakeAuthRepo(_FakeStorage())) {
    emit(
      const AuthAuthenticated(
        UserModel(
          id: 1,
          email: 'admin@cineplex.vn',
          fullName: 'Quản Trị Viên',
          role: 'ADMIN',
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

class _FakeStatisticsRepo implements StatisticsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<SummaryModel> getSummary() async {
    return const SummaryModel(
      revenue: 150000000,
      tickets: 1850,
      cinemas: 8,
      activeMovies: 12,
    );
  }

  @override
  Future<List<RevenuePeriodModel>> getRevenueStatistics({
    String filterType = 'year',
    int? year,
    int? month,
    String? startDate,
    String? endDate,
  }) async {
    return const [
      RevenuePeriodModel(period: '1', revenue: 50000000),
      RevenuePeriodModel(period: '2', revenue: 60000000),
      RevenuePeriodModel(period: '3', revenue: 40000000),
    ];
  }

  @override
  Future<List<MoviePerformanceModel>> getMoviePerformance() async {
    return const [
      MoviePerformanceModel(
        id: 1,
        title: 'Mai',
        ticketsSold: 1200,
        revenue: 120000000,
        occupancyRate: 85,
      ),
    ];
  }
}

class _FakeUserManagementRepo implements UserManagementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserManagementResult> getUsers({
    int page = 1,
    int pageSize = 10,
    String? role,
    String? status,
    String? keyword,
  }) async {
    return const UserManagementResult(
      users: [
        UserModel(
          id: 1,
          email: 'customer@cineplex.vn',
          fullName: 'Trần Khách Hàng',
          role: 'CUSTOMER',
          status: 'ACTIVE',
          loyaltyPoints: 120,
        ),
      ],
      totalAll: 1,
      totalCustomers: 1,
      totalStaff: 0,
      totalBlocked: 0,
    );
  }
}

Widget buildAdminTestApp({
  required GoRouter router,
  required AuthBloc authBloc,
}) {
  final storage = _FakeStorage();
  final dio = DioClient(storage);
  final statsRepo = _FakeStatisticsRepo();
  final usersRepo = _FakeUserManagementRepo();

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<StorageService>.value(value: storage),
      RepositoryProvider<DioClient>.value(value: dio),
      RepositoryProvider<AuthRepository>.value(value: _FakeAuthRepo(storage)),
      RepositoryProvider<StatisticsRepository>.value(value: statsRepo),
      RepositoryProvider<UserManagementRepository>.value(value: usersRepo),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<StatisticsCubit>(create: (_) => StatisticsCubit(statsRepo)),
        BlocProvider<UserManagementCubit>(create: (_) => UserManagementCubit(usersRepo)),
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
  group('Admin System Back Button Integration Tests', () {
    testWidgets('Pressing back at /statistics triggers exit confirmation dialog', (tester) async {
      bool exitTriggered = false;
      final authBloc = _AdminTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final router = createAdminRouter(authBloc, rootNavKey: rootKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        defaultRootPath: '/statistics',
        exitOnPaths: {'/statistics', '/login'},
        onExitApp: () {
          exitTriggered = true;
        },
      )..init();

      await tester.pumpWidget(buildAdminTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Press back on Statistics screen
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

    testWidgets('Pressing back at /login for unauthenticated admin shows exit dialog', (tester) async {
      bool exitTriggered = false;
      final authBloc = _UnauthTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final router = createAdminRouter(authBloc, rootNavKey: rootKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        defaultRootPath: '/statistics',
        exitOnPaths: {'/statistics', '/login'},
        onExitApp: () {
          exitTriggered = true;
        },
      )..init();

      await tester.pumpWidget(buildAdminTestApp(router: router, authBloc: authBloc));
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

    testWidgets('Navigating /statistics -> /users -> /profile returns to /users then /statistics', (tester) async {
      final authBloc = _AdminTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final router = createAdminRouter(authBloc, rootNavKey: rootKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        defaultRootPath: '/statistics',
        exitOnPaths: {'/statistics', '/login'},
      )..init();

      await tester.pumpWidget(buildAdminTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Go to /users then /profile
      router.go('/users');
      await tester.pumpAndSettle();
      router.go('/profile');
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/profile');

      // 1. Back: /profile -> /users
      var handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/users');

      // 2. Back: /users -> /statistics
      handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/statistics');

      // 3. Back on /statistics: shows exit dialog
      handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      backHandler.dispose();
      authBloc.close();
    });

    testWidgets('Open AdminDrawer is closed on back press without exiting', (tester) async {
      final authBloc = _AdminTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final router = createAdminRouter(authBloc, rootNavKey: rootKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        defaultRootPath: '/statistics',
        exitOnPaths: {'/statistics', '/login'},
      )..init();

      await tester.pumpWidget(buildAdminTestApp(router: router, authBloc: authBloc));
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

    testWidgets('After logout from /statistics to /login, back button shows exit dialog immediately', (tester) async {
      final authBloc = _AdminTestAuthBloc();
      final rootKey = GlobalKey<NavigatorState>();
      final router = createAdminRouter(authBloc, rootNavKey: rootKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        defaultRootPath: '/statistics',
        exitOnPaths: {'/statistics', '/login'},
      )..init();

      await tester.pumpWidget(buildAdminTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/statistics');

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
