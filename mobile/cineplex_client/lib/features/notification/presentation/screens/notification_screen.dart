import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/notification_cubit.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

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
    return AppScaffold(
      title: l10n.notifications,
      bottomSafeArea: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.done_all),
          onPressed: () => context.read<NotificationCubit>().markAllRead(),
        )
      ],
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) return const AppLoading();
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) return Center(child: Text(l10n.noNotifications));
            return RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom + 16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  return NotificationItem(notification: state.notifications[index]);
                },
              ),
            );
          }
          if (state is NotificationError) return Center(child: Text(state.message));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
