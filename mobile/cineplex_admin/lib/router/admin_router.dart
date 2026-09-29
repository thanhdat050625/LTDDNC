import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../features/auth/presentation/screens/admin_login_screen.dart';
import '../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../features/users/presentation/screens/user_management_screen.dart';
import '../features/statistics/presentation/screens/statistics_screen.dart';

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
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
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
