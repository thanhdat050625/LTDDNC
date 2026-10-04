import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cineplex_client/features/profile/data/repositories/profile_repository.dart';

class FakeStorageService extends StorageService {
  String? themeMode;

  @override
  Future<void> saveThemeMode(String mode) async {
    themeMode = mode;
  }

  @override
  Future<String?> getThemeMode() async {
    return themeMode;
  }
}

class FakeProfileRepository implements ProfileRepository {
  @override
  Future<Map<String, dynamic>> getProfile() async {
    return {
      'id': 1,
      'fullName': 'Nguyễn Văn A',
      'email': 'test@cineplex.vn',
      'phone': '0901234567',
      'gender': 'MALE',
      'dateOfBirth': '1995-05-15T00:00:00.000Z',
      'role': 'CUSTOMER',
      'loyaltyPoints': 250,
    };
  }

  @override
  Future<Map<String, dynamic>> getLoyaltyInfo() async {
    return {'loyaltyPoints': 250, 'membershipTier': 'SILVER'};
  }

  @override
  Future<void> updateProfile(
    Map<String, dynamic> data, {
    String? avatarPath,
  }) async {}

  @override
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {}
}

void main() {
  group('Dynamic ThemeCubit Toggling & Propagation', () {
    testWidgets(
      'Toggling in ProfileScreen seamlessly propagates theme across entire app tree',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final fakeStorage = FakeStorageService();
        final themeCubit = ThemeCubit(fakeStorage);
        final profileCubit = ProfileCubit(FakeProfileRepository());

        final dummyScreenKey = GlobalKey();

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>.value(value: themeCubit),
              BlocProvider<ProfileCubit>.value(value: profileCubit),
            ],
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return MaterialApp(
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: const [Locale('vi')],
                  locale: const Locale('vi'),
                  home: Column(
                    children: [
                      Container(
                        key: dummyScreenKey,
                        child: Builder(
                          builder: (ctx) {
                            final colors = CineplexColors.of(ctx);
                            return Text(
                              'Dummy Screen',
                              style: TextStyle(color: colors.textPrimary),
                            );
                          },
                        ),
                      ),
                      const Expanded(child: AppSettingsScreen()),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(AppSettingsScreen)),
        )!;

        // 1. Initial State: dark theme by default
        expect(themeCubit.state, equals(ThemeMode.dark));
        var screenElement = tester.element(find.byType(AppSettingsScreen));
        var dummyElement = tester.element(find.byKey(dummyScreenKey));

        expect(Theme.of(screenElement).brightness, equals(Brightness.dark));
        expect(CineplexColors.of(screenElement).isDark, isTrue);
        expect(CineplexColors.of(dummyElement).isDark, isTrue);
        expect(
          CineplexColors.of(dummyElement).textPrimary,
          equals(CineplexColors.dark.textPrimary),
        );

        // Find the segmented buttons by localized text
        final segmentedButton = find.byType(SegmentedButton<ThemeMode>);
        expect(segmentedButton, findsOneWidget);

        final lightSegment = find.descendant(
          of: segmentedButton,
          matching: find.text(l10n.themeModeLight),
        );
        final darkSegment = find.descendant(
          of: segmentedButton,
          matching: find.text(l10n.themeModeDark),
        );
        final systemSegment = find.descendant(
          of: segmentedButton,
          matching: find.text(l10n.themeModeSystem),
        );

        // 2. Tap Light Mode segment
        await tester.tap(lightSegment);
        await tester.pumpAndSettle();

        // Verify ThemeCubit transitioned to light
        expect(themeCubit.state, equals(ThemeMode.light));
        expect(fakeStorage.themeMode, equals('light'));

        // Verify theme brightness across all branches of widget tree changed to light
        screenElement = tester.element(find.byType(AppSettingsScreen));
        dummyElement = tester.element(find.byKey(dummyScreenKey));

        expect(Theme.of(screenElement).brightness, equals(Brightness.light));
        expect(CineplexColors.of(screenElement).isDark, isFalse);
        expect(CineplexColors.of(dummyElement).isDark, isFalse);
        expect(
          CineplexColors.of(dummyElement).textPrimary,
          equals(CineplexColors.light.textPrimary),
        );

        // 3. Tap System Mode segment
        await tester.tap(systemSegment);
        await tester.pumpAndSettle();

        expect(themeCubit.state, equals(ThemeMode.system));
        expect(fakeStorage.themeMode, equals('system'));

        // 4. Tap Dark Mode segment
        await tester.tap(darkSegment);
        await tester.pumpAndSettle();

        expect(themeCubit.state, equals(ThemeMode.dark));
        expect(fakeStorage.themeMode, equals('dark'));

        screenElement = tester.element(find.byType(AppSettingsScreen));
        dummyElement = tester.element(find.byKey(dummyScreenKey));

        expect(Theme.of(screenElement).brightness, equals(Brightness.dark));
        expect(CineplexColors.of(screenElement).isDark, isTrue);
        expect(CineplexColors.of(dummyElement).isDark, isTrue);
        expect(
          CineplexColors.of(dummyElement).textPrimary,
          equals(CineplexColors.dark.textPrimary),
        );
      },
    );

    test('ThemeCubit restores persisted themeMode from StorageService on initialization', () async {
      final fakeStorage = FakeStorageService()..themeMode = 'light';
      final newThemeCubit = ThemeCubit(fakeStorage);

      // Allow async _loadSavedTheme to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(newThemeCubit.state, equals(ThemeMode.light));
    });
  });
}
