import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/notification_cubit.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 16;

    return AppScaffold(
      title: l10n.notifications,
      bottomSafeArea: false,
      actions: [
        IconButton(
          icon: Icon(Icons.done_all, color: colors.primary),
          onPressed: () => context.read<NotificationCubit>().markAllRead(),
        )
      ],
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) return const AppLoading();
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return AppEmptyView(
                icon: Icons.notifications_none_outlined,
                title: l10n.noNotifications,
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
              color: colors.primary,
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: colors.divider),
                itemBuilder: (context, index) {
                  return NotificationItem(notification: state.notifications[index]);
                },
              ),
            );
          }
          if (state is NotificationError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<NotificationCubit>().loadNotifications(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
