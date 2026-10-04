import 'package:cineplex_admin/features/auth/presentation/screens/admin_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'AdminLoginScreen renders single line "Quản Trị Hệ Thống" and subtitle "Admin"',
    (tester) async {
      final authBloc = AuthBloc(_FakeAuthRepository());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            home: const AdminLoginScreen(),
          ),
        ),
      );

      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AdminLoginScreen)),
      )!;

      expect(l10n.adminLoginTitle, 'Quản Trị Hệ Thống');
      expect(l10n.adminLoginSubtitle, 'Admin');

      final titleFinder = find.text('Quản Trị Hệ Thống');
      expect(titleFinder, findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);

      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.maxLines, 1);
    },
  );
}
