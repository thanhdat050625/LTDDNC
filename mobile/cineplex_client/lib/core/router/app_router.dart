import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/auth/presentation/screens/login_screen.dart';
import 'package:cineplex_client/features/auth/presentation/screens/register_screen.dart';
import 'package:cineplex_client/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:cineplex_client/features/home/presentation/screens/home_screen.dart';
import 'package:cineplex_client/features/movie/presentation/screens/movie_list_screen.dart';
import 'package:cineplex_client/features/movie/presentation/screens/movie_detail_screen.dart';
import 'package:cineplex_client/features/showtime/presentation/screens/showtime_selection_screen.dart';
import 'package:cineplex_client/features/booking/presentation/screens/seat_selection_screen.dart';
import 'package:cineplex_client/features/concession/presentation/screens/concession_screen.dart';
import 'package:cineplex_client/features/payment/presentation/screens/checkout_screen.dart';
import 'package:cineplex_client/features/payment/presentation/screens/payment_webview_screen.dart';
import 'package:cineplex_client/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:cineplex_client/features/ticket/presentation/screens/my_tickets_screen.dart';
import 'package:cineplex_client/features/ticket/presentation/screens/ticket_detail_screen.dart';
import 'package:cineplex_client/features/ticket/presentation/cubit/my_tickets_cubit.dart';
import 'package:cineplex_client/features/ticket/data/repositories/ticket_repository.dart';
import 'package:cineplex_client/features/notification/presentation/screens/notification_screen.dart';
import 'package:cineplex_client/features/profile/presentation/screens/profile_screen.dart';
import 'package:cineplex_client/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:cineplex_client/features/showtime/presentation/cubit/showtime_cubit.dart';
import 'package:cineplex_client/features/showtime/data/repositories/showtime_repository.dart';
import 'package:cineplex_client/core/router/main_shell.dart';

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
        '/booking',
        '/concessions',
        '/checkout',
        '/payment',
        '/my-tickets',
        '/notifications',
        '/profile',
        '/edit-profile',
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
          GoRoute(
            path: '/my-tickets',
            builder: (context, _) => BlocProvider(
              create: (ctx) => MyTicketsCubit(ctx.read<TicketRepository>()),
              child: const MyTicketsScreen(),
            ),
          ),
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
        builder: (_, state) => BlocProvider(
          create: (context) => ShowtimeCubit(context.read<ShowtimeRepository>()),
          child: ShowtimeSelectionScreen(
            movieId: int.parse(state.pathParameters['movieId']!),
          ),
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
      GoRoute(
        path: '/my-tickets/:id',
        builder: (_, state) {
          final booking = state.extra as BookingDetailModel;
          return TicketDetailScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (_, state) => EditProfileScreen(
          initialUser: state.extra as Map<String, dynamic>?,
        ),
      ),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
