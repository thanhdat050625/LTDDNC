import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/notification/presentation/widgets/notification_badge_icon.dart';
import 'package:cineplex_client/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:cineplex_client/features/notification/data/repositories/notification_repository.dart';
import 'package:cineplex_client/features/notification/data/models/notification_model.dart';
import 'package:cineplex_client/features/notification/presentation/widgets/in_app_notification_banner.dart';
import 'package:cineplex_client/features/notification/presentation/widgets/notification_item.dart';

class _FakeNotificationRepo extends NotificationRepository {
  _FakeNotificationRepo() : super(DioClient(StorageService()));

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1}) async => [];

  @override
  Future<int> getUnreadCount() async => 0;
}

Widget _wrap(NotificationCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('vi')],
    locale: const Locale('vi'),
    home: BlocProvider<NotificationCubit>.value(
      value: cubit,
      child: const Scaffold(body: Center(child: NotificationBadgeIcon(color: Colors.red))),
    ),
  );
}

void main() {
  testWidgets('Notification badge: hidden on 0, displays count, and caps at 99+', (tester) async {
    final cubit = NotificationCubit(_FakeNotificationRepo());

    // 1. Initial / 0 unread
    cubit.emit(const NotificationLoaded([], 0));
    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();

    final badgeFinder = find.byType(Badge);
    expect(badgeFinder, findsOneWidget);
    final badgeWidget0 = tester.widget<Badge>(badgeFinder);
    expect(badgeWidget0.isLabelVisible, isFalse);

    // 2. Count = 5 -> should show '5'
    cubit.emit(const NotificationLoaded([], 5));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);

    // 3. Count = 99 -> should show '99'
    cubit.emit(const NotificationLoaded([], 99));
    await tester.pumpAndSettle();
    expect(find.text('99'), findsOneWidget);

    // 4. Count = 150 (> 99) -> should show '99+'
    cubit.emit(const NotificationLoaded([], 150));
    await tester.pumpAndSettle();
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('InAppNotificationBanner displays notification subject and content', (tester) async {
    final notif = NotificationModel(
      id: '1',
      subject: 'Đổi mật khẩu thành công',
      content: 'Mật khẩu của bạn đã được thay đổi',
      type: 'ACCOUNT',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  InAppNotificationBanner.show(
                    context: context,
                    notification: notif,
                    onTap: () {},
                  );
                },
                child: const Text('Show Banner'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Banner'));
    await tester.pumpAndSettle();

    expect(find.text('Đổi mật khẩu thành công'), findsOneWidget);
    expect(find.text('Mật khẩu của bạn đã được thay đổi'), findsOneWidget);

    InAppNotificationBanner.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('Đổi mật khẩu thành công'), findsNothing);
  });

  testWidgets('NotificationItem renders without ListTile ColoredBox assertion error', (tester) async {
    final unreadItem = NotificationModel(
      id: 'item-1',
      subject: 'Thông báo chưa đọc',
      content: 'Nội dung thông báo mới',
      type: 'PROMOTION',
      isRead: false,
      createdAt: DateTime.now(),
    );

    final readItem = NotificationModel(
      id: 'item-2',
      subject: 'Thông báo đã đọc',
      content: 'Nội dung thông báo cũ',
      type: 'ACCOUNT',
      isRead: true,
      createdAt: DateTime.now(),
    );

    final cubit = NotificationCubit(_FakeNotificationRepo());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('vi')],
        locale: const Locale('vi'),
        home: BlocProvider<NotificationCubit>.value(
          value: cubit,
          child: Scaffold(
            body: ListView(
              children: [
                NotificationItem(notification: unreadItem),
                NotificationItem(notification: readItem),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify both items rendered
    expect(find.text('Thông báo chưa đọc'), findsOneWidget);
    expect(find.text('Thông báo đã đọc'), findsOneWidget);

    // Tap unread item to trigger splash and onTap
    await tester.tap(find.text('Thông báo chưa đọc'));
    await tester.pumpAndSettle();
  });
}

