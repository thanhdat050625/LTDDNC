import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cineplex_client/features/profile/data/repositories/profile_repository.dart';
import 'package:cineplex_client/features/profile/presentation/screens/loyalty_detail_screen.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository profileRepository;

  setUp(() {
    profileRepository = MockProfileRepository();
    when(() => profileRepository.getLoyaltyHistory(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => {
          'loyaltyPoints': 91453,
          'items': [
            {
              'id': 'earn-1',
              'bookingId': 10023,
              'bookingCode': 'BK-10023',
              'movieTitle': 'Đào, Phở và Piano',
              'type': 'EARN',
              'points': 15000,
              'title': 'Tích lũy từ đơn vé',
              'description': 'Đơn hàng #BK-10023 - Đào, Phở và Piano',
              'createdAt': '2026-10-09T14:30:00.000Z',
            },
            {
              'id': 'redeem-1',
              'bookingId': 10022,
              'bookingCode': 'BK-10022',
              'movieTitle': 'Mai',
              'type': 'REDEEM',
              'points': -5000,
              'title': 'Dùng điểm thanh toán',
              'description': 'Đơn hàng #BK-10022 - Mai',
              'createdAt': '2026-10-08T10:00:00.000Z',
            },
            {
              'id': 'refund-1',
              'bookingId': 10020,
              'bookingCode': 'BK-10020',
              'type': 'REFUND',
              'points': 5000,
              'title': 'Hoàn trả điểm tích lũy',
              'description': 'Đơn hàng #BK-10020 bị hủy/hết hạn',
              'createdAt': '2026-10-07T12:00:00.000Z',
            },
          ],
        });
  });

  Widget buildTestWidget({ThemeMode themeMode = ThemeMode.dark}) {
    return RepositoryProvider<ProfileRepository>.value(
      value: profileRepository,
      child: MaterialApp(
        themeMode: themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: const LoyaltyDetailScreen(
          initialUser: {
            'fullName': 'Nguyễn Văn A',
            'email': 'customer@cineplex.vn',
            'loyaltyPoints': 91453,
          },
          initialLoyalty: {
            'loyaltyPoints': 91453,
          },
        ),
      ),
    );
  }

  testWidgets('LoyaltyDetailScreen renders points card, history items and switches tabs cleanly', (tester) async {
    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Points and User display
    expect(find.text('91.453'), findsOneWidget);
    expect(find.text('Nguyễn Văn A'), findsOneWidget);

    // Verify History list items
    expect(find.text('Tích lũy từ đơn vé'), findsOneWidget);
    expect(find.text('Dùng điểm thanh toán'), findsOneWidget);
    expect(find.text('Hoàn trả điểm tích lũy'), findsOneWidget);
    expect(find.text('+15.000'), findsOneWidget);
    expect(find.text('-5.000'), findsOneWidget);
    expect(find.text('+5.000'), findsOneWidget);

    // Tap on Policy Tab
    final policyTab = find.byIcon(Icons.menu_book_rounded);
    expect(policyTab, findsOneWidget);
    await tester.tap(policyTab);
    await tester.pumpAndSettle();

    // Verify Policy cards are visible
    expect(find.byIcon(Icons.card_giftcard_rounded), findsOneWidget);
    expect(find.byIcon(Icons.currency_exchange_rounded), findsOneWidget);
    expect(find.byIcon(Icons.replay_circle_filled_rounded), findsOneWidget);
  });

  testWidgets('LoyaltyDetailScreen renders cleanly in Light Mode', (tester) async {
    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.light));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('91.453'), findsOneWidget);
    expect(find.text('Tích lũy từ đơn vé'), findsOneWidget);
  });

  testWidgets('Tapping history item opens transaction detail modal sheet and shows details', (tester) async {
    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();
    await tester.pumpAndSettle();

    // Tap first item
    await tester.tap(find.text('Tích lũy từ đơn vé'));
    await tester.pumpAndSettle();

    // Verify modal bottom sheet details
    expect(find.text('Chi tiết giao dịch điểm'), findsOneWidget);
    expect(find.text('#BK-10023'), findsOneWidget);
    expect(find.text('Đào, Phở và Piano'), findsOneWidget);
    expect(find.text('+15.000 điểm'), findsOneWidget);
    expect(find.text('Xem chi tiết vé'), findsOneWidget);

    // Close button pops the sheet
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết giao dịch điểm'), findsNothing);
  });

  for (final width in [320.0, 360.0, 390.0, 412.0]) {
    testWidgets('LoyaltyDetailScreen has zero overflow on ${width}px width', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final List<FlutterErrorDetails> errors = [];
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      try {
        await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
        await tester.pump();
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = oldOnError;
      }

      final overflows = errors.where((e) => e.toString().contains('overflowed')).toList();
      expect(overflows, isEmpty, reason: 'Zero overflow on ${width}px');
    });
  }
}
