import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_staff/features/scanner/presentation/screens/staff_scanner_screen.dart';
import 'package:cineplex_staff/features/scanner/presentation/cubit/staff_cubit.dart';
import 'package:cineplex_staff/features/scanner/data/repositories/staff_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStaffRepository implements StaffRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Pumping StaffScannerScreen renders UI elements', (tester) async {
    final authBloc = AuthBloc(FakeAuthRepository());
    final staffCubit = StaffCubit(FakeStaffRepository());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<StaffCubit>.value(value: staffCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: const StaffScannerScreen(),
        ),
      ),
    );

    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(StaffScannerScreen)),
    )!;

    // Verify AppBar
    expect(find.text(l10n.scanTicket), findsOneWidget);

    // Verify manual input label above is removed
    expect(find.text(l10n.manualTicketInput), findsNothing);

    // Verify verify ticket button
    expect(find.text(l10n.verifyTicket), findsOneWidget);

    // Verify text field with hint
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(l10n.manualCodeHint), findsOneWidget);
  });
}
