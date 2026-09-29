import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_client/core/widgets/app_scaffold.dart';
import 'package:cineplex_client/core/widgets/app_loading.dart';
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
    return AppScaffold(
      title: 'Notifications',
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
            if (state.notifications.isEmpty) return const Center(child: Text('No notifications'));
            return RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
              child: ListView.builder(
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
