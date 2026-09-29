# Feature Creation Workflow (`Flutter Mobile Monorepo`)

Tài liệu quy định quy trình chuẩn từng bước khi AI hoặc Dev tạo mới một tính năng trong hệ sinh thái Mobile App CINEPLEX.

---

## Các bước thực hiện:

1. **Phân tích yêu cầu (Analyze Requirements):**
   - Xác định rõ vai trò và app tương ứng: Khách hàng (`cineplex_client`), Nhân viên (`cineplex_staff`), hay Quản trị viên (`cineplex_admin`).
   - Kiểm tra các API endpoint tương ứng bên Backend NestJS đã sẵn sàng chưa.

2. **Xác định Tài nguyên Dùng chung:**
   - Nếu Model, Helper hoặc Widget có khả năng dùng chung -> Định nghĩa trước tại `mobile_shared`.
   - Nếu có chuỗi hiển thị mới -> Bổ sung vào `mobile_shared/lib/l10n/app_en.arb` và `app_vi.arb`, sau đó chạy `flutter gen-l10n`.

3. **Xây dựng Data Layer trong App mục tiêu:**
   - Tạo Repository nhận `DioClient` từ `mobile_shared`.
   - Gọi endpoint qua `_dioClient.get/post/...` và parse dữ liệu bằng Model từ `mobile_shared`.

4. **Xây dựng Presentation Layer (BLoC/Cubit):**
   - Tạo các Event/Method và State (Initial, Loading, Success, Failure) kế thừa `Equatable`.
   - Viết Cubit xử lý logic bất đồng bộ.

5. **Thiết kế UI Screens & Widgets:**
   - Tạo Screen chính và các Sub-widgets.
   - Kết nối với Cubit qua `BlocConsumer` hoặc `BlocBuilder`.
   - Tái sử dụng các widgets `AppButton`, `AppTextField`, `AppLoading`, `AppErrorView`, `AppScaffold` từ `mobile_shared`.
   - Đảm bảo tương thích hoàn hảo ở cả Light Mode và Dark Mode.

6. **Khai báo Router & Kiểm thử:**
   - Cấu hình route trong GoRouter của app tương ứng (`app_router.dart`, `staff_router.dart`, hoặc `admin_router.dart`).
   - Kiểm thử chạy app qua script root: `npm run client:dev`, `npm run staff:dev`, hoặc `npm run admin:dev`.
   - Chạy `flutter analyze --no-fatal-infos` đảm bảo không phát sinh lỗi.
