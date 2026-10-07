# Architecture Overview (`CINEPLEX Mobile Monorepo`)

Hệ thống Mobile App CINEPLEX được phát triển đa nền tảng (Android & iOS) bằng Flutter, tổ chức theo mô hình **Monorepo gồm 4 thư mục**:

```text
mobile/
├── mobile_shared/     # Package thư viện & tài nguyên dùng chung
├── cineplex_client/   # Ứng dụng Khách hàng (Customer)
├── cineplex_staff/    # Ứng dụng Nhân viên (Staff)
└── cineplex_admin/    # Ứng dụng Quản trị viên (Admin)
```

---

## 1. Các Ứng dụng trong Hệ thống

1. **Khách hàng (`cineplex_client`):**
   - Xem danh sách phim đang chiếu / sắp chiếu, xem chi tiết trailer và thông tin phim.
   - Chọn cụm rạp, ngày chiếu và suất chiếu.
   - Giữ ghế real-time (khóa 5 phút qua WebSocket).
   - Chọn combo bắp nước, áp dụng mã khuyến mãi.
   - Thanh toán online VNPay Sandbox và nhận vé điện tử kèm mã QR.
   - Quản lý lịch sử vé, điểm thưởng loyalty, thông báo đẩy và hồ sơ cá nhân.

2. **Nhân viên (`cineplex_staff`):**
   - Đăng nhập xác thực role `STAFF` hoặc `ADMIN`.
   - Quét mã QR vé xem phim qua camera (`mobile_scanner`) hoặc nhập mã thủ công.
   - Kiểm tra tính hợp lệ của vé, ngăn chặn check-in lặp lại (double check-in).
   - POS bán vé và bắp nước tại quầy rạp.

3. **Quản trị viên (`cineplex_admin`):**
   - Đăng nhập bảo mật role `ADMIN`.
   - Dashboard điều hành trung tâm và tổng quan hoạt động rạp.
   - Quản lý tài khoản người dùng (Customer / Staff / Admin) và thay đổi trạng thái (Active / Blocked).
   - Báo cáo thống kê doanh thu theo ngày/tháng/năm và phân tích hiệu suất phim.

4. **Package dùng chung (`mobile_shared`):**
   - Chứa hạ tầng mạng `DioClient`, quản lý token `StorageService`, kết nối `SocketService`.
   - Theme tokens (`AppColors`, `CineplexColors`, `AppTheme` hỗ trợ Dark & Light mode).
   - Bộ component giao diện dùng chung (`AppButton`, `AppTextField`, `AppLoading`, `AppErrorView`, `AppCard`, `AppScaffold`).
   - Toàn bộ Data Models và AuthBloc.
   - Thư viện đa ngôn ngữ tập trung `AppLocalizations` (`app_en.arb`, `app_vi.arb`).

---

## 2. Kiến trúc Tổng thể:
- **Presentation:** Flutter Widgets, BLoC / Cubit State Management, GoRouter độc lập cho từng vai trò.
- **Domain & Data:** Data Models kế thừa `Equatable`, Repository Pattern nhận `DioClient`.
- **Security:** Token JWT lưu tại `FlutterSecureStorage`, tự động làm mới qua Interceptor.
