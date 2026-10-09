import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_admin/features/auth/presentation/screens/admin_login_screen.dart';
import 'package:cineplex_admin/features/profile/presentation/screens/admin_profile_screen.dart';
import 'package:cineplex_admin/features/settings/presentation/screens/admin_settings_screen.dart';
import 'package:cineplex_admin/features/statistics/data/repositories/statistics_repository.dart';
import 'package:cineplex_admin/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:cineplex_admin/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:cineplex_admin/features/users/data/repositories/user_management_repository.dart';
import 'package:cineplex_admin/features/users/presentation/cubit/user_management_cubit.dart';
import 'package:cineplex_admin/features/users/presentation/widgets/create_staff_bottom_sheet.dart';
import 'package:cineplex_admin/features/users/presentation/widgets/user_card_item.dart';
import 'package:cineplex_admin/features/users/presentation/widgets/user_detail_bottom_sheet.dart';

// ==========================================
// 1. WCAG 2.1 Contrast Formula Utilities
// ==========================================

double _linearize(double c) {
  return (c <= 0.04045) ? (c / 12.92) : pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double relativeLuminance(Color c) {
  final r = _linearize(c.r);
  final g = _linearize(c.g);
  final b = _linearize(c.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

Color composite(Color fg, Color bg) {
  final a = fg.a;
  final r = (fg.r * a + bg.r * (1.0 - a)).clamp(0.0, 1.0);
  final g = (fg.g * a + bg.g * (1.0 - a)).clamp(0.0, 1.0);
  final b = (fg.b * a + bg.b * (1.0 - a)).clamp(0.0, 1.0);
  return Color.from(alpha: 1.0, red: r, green: g, blue: b);
}

double contrastRatio(Color foreground, Color background) {
  final effectiveFg = foreground.a < 1.0 ? composite(foreground, background) : foreground;
  final l1 = relativeLuminance(effectiveFg);
  final l2 = relativeLuminance(background);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

// ==========================================
// 2. Mocks & Test Doubles
// ==========================================

class MockAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

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
}

class MockStatisticsRepository implements StatisticsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<SummaryModel> getSummary() async {
    return const SummaryModel(
      revenue: 250000000,
      tickets: 3200,
      cinemas: 10,
      activeMovies: 15,
    );
  }

  @override
  Future<List<RevenuePeriodModel>> getRevenueStatistics({
    String filterType = 'year',
    int? year,
    int? month,
    String? startDate,
    String? endDate,
  }) async {
    return const [
      RevenuePeriodModel(period: '2026-01', revenue: 60000000),
      RevenuePeriodModel(period: '2026-02', revenue: 90000000),
      RevenuePeriodModel(period: '2026-03', revenue: 100000000),
    ];
  }

  @override
  Future<List<MoviePerformanceModel>> getMoviePerformance({
    String filterType = 'year',
    int? year,
    int? month,
    String? startDate,
    String? endDate,
  }) async {
    return const [
      MoviePerformanceModel(
        id: 1,
        title: 'Mai',
        ticketsSold: 1800,
        revenue: 150000000,
        occupancyRate: 85,
      ),
      MoviePerformanceModel(
        id: 2,
        title: 'Đào, Phở và Piano',
        ticketsSold: 900,
        revenue: 70000000,
        occupancyRate: 55,
      ),
      MoviePerformanceModel(
        id: 3,
        title: 'Kung Fu Panda 4',
        ticketsSold: 500,
        revenue: 30000000,
        occupancyRate: 35,
      ),
    ];
  }
}

class MockUserManagementRepository implements UserManagementRepository {
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
    return UserManagementResult(
      users: [
        UserModel(
          id: 101,
          email: 'vip.customer@cineplex.vn',
          fullName: 'Trần Kim Cương Siêu VIP',
          role: 'CUSTOMER',
          status: 'ACTIVE',
          loyaltyPoints: 1250,
          phone: '0901234567',
          createdAt: DateTime(2026, 1, 15),
        ),
        UserModel(
          id: 102,
          email: 'blocked.user@cineplex.vn',
          fullName: 'Nguyễn Bị Khóa',
          role: 'CUSTOMER',
          status: 'BLOCKED',
          loyaltyPoints: 0,
          phone: '0988776655',
          createdAt: DateTime(2026, 2, 20),
        ),
      ],
      totalAll: 2,
      totalCustomers: 2,
      totalStaff: 0,
      totalBlocked: 1,
    );
  }

  @override
  Future<UserModel> createStaff({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? avatarFilePath,
  }) async {
    return UserModel(
      id: 999,
      email: email,
      fullName: fullName,
      role: 'STAFF',
      status: 'ACTIVE',
      phone: phone,
    );
  }

  @override
  Future<UserModel> updateStaff({
    required int staffId,
    required String fullName,
    String? email,
    String? password,
    String? phone,
    String? avatarFilePath,
  }) async {
    return UserModel(
      id: staffId,
      email: email ?? 'staff@cineplex.vn',
      fullName: fullName,
      role: 'STAFF',
      status: 'ACTIVE',
      phone: phone,
    );
  }

  @override
  Future<bool> updateUserStatus(int userId, String status) async => true;
}

// ==========================================
// 3. Main Test Suite
// ==========================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WCAG AA Mathematical Contrast Stress Verification', () {
    test('Token contrast verification for Light and Dark modes', () {
      const light = CineplexColors.light;
      const dark = CineplexColors.dark;

      // 1. Text Primary on Surface/Card
      final lightTextOnCard = contrastRatio(light.textPrimary, light.card);
      final darkTextOnCard = contrastRatio(dark.textPrimary, dark.card);
      debugPrint('[CONTRAST] Light textPrimary on card: ${lightTextOnCard.toStringAsFixed(2)}:1');
      debugPrint('[CONTRAST] Dark textPrimary on card: ${darkTextOnCard.toStringAsFixed(2)}:1');
      expect(lightTextOnCard, greaterThanOrEqualTo(4.5), reason: 'Light textPrimary must meet WCAG AA normal text');
      expect(darkTextOnCard, greaterThanOrEqualTo(4.5), reason: 'Dark textPrimary must meet WCAG AA normal text');

      // 2. Text Secondary on Surface/Card
      final lightTextSecOnCard = contrastRatio(light.textSecondary, light.card);
      final darkTextSecOnCard = contrastRatio(dark.textSecondary, dark.card);
      debugPrint('[CONTRAST] Light textSecondary on card: ${lightTextSecOnCard.toStringAsFixed(2)}:1');
      debugPrint('[CONTRAST] Dark textSecondary on card: ${darkTextSecOnCard.toStringAsFixed(2)}:1');
      expect(lightTextSecOnCard, greaterThanOrEqualTo(4.5), reason: 'Light textSecondary must meet WCAG AA');
      expect(darkTextSecOnCard, greaterThanOrEqualTo(4.5), reason: 'Dark textSecondary must meet WCAG AA');

      // 3. Primary Button (White on Primary)
      final primaryBtnLight = contrastRatio(Colors.white, light.primary);
      final primaryBtnDark = contrastRatio(Colors.white, dark.primary);
      debugPrint('[CONTRAST] White on Primary: ${primaryBtnLight.toStringAsFixed(2)}:1');
      expect(primaryBtnLight, greaterThanOrEqualTo(3.0), reason: 'Primary button text must meet WCAG AA large/component');
      expect(primaryBtnDark, greaterThanOrEqualTo(3.0));

      // 4. StatisticsScreen KPI Card Text Contrast
      // KPI values use colors.textPrimary on colors.card
      expect(contrastRatio(light.textPrimary, light.card), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(dark.textPrimary, dark.card), greaterThanOrEqualTo(4.5));

      // KPI titles use colors.textSecondary on colors.card
      expect(contrastRatio(light.textSecondary, light.card), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(dark.textSecondary, dark.card), greaterThanOrEqualTo(4.5));
    });

    test('Empirical Contrast Check: StatisticsScreen Movie Ranking Medals & Occupancy Badges', () {
      // Top 1, 2, 3 Medals: Dark text #111827 on pastel medal backgrounds
      const top1Badge = Color(0xFFF59E0B);
      const top2Badge = Color(0xFF94A3B8);
      const top3Badge = Color(0xFFD97706);
      const rankTextColor = Color(0xFF111827);

      final top1Ratio = contrastRatio(rankTextColor, top1Badge);
      final top2Ratio = contrastRatio(rankTextColor, top2Badge);
      final top3Ratio = contrastRatio(rankTextColor, top3Badge);

      debugPrint('[CONTRAST VERIFIED] Top 1 Medal (#111827 on #F59E0B) contrast ratio: ${top1Ratio.toStringAsFixed(2)}:1');
      debugPrint('[CONTRAST VERIFIED] Top 2 Medal (#111827 on #94A3B8) contrast ratio: ${top2Ratio.toStringAsFixed(2)}:1');
      debugPrint('[CONTRAST VERIFIED] Top 3 Medal (#111827 on #D97706) contrast ratio: ${top3Ratio.toStringAsFixed(2)}:1');

      expect(top1Ratio, greaterThanOrEqualTo(4.5), reason: 'Top 1 medal #111827 text meets WCAG AA >= 4.5:1');
      expect(top2Ratio, greaterThanOrEqualTo(4.5), reason: 'Top 2 medal #111827 text meets WCAG AA >= 4.5:1');
      expect(top3Ratio, greaterThanOrEqualTo(4.5), reason: 'Top 3 medal #111827 text meets WCAG AA >= 4.5:1');

      // Light Mode Occupancy Badges with high-contrast foreground text
      const light = CineplexColors.light;
      final successBgLight = composite(light.success.withValues(alpha: 0.12), light.surface);
      final accentBgLight = composite(light.accent.withValues(alpha: 0.12), light.surface);
      final secondaryBgLight = composite(light.secondary.withValues(alpha: 0.12), light.surface);

      const successTextLight = Color(0xFF14532D);
      const accentTextLight = Color(0xFF7C2D12);
      const secondaryTextLight = Color(0xFF1E3A8A);

      final successRatioLight = contrastRatio(successTextLight, successBgLight);
      final accentRatioLight = contrastRatio(accentTextLight, accentBgLight);
      final secondaryRatioLight = contrastRatio(secondaryTextLight, secondaryBgLight);

      debugPrint('[CONTRAST VERIFIED] Light Occupancy Badge Success (>=70%): ${successRatioLight.toStringAsFixed(2)}:1');
      debugPrint('[CONTRAST VERIFIED] Light Occupancy Badge Accent (40-69%): ${accentRatioLight.toStringAsFixed(2)}:1');
      debugPrint('[CONTRAST VERIFIED] Light Occupancy Badge Secondary (<40%): ${secondaryRatioLight.toStringAsFixed(2)}:1');

      expect(successRatioLight, greaterThanOrEqualTo(4.5), reason: 'Light occupancy success meets WCAG AA >= 4.5:1');
      expect(accentRatioLight, greaterThanOrEqualTo(4.5), reason: 'Light occupancy accent meets WCAG AA >= 4.5:1');
      expect(secondaryRatioLight, greaterThanOrEqualTo(4.5), reason: 'Light occupancy secondary meets WCAG AA >= 4.5:1');

      // Dark Mode Occupancy Badges
      const dark = CineplexColors.dark;
      final successBgDark = composite(dark.success.withValues(alpha: 0.18), dark.surface);
      final accentBgDark = composite(dark.accent.withValues(alpha: 0.18), dark.surface);
      final secondaryBgDark = composite(dark.secondary.withValues(alpha: 0.18), dark.surface);

      final successRatioDark = contrastRatio(dark.success, successBgDark);
      final accentRatioDark = contrastRatio(dark.accent, accentBgDark);
      const secondaryTextDark = Color(0xFF93C5FD);
      final secondaryRatioDark = contrastRatio(secondaryTextDark, secondaryBgDark);

      debugPrint('[CONTRAST VERIFIED] Dark Occupancy Badge Success (>=70%): ${successRatioDark.toStringAsFixed(2)}:1');
      debugPrint('[CONTRAST VERIFIED] Dark Occupancy Badge Accent (40-69%): ${accentRatioDark.toStringAsFixed(2)}:1');
      debugPrint('[CONTRAST VERIFIED] Dark Occupancy Badge Secondary (<40%): ${secondaryRatioDark.toStringAsFixed(2)}:1');

      expect(successRatioDark, greaterThanOrEqualTo(4.5), reason: 'Dark occupancy success meets WCAG AA >= 4.5:1');
      expect(accentRatioDark, greaterThanOrEqualTo(4.5), reason: 'Dark occupancy accent meets WCAG AA >= 4.5:1');
      expect(secondaryRatioDark, greaterThanOrEqualTo(4.5), reason: 'Dark occupancy secondary meets WCAG AA >= 4.5:1');
    });
  });

  group('Viewport Overflow Stress Testing (320px, 360px, 390px)', () {
    const viewports = [
      Size(320, 640), // iPhone SE 1st gen
      Size(360, 800), // Android compact
      Size(390, 844), // iPhone 12/13/14
    ];

    Widget buildAppHarness({
      required Widget child,
      ThemeMode themeMode = ThemeMode.light,
      AuthBloc? authBloc,
      StatisticsCubit? statsCubit,
      UserManagementCubit? userCubit,
      ThemeCubit? themeCubit,
    }) {
      final aBloc = authBloc ?? AuthBloc(MockAuthRepository())..emit(const AuthAuthenticated(UserModel(
        id: 1,
        email: 'admin@cineplex.vn',
        fullName: 'Quản Trị Viên',
        role: 'ADMIN',
        status: 'ACTIVE',
      )));
      final sCubit = statsCubit ?? StatisticsCubit(MockStatisticsRepository());
      final uCubit = userCubit ?? UserManagementCubit(MockUserManagementRepository());
      final tCubit = themeCubit ?? ThemeCubit();

      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: aBloc),
          BlocProvider<StatisticsCubit>.value(value: sCubit),
          BlocProvider<UserManagementCubit>.value(value: uCubit),
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

    for (final size in viewports) {
      testWidgets('AdminLoginScreen viewport test on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        await tester.pumpWidget(buildAppHarness(child: const AdminLoginScreen()));
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(errors.isEmpty, isTrue, reason: 'AdminLoginScreen zero overflow on ${size.width}px');
      });

      testWidgets('AdminProfileScreen renders without overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        await tester.pumpWidget(buildAppHarness(child: const AdminProfileScreen()));
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;
        expect(errors.isEmpty, isTrue, reason: 'Zero RenderFlex overflow on ${size.width}px');
        expect(find.byType(AdminProfileScreen), findsOneWidget);
      });

      testWidgets('AdminSettingsScreen viewport test on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        await tester.pumpWidget(buildAppHarness(child: const AdminSettingsScreen()));
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(errors.isEmpty, isTrue, reason: 'AdminSettingsScreen zero overflow on ${size.width}px');
      });

      testWidgets('AdminDrawer renders without overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        await tester.pumpWidget(buildAppHarness(
          child: const Scaffold(
            drawer: AdminDrawer(),
            body: SizedBox.expand(),
          ),
        ));
        await tester.pumpAndSettle();

        final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;
        expect(errors.isEmpty, isTrue, reason: 'Zero RenderFlex overflow on drawer at ${size.width}px');
        expect(find.byType(AdminDrawer), findsOneWidget);
      });

      testWidgets('StatisticsScreen viewport test on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        await tester.pumpWidget(buildAppHarness(child: const StatisticsScreen()));
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(errors.isEmpty, isTrue, reason: 'Zero RenderFlex overflow on StatisticsScreen at ${size.width}px');
      });

      testWidgets('CreateStaffBottomSheet renders without overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        await tester.pumpWidget(buildAppHarness(
          child: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => CreateStaffBottomSheet.show(ctx),
                child: const Text('Open'),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;
        expect(errors.isEmpty, isTrue, reason: 'Zero overflow on CreateStaffBottomSheet at ${size.width}px');
        expect(find.byType(CreateStaffBottomSheet), findsOneWidget);
      });

      testWidgets('UserDetailBottomSheet viewport test on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final errors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        const sampleUser = UserModel(
          id: 777,
          email: 'vip.superlongname@cineplex.vn',
          fullName: 'Nguyễn Văn Siêu Cấp Khách Hàng VIP Trọn Đời',
          role: 'CUSTOMER',
          status: 'ACTIVE',
          loyaltyPoints: 9999,
          phone: '0912345678',
        );

        await tester.pumpWidget(buildAppHarness(
          child: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => UserDetailBottomSheet.show(ctx, sampleUser),
                child: const Text('Open'),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(errors.isEmpty, isTrue, reason: 'Zero RenderFlex overflow on UserDetailBottomSheet at ${size.width}px');
      });
    }

    testWidgets('Adversarial Viewport Stress: UserCardItem with LoyaltyPoints + CreatedAt on 320px', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      final userWithAllDetails = UserModel(
        id: 999,
        email: 'customer.test@cineplex.vn',
        fullName: 'Khách Hàng Thân Thiết Điểm Cao',
        role: 'CUSTOMER',
        status: 'ACTIVE',
        loyaltyPoints: 12500,
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(buildAppHarness(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: UserCardItem(
              user: userWithAllDetails,
              isUpdating: false,
              onToggleStatus: () {},
              onTap: () {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      expect(errors.isEmpty, isTrue, reason: 'UserCardItem zero overflow on 320px');
    });
  });

  group('Dynamic Theme Toggling Across App', () {
    testWidgets('Toggling ThemeCubit dynamically switches entire app between Light and Dark mode', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final themeCubit = ThemeCubit();

      await tester.pumpWidget(
        BlocProvider<ThemeCubit>.value(
          value: themeCubit,
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: const Locale('vi'),
                home: Builder(
                  builder: (ctx) {
                    final isDark = Theme.of(ctx).brightness == Brightness.dark;
                    final colors = CineplexColors.of(ctx);
                    return Scaffold(
                      backgroundColor: colors.background,
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isDark ? 'CURRENT_THEME_DARK' : 'CURRENT_THEME_LIGHT',
                            style: TextStyle(color: colors.textPrimary),
                          ),
                          ElevatedButton(
                            onPressed: () => ctx.read<ThemeCubit>().toggleTheme(),
                            child: const Text('TOGGLE_THEME'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially Dark Mode (ThemeCubit defaults to dark)
      expect(find.text('CURRENT_THEME_DARK'), findsOneWidget);
      expect(find.text('CURRENT_THEME_LIGHT'), findsNothing);

      // Tap toggle button
      await tester.tap(find.text('TOGGLE_THEME'));
      await tester.pumpAndSettle();

      // Must now immediately be Light Mode
      expect(themeCubit.state, equals(ThemeMode.light));
      expect(find.text('CURRENT_THEME_LIGHT'), findsOneWidget);
      expect(find.text('CURRENT_THEME_DARK'), findsNothing);

      // Tap toggle button again
      await tester.tap(find.text('TOGGLE_THEME'));
      await tester.pumpAndSettle();

      // Must now be back to Dark Mode
      expect(themeCubit.state, equals(ThemeMode.dark));
      expect(find.text('CURRENT_THEME_DARK'), findsOneWidget);
    });
  });
}
