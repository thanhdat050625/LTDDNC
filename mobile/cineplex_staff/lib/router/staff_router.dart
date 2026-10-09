import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

import '../core/widgets/staff_shell_scaffold.dart';
import '../features/auth/presentation/screens/staff_login_screen.dart';
import '../features/dashboard/presentation/screens/staff_dashboard_screen.dart';
import '../features/profile/presentation/screens/staff_profile_screen.dart';
import '../features/scanner/presentation/screens/staff_scanner_screen.dart';
import '../features/ticket_sale/data/models/checkout_args.dart';
import '../features/ticket_sale/presentation/cubit/ticket_sale_cubit.dart';
import '../features/ticket_sale/presentation/screens/checkout_screen.dart';
import '../features/ticket_sale/presentation/screens/concession_selection_screen.dart';
import '../features/ticket_sale/presentation/screens/payment_result_screen.dart';
import '../features/ticket_sale/presentation/screens/seat_selection_screen.dart';
import '../features/ticket_sale/presentation/screens/ticket_sale_screen.dart';

final staffRootNavigatorKey = GlobalKey<NavigatorState>();
final staffShellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createStaffRouter(
  AuthBloc authBloc, {
  GlobalKey<NavigatorState>? rootNavKey,
  GlobalKey<NavigatorState>? shellNavKey,
}) {
  final rootKey = rootNavKey ?? staffRootNavigatorKey;
  final shellKey = shellNavKey ?? staffShellNavigatorKey;
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/scanner',
    refreshListenable: _StaffAuthRefreshNotifier(authBloc),
    redirect: (context, state) {
      if (state.uri.scheme == 'cineplexstaff') {
        final hostPart = state.uri.host.isNotEmpty ? '/${state.uri.host}' : '';
        final path = '$hostPart${state.uri.path}'.replaceAll('//', '/');
        final query = state.uri.hasQuery ? '?${state.uri.query}' : '';
        return path.isEmpty ? '/pos' : '$path$query';
      }

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

      if (state.matchedLocation == '/dashboard') {
        return '/scanner';
      }

      if (state.matchedLocation == '/ticket-sale') {
        return '/pos';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const StaffLoginScreen(),
      ),

      // 5 Core Staff Destinations hosted in ShellRoute
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) => StaffShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const StaffDashboardScreen(),
          ),
          GoRoute(
            path: '/scanner',
            builder: (context, state) => const StaffScannerScreen(),
          ),
          GoRoute(
            path: '/pos',
            builder: (context, state) => const TicketSaleScreen(),
          ),
          GoRoute(
            path: '/showtimes-occupancy',
            builder: (context, state) =>
                const ShowtimeOccupancyScreen(drawer: StaffDrawer()),
          ),
          GoRoute(
            path: '/my-schedule',
            builder: (context, state) => BlocProvider(
              create: (context) => StaffMyScheduleCubit(
                ShiftRepository(context.read<DioClient>()),
              ),
              child: const StaffMyScheduleScreen(drawer: StaffDrawer()),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const StaffProfileScreen(),
          ),
        ],
      ),

      // Fullscreen Ticket Sale Flow
      GoRoute(
        path: '/ticket-sale/seat-selection',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is TicketSaleCubit) {
            return BlocProvider.value(
              value: extra,
              child: const SeatSelectionScreen(),
            );
          }
          final dioClient = context.read<DioClient>();
          final authState = context.read<AuthBloc>().state;
          final staffUser = authState is AuthAuthenticated ? authState.user : null;
          final defaultCinemaId = staffUser?.cinema?.id ?? staffUser?.cinemaId;
          return BlocProvider(
            create: (_) => TicketSaleCubit(
              CinemaManagementRepository(dioClient),
              ShowtimeManagementRepository(dioClient),
              BookingManagementRepository(dioClient),
            )..loadInitialData(defaultCinemaId: defaultCinemaId),
            child: const SeatSelectionScreen(),
          );
        },
      ),
      GoRoute(
        path: '/ticket-sale/concessions',
        builder: (context, state) {
          final args = state.extra as CheckoutArgs?;
          return ConcessionSelectionScreen(args: args);
        },
      ),
      GoRoute(
        path: '/ticket-sale/checkout',
        builder: (context, state) {
          final args = state.extra as CheckoutArgs?;
          return CheckoutScreen(args: args);
        },
      ),
      GoRoute(
        path: '/ticket-sale/payment-result/:id',
        builder: (context, state) {
          final bookingId = state.pathParameters['id'] ?? '0';
          final extra = state.extra as Map<String, dynamic>?;
          return StaffPaymentResultScreen(
            bookingId: bookingId,
            initialData: extra,
          );
        },
      ),
      GoRoute(
        path: '/payment-result/:id',
        builder: (context, state) {
          final bookingId = state.pathParameters['id'] ?? '0';
          final extra = state.extra as Map<String, dynamic>?;
          return StaffPaymentResultScreen(
            bookingId: bookingId,
            initialData: extra,
          );
        },
      ),

      // Admin / Managerial CRUD routes
      GoRoute(
        path: '/ticket-management',
        builder: (context, state) => BlocProvider(
          create: (context) => TicketManagementCubit(
            BookingManagementRepository(context.read<DioClient>()),
          ),
          child: const TicketManagementScreen(drawer: StaffDrawer()),
        ),
      ),
      GoRoute(
        path: '/movies',
        builder: (context, state) => BlocProvider(
          create: (context) => MovieManagementCubit(
            MovieManagementRepository(context.read<DioClient>()),
          ),
          child: const MovieManagementScreen(drawer: StaffDrawer()),
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
        path: '/movies/:id',
        builder: (context, state) {
          final movieId = int.parse(state.pathParameters['id']!);
          final extra = state.extra as MovieModel?;
          return MovieManagementDetailScreen(
            movieId: movieId,
            initialMovie: extra,
          );
        },
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
          child: const ShowtimeManagementScreen(drawer: StaffDrawer()),
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
          child: const ShowtimeFormScreen(drawer: StaffDrawer()),
        ),
      ),
      GoRoute(
        path: '/showtimes/bulk',
        builder: (context, state) => BlocProvider(
          create: (context) => ShowtimeBulkCreateCubit(
            ShowtimeManagementRepository(context.read<DioClient>()),
            MovieManagementRepository(context.read<DioClient>()),
            CinemaManagementRepository(context.read<DioClient>()),
          ),
          child: const ShowtimeBulkCreateScreen(drawer: StaffDrawer()),
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
            child: ShowtimeFormScreen(showtime: extra, drawer: const StaffDrawer()),
          );
        },
      ),
      GoRoute(
        path: '/cinemas',
        builder: (context, state) => BlocProvider(
          create: (context) => CinemaManagementCubit(
            CinemaManagementRepository(context.read<DioClient>()),
          ),
          child: const CinemaManagementScreen(drawer: StaffDrawer()),
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
      GoRoute(
        path: '/promotions',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => PromotionManagementCubit(
              PromotionManagementRepository(context.read<DioClient>()),
            ),
            child: const PromotionManagementScreen(drawer: StaffDrawer()),
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
      GoRoute(
        path: '/concessions',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => ConcessionManagementCubit(
              ConcessionManagementRepository(context.read<DioClient>()),
            ),
            child: const ConcessionManagementScreen(drawer: StaffDrawer()),
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
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AppSettingsScreen(
          drawer: StaffDrawer(),
          appName: 'Cineplex Staff',
        ),
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
