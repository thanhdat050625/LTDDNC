import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
  final Set<String> _knownNotificationIds = {};
  bool _hasInitialized = false;

  Timer? _pollTimer;
  final _newNotificationController = StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get newNotificationStream => _newNotificationController.stream;

  NotificationCubit(this.repository) : super(NotificationInitial());

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    _pollTimer?.cancel();
    // Immediate load then periodic polling
    loadNotifications(isSilent: state is NotificationLoaded);
    _pollTimer = Timer.periodic(interval, (_) {
      loadNotifications(isSilent: true);
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
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
    _pollTimer?.cancel();
    _newNotificationController.close();
    return super.close();
  }
}
