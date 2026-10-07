import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/profile/data/repositories/profile_repository.dart';
import 'package:cineplex_client/features/profile/presentation/screens/change_password_screen.dart';

class _FakeProfileRepo extends ProfileRepository {
  _FakeProfileRepo() : super(DioClient(StorageService()));

  String? lastOld;
  String? lastNew;
  String? lastConfirm;
  bool shouldThrow = false;

  @override
  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    if (shouldThrow) {
      throw ServerException('Mật khẩu cũ không chính xác');
    }
    lastOld = oldPassword;
    lastNew = newPassword;
    lastConfirm = confirmPassword;
  }
}

Widget _wrap(_FakeProfileRepo repo, Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('vi')],
    locale: const Locale('vi'),
    home: RepositoryProvider<ProfileRepository>.value(
      value: repo,
      child: child,
    ),
  );
}

void main() {
  testWidgets('ChangePasswordScreen: Validate full 3 fields and submission', (tester) async {
    final repo = _FakeProfileRepo();
    await tester.pumpWidget(_wrap(repo, const ChangePasswordScreen()));
    await tester.pumpAndSettle();

    // Verify 3 AppTextField / TextFormField exist
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Đổi mật khẩu'), findsWidgets);

    // 1. Submit with all fields empty -> should trigger validations for all 3 required fields
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập mật khẩu cũ'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu mới'), findsOneWidget);
    expect(find.text('Vui lòng xác nhận mật khẩu mới'), findsOneWidget);

    // 2. Enter old password, but short new password
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'oldpass123');
    await tester.enterText(fields.at(1), '12345');
    await tester.enterText(fields.at(2), '12345');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);

    // 3. New password same as old password
    await tester.enterText(fields.at(1), 'oldpass123');
    await tester.enterText(fields.at(2), 'oldpass123');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text('Mật khẩu mới phải khác mật khẩu cũ'), findsOneWidget);

    // 4. Mismatched confirm password
    await tester.enterText(fields.at(1), 'newpass123');
    await tester.enterText(fields.at(2), 'different123');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text('Mật khẩu không khớp'), findsOneWidget);

    // 5. Valid passwords -> success call to repository
    await tester.enterText(fields.at(2), 'newpass123');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(repo.lastOld, 'oldpass123');
    expect(repo.lastNew, 'newpass123');
    expect(repo.lastConfirm, 'newpass123');
  });

  testWidgets('ChangePasswordScreen: Displays error message from backend when server fails', (tester) async {
    final repo = _FakeProfileRepo()..shouldThrow = true;
    await tester.pumpWidget(_wrap(repo, const ChangePasswordScreen()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'wrongoldpass');
    await tester.enterText(fields.at(1), 'newpass123');
    await tester.enterText(fields.at(2), 'newpass123');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    // Verify error banner is shown
    expect(find.text('Mật khẩu cũ không chính xác'), findsWidgets);
  });
}
