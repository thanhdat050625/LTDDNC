import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_admin/router/admin_router.dart';
import 'package:cineplex_admin/features/profile/presentation/screens/admin_profile_screen.dart';
import 'package:cineplex_admin/features/settings/presentation/screens/admin_settings_screen.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserModel> login(String email, String password, {bool rememberMe = false}) async {
    return const UserModel(
      id: 1,
      email: 'admin@cineplex.vn',
      fullName: 'Quản Trị Viên',
      role: 'ADMIN',
      status: 'ACTIVE',
    );
  }

  @override
  Future<UserModel?> checkAuth() async {
    return const UserModel(
      id: 1,
      email: 'admin@cineplex.vn',
      fullName: 'Quản Trị Viên',
      role: 'ADMIN',
      status: 'ACTIVE',
    );
  }
}

class TestAuthBloc extends AuthBloc {
  TestAuthBloc([AuthState? initialState])
      : super(FakeAuthRepository()) {
    if (initialState != null) {
      emit(initialState);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({
    required Widget child,
    ThemeMode themeMode = ThemeMode.dark,
    ThemeCubit? themeCubit,
    AuthBloc? authBloc,
  }) {
    final cubit = themeCubit ?? ThemeCubit();
    final aBloc = authBloc ?? TestAuthBloc(
      const AuthAuthenticated(
        UserModel(
          id: 1,
          email: 'admin@cineplex.vn',
          fullName: 'Admin Cineplex',
          role: 'ADMIN',
          status: 'ACTIVE',
        ),
      ),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: cubit),
        BlocProvider<AuthBloc>.value(value: aBloc),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: child,
      ),
    );
  }

  group('Admin Router Configuration Tests', () {
    test('Router exposes all required admin routes including /profile and /settings', () {
      final authBloc = TestAuthBloc(
        const AuthAuthenticated(
          UserModel(
            id: 1,
            email: 'admin@cineplex.vn',
            fullName: 'Admin',
            role: 'ADMIN',
            status: 'ACTIVE',
          ),
        ),
      );
      final router = createAdminRouter(authBloc);
      expect(router, isA<GoRouter>());

      // Find route paths
      final routePaths = router.configuration.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toList();

      expect(routePaths, contains('/statistics'));
      expect(routePaths, contains('/login'));
      expect(routePaths, contains('/profile'));
      expect(routePaths, contains('/settings'));
      expect(routePaths, contains('/movies/:id'));
    });

    test('Unauthenticated user route configuration is valid', () {
      final authBloc = TestAuthBloc(AuthUnauthenticated());
      final router = createAdminRouter(authBloc);
      expect(router, isA<GoRouter>());
      expect(router.configuration.routes.isNotEmpty, isTrue);
    });
  });

  group('Admin Profile & Settings Screens Widget Tests', () {
    testWidgets('AdminProfileScreen renders correctly in Light Mode', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const AdminProfileScreen(),
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdminProfileScreen), findsOneWidget);
      expect(find.text('Hồ sơ quản trị viên'), findsOneWidget);
      expect(find.text('Giao diện tối'), findsOneWidget);
      expect(find.text('Giao diện sáng'), findsOneWidget);
      expect(find.text('Theo hệ thống'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
    });

    testWidgets('AdminProfileScreen renders correctly in Dark Mode', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const AdminProfileScreen(),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdminProfileScreen), findsOneWidget);
      expect(find.text('Hồ sơ quản trị viên'), findsOneWidget);
      expect(find.text('QUẢN TRỊ VIÊN'), findsOneWidget);
    });

    testWidgets('AdminSettingsScreen renders theme options and system info', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const AdminSettingsScreen(),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdminSettingsScreen), findsOneWidget);
      expect(find.text('Cài đặt hệ thống'), findsOneWidget);
      expect(find.text('Giao diện'), findsOneWidget);
      expect(find.text('Thông tin hệ thống'), findsOneWidget);
      expect(find.text('Xóa bộ nhớ đệm'), findsAtLeastNWidgets(1));
    });

    testWidgets('AdminSettingsScreen theme selection triggers ThemeCubit', (tester) async {
      final themeCubit = ThemeCubit();
      await tester.pumpWidget(
        buildTestableWidget(
          child: const AdminSettingsScreen(),
          themeMode: ThemeMode.dark,
          themeCubit: themeCubit,
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Light Mode option
      final lightModeRadio = find.text('Giao diện sáng');
      expect(lightModeRadio, findsOneWidget);
      await tester.tap(lightModeRadio);
      await tester.pumpAndSettle();

      expect(themeCubit.state, equals(ThemeMode.light));
    });
  });
}
