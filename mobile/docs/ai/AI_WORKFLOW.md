# AI Agent Workflow (`CINEPLEX Mobile - Flutter`)

Tài liệu này định nghĩa quy trình làm việc (workflow) BẮT BUỘC dành cho AI Agent trước khi thực hiện bất kỳ thay đổi nào trong mã nguồn Flutter (`mobile/`).

---

## 1. Startup Workflow

1. **Đọc tài liệu kiến trúc**: Đọc các file trong `mobile_architecture/` và `mobile/docs/architecture/` để nắm rõ cấu trúc Clean Architecture & BLoC.
2. **Xác định Feature**: Xác định thay đổi nằm ở feature nào trong `lib/features/` hoặc hạ tầng chung `lib/core/`.
3. **Tìm module tương đương**: Lấy một feature đã hoàn thiện (như `features/auth/` hoặc `features/movie/`) làm mốc tham chiếu về phong cách code.

---

## 2. Flutter UI / Design Rules

Trước khi viết code Widget Flutter:
- Đảm bảo tuân thủ theme **Cinema Dark Theme** (`#121212`, `#E50914`).
- Không để hardcoded string (sử dụng l10n hoặc constants).
- Tách nhỏ widget thành các component tái sử dụng, không viết widget dài quá 250 dòng.
- Không để logic tính toán hoặc gọi API trực tiếp trong `build()`.
- Gắn `const` constructor cho các widget tĩnh.

---

## 3. Architecture Validation

- Đảm bảo phân tầng rành mạch: Widget -> Cubit/BLoC -> Repository -> DataSource / Dio.
- Không mutate trực tiếp state; dùng `copyWith`.
- Giải phóng kết nối WebSocket / Controllers trong `dispose()`.
