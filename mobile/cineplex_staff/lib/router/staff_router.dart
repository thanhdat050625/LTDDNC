import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../features/auth/presentation/screens/staff_login_screen.dart';
import '../features/scanner/presentation/screens/staff_scanner_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createStaffRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/scanner',
    refreshListenable: _StaffAuthRefreshNotifier(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isAuth && !isOnLogin) {
        return '/login';
      }

      if (isAuth && isOnLogin) {
        final role = authState.user.role.toUpperCase();
        if (role == 'STAFF' || role == 'ADMIN') {
          return '/scanner';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const StaffLoginScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const StaffScannerScreen(),
      ),
      GoRoute(
        path: '/ticket-sale',
        builder: (context, state) => const TicketSaleScreen(),
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

class _StaffAuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription _subscription;

  _StaffAuthRefreshNotifier(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
