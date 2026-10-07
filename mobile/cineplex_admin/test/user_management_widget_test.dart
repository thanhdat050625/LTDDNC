import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_admin/features/users/data/repositories/user_management_repository.dart';
import 'package:cineplex_admin/features/users/presentation/cubit/user_management_cubit.dart';
import 'package:cineplex_admin/features/users/presentation/widgets/user_card_item.dart';
import 'package:cineplex_admin/features/users/presentation/widgets/create_staff_bottom_sheet.dart';

class FakeUserManagementRepository implements UserManagementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserManagementResult> getUsers({
    int page = 1,
    int pageSize = 10,
    String? role,
    String? status,
    String? keyword,
  }) async {
    return const UserManagementResult(
      users: [
        UserModel(
          id: 1,
          email: 'customer@cineplex.vn',
          fullName: 'Trần Khách Hàng',
          role: 'CUSTOMER',
          status: 'ACTIVE',
          loyaltyPoints: 120,
        ),
      ],
      totalAll: 1,
      totalCustomers: 1,
      totalStaff: 0,
      totalBlocked: 0,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({
    required Widget child,
    ThemeMode themeMode = ThemeMode.dark,
    UserManagementCubit? cubit,
  }) {
    final userCubit = cubit ?? UserManagementCubit(FakeUserManagementRepository());
    return BlocProvider<UserManagementCubit>.value(
      value: userCubit,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: Scaffold(body: child),
      ),
    );
  }

  group('User Management Widgets Tests', () {
    testWidgets('UserCardItem renders user name, role, email, and toggle action', (tester) async {
      const user = UserModel(
        id: 42,
        email: 'staff@cineplex.vn',
        fullName: 'Lê Nhân Viên',
        role: 'STAFF',
        status: 'ACTIVE',
      );

      bool toggleCalled = false;
      await tester.pumpWidget(
        buildTestableWidget(
          child: UserCardItem(
            user: user,
            isUpdating: false,
            onToggleStatus: () => toggleCalled = true,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lê Nhân Viên'), findsOneWidget);
      expect(find.text('Nhân viên'), findsOneWidget);
      expect(find.text('staff@cineplex.vn'), findsOneWidget);
      expect(find.text('Khóa tài khoản'), findsOneWidget);

      await tester.tap(find.text('Khóa tài khoản'));
      await tester.pumpAndSettle();
      expect(toggleCalled, isTrue);
    });

    testWidgets('CreateStaffBottomSheet renders with visibility toggles and localized hints', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const CreateStaffBottomSheet(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tạo tài khoản nhân viên'), findsOneWidget);
      expect(find.text('nhanvien@cineplex.vn'), findsOneWidget);
      expect(find.text('09xxxxxxxx'), findsOneWidget);
      expect(find.text('Nhập mật khẩu'), findsOneWidget);
      expect(find.text('Nhập lại mật khẩu'), findsOneWidget);

      // Verify visibility toggle buttons
      final visibilityIcons = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityIcons, findsNWidgets(2)); // for password and confirm password

      // Tap on first visibility icon
      await tester.tap(visibilityIcons.first);
      await tester.pumpAndSettle();

      // Now one is visible
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
