import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/socket_events.dart';

class SocketService {
  final String baseUrl;
  final String? token;
  
  IO.Socket? _seatSocket;
  IO.Socket? _notificationSocket;

  SocketService({required this.baseUrl, this.token});

  void connectSeat() {
    if (_seatSocket != null && _seatSocket!.connected) return;
    _seatSocket = IO.io('$baseUrl${SocketEvents.seatNamespace}', IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setAuth({'token': token})
        .build());
    _seatSocket?.connect();
  }

  void connectNotification(int userId) {
    _notificationSocket = IO.io('$baseUrl${SocketEvents.notificationNamespace}', IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token})
        .build());
    _notificationSocket?.connect();
    joinNotification(userId);
  }

  void joinShowtime(int showtimeId) {
    if (_seatSocket == null) {
      connectSeat();
    } else if (!_seatSocket!.connected) {
      _seatSocket?.connect();
    }
    _seatSocket?.emit(SocketEvents.joinShowtime, {'showtimeId': showtimeId});
  }

  void leaveShowtime(int showtimeId) {
    _seatSocket?.emit(SocketEvents.leaveShowtime, {'showtimeId': showtimeId});
  }

  void joinNotification(int userId) {
    _notificationSocket?.emit(SocketEvents.joinNotification, userId);
  }

  void leaveNotification(int userId) {
    _notificationSocket?.emit(SocketEvents.leaveNotification, userId);
  }

  void onSeatUpdate(Function(Map<String, dynamic>) callback) {
    _seatSocket?.on(SocketEvents.seatUpdate, (data) => callback(data as Map<String, dynamic>));
  }

  void offSeatUpdate() {
    _seatSocket?.off(SocketEvents.seatUpdate);
  }

  void onNewNotification(Function(Map<String, dynamic>) callback) {
    _notificationSocket?.on(SocketEvents.newNotification, (data) => callback(data as Map<String, dynamic>));
  }

  void offNewNotification() {
    _notificationSocket?.off(SocketEvents.newNotification);
  }

  void dispose() {
    _seatSocket?.disconnect();
    _seatSocket?.dispose();
    _notificationSocket?.disconnect();
    _notificationSocket?.dispose();
  }
}
