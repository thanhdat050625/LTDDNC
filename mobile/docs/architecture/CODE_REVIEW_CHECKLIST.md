# Code Review Checklist (`Flutter Mobile Monorepo`)

Bảng kiểm tra tự động và thủ công trước khi tạo PR hoặc merge code vào nhánh chính:

---

## 1. Ranh giới Monorepo
- [ ] Không có import chéo giữa `cineplex_client`, `cineplex_staff`, `cineplex_admin`.
- [ ] Các thành phần dùng chung (Model, Widget, Helper, Theme) được đưa đúng vào `mobile_shared`.
- [ ] Chạy `flutter analyze --no-fatal-infos` đạt 0 lỗi và 0 warnings trên cả 4 thư mục.

---

## 2. Clean Architecture & Code Quality
- [ ] Không có import từ tầng hạ tầng mạng vào `presentation/` (trừ khởi tạo dependency injection).
- [ ] State không bị mutate trực tiếp; luôn dùng `copyWith`.
- [ ] Toàn bộ Controllers (`TextEditingController`, `AnimationController`, `MobileScannerController`) và Stream Subscriptions đều có `dispose()` / `cancel()`.
- [ ] Không hardcode string hiển thị trong UI (100% sử dụng `AppLocalizations`).
- [ ] Màn hình được bọc `SafeArea` hoặc xử lý padding an toàn.
- [ ] Không gọi `Navigator` hoặc `showDialog` trực tiếp trong hàm build của `BlocBuilder`.
- [ ] Sử dụng `const` constructor cho tất cả widget không biến đổi.

---

## 3. UI, Dark/Light Mode & Theme
- [ ] Hỗ trợ đầy đủ cả Dark Mode và Light Mode.
- [ ] Không hardcode mã màu cố định gây mất tương phản (chữ đen trên nền tối, chữ trắng trên nền sáng).
- [ ] Sử dụng theme token từ `AppColors` hoặc `Theme.of(context).colorScheme`.
