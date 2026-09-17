# Backend Architecture (`CINEPLEX Backend`)

Backend của hệ thống **CINEPLEX** (Quản lý rạp chiếu phim & Đặt vé trực tuyến) được xây dựng bằng **NestJS 11** với **TypeScript**, thiết kế theo kiến trúc Module hóa (Modular Architecture) và phân tầng rõ ràng (Layered / N-Tier Architecture) nhằm đảm bảo tính mở rộng, bảo mật, và xử lý real-time hiệu năng cao.

---

## 1. Công nghệ & Stack cốt lõi (Tech Stack)

- **Framework:** NestJS 11 (Node.js runtime)
- **Ngôn ngữ:** TypeScript 5.9+
- **Database & ORM:** MySQL 8.x + TypeORM 0.3.x (`autoLoadEntities: true`, đồng bộ tự động trong môi trường phát triển)
- **Caching & Real-time Locking:** Redis (`ioredis`, `@nestjs/cache-manager`) phục vụ giữ ghế tạm thời (Distributed Seat Lock 5 phút), cooldown OTP
- **Realtime / WebSocket:** Socket.IO (`@nestjs/websockets`, `@nestjs/platform-socket.io`) cho sơ đồ ghế trực tiếp (`seat.gateway.ts`) và thông báo hệ thống (`notification.gateway.ts`)
- **Authentication & Security:** Passport JWT (`@nestjs/passport`, `passport-jwt`), Role-based Access Control (RBAC: `ADMIN`, `STAFF`, `USER`), Throttler rate-limiting (`@nestjs/throttler`), `cookie-parser`, `bcrypt`
- **Validation & Serialization:** `class-validator`, `class-transformer`
- **Storage & Media:** Cloudinary (`cloudinary`, `multer`, `streamifier`) cho hình ảnh poster phim, banner rạp
- **QR Code & Vé điện tử:** `qrcode` sinh mã QR vé gửi qua email
- **Mail Service:** `@nestjs-modules/mailer`, Nodemailer gửi OTP và E-Ticket đính kèm mã QR
- **Payment Gateways:** VNPay, MoMo, PayPal (Sandbox integration)
- **Scheduling / Cron:** `@nestjs/schedule` (quét suất chiếu hết hạn, dọn ghế giữ quá hạn)

---

## 2. Kiến trúc phân tầng & Luồng dữ liệu (API Data Flow)

Luồng xử lý chuẩn của mọi HTTP Request trong hệ thống Backend CINEPLEX:

```mermaid
graph TD
    Client[Client: Mobile App / Web] --> Middleware[CookieParser / CORS / TrustProxy]
    Middleware --> Guards[Guards: ThrottlerGuard -> JwtAuthGuard -> RolesGuard]
    Guards --> InterceptorIn[LoggingInterceptor (Request)]
    InterceptorIn --> Validation[ValidationPipe: class-validator DTO]
    Validation --> Controller[NestJS Controller]
    Controller --> Service[Business Service Layer]
    Service --> TypeORM[TypeORM Repository / DataSource / QueryRunner Transaction]
    TypeORM --> Database[(MySQL Database: Phim, Suất chiếu, Rạp, Ghế, Đơn hàng, Vé)]
    Service --> Redis[(Redis Cache: Khóa ghế 5 phút, OTP)]
    Service --> Gateways[Socket.IO Gateways: SeatGateway / NotificationGateway]
    Service --> External[External Services: VNPay / MoMo / PayPal / Cloudinary / Nodemailer]
    Service --> Controller
    Controller --> InterceptorOut[LoggingInterceptor (Response)]
    InterceptorOut --> ClientResponse[Client Response: ApiResponse<T>]
    
    Service -.->|Exception Thrown| ExceptionFilter[HttpExceptionFilter]
    ExceptionFilter --> ErrorResponse[Standard Error JSON: { success: false, error }]
```

---

## 3. Cấu trúc thư mục Source Code (`backend/src/`)

```text
backend/src/
├── constants/             # Enums, ENV constants, System-wide constants
├── core/                  # Hạ tầng dùng chung (Cross-cutting Concerns)
│   ├── common/
│   │   ├── filters/       # HttpExceptionFilter (Standard error response)
│   │   └── interceptors/ # LoggingInterceptor
│   ├── dto/               # ApiResponse.dto.ts (Chuẩn hóa response)
│   ├── exceptions/        # CustomException.ts
│   └── security/          # JWT Strategy, JwtAuthGuard, OptionalJwtAuthGuard, RolesGuard, CustomThrottlerGuard
├── migrations/            # Database schema migrations
├── module/                # Domain Feature Modules
│   ├── auth/              # Đăng nhập, đăng ký, OTP email, reset mật khẩu, JWT tokens
│   ├── booking/           # Giữ ghế real-time (SeatGateway), tạo booking, cập nhật bắp nước
│   │   ├── entities/      # Booking, BookingConcession, SeatHold
│   │   └── seat.gateway.ts# WebSocket Gateway giữ ghế real-time
│   ├── cinema/            # Quản lý rạp chiếu, phòng chiếu, layout cấu hình ghế
│   ├── cloudinary/        # Upload ảnh poster, banner lên Cloudinary
│   ├── concession/        # Quản lý đồ ăn, thức uống, combo bắp nước
│   ├── home/              # API trang chủ: phim đang chiếu, sắp chiếu, banner
│   ├── mails/             # Template & Service gửi Email (OTP, Vé điện tử kèm QR)
│   ├── movie/             # Quản lý phim, thể loại, độ tuổi, trailer
│   ├── notification/      # Thông báo người dùng, Socket.IO NotificationGateway
│   ├── payment/           # Xử lý thanh toán đa cổng: MoMo, VNPay, PayPal & IPN Webhook
│   ├── promotion/         # Mã giảm giá, voucher khuyến mãi, tích điểm thành viên
│   ├── redis/             # Redis client, distributed seat lock, cache & cooldown
│   ├── showtime/          # Quản lý suất chiếu, lịch chiếu theo ngày/rạp, auto scheduler
│   ├── statistics/        # Thống kê doanh thu, số vé bán, tỷ lệ lấp đầy rạp cho Admin
│   ├── ticket/            # Bảng giá vé, cấu hình vé theo loại phòng/ngày, vé điện tử
│   └── users/             # Quản lý tài khoản, phân quyền, hồ sơ người dùng
├── utils/                 # Các hàm tiện ích (format, mã hóa, ngày giờ)
├── app.module.ts          # Root Module kết nối DB, Redis, Cron & các feature modules
└── main.ts                # Bootstrap app, CORS, CookieParser, Global Pipes & Filters
```

---

## 4. Module tham chiếu chuẩn (Source of Truth)

Khi triển khai feature mới hoặc sửa đổi code, Agent **BẮT BUỘC** tham khảo:
1. **Authentication & Security:** `src/module/auth/` và `src/core/security/`
2. **Booking & Realtime Gateway:** `src/module/booking/` (bao gồm `seat.gateway.ts` và `booking.service.ts`)
3. **CRUD & Feature Flow:** `src/module/movie/` và `src/module/cinema/`
4. **Payment & Webhook:** `src/module/payment/`
5. **Response & Error Handling:** `src/core/dto/ApiResponse.dto.ts` & `src/core/common/filters/http-exception.filter.ts`

---

## 5. Tài liệu chi tiết liên quan

- [API Rules & Layer Conventions](api_rules.md)
- [Security & Performance Guidelines](security_and_performance.md)
- [Development Workflow & Lifecycle](workflow.md)
