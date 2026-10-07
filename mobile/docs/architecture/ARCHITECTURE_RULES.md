# Architecture Rules (`Flutter Monorepo Clean Architecture`)

Các quy tắc kiến trúc bắt buộc mọi lập trình viên và AI Agent phải tuân thủ:

---

## 1. Ranh giới Monorepo & Chiều phụ thuộc (Monorepo Dependency Rules)
- Các ứng dụng (`cineplex_client`, `cineplex_staff`, `cineplex_admin`) chỉ được phép phụ thuộc vào `mobile_shared` qua path dependency:
  ```yaml
  dependencies:
    mobile_shared:
      path: ../mobile_shared
  ```
- **TUYỆT ĐỐI CẤM** import chéo giữa 3 ứng dụng (ví dụ: cấm `cineplex_staff` import từ `cineplex_client` hay `cineplex_admin`).
- Mọi logic, widget, helper hoặc model được dùng từ 2 ứng dụng trở lên **bắt buộc** phải được chuyển vào `mobile_shared`.
- Trong từng ứng dụng: `Presentation` phụ thuộc vào `Repository`, `Repository` nhận `DioClient` từ `mobile_shared`. Không gọi HTTP trực tiếp trong UI / Cubit.

---

## 2. Quy tắc đặt tên và cấu trúc
- Thư mục feature đặt theo snake_case: `booking`, `scanner`, `users`, `statistics`.
- File Dart theo snake_case: `movie_model.dart`, `staff_cubit.dart`, `app_colors.dart`.
- Class theo PascalCase: `MovieModel`, `StaffCubit`, `AppColors`.

---

## 3. Xử lý lỗi (Error Handling)
- Mọi lỗi mạng phải được bắt tại `DioClient` trong `mobile_shared` và bọc thành `ServerException`.
- BLoC/Cubit chỉ phát ra `ErrorMessage` thân thiện với người dùng, không hiển thị raw exception stacktrace lên màn hình.

---

## 4. UI Design & Localization
- Mọi màn hình phải hỗ trợ cả Dark Mode và Light Mode, ưu tiên sử dụng `AppColors` và `Theme.of(context)`.
- 100% user-facing strings phải thông qua `AppLocalizations.of(context)!` trong `mobile_shared`.
