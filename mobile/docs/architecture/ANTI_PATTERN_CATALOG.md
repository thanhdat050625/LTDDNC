# Anti-Pattern Catalog (`Flutter Mobile`)

Danh mục các lỗi phản kiến trúc (Anti-patterns) nghiêm cấm trong dự án Flutter CINEPLEX.

---

## 1. The "God Widget" (Widget siêu to khổng lồ)
- **Biểu hiện:** Một file widget dài hơn 400 dòng, kiêm nhiệm cả logic gọi API, tính toán tiền bắp nước, định dạng chuỗi và dựng layout.
- **Tác hại:** Khó đọc, khó test, re-build toàn bộ màn hình khi chỉ 1 trường nhỏ thay đổi.
- **Khắc phục:** Tách thành Screen điều phối + các Sub-widgets nhỏ + chuyển state vào BLoC/Cubit.

---

## 2. Calling API in `build()` or `initState()` directly
- **Biểu hiện:** Gọi trực tiếp `Dio().get()` hoặc `movieRepository.getMovies()` bên trong hàm `build()` hoặc `initState()`.
- **Tác hại:** Mỗi lần widget rebuild (ví dụ xoay màn hình, mở bàn phím) sẽ gọi lại API, gây quá tải server và lag app.
- **Khắc phục:** Kích hoạt event qua BLoC/Cubit và dùng `BlocBuilder`.

---

## 3. Forgetting to Dispose Controllers & Stream Subscriptions
- **Biểu hiện:** Khởi tạo `TextEditingController`, `AnimationController`, `StreamSubscription` của Socket.IO nhưng không gọi `dispose()` hoặc `cancel()` trong `dispose()`.
- **Tác hại:** Rò rỉ bộ nhớ (Memory Leak), app giật lag hoặc crash sau một thời gian sử dụng.
- **Khắc phục:** Luôn giải phóng tài nguyên trong hàm `dispose()`.

---

## 4. Mutating State Directly
- **Biểu hiện:** Thay đổi trực tiếp thuộc tính của object trong state mà không emit state mới.
- **Tác hại:** `Equatable` không nhận diện được sự thay đổi, UI không re-render.
- **Khắc phục:** Luôn tạo đối tượng mới thông qua `copyWith()`.
