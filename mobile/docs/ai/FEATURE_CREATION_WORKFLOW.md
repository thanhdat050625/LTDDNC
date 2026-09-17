# Feature Creation Workflow (`Flutter Mobile`)

Tài liệu quy định quy trình chuẩn từng bước khi AI hoặc Dev tạo mới một tính năng trong Mobile App CINEPLEX.

---

## Các bước thực hiện:

1. **Phân tích yêu cầu (Analyze Requirements):**
   - Xác định rõ user story và vai trò: Khách hàng (đặt vé, chọn rạp) hay Nhân viên (soát vé QR).
   - Kiểm tra các API endpoint tương ứng bên Backend NestJS đã sẵn sàng chưa.

2. **Xây dựng Data Layer:**
   - Tạo Model kế thừa `Equatable` với `fromJson` / `toJson`.
   - Viết Remote DataSource gọi endpoint qua `DioClient`.
   - Triển khai `RepositoryImpl` bắt lỗi `ServerException`.

3. **Xây dựng Domain Layer:**
   - Khai báo Interface `Repository` trong `domain/repositories/`.

4. **Xây dựng Presentation Layer (BLoC/Cubit):**
   - Tạo các Event (nếu dùng BLoC) và State (Initial, Loading, Success, Failure).
   - Viết test cơ bản cho Cubit/Bloc.

5. **Thiết kế UI Screens & Widgets:**
   - Tạo Screen chính và các Sub-widgets.
   - Bọc giao diện với `BlocConsumer` / `BlocBuilder`.
   - Gắn `AppLoadingIndicator` và `AppErrorView`.

6. **Khai báo Router & Kiểm thử:**
   - Cấu hình route trong `GoRouter`.
   - Kiểm thử hiển thị trên mobile device hoặc web simulator.
