# Security & Performance Guidelines (`CINEPLEX Backend`)

Tài liệu này quy định các tiêu chuẩn bắt buộc về bảo mật và tối ưu hóa hiệu năng trong hệ thống Backend CINEPLEX.

---

## 1. Authentication & Session Management

### 1.1 JWT (JSON Web Token) Flow
- **Cơ chế truyền Token:** Hỗ trợ song song 2 cách truyền JWT:
  1. Cookie `accessToken` (được parse tự động qua `cookie-parser`).
  2. Header `Authorization: Bearer <token>` (cho Mobile App Flutter và API Client).
- **Strategy & Guard:**
  - `JwtStrategy`: Giải mã và xác thực token với secret từ `ConfigService.get('JWT_ACCESS_SECRET')`.
  - `JwtAuthGuard`: Bắt buộc token hợp lệ, trả về `401 Unauthorized` nếu thiếu hoặc sai token.
  - `OptionalJwtAuthGuard`: Cho phép truy cập ẩn danh (xem danh sách phim, suất chiếu), nhưng nếu có token hợp lệ thì gắn user vào `req.user`.
- **Hủy phiên đăng nhập & Quản lý Refresh Token:**
  - Refresh Token được lưu trữ bảo mật để cấp phát lại Access Token khi hết hạn mà không bắt người dùng đăng nhập lại liên tục.

---

## 2. Authorization & Role-based Access Control (RBAC)

- **Định nghĩa Role:** Enum `EUserRole`:
  - `ADMIN`: Quản trị toàn bộ rạp, phim, suất chiếu, giá vé, cấu hình phòng, nhân sự và báo cáo doanh thu.
  - `STAFF`: Nhân viên bán vé tại quầy, quét mã QR soát vé (Check-in prevention double-use).
  - `USER`: Khách hàng xem phim, đặt vé, mua bắp nước, áp dụng khuyến mãi và tích điểm.
- **Phân quyền Endpoint:**
  ```typescript
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN)
  ```
- **Ràng buộc:** `RolesGuard` **BẮT BUỘC** đi sau `JwtAuthGuard`. Không đặt `RolesGuard` đứng một mình vì cần `req.user` đã được xác thực trước.

---

## 3. Real-time Seat Hold & Concurrency Control (Chống trùng ghế)

- **Vấn đề bài toán:** Nhiều người dùng đồng thời click chọn cùng một ghế trong cùng một suất chiếu.
- **Giải pháp Redis Distributed Lock:**
  1. Khi client phát sự kiện `hold_seat` qua `SeatGateway` (WebSocket), hệ thống kiểm tra trạng thái ghế trong MySQL và Redis.
  2. Sử dụng Redis key: `seat_hold:{showtimeId}:{seatId}` với giá trị là `userId` và TTL là **300 giây (5 phút)** (`SET seat_hold:x:y userId EX 300 NX`).
  3. Nếu set thành công, broadcast sự kiện `seat_status_changed` tới toàn bộ client đang mở màn hình phòng chiếu đó.
  4. Sau 5 phút, nếu người dùng chưa hoàn tất thanh toán, Redis tự động giải phóng key (hết hạn TTL) hoặc Scheduler định kỳ dọn bản ghi tạm.

---

## 4. Bảo mật Cổng thanh toán & Webhook (VNPay, MoMo, PayPal)

- **Kiểm tra chữ ký số (Checksum Verification):**
  - Mọi IPN / Webhook callback từ cổng thanh toán (MoMo, VNPay) **BẮT BUỘC** phải được kiểm tra chữ ký số (HMAC SHA512 với bí mật `VNP_HASH_SECRET` hoặc HMAC SHA256 với MoMo Secret).
  - Tuyệt đối không cập nhật trạng thái đơn hàng thành `SUCCESS` nếu chữ ký số không khớp hoặc số tiền thanh toán không khớp với `totalPrice` của Booking trong DB.
- **Idempotency (Chống xử lý lặp Webhook):**
  - Kiểm tra trạng thái hiện tại của Booking trước khi xử lý. Nếu đơn hàng đã ở trạng thái `PAID` hoặc `CANCELLED`, ghi nhận log và trả về HTTP 200/OK cho cổng thanh toán mà không cấp vé lặp lại.

---

## 5. Rate Limiting & Throttler

- **Mục tiêu:** Ngăn chặn tấn công Brute Force, spam giữ ghế và spam gửi OTP qua email.
- **Cấu hình:** Sử dụng `@nestjs/throttler` và `CustomThrottlerGuard`.
- **Quy tắc:** Các API nhạy cảm (`auth/login`, `auth/register`, `auth/send-otp`, `booking/hold-seat`) phải có rate limit giới hạn tần suất chặt chẽ.

---

## 6. Quản lý Bí mật & Mã hóa (Secrets & Cryptography)

- **Môi trường & Biến nhạy cảm:**
  - **TUYỆT ĐỐI KHÔNG** hard-code secret, mật khẩu DB, khóa thanh toán, API key trong mã nguồn.
  - Tất cả lưu tại file `.env` và truy cập qua `ConfigModule` / `ConfigService`.
- **Mã hóa mật khẩu:**
  - Mật khẩu người dùng **BẮT BUỘC** được băm bằng `bcrypt` với Salt Rounds >= 10.
- **Mã QR vé điện tử:**
  - Mã QR của vé chứa chuỗi mã hóa ký số bảo mật để nhân viên soát vé quét, tránh việc tự chế mã QR giả mạo.

---

## 7. Tối ưu hóa Database & Query (TypeORM & MySQL)

- **Tránh N+1 Query:**
  - Tải dữ liệu rạp, phòng chiếu, suất chiếu, phim bằng `relations` hoặc `QueryBuilder.leftJoinAndSelect()`.
- **Index cần thiết:**
  - Các bảng lớn như `bookings`, `tickets`, `showtimes`, `seat_holds` phải được gắn `@Index()` trên các khóa ngoại và cột lọc trạng thái/thời gian.
- **Phân trang (Pagination):**
  - Mọi API danh sách (Phim, Suất chiếu, Lịch sử đặt vé, Khuyến mãi) đều phải hỗ trợ phân trang (`page`, `limit`).
