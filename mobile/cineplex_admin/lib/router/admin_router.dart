import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../features/auth/presentation/screens/admin_login_screen.dart';
import '../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../features/users/presentation/screens/user_management_screen.dart';
import '../features/statistics/presentation/screens/statistics_screen.dart';
import '../features/dashboard/presentation/widgets/admin_drawer.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAdminRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: _AdminAuthRefreshNotifier(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isAuth && !isOnLogin) {
        return '/login';
      }

      if (isAuth && isOnLogin) {
        final role = authState.user.role.toUpperCase();
        if (role == 'ADMIN') {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AdminDashboardScreen(drawer: AdminDrawer()),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserManagementScreen(drawer: AdminDrawer()),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(drawer: AdminDrawer()),
      ),
      GoRoute(
        path: '/movies',
        builder: (context, state) => BlocProvider(
          create: (context) => MovieManagementCubit(
            MovieManagementRepository(context.read<DioClient>()),
          ),
          child: const MovieManagementScreen(drawer: AdminDrawer()),
        ),
      ),
      GoRoute(
        path: '/movies/new',
        builder: (context, state) => BlocProvider(
          create: (context) => MovieFormCubit(
            MovieManagementRepository(context.read<DioClient>()),
          ),
          child: const MovieFormScreen(),
        ),
      ),
      GoRoute(
        path: '/movies/:id/edit',
        builder: (context, state) {
          final extra = state.extra as MovieModel?;
          return BlocProvider(
            create: (context) => MovieFormCubit(
              MovieManagementRepository(context.read<DioClient>()),
            ),
            child: MovieFormScreen(movie: extra),
          );
        },
      ),
      GoRoute(
        path: '/showtimes',
        builder: (context, state) => BlocProvider(
          create: (context) => ShowtimeManagementCubit(
            ShowtimeManagementRepository(context.read<DioClient>()),
          ),
          child: const ShowtimeManagementScreen(drawer: AdminDrawer()),
        ),
      ),
      GoRoute(
        path: '/showtimes/new',
        builder: (context, state) => BlocProvider(
          create: (context) => ShowtimeFormCubit(
            ShowtimeManagementRepository(context.read<DioClient>()),
            MovieManagementRepository(context.read<DioClient>()),
            CinemaManagementRepository(context.read<DioClient>()),
          ),
          child: const ShowtimeFormScreen(),
        ),
      ),
      GoRoute(
        path: '/showtimes/:id/edit',
        builder: (context, state) {
          final extra = state.extra as ShowtimeModel?;
          return BlocProvider(
            create: (context) => ShowtimeFormCubit(
              ShowtimeManagementRepository(context.read<DioClient>()),
              MovieManagementRepository(context.read<DioClient>()),
              CinemaManagementRepository(context.read<DioClient>()),
            ),
            child: ShowtimeFormScreen(showtime: extra),
          );
        },
      ),
      GoRoute(
        path: '/cinemas',
        builder: (context, state) => BlocProvider(
          create: (context) => CinemaManagementCubit(
            CinemaManagementRepository(context.read<DioClient>()),
          ),
          child: const CinemaManagementScreen(drawer: AdminDrawer()),
        ),
      ),
      GoRoute(
        path: '/cinemas/new',
        builder: (context, state) => BlocProvider(
          create: (context) => CinemaFormCubit(
            CinemaManagementRepository(context.read<DioClient>()),
          ),
          child: const CinemaFormScreen(),
        ),
      ),
      GoRoute(
        path: '/cinemas/:id/edit',
        builder: (context, state) {
          final extra = state.extra as CinemaModel?;
          return BlocProvider(
            create: (context) => CinemaFormCubit(
              CinemaManagementRepository(context.read<DioClient>()),
            ),
            child: CinemaFormScreen(cinema: extra),
          );
        },
      ),
      GoRoute(
        path: '/cinemas/:cinemaId/rooms',
        builder: (context, state) {
          final cinemaId = int.parse(state.pathParameters['cinemaId']!);
          return BlocProvider(
            create: (context) => RoomManagementCubit(
              CinemaManagementRepository(context.read<DioClient>()),
            ),
            child: RoomManagementScreen(cinemaId: cinemaId),
          );
        },
      ),
      GoRoute(
        path: '/cinemas/:cinemaId/rooms/new',
        builder: (context, state) {
          final cinemaId = int.parse(state.pathParameters['cinemaId']!);
          return BlocProvider(
            create: (context) => RoomFormCubit(
              CinemaManagementRepository(context.read<DioClient>()),
            ),
            child: RoomFormScreen(cinemaId: cinemaId),
          );
        },
      ),
      GoRoute(
        path: '/cinemas/:cinemaId/rooms/:roomId/edit',
        builder: (context, state) {
          final cinemaId = int.parse(state.pathParameters['cinemaId']!);
          final extra = state.extra as RoomModel?;
          return BlocProvider(
            create: (context) => RoomFormCubit(
              CinemaManagementRepository(context.read<DioClient>()),
            ),
            child: RoomFormScreen(cinemaId: cinemaId, room: extra),
          );
        },
      ),
      // Promotions
      GoRoute(
        path: '/promotions',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => PromotionManagementCubit(
              PromotionManagementRepository(context.read<DioClient>()),
            ),
            child: const PromotionManagementScreen(drawer: AdminDrawer()),
          );
        },
      ),
      GoRoute(
        path: '/promotions/new',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => PromotionFormCubit(
              PromotionManagementRepository(context.read<DioClient>()),
            ),
            child: const PromotionFormScreen(),
          );
        },
      ),
      GoRoute(
        path: '/promotions/:id/edit',
        builder: (context, state) {
          final promotion = state.extra as PromotionModel?;
          return BlocProvider(
            create: (context) => PromotionFormCubit(
              PromotionManagementRepository(context.read<DioClient>()),
            ),
            child: PromotionFormScreen(promotion: promotion),
          );
        },
      ),
      // Concessions
      GoRoute(
        path: '/concessions',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => ConcessionManagementCubit(
              ConcessionManagementRepository(context.read<DioClient>()),
            ),
            child: const ConcessionManagementScreen(drawer: AdminDrawer()),
          );
        },
      ),
      GoRoute(
        path: '/concessions/new',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => ConcessionFormCubit(
              ConcessionManagementRepository(context.read<DioClient>()),
            ),
            child: const ConcessionFormScreen(),
          );
        },
      ),
      GoRoute(
        path: '/concessions/:id/edit',
        builder: (context, state) {
          final concession = state.extra as ConcessionProductModel?;
          return BlocProvider(
            create: (context) => ConcessionFormCubit(
              ConcessionManagementRepository(context.read<DioClient>()),
            ),
            child: ConcessionFormScreen(concession: concession),
          );
        },
      ),
    ],
  );
}

class _AdminAuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription _subscription;

  _AdminAuthRefreshNotifier(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
