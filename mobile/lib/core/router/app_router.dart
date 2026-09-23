import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cineplex_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cineplex_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:cineplex_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:cineplex_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:cineplex_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:cineplex_mobile/features/movie/presentation/screens/movie_list_screen.dart';
import 'package:cineplex_mobile/features/movie/presentation/screens/movie_detail_screen.dart';
import 'package:cineplex_mobile/features/showtime/presentation/screens/showtime_selection_screen.dart';
import 'package:cineplex_mobile/features/booking/presentation/screens/seat_selection_screen.dart';
import 'package:cineplex_mobile/features/concession/presentation/screens/concession_screen.dart';
import 'package:cineplex_mobile/features/payment/presentation/screens/checkout_screen.dart';
import 'package:cineplex_mobile/features/payment/presentation/screens/payment_webview_screen.dart';
import 'package:cineplex_mobile/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:cineplex_mobile/features/ticket/presentation/screens/my_tickets_screen.dart';
import 'package:cineplex_mobile/features/notification/presentation/screens/notification_screen.dart';
import 'package:cineplex_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:cineplex_mobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:cineplex_mobile/features/staff/presentation/screens/staff_scanner_screen.dart';
import 'package:cineplex_mobile/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:cineplex_mobile/core/router/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: _AuthRefreshNotifier(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      final protectedPrefixes = [
        '/booking', '/concessions', '/checkout', '/payment',
        '/my-tickets', '/notifications', '/profile', '/staff', '/statistics',
      ];
      final isProtected = protectedPrefixes.any((p) => state.matchedLocation.startsWith(p));

      if (!isAuth && isProtected) return '/login';
      if (isAuth && isOnAuth) return '/home';
      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/movies', builder: (_, __) => const MovieListScreen()),
          GoRoute(path: '/my-tickets', builder: (_, __) => const MyTicketsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Feature routes (full screen, no bottom nav)
      GoRoute(
        path: '/movies/:id',
        builder: (_, state) {
          final movieId = int.parse(state.pathParameters['id']!);
          return MovieDetailScreen(movieId: movieId);
        },
      ),
      GoRoute(
        path: '/showtimes/:movieId',
        builder: (_, state) => ShowtimeSelectionScreen(
          movieId: int.parse(state.pathParameters['movieId']!),
        ),
      ),
      GoRoute(
        path: '/booking/:showtimeId',
        builder: (_, state) => SeatSelectionScreen(
          showtimeId: int.parse(state.pathParameters['showtimeId']!),
        ),
      ),
      GoRoute(
        path: '/concessions/:bookingId',
        builder: (_, state) => ConcessionScreen(
          bookingId: int.parse(state.pathParameters['bookingId']!),
        ),
      ),
      GoRoute(
        path: '/checkout/:bookingId',
        builder: (_, state) => CheckoutScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
      GoRoute(
        path: '/payment-webview',
        builder: (_, state) => PaymentWebviewScreen(
          url: state.uri.queryParameters['url'] ?? '',
          bookingId: state.uri.queryParameters['bookingId'] ?? '0',
        ),
      ),
      GoRoute(
        path: '/payment-result/:bookingId',
        builder: (_, state) => PaymentResultScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
      GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/staff/scanner', builder: (_, __) => const StaffScannerScreen()),
      GoRoute(path: '/statistics', builder: (_, __) => const StatisticsScreen()),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
