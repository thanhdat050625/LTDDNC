import 'package:cineplex_staff/features/auth/presentation/screens/staff_login_screen.dart';
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
    'StaffLoginScreen renders single line "Quản Lý Rạp" and subtitle "Nhân Viên"',
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
            home: const StaffLoginScreen(),
          ),
        ),
      );

      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(StaffLoginScreen)),
      )!;

      // Verify title and subtitle strings
      expect(l10n.staffLoginTitle, 'Quản Lý Rạp');
      expect(l10n.staffLoginSubtitle, 'Nhân Viên');

      final titleFinder = find.text('Quản Lý Rạp');
      final subtitleFinder = find.text('Nhân Viên');

      expect(titleFinder, findsOneWidget);
      expect(subtitleFinder, findsOneWidget);

      // Verify title is configured for single-line display
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.maxLines, 1);
    },
  );
}
