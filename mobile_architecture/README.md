# Mobile Monorepo Architecture (`CINEPLEX Mobile - Flutter`)

Thư mục này chứa toàn bộ quy tắc về kiến trúc (architecture), thiết kế giao diện (design system) và chuẩn phát triển bắt buộc đối với tất cả AI Agents khi làm việc trên hệ sinh thái Mobile CINEPLEX (`mobile/`) viết bằng **Flutter**.

---

## 1. Cấu trúc Monorepo 4 Thư Mục

Toàn bộ mã nguồn mobile được phân tách thành **3 ứng dụng Flutter độc lập** và **1 Flutter package dùng chung**:

```text
mobile/
├── mobile_shared/         # Shared Flutter Package (chứa mọi tài nguyên dùng chung)
│   ├── lib/
│   │   ├── network/       # DioClient, ApiResponse, Interceptors
│   │   ├── services/      # StorageService, SocketService
│   │   ├── theme/         # AppColors, CineplexColors, AppTheme
│   │   ├── errors/        # AppException, ServerException
│   │   ├── utils/         # FormatUtils (tiền tệ VNĐ, ngày giờ, format mã)
│   │   ├── widgets/       # Core UI: AppButton, AppTextField, AppLoading, AppErrorView, AppCard, AppScaffold
│   │   ├── models/        # UserModel, MovieModel, CinemaModel, SeatModel, ShowtimeModel, BookingModel, TicketModel, ConcessionModel, StatisticsModel, HomeDataModel
│   │   ├── repositories/  # AuthRepository
│   │   ├── bloc/          # AuthBloc, AuthState, AuthEvent
│   │   ├── l10n/          # AppLocalizations, app_en.arb, app_vi.arb (Tập trung toàn bộ chuỗi đa ngôn ngữ)
│   │   └── mobile_shared.dart # Barrel export duy nhất của package
│   └── pubspec.yaml
│
├── cineplex_client/       # Ứng dụng Khách Hàng (Customer App)
│   ├── lib/
│   │   ├── core/router/   # GoRouter client: Bottom Nav Bar, ShellRoute, Deep Link
│   │   └── features/      # auth, home, movie, showtime, booking, concession, payment, ticket, notification, profile
│   └── pubspec.yaml       # dependencies: mobile_shared (path: ../mobile_shared)
│
├── cineplex_staff/        # Ứng dụng Nhân Viên (Staff App)
│   ├── lib/
│   │   ├── router/        # GoRouter staff: /login, /scanner
│   │   └── features/      # auth (staff login), scanner (quét QR vé & xác thực check-in phòng chiếu, POS)
│   └── pubspec.yaml       # dependencies: mobile_shared (path: ../mobile_shared), mobile_scanner
│
└── cineplex_admin/        # Ứng dụng Quản Trị Viên (Admin App)
    ├── lib/
    │   ├── router/        # GoRouter admin: /login, /dashboard, /users, /statistics
    │   └── features/      # auth (admin login), dashboard, users, statistics
    └── pubspec.yaml       # dependencies: mobile_shared (path: ../mobile_shared)
```

---

## 2. Công nghệ & Stack cốt lõi (Tech Stack)

- **Framework & SDK:** Flutter 3.x + Dart 3.x (Null safety strict mode)
- **Kiến trúc ứng dụng:** Monorepo đa ứng dụng (Multi-app Monorepo) kết hợp Feature-first Clean Architecture.
- **Quản lý State:**
  - **BLoC / Cubit** (`flutter_bloc`): Quản lý luồng đặt vé, realtime lock ghế, authentication, báo cáo doanh thu, quét mã QR.
  - **ValueNotifier / State**: Quản lý trạng thái cục bộ của widget nhỏ (animation, toggle button).
- **HTTP Client & Networking:** **Dio** (`dio`) qua `DioClient` trong `mobile_shared` với Interceptor tự động gắn JWT Bearer token và xử lý Refresh Token.
- **Realtime / WebSocket:** **socket_io_client** qua `SocketService` trong `mobile_shared` kết nối tới `SeatGateway` và `NotificationGateway`.
- **Local Storage / Caching:** `flutter_secure_storage` lưu trữ access token, refresh token và remember me.
- **Routing & Navigation:** `go_router` độc lập cho từng app, hỗ trợ declarative routing, deep linking và route guards (`AuthGuard`).
- **Quét mã QR & Hiển thị Vé:**
  - `mobile_scanner`: Quét vé điện tử trong `cineplex_staff`.
  - `qr_flutter`: Hiển thị mã QR vé điện tử cho Khách hàng trong `cineplex_client`.
