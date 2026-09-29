# AI Agent Workflow (`CINEPLEX Mobile Monorepo`)

Tài liệu này định nghĩa quy trình làm việc (workflow) BẮT BUỘC dành cho AI Agent trước khi thực hiện bất kỳ thay đổi nào trong mã nguồn Flutter (`mobile/`).

---

## 1. Startup Workflow

1. **Đọc tài liệu kiến trúc**: Đọc các file trong `mobile_architecture/` và `mobile/docs/architecture/` để nắm rõ cấu trúc Monorepo 4 thư mục.
2. **Xác định Phạm vi Thư mục Mục tiêu**:
   - Nếu là thành phần dùng chung (Model, Widget, Theme, Hạ tầng, L10n) -> Làm việc trên `mobile/mobile_shared/`.
   - Nếu là tính năng Khách hàng -> Làm việc trên `mobile/cineplex_client/`.
   - Nếu là tính năng Nhân viên (Soát vé, POS) -> Làm việc trên `mobile/cineplex_staff/`.
   - Nếu là tính năng Quản trị (Dashboard, Quản lý rạp, Người dùng, Thống kê) -> Làm việc trên `mobile/cineplex_admin/`.
3. **Tìm module tương đương**: Lấy một feature đã hoàn thiện làm mốc tham chiếu về phong cách code.

---

## 2. Flutter UI / Design Rules

Trước khi viết code Widget Flutter:
- Đảm bảo tuân thủ theme **Cinema Dark Theme** (`#0D0D11`, `#1E1E28`, `#E50914`) và hỗ trợ đúng cả **Light Mode**.
- Tuyệt đối không để hardcoded user-facing string (100% sử dụng `AppLocalizations`).
- Tách nhỏ widget thành các component tái sử dụng, không viết widget dài quá 250 dòng.
- Không để logic tính toán hoặc gọi API trực tiếp trong `build()`.
- Gắn `const` constructor cho các widget tĩnh.

---

## 3. Architecture Validation

- Đảm bảo phân tầng rành mạch: Widget -> Cubit/BLoC -> Repository -> `DioClient`.
- Không mutate trực tiếp state; dùng `copyWith`.
- Giải phóng kết nối WebSocket / Controllers trong `dispose()`.
- Chạy `flutter analyze --no-fatal-infos` kiểm tra sạch lỗi trên thư mục làm việc.
