import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'features/statistics/data/repositories/statistics_repository.dart';
import 'features/statistics/presentation/cubit/statistics_cubit.dart';
import 'features/users/data/repositories/user_management_repository.dart';
import 'features/users/presentation/cubit/user_management_cubit.dart';
import 'router/admin_router.dart';

class CineplexAdminApp extends StatefulWidget {
  final StorageService storageService;
  final DioClient dioClient;
  final AuthRepository authRepo;
  final StatisticsRepository statisticsRepo;
  final UserManagementRepository userManagementRepo;

  const CineplexAdminApp({
    super.key,
    required this.storageService,
    required this.dioClient,
    required this.authRepo,
    required this.statisticsRepo,
    required this.userManagementRepo,
  });

  @override
  State<CineplexAdminApp> createState() => _CineplexAdminAppState();
}

class _CineplexAdminAppState extends State<CineplexAdminApp> {
  late final AuthBloc _authBloc;
  late final StatisticsCubit _statisticsCubit;
  late final UserManagementCubit _userManagementCubit;
  late final ThemeCubit _themeCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(widget.authRepo)..add(CheckAuthStatus());
    _statisticsCubit = StatisticsCubit(widget.statisticsRepo);
    _userManagementCubit = UserManagementCubit(widget.userManagementRepo);
    _themeCubit = ThemeCubit(widget.storageService);
    _router = createAdminRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _statisticsCubit.close();
    _userManagementCubit.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.storageService),
        RepositoryProvider.value(value: widget.dioClient),
        RepositoryProvider.value(value: widget.authRepo),
        RepositoryProvider.value(value: widget.statisticsRepo),
        RepositoryProvider.value(value: widget.userManagementRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _statisticsCubit),
          BlocProvider.value(value: _userManagementCubit),
          BlocProvider.value(value: _themeCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'Cineplex Admin',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: _router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [Locale('vi')],
              locale: const Locale('vi'),
            );
          },
        ),
      ),
    );
  }
}
