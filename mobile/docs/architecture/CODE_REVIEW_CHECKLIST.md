# Code Review Checklist (`Flutter Mobile`)

Bảng kiểm tra tự động và thủ công trước khi merge code vào nhánh chính:

---

## Danh sách kiểm tra:
- [ ] **Clean Architecture:** Không có import từ `data/` vào `presentation/` (trừ khởi tạo dependency injection).
- [ ] **State:** Không mutate trực tiếp object trong state; dùng `copyWith`.
- [ ] **Memory Management:** Toàn bộ Controllers và Stream Subscriptions đều có `dispose()` / `cancel()`.
- [ ] **Hardcode String:** Không hardcode string hiển thị trong UI (sử dụng l10n).
- [ ] **Responsive & Notch:** Màn hình được bọc `SafeArea` hoặc xử lý padding an toàn.
- [ ] **Async & UI:** Không gọi `Navigator` hoặc `showDialog` trực tiếp trong hàm build của `BlocBuilder`.
- [ ] **Const Constructor:** Sử dụng `const` cho tất cả widget không biến đổi.
