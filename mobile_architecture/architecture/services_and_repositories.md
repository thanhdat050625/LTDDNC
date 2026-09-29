# Services & Repositories (`Flutter Networking & Repositories`)

Tài liệu này quy định việc giao tiếp mạng qua Dio HTTP Client và triển khai Repository Pattern trong hệ sinh thái Monorepo CINEPLEX Mobile.

---

## 1. Hạ tầng Network & Storage Dùng Chung (`mobile_shared`)

### `DioClient` (`mobile_shared/lib/network/dio_client.dart`)
- **Tự động gắn Base URL:** Lấy từ biến môi trường `BASE_URL` được cấu hình thông qua script `update-ip.js` và nạp qua `.env`.
- **Timeouts:** `connectTimeout`: 15s, `receiveTimeout`: 15s.
- **Interceptors:**
  - `Authorization`: Tự động đọc access token từ `StorageService` và đính kèm `Bearer <token>`.
  - `401 Unauthorized`: Xoá token khỏi bộ nhớ an toàn để BLoC kích hoạt điều hướng về màn hình đăng nhập.
- **Methods chuẩn:** `get()`, `post()`, `put()`, `patch()`, `delete()` đều tự động bọc lỗi và chuyển đổi thành `ServerException`.

### `StorageService` (`mobile_shared/lib/services/storage_service.dart`)
- Sử dụng `flutter_secure_storage` lưu trữ `access_token`, `refresh_token`, `user_profile`, `remember_me`.

### `AuthRepository` (`mobile_shared/lib/repositories/auth_repository.dart`)
- Dùng chung cho cả 3 ứng dụng: `login`, `register`, `sendOtp`, `forgotPassword`, `checkAuth`, `logout`.

---

## 2. Phân loại Repositories theo Ứng dụng

```text
mobile/
├── mobile_shared/
│   └── lib/repositories/
│       └── auth_repository.dart       # Xác thực người dùng chung (Customer/Staff/Admin)
│
├── cineplex_client/
│   └── lib/features/
│       ├── home/data/repositories/home_repository.dart
│       ├── movie/data/repositories/movie_repository.dart
│       ├── showtime/data/repositories/showtime_repository.dart
│       ├── booking/data/repositories/booking_repository.dart
│       ├── concession/data/repositories/concession_repository.dart
│       ├── payment/data/repositories/payment_repository.dart
│       ├── ticket/data/repositories/ticket_repository.dart
│       ├── notification/data/repositories/notification_repository.dart
│       └── profile/data/repositories/profile_repository.dart
│
├── cineplex_staff/
│   └── lib/features/
│       └── scanner/data/repositories/staff_repository.dart # Check-in vé & POS
│
└── cineplex_admin/
    └── lib/features/
        ├── statistics/data/repositories/statistics_repository.dart # Doanh thu & hiệu suất phim
        └── users/data/repositories/user_management_repository.dart # Quản lý user & trạng thái
```

---

## 3. Quy tắc Triển khai Repository

1. **Dependency Injection:** Mọi Repository nhận instance `DioClient` qua constructor (`this._dioClient`).
2. **Không gọi API trực tiếp trong UI / Cubit:** Mọi luồng dữ liệu bắt buộc đi qua Repository.
3. **Parse DTO/Model an toàn:** Sử dụng `fromJson()` của Model tương ứng trong `mobile_shared`.
4. **Xử lý Exception:** Để `ServerException` từ `DioClient` nổi lên để Cubit bắt và emit State lỗi tương ứng.
