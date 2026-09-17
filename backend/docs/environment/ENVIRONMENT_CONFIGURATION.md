# Kiến trúc Environment Configuration (`CINEPLEX Backend`)

Tài liệu này giải thích chi tiết về kiến trúc cấu hình môi trường chuẩn hóa của Backend CINEPLEX, phân tách rõ ràng thành 2 môi trường: **Development (`.env.dev`)** và **Production (`.env.prod`)**.

---

## 1. Các biến Environment Cốt Lõi

Hệ thống sử dụng các biến cấu hình cốt lõi để đảm bảo hoạt động an toàn và độc lập:

### Máy chủ & Cổng truy cập
- **`PORT`**: Cổng lắng nghe của NestJS server (mặc định: `3000`).
- **`FRONTEND_URL`**: Đường dẫn frontend web hoặc mobile origin được phép CORS (Dev: `http://localhost:5173`, Prod: `https://cineplex.app`).

### Cơ sở dữ liệu MySQL (TypeORM)
- **`DB_HOST`**: Địa chỉ máy chủ MySQL (Dev: `localhost` hoặc `127.0.0.1`, Prod: host MySQL cloud).
- **`DB_PORT`**: Cổng MySQL (mặc định `3306`).
- **`DB_USER`**: Tên người dùng database.
- **`DB_PASS`**: Mật khẩu database.
- **`DB_NAME`**: Tên cơ sở dữ liệu (`qlda_movie`).

### Redis (Real-time Seat Hold & OTP Cache)
- **`REDIS_HOST`**: Địa chỉ Redis (Dev: `localhost`, Prod: cloud Redis host).
- **`REDIS_PORT`**: Cổng Redis (mặc định `6379`).
- **`REDIS_PASSWORD`**: Mật khẩu Redis (nếu có).

### Bảo mật & JWT
- **`JWT_ACCESS_SECRET`**: Khóa bí mật dùng để ký và giải mã Access Token.
- **`JWT_REFRESH_SECRET`**: Khóa bí mật dùng cho Refresh Token.
- **`JWT_ACCESS_EXPIRES_IN`**: Thời gian hiệu lực của Access Token (ví dụ: `1d` hoặc `15m`).
- **`JWT_REFRESH_EXPIRES_IN`**: Thời gian hiệu lực của Refresh Token (ví dụ: `7d`).

### Email SMTP (Nodemailer)
- **`MAIL_HOST`**: Máy chủ SMTP (ví dụ: `smtp.gmail.com`).
- **`MAIL_PORT`**: Cổng SMTP (`587` cho TLS hoặc `465` cho SSL).
- **`MAIL_USER`**: Tài khoản email gửi tin.
- **`MAIL_PASS`**: Mật khẩu ứng dụng (App Password) của email.
- **`MAIL_FROM`**: Tên hiển thị người gửi (`Cineplex Support <no-reply@cineplex.com>`).

### Lưu trữ hình ảnh (Cloudinary)
- **`CLOUDINARY_CLOUD_NAME`**: Tên Cloudinary account.
- **`CLOUDINARY_API_KEY`**: API Key của Cloudinary.
- **`CLOUDINARY_API_SECRET`**: API Secret của Cloudinary.

### Cổng thanh toán Sandbox (Payment Gateways)
- **`VNP_TMN_CODE`**: Mã website tại VNPay sandbox.
- **`VNP_HASH_SECRET`**: Chuỗi bí mật tạo mã checksum SHA512 của VNPay.
- **`VNP_URL`**: Endpoint cổng thanh toán VNPay.
- **`VNP_RETURN_URL`**: URL trả về sau khi khách hoàn tất giao dịch VNPay.
- **`MOMO_PARTNER_CODE`**, **`MOMO_ACCESS_KEY`**, **`MOMO_SECRET_KEY`**: Cấu hình Sandbox MoMo.
- **`PAYPAL_CLIENT_ID`**, **`PAYPAL_CLIENT_SECRET`**: Cấu hình Sandbox PayPal.

---

## 2. Chuẩn Hóa 2 Môi Trường (`APP_ENV`)

Hệ thống tuân thủ nguyên tắc **Strict Isolation**:

- **`.env.dev`** (`APP_ENV=dev`, `NODE_ENV=development`):
  - Dành cho lập trình nội bộ, kiểm thử chức năng trên máy cá nhân.
  - Tự động nạp khi chạy `npm run dev` hoặc `npm run start:dev`.
  - TypeORM có thể bật tự động đồng bộ (`synchronize: true`).

- **`.env.prod`** (`APP_ENV=prod`, `NODE_ENV=production`):
  - Dành cho môi trường phát hành hoặc triển khai lên Server/Cloud.
  - Kết nối tới Cloud MySQL, Cloud Redis, email và domain thật.
  - Tự động nạp khi chạy `npm run prod` hoặc `npm run start:prod`.
  - TypeORM tắt tự động đồng bộ (`synchronize: false`), chạy qua Migrations.

---

## 3. Bảng Tổng Hợp Cấu Hình (Configuration Matrix)

| Mục cấu hình | Môi trường Dev (`.env.dev`) | Môi trường Prod (`.env.prod`) |
| :--- | :--- | :--- |
| **PORT** | `3000` | Cổng từ process.env của host (vd: 8080) |
| **DB_HOST** | `localhost` / `127.0.0.1` | Cloud MySQL Host |
| **REDIS_HOST**| `localhost` / `127.0.0.1` | Cloud Redis Host |
| **FRONTEND_URL** | `http://localhost:5173` | Domain chính thức ứng dụng |
| **Synchronize DB** | `true` | `false` (Dùng Migration) |
