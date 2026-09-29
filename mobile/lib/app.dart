import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/api/dio_client.dart';
import 'package:cineplex_mobile/core/services/storage_service.dart';

import 'features/auth/data/repositories/auth_repository.dart';
import 'features/home/data/repositories/home_repository.dart';
import 'features/movie/data/repositories/movie_repository.dart';
import 'features/showtime/data/repositories/showtime_repository.dart';
import 'features/booking/data/repositories/booking_repository.dart';
import 'features/concession/data/repositories/concession_repository.dart';
import 'features/payment/data/repositories/payment_repository.dart';
import 'features/ticket/data/repositories/ticket_repository.dart';
import 'features/notification/data/repositories/notification_repository.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/staff/data/repositories/staff_repository.dart';
import 'features/statistics/data/repositories/statistics_repository.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/notification/presentation/cubit/notification_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

class App extends StatefulWidget {
  final StorageService storageService;
  final DioClient dioClient;
  final AuthRepository authRepo;
  final HomeRepository homeRepo;
  final MovieRepository movieRepo;
  final ShowtimeRepository showtimeRepo;
  final BookingRepository bookingRepo;
  final ConcessionRepository concessionRepo;
  final PaymentRepository paymentRepo;
  final TicketRepository ticketRepo;
  final NotificationRepository notificationRepo;
  final ProfileRepository profileRepo;
  final StaffRepository staffRepo;
  final StatisticsRepository statisticsRepo;

  const App({
    super.key,
    required this.storageService,
    required this.dioClient,
    required this.authRepo,
    required this.homeRepo,
    required this.movieRepo,
    required this.showtimeRepo,
    required this.bookingRepo,
    required this.concessionRepo,
    required this.paymentRepo,
    required this.ticketRepo,
    required this.notificationRepo,
    required this.profileRepo,
    required this.staffRepo,
    required this.statisticsRepo,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final HomeCubit _homeCubit;
  late final NotificationCubit _notificationCubit;
  late final ProfileCubit _profileCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(widget.authRepo)..add(CheckAuthStatus());
    _homeCubit = HomeCubit(widget.homeRepo)..load();
    _notificationCubit = NotificationCubit(widget.notificationRepo);
    _profileCubit = ProfileCubit(widget.profileRepo);
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _homeCubit.close();
    _notificationCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.storageService),
        RepositoryProvider.value(value: widget.dioClient),
        RepositoryProvider.value(value: widget.authRepo),
        RepositoryProvider.value(value: widget.homeRepo),
        RepositoryProvider.value(value: widget.movieRepo),
        RepositoryProvider.value(value: widget.showtimeRepo),
        RepositoryProvider.value(value: widget.bookingRepo),
        RepositoryProvider.value(value: widget.concessionRepo),
        RepositoryProvider.value(value: widget.paymentRepo),
        RepositoryProvider.value(value: widget.ticketRepo),
        RepositoryProvider.value(value: widget.notificationRepo),
        RepositoryProvider.value(value: widget.profileRepo),
        RepositoryProvider.value(value: widget.staffRepo),
        RepositoryProvider.value(value: widget.statisticsRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _homeCubit),
          BlocProvider.value(value: _notificationCubit),
          BlocProvider.value(value: _profileCubit),
        ],
        child: MaterialApp.router(
          routerConfig: _router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('vi'),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
