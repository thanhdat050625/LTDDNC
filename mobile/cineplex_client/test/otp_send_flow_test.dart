import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'package:cineplex_client/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:cineplex_client/features/auth/presentation/screens/register_screen.dart';

class _FakeStorage extends StorageService {}

class _OtpRepo extends AuthRepository {
  _OtpRepo() : super(DioClient(_FakeStorage()), _FakeStorage());
  @override
  Future<void> sendOtp(String email, String purpose) async {}
}

Widget _wrap(AuthBloc bloc, Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('vi')],
    locale: const Locale('vi'),
    home: BlocProvider<AuthBloc>.value(value: bloc, child: child),
  );
}

void main() {
  testWidgets('Register: Gui OTP xong phai sang buoc OTP (khong bi ket)', (t) async {
    final bloc = AuthBloc(_OtpRepo())..emit(AuthUnauthenticated());
    await t.pumpWidget(_wrap(bloc, const RegisterScreen()));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextFormField).first, 'user@test.com');
    await t.pump();
    await t.tap(find.text('Gửi mã OTP'));
    await t.pump(); // dispatch
    await t.pump(const Duration(milliseconds: 50)); // repo future done
    await t.pump(const Duration(milliseconds: 400)); // listener + setState
    await t.pumpAndSettle();

    final step1Gone = find.text('Gửi mã OTP').evaluate().isEmpty;
    expect(step1Gone, isTrue, reason: 'RegisterScreen van kêt o buoc 0 sau khi OTP xong');
  });

  testWidgets('Forgot: Gui OTP xong phai sang buoc OTP (khong bi ket)', (t) async {
    final bloc = AuthBloc(_OtpRepo())..emit(AuthUnauthenticated());
    await t.pumpWidget(_wrap(bloc, const ForgotPasswordScreen()));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextFormField).first, 'user@test.com');
    await t.pump();
    await t.tap(find.text('Gửi mã OTP'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 50));
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();

    final step1Gone = find.text('Gửi mã OTP').evaluate().isEmpty;
    expect(step1Gone, isTrue, reason: 'ForgotPasswordScreen van kêt o buoc 0 sau khi OTP xong');
  });

  testWidgets('OtpInputWidget: cac o OTP co khoang cach ro rang, khong bi dinh nhau', (t) async {
    final bloc = AuthBloc(_OtpRepo())..emit(AuthUnauthenticated());
    // Simulate 360px screen width constraint
    t.view.physicalSize = const Size(360, 640);
    t.view.devicePixelRatio = 1.0;
    addTearDown(() => t.view.resetPhysicalSize());

    await t.pumpWidget(_wrap(bloc, const RegisterScreen()));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextFormField).first, 'user@test.com');
    await t.pump();
    await t.tap(find.text('Gửi mã OTP'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 50));
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();

    // In step 2, there should be 6 OTP TextFields
    final otpFields = find.byType(TextField);
    expect(otpFields, findsNWidgets(6));

    final rects = <Rect>[];
    for (int i = 0; i < 6; i++) {
      rects.add(t.getRect(otpFields.at(i)));
    }

    // Verify each adjacent box has at least 6px gap
    for (int i = 0; i < 5; i++) {
      final gap = rects[i + 1].left - rects[i].right;
      expect(gap, greaterThanOrEqualTo(6.0),
          reason: 'Khoang cach giua o $i va o ${i + 1} phai >= 6px, hien tai: $gap');
    }
  });
}
