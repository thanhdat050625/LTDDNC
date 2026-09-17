# Localization Guide (`Flutter l10n & Intl`)

Tài liệu này quy định việc đa ngôn ngữ (Localization) trong ứng dụng Flutter CINEPLEX.

---

## 1. Cấu hình ARB Files (`lib/l10n/`)

- `app_vi.arb`: Tiếng Việt (Ngôn ngữ mặc định)
- `app_en.arb`: Tiếng Anh

```json
// app_vi.arb
{
  "appTitle": "CINEPLEX Đặt Vé Rạp",
  "bookNow": "Đặt vé ngay",
  "holdSeatExpired": "Thời gian giữ ghế 5 phút đã hết hạn",
  "totalPrice": "Tổng tiền: {price} đ",
  "@totalPrice": {
    "placeholders": {
      "price": { "type": "String" }
    }
  }
}
```

---

## 2. Quy tắc trong Code

- **KHÔNG hardcode text** trong các widget hiển thị cho người dùng.
- Luôn truy cập qua `AppLocalizations.of(context)!.bookNow`.
- Định dạng tiền tệ VNĐ và thời gian theo chuẩn locale Việt Nam (`intl`).
