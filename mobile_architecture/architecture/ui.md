# UI Standards & Widget Composition (`Flutter UI`)

Tài liệu này quy định các tiêu chuẩn xây dựng giao diện người dùng trên Flutter trong dự án CINEPLEX.

---

## 1. Widget Decomposition (Tách nhỏ Component)

- **Quy tắc độ dài file:** Một file widget không được vượt quá **250 dòng code**. Nếu vượt quá, bắt buộc phải tách các private widget hoặc components ra file riêng trong thư mục `widgets/` của feature.
- **Tránh Build Function phình to:** Không lồng 10-15 cấp widget trong 1 hàm `build()`. Tách thành các widget độc lập kế thừa `StatelessWidget`.
- **Sử dụng `const` Constructor:** Tối ưu hóa render tree bằng cách gắn `const` cho mọi widget không thay đổi giá trị.

---

## 2. Reusable Core Widgets (`lib/core/widgets/`)

Tái sử dụng các UI components chuẩn đã được xây dựng sẵn:
- `AppButton`: Nút bấm với trạng thái loading tích hợp, disabled, icon.
- `AppTextField`: Ô nhập liệu kèm validate form, icon mật khẩu, error text.
- `AppLoadingIndicator`: Vòng xoay tải dữ liệu theo chủ đề rạp chiếu phim.
- `AppErrorView`: Hiển thị lỗi mạng kèm nút "Thử lại" (Retry).
- `SeatItemWidget`: Widget đại diện cho 1 ghế (Standard, VIP, Couple, Selected, Held, Booked).

---

## 3. Quản lý Responsive & SafeArea

- Luôn bọc màn hình bên trong `SafeArea` để tránh tai thỏ (Notch) và thanh điều hướng hệ thống.
- Sử dụng `LayoutBuilder` hoặc `MediaQuery` hợp lý, không hardcode kích thước cố định gây vỡ giao diện trên màn hình nhỏ.
