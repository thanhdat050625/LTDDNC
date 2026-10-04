import 'package:cineplex_staff/features/profile/presentation/screens/staff_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStorageService implements StorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveThemeMode(String mode) async {
    _storage['theme_mode'] = mode;
  }

  @override
  Future<String?> getThemeMode() async {
    return _storage['theme_mode'];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('StaffProfileScreen renders theme toggle and sound preferences', (
    tester,
  ) async {
    final authBloc = AuthBloc(_FakeAuthRepository());
    final themeCubit = ThemeCubit(_FakeStorageService());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: const StaffProfileScreen(),
        ),
      ),
    );

    await tester.pump();

    final l10n = AppLocalizations.of(tester.element(find.byType(StaffProfileScreen)))!;

    // Verify Title & settings
    expect(find.text(l10n.staffProfile), findsOneWidget);
    expect(find.text(l10n.themeModeSetting), findsOneWidget);
    expect(find.text(l10n.themeModeDark), findsOneWidget);
    expect(find.text(l10n.themeModeLight), findsOneWidget);
    expect(find.text(l10n.themeModeSystem), findsOneWidget);

    // Verify Preferences
    expect(find.text(l10n.soundAndHaptic), findsOneWidget);
    expect(find.text(l10n.endShift), findsOneWidget);
  });
}
