import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'features/scanner/data/repositories/staff_repository.dart';
import 'features/scanner/presentation/cubit/staff_cubit.dart';
import 'router/staff_router.dart';

class CineplexStaffApp extends StatefulWidget {
  final StorageService storageService;
  final DioClient dioClient;
  final AuthRepository authRepo;
  final StaffRepository staffRepo;

  const CineplexStaffApp({
    super.key,
    required this.storageService,
    required this.dioClient,
    required this.authRepo,
    required this.staffRepo,
  });

  @override
  State<CineplexStaffApp> createState() => _CineplexStaffAppState();
}

class _CineplexStaffAppState extends State<CineplexStaffApp> {
  late final AuthBloc _authBloc;
  late final StaffCubit _staffCubit;
  late final ThemeCubit _themeCubit;
  late final GoRouter _router;
  late final AppBackHandler _backHandler;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(widget.authRepo)..add(CheckAuthStatus());
    _staffCubit = StaffCubit(widget.staffRepo);
    _themeCubit = ThemeCubit(widget.storageService);
    _router = createStaffRouter(_authBloc);
    _backHandler = AppBackHandler(
      router: _router,
      rootNavKey: staffRootNavigatorKey,
      shellNavKey: staffShellNavigatorKey,
      defaultRootPath: '/dashboard',
      exitOnPaths: {'/dashboard', '/login'},
    )..init();
  }

  @override
  void dispose() {
    _backHandler.dispose();
    _authBloc.close();
    _staffCubit.close();
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
        RepositoryProvider.value(value: widget.staffRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _staffCubit),
          BlocProvider.value(value: _themeCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'Cineplex Staff',
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
