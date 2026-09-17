# Flutter Architecture Overview (`CINEPLEX Mobile`)

Hệ thống Mobile Flutter của CINEPLEX được xây dựng theo kiến trúc **Feature-First Clean Architecture**, phân tách rành mạch thành 4 tầng trách nhiệm:

```text
mobile/lib/
├── core/                  # Hạ tầng dùng chung toàn app
│   ├── api/               # Dio Client singleton, Interceptors, Base Response
│   ├── constants/         # App constants, Socket events, Storage keys
│   ├── errors/            # AppExceptions, Failure objects
│   ├── theme/             # AppColors, AppTextStyles, ThemeMode
│   ├── utils/             # Format tiền tệ VNĐ, ngày giờ, validation helpers
│   └── widgets/           # Common UI: AppButton, AppTextField, LoadingDialog, ErrorView
├── features/              # Các module nghiệp vụ (Feature-First)
│   ├── <feature_name>/
│   │   ├── data/          # Models (JSON serialization), DataSources, Repository Implementations
│   │   ├── domain/        # Entities, Repository Interfaces, UseCases (optional)
│   │   └── presentation/  # BLoC / Cubit, Screens, Feature-specific Widgets
└── main.dart              # Khởi tạo App, cấu hình Provider/Bloc, GoRouter
```

---

## Các tầng trách nhiệm

1. **Presentation Layer (`presentation/`):**
   - Chỉ đảm nhận hiển thị UI và lắng nghe state (`BlocBuilder`, `BlocConsumer`, `BlocListener`).
   - Gửi Events hoặc gọi methods trên Cubit/Bloc khi người dùng tương tác.
   - Tuyệt đối không chứa logic gọi API, tính toán tiền tệ phức tạp hay parse JSON.

2. **Domain Layer (`domain/`):**
   - Chứa thực thể nghiệp vụ (`Entity`) và định nghĩa giao diện trừu tượng (`Repository Interface`).
   - Đảm bảo độc lập với các thư viện bên ngoài (không phụ thuộc Dio, Socket.IO).

3. **Data Layer (`data/`):**
   - Chứa `Models` (kế thừa hoặc map sang `Entity`, có `fromJson` và `toJson`).
   - `RemoteDataSource`: Gọi API qua `Dio`.
   - `LocalDataSource`: Đọc ghi token/cache từ `SharedPreferences` hoặc `FlutterSecureStorage`.
   - `RepositoryImpl`: Triển khai `Repository Interface`, bắt lỗi và đóng gói thành `Result` hoặc `Either`.

4. **Core Layer (`core/`):**
   - Cung cấp các thành phần tái sử dụng xuyên suốt app: theme, formatters, HTTP client, WebSocket manager.

---

## Chi tiết các tài liệu liên quan:
- [Data Flow](data_flow.md)
- [DTO & Models](dto_and_models.md)
- [Realtime Socket Rules](realtime_socket_rules.md)
- [Services & Repositories](services_and_repositories.md)
- [State Management](state_management.md)
- [UI Standards](ui.md)
