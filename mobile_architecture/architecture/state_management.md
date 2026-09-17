# State Management Rules (`Flutter BLoC & Cubit`)

Tài liệu này chuẩn hóa việc quản lý trạng thái trong ứng dụng Flutter CINEPLEX bằng thư viện `flutter_bloc`.

---

## 1. Khi nào dùng Cubit, khi nào dùng BLoC?

- **Dùng Cubit:** Khi nghiệp vụ đơn giản, phản ứng đồng bộ với thao tác người dùng (ví dụ: Toggle ẩn/hiện mật khẩu, chọn tab, thay đổi số lượng bắp nước, lọc phim theo thể loại).
- **Dùng BLoC:** Khi nghiệp vụ phức tạp, cần debounce/throttle sự kiện, có nhiều luồng sự kiện bất đồng bộ liên tiếp (ví dụ: Tìm kiếm phim theo từ khóa, luồng xác thực OTP và đăng nhập, luồng giữ ghế Socket.IO).

---

## 2. Chuẩn hóa State Model

Mọi state nên kế thừa `Equatable` và hỗ trợ đầy đủ các trạng thái cơ bản:
```dart
abstract class MovieState extends Equatable {
  const MovieState();
  @override
  List<Object?> get props => [];
}

class MovieInitialState extends MovieState {}
class MovieLoadingState extends MovieState {}
class MovieLoadedState extends MovieState {
  final List<MovieModel> movies;
  const MovieLoadedState(this.movies);
  @override
  List<Object?> get props => [movies];
}
class MovieErrorState extends MovieState {
  final String message;
  const MovieErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
```

---

## 3. Quy tắc Widget lắng nghe State

- Sử dụng `BlocBuilder` khi chỉ cần re-render giao diện dựa theo State.
- Sử dụng `BlocListener` khi chỉ cần thực hiện hành động phụ một lần (Side-effects như hiển thị SnackBar lỗi, Navigate sang màn hình khác, mở BottomSheet).
- Sử dụng `BlocConsumer` khi cần kết hợp cả re-render và Side-effects.
- **TUYỆT ĐỐI KHÔNG** trigger `Navigator.push` hoặc `showDialog` bên trong hàm `builder` của `BlocBuilder`.
