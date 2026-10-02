---
trigger: always_on
---

# Shared UI & Localization Rules

Mọi thay đổi liên quan đến Giao diện người dùng (UI) và Text hiển thị (User-facing text) MUST tuân thủ nghiêm ngặt các quy định sau đây. 
Không có ngoại lệ. Các quy định này áp dụng cho mọi tác vụ: Feature mới, Bug fix, Code review, UI refactor, UI redesign, PR review.

## 1. DESIGN / DARK MODE & LIGHT MODE

Mọi UI được tạo mới hoặc chỉnh sửa MUST hỗ trợ đúng cả hai chế độ: Light Mode và Dark Mode.

- **MUST NOT** hardcode màu theo cách gây lỗi tương phản giữa hai mode (ví dụ: chữ màu đen trên nền tối trong Dark Mode, chữ màu trắng trên nền sáng trong Light Mode).
- **MUST NOT** sử dụng icon hoặc một thành phần có màu tối trên nền tối khiến khó nhìn.
- **MUST NOT** dùng trực tiếp một màu cố định (fixed color) thay vì màu/theme token nếu project đã có theme/color token tương ứng.
- **MUST** kiểm tra theme hiện tại của project trước khi tạo/chỉnh sửa UI.
- **MUST** ưu tiên sử dụng hệ thống màu/theme/design token (cho Background, text, icon, border, divider, button, input, card...) đã có trong project phù hợp với theme hiện hành.
- **MUST** phải tuân thủ quy tắc thiết kế UI của taste skill trong global workspace của máy tính, đảm bảo UI được thiết kế không bị AI_SL. Nếu không tìm thấy bộ quy tắc này trong global workspace thì bỏ qua
- **MUST** tuân thủ quy tắc thiết kế màu sắc, font chữ trong mobile_architecture/design/design.md
- **MUST** đảm bảo khi thêm màu mới, màu đó phù hợp và hiển thị tốt ở cả Light Mode và Dark Mode.
- **MUST** kiểm tra trực tiếp các trường hợp tương phản giữa foreground và background ở cả 2 mode (không chỉ kiểm tra syntax/compile) trong quá trình thiết kế, code và review.
- **MUST NOT** thay đổi màu để fix một mode nhưng làm hỏng mode còn lại.
- **Khi code review / PR review**: Nếu phát hiện UI chỉ đúng ở một theme, hoặc một component bị mất tương phản/khó đọc ở mode còn lại, hoặc hardcode màu sai quy tắc, Agent MUST đánh dấu đó là lỗi và yêu cầu fix.

## 2. LANGUAGE / LOCALIZATION (L10N)

Toàn bộ project (cả 3 app: Client, Staff, Admin) chỉ sử dụng duy nhất **1 ngôn ngữ chuẩn: Tiếng Việt (`vi`)**, không dùng đa ngôn ngữ (`en`, v.v.).

Toàn bộ text hiển thị cho người dùng (user-facing text) MUST được quản lý tập trung qua file L10n của project (`app_vi.arb`).

- **MUST NOT** hardcode UI text. Không được viết trực tiếp string vào code như `Text("Đăng nhập")`.
- **MUST** sử dụng cơ chế `AppLocalizations` hiện có của project (`mobile/mobile_shared/lib/l10n/app_vi.arb`) cho mọi user-facing text (bao gồm: Text widget/component, Button label, AppBar title, Dialog, Snackbar/Toast, Error message, Validation message, Empty state, Loading state, Tooltip, Placeholder, Form label, Confirmation message, Permission message, Notification text, Accessibility/semantic label, và bất kỳ text nào sinh ra trong các state khác nhau).
- **Phân biệt String**: User-facing text MUST được khai báo trong `app_vi.arb`. Internal technical string, log, debug string không hiển thị cho user thì không bắt buộc.
- **MUST** tìm kiếm và sử dụng localization key hiện có trong `app_vi.arb` trước khi tạo key mới (để tránh tạo duplicate localization key).
- **MUST** chỉ bổ sung text mới vào duy nhất file `mobile/mobile_shared/lib/l10n/app_vi.arb` bằng Tiếng Việt khi cần text mới, sau đó chạy `flutter gen-l10n` trong `mobile_shared`.
- **MUST NOT** tạo thêm file ngôn ngữ khác (như `app_en.arb`), không hỗ trợ đa ngôn ngữ hay tính năng chuyển đổi ngôn ngữ.
- **Khi code review / PR review**: Agent MUST kiểm tra và phát hiện các hardcoded user-facing strings hoặc việc thêm file đa ngôn ngữ không cần thiết. Nếu phát hiện hardcoded user-facing text, Agent MUST coi đó là lỗi cần fix.
