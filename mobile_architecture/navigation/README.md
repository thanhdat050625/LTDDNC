# Navigation & Routing Guide (`GoRouter Flutter Monorepo`)

Mỗi ứng dụng trong hệ thống CINEPLEX Mobile sở hữu một cấu hình `GoRouter` độc lập, phản ánh đúng vai trò và quyền hạn của người dùng.

---

## 1. Cấu hình GoRouter trong từng ứng dụng

### A. Customer App (`cineplex_client/lib/core/router/app_router.dart`)
- **Root Navigator & StatefulShellRoute:** Quản lý Bottom Navigation Bar với 4 tabs:
  - Tab 1: Trang chủ (`/home`)
  - Tab 2: Danh sách Phim (`/movies`)
  - Tab 3: Vé của tôi (`/my-tickets`)
  - Tab 4: Cá nhân (`/profile`)
- **Pushed Routes (Mở đè không có thanh điều hướng dưới):**
  - Chi tiết phim: `/movie/:id`
  - Chọn suất chiếu: `/showtimes`
  - Giữ ghế: `/booking/:showtimeId`
  - Bắp nước: `/concessions/:bookingId`
  - Thanh toán: `/checkout/:bookingId`
  - Kết quả thanh toán: `/payment/result`
  - Chi tiết vé: `/tickets/:id`
  - Thông báo: `/notifications`
  - Chỉnh sửa hồ sơ: `/edit-profile`
- **Route Guard:** Bắt buộc đăng nhập với các route thao tác thanh toán, vé và hồ sơ cá nhân.

---

### B. Staff App (`cineplex_staff/lib/router/staff_router.dart`)
- **Routes:**
  - Đăng nhập Nhân viên: `/login`
  - Quét mã QR soát vé: `/scanner`
- **Route Guard:**
  - Nếu chưa đăng nhập: chuyển hướng về `/login`.
  - Nếu đã đăng nhập với vai trò `STAFF` hoặc `ADMIN`: chuyển hướng vào `/scanner`.
  - Nếu tài khoản không có quyền nhân viên: hiển thị lỗi truy cập và đăng xuất.

---

### C. Admin App (`cineplex_admin/lib/router/admin_router.dart`)
- **Routes:**
  - Đăng nhập Quản trị: `/login`
  - Bảng điều khiển trung tâm: `/dashboard`
  - Quản lý người dùng: `/users`
  - Báo cáo thống kê: `/statistics`
- **Route Guard:**
  - Nếu chưa đăng nhập: chuyển hướng về `/login`.
  - Chỉ cho phép tài khoản có vai trò `ADMIN` truy cập `/dashboard` và các module quản trị.

---

## 2. Đồng bộ Auth State (`Listenable`)

Cả 3 ứng dụng đều sử dụng `ChangeNotifier` lắng nghe luồng sự kiện từ `AuthBloc` trong `mobile_shared`:

```dart
class _AuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription _subscription;

  _AuthRefreshNotifier(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

Khi trạng thái chuyển từ `AuthUnauthenticated` sang `AuthAuthenticated` (hoặc ngược lại), GoRouter tự động kích hoạt `redirect` callback mà không cần reload app thủ công.
