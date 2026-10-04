import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:go_router/go_router.dart';
import 'package:cineplex_client/core/router/app_router.dart';
import 'package:cineplex_client/features/home/data/repositories/home_repository.dart';
import 'package:cineplex_client/features/home/presentation/cubit/home_cubit.dart';
import 'package:cineplex_client/features/movie/data/repositories/movie_repository.dart';
import 'package:cineplex_client/features/notification/data/repositories/notification_repository.dart';
import 'package:cineplex_client/features/notification/data/models/notification_model.dart';
import 'package:cineplex_client/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:cineplex_client/features/profile/data/repositories/profile_repository.dart';
import 'package:cineplex_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cineplex_client/features/ticket/data/repositories/ticket_repository.dart';

class _FakeAuthRepo extends AuthRepository {
  _FakeAuthRepo(StorageService storage) : super(DioClient(storage), storage);
}

class _FakeStorage extends StorageService {
  @override
  Future<String?> getToken() async => null;
  @override
  Future<void> saveToken(String token) async {}
  @override
  Future<void> deleteToken() async {}
}

class _FakeHomeRepo extends HomeRepository {
  _FakeHomeRepo(super.dioClient);
  @override
  Future<HomeDataModel> getHomeData() async {
    return const HomeDataModel(nowShowing: [], comingSoon: [], activePromotions: []);
  }
}

class _FakeMovieRepo extends MovieRepository {
  _FakeMovieRepo(super.dioClient);
  @override
  Future<({List<MovieModel> movies, int totalPages})> getAllMovies(
      int page, int pageSize, {String? genre}) async {
    return (movies: <MovieModel>[], totalPages: 1);
  }
}

class _FakeNotificationRepo extends NotificationRepository {
  _FakeNotificationRepo(super.dioClient);
  @override
  Future<List<NotificationModel>> getNotifications({int page = 1}) async => [];
  @override
  Future<int> getUnreadCount() async => 0;
}

class _FakeProfileRepo extends ProfileRepository {
  _FakeProfileRepo(super.dioClient);
  @override
  Future<Map<String, dynamic>> getProfile() async => {'id': 1, 'fullName': 'Test User'};
}

class _FakeTicketRepo extends TicketRepository {
  _FakeTicketRepo(super.dioClient);
  @override
  Future<List<BookingDetailModel>> getMyBookings({int page = 1, int pageSize = 20}) async => [];
}

Widget buildTestApp({
  required GoRouter router,
  required AuthBloc authBloc,
}) {
  final storage = _FakeStorage();
  final dio = DioClient(storage);

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<StorageService>.value(value: storage),
      RepositoryProvider<DioClient>.value(value: dio),
      RepositoryProvider<MovieRepository>.value(value: _FakeMovieRepo(dio)),
      RepositoryProvider<TicketRepository>.value(value: _FakeTicketRepo(dio)),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<HomeCubit>(create: (_) => HomeCubit(_FakeHomeRepo(dio))),
        BlocProvider<NotificationCubit>(create: (_) => NotificationCubit(_FakeNotificationRepo(dio))),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit(_FakeProfileRepo(dio))),
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
  group('Client System Back Button Integration Tests', () {
    testWidgets('Pressing back at /home triggers exit confirmation dialog', (tester) async {
      bool exitTriggered = false;
      final authBloc = AuthBloc(_FakeAuthRepo(_FakeStorage()));
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/home',
        exitOnPaths: {'/home'},
        onExitApp: () {
          exitTriggered = true;
        },
      )..init();

      await tester.pumpWidget(buildTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Press back on Home
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn thoát ứng dụng không?'), findsOneWidget);

      // Tap 'Hủy' to dismiss
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsNothing);
      expect(exitTriggered, isFalse);

      // Press back again and tap 'Thoát'
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Thoát'));
      await tester.pumpAndSettle();
      expect(exitTriggered, isTrue);

      backHandler.dispose();
      authBloc.close();
    });

    testWidgets('Navigating from /home to /movies tab then pressing back returns to /home', (tester) async {
      final authBloc = AuthBloc(_FakeAuthRepo(_FakeStorage()));
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/home',
        exitOnPaths: {'/home'},
      )..init();

      await tester.pumpWidget(buildTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Go to /movies tab
      router.go('/movies');
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/movies');

      // Press back
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');

      backHandler.dispose();
      authBloc.close();
    });

    testWidgets('Multi-step tab navigation unwinds correctly before root exit', (tester) async {
      final authBloc = AuthBloc(_FakeAuthRepo(_FakeStorage()));
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/home',
        exitOnPaths: {'/home'},
      )..init();

      await tester.pumpWidget(buildTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Navigate: /home -> /movies -> /login
      router.go('/movies');
      await tester.pumpAndSettle();
      router.go('/login');
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');

      // 1. Back: /login -> /movies
      var handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/movies');

      // 2. Back: /movies -> /home
      handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');

      // 3. Back on /home: shows exit dialog!
      handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      backHandler.dispose();
      authBloc.close();
    });

    testWidgets('Open dialog is closed first on back press without exiting', (tester) async {
      final authBloc = AuthBloc(_FakeAuthRepo(_FakeStorage()));
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/home',
        exitOnPaths: {'/home'},
      )..init();

      await tester.pumpWidget(buildTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Open a custom modal dialog on root navigator
      showDialog(
        context: rootKey.currentContext!,
        builder: (ctx) => const AlertDialog(title: Text('Test Popup')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Test Popup'), findsOneWidget);

      // Press back: should dismiss the popup dialog
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(find.text('Test Popup'), findsNothing);
      expect(find.text('Thoát ứng dụng'), findsNothing);

      backHandler.dispose();
      authBloc.close();
    });

    testWidgets('Tab navigation loops prune cleanly on back press', (tester) async {
      final authBloc = AuthBloc(_FakeAuthRepo(_FakeStorage()));
      final rootKey = GlobalKey<NavigatorState>();
      final shellKey = GlobalKey<NavigatorState>();
      final router = createRouter(authBloc, rootNavKey: rootKey, shellNavKey: shellKey);

      final backHandler = AppBackHandler(
        router: router,
        rootNavKey: rootKey,
        shellNavKey: shellKey,
        defaultRootPath: '/home',
        exitOnPaths: {'/home'},
      )..init();

      await tester.pumpWidget(buildTestApp(router: router, authBloc: authBloc));
      await tester.pumpAndSettle();

      // Home -> /movies -> /notifications -> /movies
      router.go('/movies');
      await tester.pumpAndSettle();
      router.go('/notifications');
      await tester.pumpAndSettle();
      router.go('/movies');
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/movies');

      // 1. Back: /movies -> /home (because /movies was returned to, pruning /notifications)
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');

      // 2. Back on /home: shows exit dialog!
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Thoát ứng dụng'), findsOneWidget);

      backHandler.dispose();
      authBloc.close();
    });
  });
}
