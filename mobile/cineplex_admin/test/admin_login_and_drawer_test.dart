import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_admin/features/auth/presentation/screens/admin_login_screen.dart';
import 'package:cineplex_admin/features/dashboard/presentation/widgets/admin_drawer.dart';

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
    AuthBloc? authBloc,
    ThemeCubit? themeCubit,
  }) {
    final aBloc = authBloc ?? TestAuthBloc(AuthUnauthenticated());
    final tCubit = themeCubit ?? ThemeCubit();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: aBloc),
        BlocProvider<ThemeCubit>.value(value: tCubit),
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

  group('Admin Login Screen Tests', () {
    testWidgets('AdminLoginScreen renders with branding, inputs, and button in Dark Mode', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const AdminLoginScreen(),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoginScreen), findsOneWidget);
      expect(find.text('Cổng Quản trị Hệ thống'), findsOneWidget);
      expect(find.text('Bảng điều khiển Quản trị'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.text('Ghi nhớ đăng nhập'), findsOneWidget);
    });

    testWidgets('AdminLoginScreen renders with dual-theme compatibility in Light Mode', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const AdminLoginScreen(),
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoginScreen), findsOneWidget);
      expect(find.text('Cổng Quản trị Hệ thống'), findsOneWidget);
      expect(find.text('Bảng điều khiển Quản trị'), findsOneWidget);
    });

    testWidgets('Submitting empty login form displays validation errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const AdminLoginScreen(),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      final loginBtn = find.text('Đăng nhập');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text('Email không được để trống'), findsOneWidget);
      expect(find.text('Mật khẩu không được để trống'), findsOneWidget);
    });
  });

  group('Admin Drawer Tests', () {
    testWidgets('AdminDrawer displays navigation items and user info', (tester) async {
      const user = UserModel(
        id: 99,
        email: 'admin@cineplex.vn',
        fullName: 'Nguyễn Văn Admin',
        role: 'ADMIN',
        status: 'ACTIVE',
      );
      final authBloc = TestAuthBloc(const AuthAuthenticated(user));

      await tester.pumpWidget(
        buildTestableWidget(
          child: const SizedBox(
            width: 320,
            child: Scaffold(
              body: AdminDrawer(),
            ),
          ),
          authBloc: authBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdminDrawer), findsOneWidget);
      expect(find.text('Nguyễn Văn Admin'), findsOneWidget);
      expect(find.text('QUẢN TRỊ VIÊN'), findsOneWidget);
      expect(find.textContaining('Thống kê'), findsOneWidget);
      expect(find.text('Quản lý Phim'), findsOneWidget);
      expect(find.text('Quản lý Rạp'), findsOneWidget);
      expect(find.text('Quản lý Suất chiếu'), findsOneWidget);
      expect(find.text('Quản lý người dùng'), findsOneWidget);
      expect(find.text('Quản lý Khuyến mãi'), findsOneWidget);
      expect(find.text('Quản lý Bắp nước'), findsOneWidget);
      expect(find.text('Cài đặt hệ thống'), findsOneWidget);
      expect(find.text('Giao diện tối'), findsOneWidget);
    });

    testWidgets('AdminDrawer theme switch toggles ThemeCubit', (tester) async {
      const user = UserModel(
        id: 99,
        email: 'admin@cineplex.vn',
        fullName: 'Nguyễn Văn Admin',
        role: 'ADMIN',
        status: 'ACTIVE',
      );
      final authBloc = TestAuthBloc(const AuthAuthenticated(user));
      final themeCubit = ThemeCubit();

      await tester.pumpWidget(
        buildTestableWidget(
          child: const SizedBox(
            width: 320,
            child: Scaffold(
              body: AdminDrawer(),
            ),
          ),
          authBloc: authBloc,
          themeCubit: themeCubit,
        ),
      );
      await tester.pumpAndSettle();

      // Find theme switch
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Toggle dark to light
      expect(themeCubit.state, equals(ThemeMode.light));
    });
  });
}
