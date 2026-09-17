# Realtime Socket.IO Rules (`Flutter Mobile Client`)

Tài liệu này quy định việc quản lý kết nối Socket.IO thời gian thực giữa Mobile App và Backend CINEPLEX (cho sơ đồ chọn ghế và nhận thông báo).

---

## 1. Socket Service Singleton

Quản lý kết nối Socket qua một class tập trung: `SocketService`:
- Tự động đính kèm `auth: { token: accessToken }` khi kết nối.
- Xử lý các sự kiện vòng đời: `connect`, `disconnect`, `connect_error`, `reconnect`.
- Không tạo nhiều instance socket gây lãng phí tài nguyên và làm nghẽn server.

---

## 2. Quy ước sự kiện Đặt ghế (Seat Gateway)

| Tên sự kiện (Event Name) | Chiều gửi | Dữ liệu (Payload) | Mô tả |
| :--- | :--- | :--- | :--- |
| `join_room` | Client -> Server | `{ showtimeId: string }` | Vào phòng xem sơ đồ ghế của suất chiếu |
| `leave_room` | Client -> Server | `{ showtimeId: string }` | Rời phòng khi back ra khỏi màn hình chọn ghế |
| `hold_seat` | Client -> Server | `{ showtimeId, seatId }` | Yêu cầu khóa tạm ghế trong 5 phút |
| `release_seat` | Client -> Server | `{ showtimeId, seatId }` | Hủy chọn ghế |
| `seat_status_changed` | Server -> Client | `{ showtimeId, seatId, status, heldBy }` | Cập nhật real-time trạng thái ghế cho toàn bộ client |

---

## 3. Quản lý vòng đời (Lifecycle) trên Flutter Widget

```dart
// Mẫu quản lý Socket trong State
class _SeatBookingScreenState extends State<SeatBookingScreen> {
  @override
  void initState() {
    super.initState();
    final socket = context.read<SocketService>();
    socket.emit('join_room', {'showtimeId': widget.showtimeId});
    socket.on('seat_status_changed', _handleSeatStatusChanged);
  }

  @override
  void dispose() {
    final socket = context.read<SocketService>();
    socket.emit('leave_room', {'showtimeId': widget.showtimeId});
    socket.off('seat_status_changed', _handleSeatStatusChanged);
    super.dispose();
  }
}
```
