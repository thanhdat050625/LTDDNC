# Navigation & Routing Guide (`GoRouter Flutter`)

Tài liệu này chuẩn hóa quy tắc điều hướng (Routing) trong ứng dụng CINEPLEX Mobile sử dụng package `go_router`.

---

## 1. Cấu hình GoRouter tập trung (`core/router/app_router.dart`)

- Khai báo toàn bộ route tĩnh và động trong singleton `GoRouter`.
- Phân nhóm routes theo vai trò:
  - Public Routes: Splash, Login, Register, Home, Movie Detail, Showtimes.
  - Protected Customer Routes: Seat Booking, Checkout, My Tickets, Profile.
  - Staff Only Routes: Staff QR Scanner, Ticket Validation Result.

---

## 2. Route Guards & Redirection

Tự động kiểm tra trạng thái đăng nhập qua `refreshListenable` từ `AuthBloc`:
```dart
redirect: (BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;
  final isLoggingIn = state.matchedLocation == '/login';

  if (authState is! AuthAuthenticatedState) {
    if (state.matchedLocation.startsWith('/checkout') ||
        state.matchedLocation.startsWith('/staff')) {
      return '/login';
    }
  }
  return null;
}
```

---

## 3. Deep Linking Vé xem phim

Hỗ trợ mở trực tiếp vé xem phim từ liên kết mã QR hoặc thông báo đẩy:
- URL Scheme: `cineplex://tickets/:id`
- Mở thẳng màn hình `TicketDetailScreen(ticketId: id)`.
