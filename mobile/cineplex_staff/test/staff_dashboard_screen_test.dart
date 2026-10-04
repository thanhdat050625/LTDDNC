import 'package:cineplex_staff/features/dashboard/presentation/screens/staff_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('StaffDashboardScreen renders shift header, KPI cards, and quick actions', (
    tester,
  ) async {
    final authBloc = AuthBloc(_FakeAuthRepository());

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: const StaffDashboardScreen(),
        ),
      ),
    );

    await tester.pump();

    final l10n = AppLocalizations.of(tester.element(find.byType(StaffDashboardScreen)))!;

    // Verify Title and shift info
    expect(find.text(l10n.staffDashboard), findsOneWidget);
    expect(find.text(l10n.shiftInfo), findsOneWidget);
    expect(find.text(l10n.quickActions), findsOneWidget);

    // Verify KPI Labels
    expect(find.text(l10n.ticketsScannedToday), findsOneWidget);
    expect(find.text(l10n.counterRevenueToday), findsOneWidget);
    expect(find.text(l10n.upcomingShowtimesCount), findsOneWidget);
  });
}
