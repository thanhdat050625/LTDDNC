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
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(widget.authRepo)..add(CheckAuthStatus());
    _staffCubit = StaffCubit(widget.staffRepo);
    _router = createStaffRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _staffCubit.close();
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
        ],
        child: MaterialApp.router(
          title: 'Cineplex Staff',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: _router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
        ),
      ),
    );
  }
}
