import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../features/auth/presentation/screens/staff_login_screen.dart';
import '../features/scanner/presentation/screens/staff_scanner_screen.dart';
import '../features/home/presentation/widgets/staff_drawer.dart';
import '../features/ticket_sale/presentation/screens/ticket_sale_screen.dart';
import '../features/ticket_sale/presentation/screens/seat_selection_screen.dart';
import '../features/ticket_sale/presentation/screens/checkout_screen.dart';
import '../features/ticket_sale/presentation/cubit/ticket_sale_cubit.dart';
import '../features/ticket_sale/presentation/cubit/ticket_sale_state.dart';

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
        builder: (context, state) => const TicketSaleScreen(drawer: StaffDrawer()),
      ),
      GoRoute(
        path: '/ticket-sale/seat-selection',
        builder: (context, state) {
          final cubit = state.extra as TicketSaleCubit;
          return BlocProvider.value(
            value: cubit,
            child: const SeatSelectionScreen(),
          );
        },
      ),
      GoRoute(
        path: '/ticket-sale/checkout',
        builder: (context, state) => const CheckoutScreen(),
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
      // Promotions
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
      // Concessions
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
