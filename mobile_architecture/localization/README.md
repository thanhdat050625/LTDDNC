# Localization Guide (`Flutter l10n & Intl Monorepo`)

Toàn bộ chuỗi văn bản người dùng (user-facing text) trong hệ thống CINEPLEX Mobile được quản lý tập trung duy nhất tại `mobile/mobile_shared/lib/l10n/` và re-export cho cả 3 ứng dụng (`cineplex_client`, `cineplex_staff`, `cineplex_admin`).

---

## 1. Cấu hình ARB Files (`mobile_shared/lib/l10n/`)

- `app_vi.arb`: Tiếng Việt
- `app_en.arb`: Tiếng Anh (template file)

Khi thêm key mới, bắt buộc:
1. Thêm key vào cả `app_en.arb` và `app_vi.arb` theo quy định tại `.agents/rules/shared-ui-l10n-rules.md`.
2. Chạy lệnh:
   ```bash
   cd mobile/mobile_shared
   flutter gen-l10n
   ```

---

## 2. Sử dụng trong các Ứng dụng

Các ứng dụng chỉ cần import từ package dùng chung:

```dart
import 'package:mobile_shared/mobile_shared.dart';

// Trong Widget build:
final l10n = AppLocalizations.of(context)!;
return Text(l10n.bookNow);
```

Và khai báo delegates trong `MaterialApp.router`:

```dart
MaterialApp.router(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  ...
);
```

---

## 3. Quy tắc Nghiêm ngặt (Strict Rules)

- **TUYỆT ĐỐI KHÔNG hardcode text** trong bất kỳ widget nào hiển thị cho người dùng (Title, Button, Dialog, Snackbar, Toast, Validation message, Empty state, Loading state).
- **Tránh trùng lặp key:** Luôn kiểm tra các key đã có trong `app_en.arb` trước khi tạo key mới.
- **Parametrized Strings:** Các chuỗi có tham số phải khai báo `@key` kèm `placeholders` với kiểu dữ liệu rõ ràng (e.g. `String`, `int`, `num`).