- **Localization (Đa ngôn ngữ):** Toàn bộ arb files và `AppLocalizations` được quản lý tập trung trong `mobile_shared` (hỗ trợ Tiếng Việt `vi` và Tiếng Anh `en`).

---

## 3. Lệnh vận hành & Scripts (Root CLI)

| Lệnh | Mục đích |
|---|---|
| `npm run mobile:update-ip` | Tự động phát hiện IPv4 Wi-Fi/LAN và cập nhật `.env` cho cả 3 apps + `adb reverse tcp:3000 tcp:3000` |
| `npm run mobile:get` | Chạy `flutter pub get` đồng loạt cho `mobile_shared`, `cineplex_client`, `cineplex_staff`, `cineplex_admin` |
| `npm run mobile:analyze` | Chạy `flutter analyze` kiểm tra chất lượng code trên cả 4 thư mục |
| `npm run mobile:client` | Chạy ứng dụng Khách hàng (`cineplex_client`) với IP tự động |
| `npm run mobile:staff` | Chạy ứng dụng Nhân viên (`cineplex_staff`) với IP tự động |
| `npm run mobile:admin` | Chạy ứng dụng Quản trị viên (`cineplex_admin`) với IP tự động |
| `npm run mobile:client:build` | Build APK cho `cineplex_client` |
| `npm run mobile:staff:build` | Build APK cho `cineplex_staff` |
| `npm run mobile:admin:build` | Build APK cho `cineplex_admin` |

---

## 4. Nguyên tắc cốt lõi (Core Principles)

1. **AI Agent BẮT BUỘC** phải đọc các quy tắc trong thư mục này trước khi triển khai hoặc chỉnh sửa code Flutter.
2. **Quy tắc phụ thuộc (Dependency Rule):**
   - Các app (`cineplex_client`, `cineplex_staff`, `cineplex_admin`) chỉ được phụ thuộc vào `mobile_shared`.
   - **TUYỆT ĐỐI CẤM** các app phụ thuộc chéo vào nhau (ví dụ: `cineplex_staff` không được import file từ `cineplex_client` hay `cineplex_admin`).
3. **DRY (Don't Repeat Yourself):** Bất kỳ Model, Service, Network helper, Widget hay Theme token nào được sử dụng từ 2 app trở lên **BẮT BUỘC** phải được đưa vào `mobile/mobile_shared/`.
4. **Repository Pattern:** Toàn bộ API calls phải thông qua Service -> Repository (`*Repository`), **KHÔNG BAO GIỜ** gọi `dio` hoặc `http` trực tiếp trong Widget Flutter.
5. **Localization & Theme Rule:** Tuân thủ triệt để quy tắc trong `.agents/rules/shared-ui-l10n-rules.md`: hỗ trợ Light/Dark mode và 100% user-facing strings qua `AppLocalizations`.

---

## 5. Cấu trúc tài liệu chi tiết:

- [`architecture/`](architecture/README.md): Quy tắc phân tầng Monorepo và ranh giới module.
- [`architecture/services_and_repositories.md`](architecture/services_and_repositories.md): Danh mục Services và Repositories chia sẻ vs riêng biệt.
- [`architecture/dto_and_models.md`](architecture/dto_and_models.md): Mô hình dữ liệu dùng chung và chuẩn serialization.
- [`design/`](design/design.md): Design System, Color Tokens (Cinema Dark theme, Neon accents), Typography.
- [`navigation/`](navigation/README.md): Quy tắc Routing độc lập với GoRouter cho Client, Staff và Admin.
- [`feature-development/`](feature-development/README.md): Quy trình phát triển tính năng mới.
- [`localization/`](localization/README.md): Quy chuẩn đa ngôn ngữ tập trung trong `mobile_shared`.
