# Mobile Architecture (`CINEPLEX Mobile - Flutter`)

Thư mục này chứa toàn bộ quy tắc về kiến trúc (architecture), thiết kế giao diện (design system) và chuẩn phát triển bắt buộc đối với tất cả AI Agents khi làm việc trên ứng dụng Mobile CINEPLEX (`mobile/`) viết bằng **Flutter**.

---

## 1. Công nghệ & Stack cốt lõi (Tech Stack)

- **Framework & SDK:** Flutter 3.x + Dart 3.x (Null safety strict mode)
- **Kiến trúc ứng dụng:** Phân tầng theo Clean / Feature-first Architecture (`presentation`, `domain`, `data`, `core`)
- **Quản lý State:**
  - **BLoC / Cubit** (`flutter_bloc`): Quản lý luồng đặt vé, giữ ghế, authentication và giỏ hàng bắp nước
  - **ValueNotifier / State**: Quản lý trạng thái cục bộ của widget nhỏ (animation, toggle button)
- **HTTP Client & Networking:** **Dio** (`dio`) với Interceptor tự động gắn JWT Bearer token và xử lý Refresh Token
- **Realtime / WebSocket:** **socket_io_client** kết nối tới `SeatGateway` và `NotificationGateway` của Backend
- **Local Storage / Caching:** `shared_preferences` / `flutter_secure_storage` lưu trữ access token, refresh token và user profile
- **Routing & Navigation:** `go_router` hỗ trợ declarative routing, deep linking và route guards (`AuthGuard`)
- **Quét mã QR & Hiển thị Vé:**
  - `mobile_scanner` / `qr_code_scanner`: Cho màn hình Nhân viên soát vé (Staff Check-in)
  - `qr_flutter`: Hiển thị mã QR vé điện tử cho Khách hàng
- **Localization (Đa ngôn ngữ):** `flutter_localizations` + `intl` (hỗ trợ Tiếng Việt `vi` và Tiếng Anh `en`)

---

## 2. Nguyên tắc cốt lõi (Core Principles)

1. **AI Agent BẮT BUỘC** phải đọc các quy tắc trong thư mục này trước khi triển khai hoặc chỉnh sửa code Flutter.
2. **Feature Tham Chiếu (Reference Architecture):**
   - **Authentication:** `lib/features/auth/` (Login, Register, OTP verification)
   - **Movie & Showtime:** `lib/features/movie/`, `lib/features/showtime/`
   - **Real-time Seat Booking:** `lib/features/booking/` (Sơ đồ ghế SVG/CustomPainter, BLoC giữ ghế 5 phút)
   - **Staff QR Scanner:** `lib/features/staff/` (Quét vé & xác thực check-in)
3. **Repository Pattern:** Toàn bộ API calls phải thông qua Service -> Repository (`*Repository`), **KHÔNG BAO GIỜ** gọi `dio` hoặc `http` trực tiếp trong Widget Flutter.
4. **Không Over-engineering:** Tái sử dụng các widgets có sẵn (`lib/core/widgets/`), custom theme tokens trước khi viết mới.

---

## 3. Cấu trúc tài liệu chi tiết:

- [`architecture/`](architecture/README.md): Quy tắc phân tầng (Presentation, Domain, Data, Core, State Management).
- [`design/`](design/design.md): Design System, Color Tokens (Cinema Dark theme, Neon accents), Typography, Responsive UI.
- [`navigation/`](navigation/README.md): Quy tắc Routing với GoRouter, Deep Link vé xem phim.
- [`feature-development/`](feature-development/README.md): Quy trình phát triển tính năng mới từ Model đến UI Widget.
- [`localization/`](localization/README.md): Quy chuẩn đa ngôn ngữ Tiếng Việt / Tiếng Anh.
