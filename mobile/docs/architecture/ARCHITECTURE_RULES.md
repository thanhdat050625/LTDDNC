# Architecture Rules (`Flutter Clean Architecture`)

Các quy tắc kiến trúc bắt buộc mọi lập trình viên và AI Agent phải tuân thủ:

---

## 1. Chiều phụ thuộc (Dependency Rule)
- `Presentation` chỉ được phụ thuộc vào `Domain` và `Core`.
- `Data` phụ thuộc vào `Domain` và `Core`.
- `Domain` KHÔNG ĐƯỢC phụ thuộc vào bất kỳ tầng nào khác.

---

## 2. Quy tắc đặt tên và cấu trúc
- Thư mục feature đặt theo snake_case: `movie_booking`, `auth`, `staff_checkin`.
- File Dart theo snake_case: `movie_model.dart`, `seat_booking_cubit.dart`, `app_colors.dart`.
- Class theo PascalCase: `MovieModel`, `SeatBookingCubit`, `AppColors`.

---

## 3. Xử lý lỗi (Error Handling)
- Mọi lỗi mạng phải được bắt tại `RepositoryImpl` và bọc thành `Failure` hoặc `AppException`.
- BLoC/Cubit chỉ phát ra `ErrorMessage` thân thiện với người dùng, không hiển thị trực tiếp raw stacktrace lên màn hình.
