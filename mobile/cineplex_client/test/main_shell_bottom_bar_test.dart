import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/core/router/main_shell.dart';
import 'package:cineplex_client/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:cineplex_client/features/notification/data/repositories/notification_repository.dart';
import 'package:cineplex_client/features/notification/data/models/notification_model.dart';

class _MockNotificationRepo extends NotificationRepository {
  _MockNotificationRepo() : super(DioClient(StorageService()));

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1}) async => [];

  @override
  Future<int> getUnreadCount() async => 0;
}

void main() {
  testWidgets('MainShell bottom bar has rounded capsule active indicator synchronized with outer bar', (tester) async {
    final notifCubit = NotificationCubit(_MockNotificationRepo());

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => BlocProvider<NotificationCubit>.value(
            value: notifCubit,
            child: MainShell(child: child),
          ),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const Scaffold(body: Text('Home Content')),
            ),
            GoRoute(
              path: '/movies',
              builder: (context, state) => const Scaffold(body: Text('Movies Content')),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('vi')],
        locale: const Locale('vi'),
      ),
    );
    await tester.pumpAndSettle();

    // Verify all 5 tab labels are rendered in Vietnamese
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Phim'), findsOneWidget);
    expect(find.text('Vé của tôi'), findsOneWidget);
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Tài khoản'), findsOneWidget);

    // Locate the AnimatedPositioned active tab indicator
    final animatedPositionedFinder = find.byType(AnimatedPositioned);
    expect(animatedPositionedFinder, findsOneWidget);

    // Find the Container inside AnimatedPositioned
    final indicatorContainerFinder = find.descendant(
      of: animatedPositionedFinder,
      matching: find.byType(Container),
    );
    expect(indicatorContainerFinder, findsOneWidget);

    final indicatorContainer = tester.widget<Container>(indicatorContainerFinder);
    final indicatorBoxDecoration = indicatorContainer.decoration as BoxDecoration;

    // Verify indicator is rounded with radius 26 (capsule shape, consistent with outer container)
    expect(indicatorBoxDecoration.borderRadius, BorderRadius.circular(26));
    expect(indicatorContainer.margin, const EdgeInsets.symmetric(horizontal: 5));

    // Tap second tab (Phim)
    await tester.tap(find.text('Phim'));
    await tester.pumpAndSettle();

    expect(find.text('Movies Content'), findsOneWidget);

    notifCubit.close();
  });
}
