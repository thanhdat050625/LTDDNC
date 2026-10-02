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
        path: '/ticket-sale',
        builder: (context, state) => const TicketSaleScreen(drawer: AdminDrawer()),
      ),
      GoRoute(
        path: '/ticket-sale/seat-selection',
        builder: (context, state) => const SeatSelectionScreen(),
      ),
      GoRoute(
        path: '/ticket-sale/checkout',
        builder: (context, state) => const CheckoutScreen(),
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
