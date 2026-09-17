# Architecture Overview (`CINEPLEX Mobile`)

Hệ thống Mobile App CINEPLEX được phát triển đa nền tảng (Android & iOS) bằng Flutter, phục vụ 2 nhóm người dùng chính:
1. **Khách hàng (Customer):** Xem phim đang chiếu, chọn suất chiếu, chọn rạp, chọn ghế real-time (khóa 5 phút), thanh toán sandbox và nhận vé điện tử QR.
2. **Nhân viên (Staff):** Quét mã QR vé xem phim qua Camera điện thoại để soát vé vào phòng chiếu (ngăn chặn vé quét 2 lần).

---

## Kiến trúc Tổng thể:
- **Presentation:** Flutter Widgets, BLoC / Cubit State Management, GoRouter.
- **Domain:** Entities và Repository Interfaces độc lập.
- **Data:** Models với json serialization, Dio HTTP Client, Socket.IO Client.
- **Security:** Token JWT lưu tại `FlutterSecureStorage`, tự động làm mới qua Interceptor.
