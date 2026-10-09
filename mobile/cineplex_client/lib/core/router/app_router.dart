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
import 'package:cineplex_client/features/profile/presentation/screens/change_password_screen.dart';
import 'package:cineplex_client/features/showtime/presentation/cubit/showtime_cubit.dart';
import 'package:cineplex_client/features/showtime/data/repositories/showtime_repository.dart';
import 'package:cineplex_client/features/booking/presentation/bloc/seat_booking_bloc.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';
import 'package:cineplex_client/features/concession/presentation/cubit/concession_cubit.dart';
import 'package:cineplex_client/features/concession/data/repositories/concession_repository.dart';
import 'package:cineplex_client/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:cineplex_client/features/payment/data/repositories/payment_repository.dart';
import 'package:cineplex_client/features/payment/data/models/payment_model.dart';
import 'package:cineplex_client/core/router/main_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(
  AuthBloc authBloc, {
  GlobalKey<NavigatorState>? rootNavKey,
  GlobalKey<NavigatorState>? shellNavKey,
}) {
  final rootKey = rootNavKey ?? rootNavigatorKey;
  final shellKey = shellNavKey ?? shellNavigatorKey;
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/home',
    refreshListenable: _AuthRefreshNotifier(authBloc),
    redirect: (context, state) {
      if (state.uri.scheme == 'cineplex') {
        final hostPart = state.uri.host.isNotEmpty ? '/${state.uri.host}' : '';
        final path = '$hostPart${state.uri.path}'.replaceAll('//', '/');
        final query = state.uri.hasQuery ? '?${state.uri.query}' : '';
        return '$path$query';
      }

      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      final isOnAuth =
          state.matchedLocation == '/login' ||
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
        '/change-password',
        '/settings',
      ];
      final isProtected = protectedPrefixes.any(
        (p) => state.matchedLocation.startsWith(p),
      );

      if (!isAuth && isProtected) return '/login';
      if (isAuth && isOnAuth) return '/home';

      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: shellKey,
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
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationScreen(),
          ),
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
          create: (context) =>
              ShowtimeCubit(context.read<ShowtimeRepository>()),
          child: ShowtimeSelectionScreen(
            movieId: int.parse(state.pathParameters['movieId']!),
          ),
        ),
      ),
      GoRoute(
        path: '/booking/:showtimeId',
        builder: (context, state) {
          final showtimeId = int.parse(state.pathParameters['showtimeId']!);
          return BlocProvider(
            create: (ctx) => SeatBookingBloc(
              ctx.read<BookingRepository>(),
              ctx.read<SocketService>(),
            )..add(LoadSeatMap(showtimeId)),
            child: SeatSelectionScreen(showtimeId: showtimeId),
          );
        },
      ),
      GoRoute(
        path: '/concessions/:bookingId',
        builder: (context, state) {
          final bookingId = int.tryParse(state.pathParameters['bookingId'] ?? '0') ?? 0;
          final args = state.extra is ConcessionScreenArgs
              ? state.extra as ConcessionScreenArgs
              : ConcessionScreenArgs(bookingId: bookingId);
          return BlocProvider(
            create: (ctx) =>
                ConcessionCubit(
                  ctx.read<ConcessionRepository>(),
                  ctx.read<BookingRepository>(),
                )..loadConcessions(),
            child: ConcessionScreen(bookingId: bookingId, args: args),
          );
        },
      ),
      GoRoute(
        path: '/checkout/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          final args = state.extra is CheckoutScreenArgs ? state.extra as CheckoutScreenArgs : null;
          return BlocProvider(
            create: (ctx) {
              final cubit = PaymentCubit(
                ctx.read<PaymentRepository>(),
                ctx.read<BookingRepository>(),
              );
              if ((bookingId == '0' || bookingId.isEmpty) && args != null) {
                cubit.prepareCheckoutDraft(args);
              } else {
                cubit.prepareCheckout(bookingId);
              }
              return cubit;
            },
            child: CheckoutScreen(bookingId: bookingId, args: args),
          );
        },
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
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BlocProvider(
            create: (ctx) =>
                PaymentCubit(ctx.read<PaymentRepository>())
                  ..checkStatus(bookingId),
            child: PaymentResultScreen(bookingId: bookingId),
          );
        },
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
      GoRoute(
        path: '/change-password',
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const AppSettingsScreen(appName: 'Cineplex Client'),
      ),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
