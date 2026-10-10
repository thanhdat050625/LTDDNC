import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded(this.notifications, this.unreadCount);

  @override
  List<Object?> get props => [notifications, unreadCount];
}
class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;
  final SocketService? socketService;
  final Set<String> _knownNotificationIds = {};
  bool _hasInitialized = false;
  int? _subscribedUserId;

  final _newNotificationController = StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get newNotificationStream => _newNotificationController.stream;

  NotificationCubit(this.repository, {this.socketService}) : super(NotificationInitial());

  void initSocket(int userId) {
    if (socketService == null) return;
    if (_subscribedUserId == userId) return;
    _subscribedUserId = userId;
    socketService!.connectNotification(userId);
    socketService!.onNewNotification(_onNewNotificationReceived);
  }

  void disconnectSocket() {
    if (socketService == null) return;
    if (_subscribedUserId != null) {
      socketService!.leaveNotification(_subscribedUserId!);
      _subscribedUserId = null;
    }
    socketService!.offNewNotification();
  }

  void _onNewNotificationReceived(Map<String, dynamic> data) {
    try {
      final notif = NotificationModel.fromJson(data);
      if (!_knownNotificationIds.contains(notif.id)) {
        _knownNotificationIds.add(notif.id);
        _newNotificationController.add(notif);
      }

      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final updatedList = [
          notif,
          ...current.notifications.where((n) => n.id != notif.id),
        ];
        final newUnread = current.unreadCount + (notif.isRead ? 0 : 1);
        emit(NotificationLoaded(updatedList, newUnread));
      }

      loadNotifications(isSilent: true);
    } catch (_) {}
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    // Deprecated: WebSocket is used for realtime notifications
    loadNotifications(isSilent: state is NotificationLoaded);
  }

  void stopPolling() {
    // Deprecated: No polling timer active
  }

  Future<void> loadNotifications({bool isSilent = false}) async {
    if (!isSilent) emit(NotificationLoading());
    try {
      final notifs = await repository.getNotifications();
      final unreadCount = await repository.getUnreadCount();

      if (!_hasInitialized) {
        _hasInitialized = true;
        for (final n in notifs) {
          _knownNotificationIds.add(n.id);
        }
      } else {
        for (final n in notifs) {
          if (!n.isRead && !_knownNotificationIds.contains(n.id)) {
            _knownNotificationIds.add(n.id);
            _newNotificationController.add(n);
          }
        }
      }

      emit(NotificationLoaded(notifs, unreadCount));
    } catch (e) {
      if (!isSilent) emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await repository.markAsRead(id);
      loadNotifications(isSilent: true);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await repository.markAllAsRead();
      loadNotifications(isSilent: true);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    disconnectSocket();
    _newNotificationController.close();
    return super.close();
  }
}
