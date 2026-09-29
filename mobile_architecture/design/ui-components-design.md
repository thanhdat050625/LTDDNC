# CINEPLEX Mobile - UI Components Design System

Tài liệu này quy định chi tiết cách triển khai các thành phần giao diện (UI Components) cho CINEPLEX Mobile, đảm bảo tính nhất quán cao nhất trên toàn ứng dụng. Các Agent làm giao diện BẮT BUỘC phải đọc và tuân theo file này.

## 1. Cấu trúc Layout (Layout Structure)
- **Glassmorphism:** Sử dụng hiệu ứng kính mờ (Frosted Glass / BackdropFilter) cho các thành phần nổi (AppBar nổi, BottomNavigationBar nổi, Dialog).
- **Radius (Bo góc):**
  - Thẻ phim / Banners (AppCard): `16px` hoặc `12px` tùy kích cỡ.
  - Buttons (AppButton): `12px` (hoặc Pill shape `BorderRadius.circular(100)` cho các tag/chip).
  - Bottom Navigation Bar: Floating (nổi), bo tròn mạnh `32px`, kết hợp hiệu ứng kính.
- **Padding & Spacing:**
  - Lề màn hình tiêu chuẩn (Screen Padding): `16px`.
  - Khoảng cách giữa các section: `24px`.
  - Khoảng cách giữa các items trong list: `12px` hoặc `16px`.

## 2. Các Components Dùng Chung (Core Widgets)

### 2.1. Nút bấm (AppButton)
- Yêu cầu mọi nút bấm tương tác phải có hiệu ứng nhún (ScaleTransition thu nhỏ về `0.95` trong `100ms`).
- Nút Primary: Background Đỏ (`CineplexColors.primary`), chữ Trắng đậm.
- Nút Outline: Border Đỏ, nền trong suốt, chữ Đỏ.

### 2.2. Thẻ hiển thị (AppCard)
- Dùng cho Movie Card, Ticket Card, Promotion Card.
- Surface Color: Lấy từ `Theme.of(context).extension<CineplexColors>()!.surface`.
- Border Radius: `12px` hoặc `16px`.
- Không sử dụng viền (border), chỉ dùng bóng đổ nhẹ (Soft Shadow) ở Light Mode, và không đổ bóng ở Dark Mode để tạo chiều sâu.

### 2.3. Loading & Skeleton (ShimmerSkeleton)
- Không dùng `CircularProgressIndicator` cho các layout phức tạp (danh sách phim, chi tiết phim).
- Bắt buộc dùng `ShimmerSkeleton` để giữ chỗ (placeholder) khi đang gọi API. Màu sắc tự động đồng bộ theo Theme (Sáng/Tối).

### 2.4. Bottom Navigation Bar (Liquid Glass)
- Hiệu ứng: Kính mờ (Frosted Glass) nổi trên nội dung (Floating). Cần đặt độ mờ nền khoảng `sigmaX: 10, sigmaY: 10`.
- Chuyển động: Chuyển tab mượt mà (smooth transition), pill indicator hình viên thuốc di chuyển đằng sau icon đang được chọn.
- Icon: Sử dụng thư viện `lucide_icons_flutter`.

### 2.5. Hình ảnh & Hero Animation
- TẤT CẢ poster phim phải có `Hero` tag định dạng: `'poster_${movie.id}'`.
- Ảnh load từ mạng phải bọc trong `AppCachedImage` hoặc sử dụng `cached_network_image` có placeholder chuẩn bị sẵn.

## 3. Typography & Text Styles
Sử dụng bộ font `Inter` làm mặc định, phân rã theo `TextTheme` của Material:
- **Headline Large (`headlineSmall`/`headlineMedium`):** Dùng cho tiêu đề màn hình, tên Phim (FontWeight: Bold/800).
- **Body Large (`bodyLarge`):** Nội dung mô tả (FontWeight: Regular/400, opacity 80%).
- **Label Small (`labelSmall`):** Badge, thời lượng, tag (FontWeight: Medium/500, size 12-14).

## 4. Dark & Light Mode Rules
- KHÔNG BAO GIỜ hardcode màu Hex vào widget. LUÔN LUÔN gọi màu thông qua `Theme.of(context).colorScheme` hoặc `Theme.of(context).extension<CineplexColors>()`.
- L10n: KHÔNG BAO GIỜ hardcode Text tiếng Việt/Anh vào UI. Bắt buộc dùng `AppLocalizations.of(context)!`.
