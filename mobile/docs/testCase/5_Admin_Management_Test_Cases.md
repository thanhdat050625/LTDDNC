# Test Cases: Quản trị Hệ thống (`Admin Management`)

Tài liệu kiểm thử dành riêng cho ứng dụng Quản trị viên (`cineplex_admin`).

---

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi |
| :--- | :--- | :--- | :--- |
| **TC-AD-01** | Đăng nhập Quản trị viên | 1. Đăng nhập với tài khoản role `ADMIN`<br>2. Kiểm tra điều hướng | Vào thẳng màn hình `AdminDashboardScreen` |
| **TC-AD-02** | Ngăn chặn vai trò không hợp lệ | 1. Đăng nhập bằng tài khoản role `CUSTOMER` hoặc `STAFF` | Hiển thị thông báo "Truy cập bị từ chối. Không đủ quyền hạn" và tự động đăng xuất |
| **TC-AD-03** | Xem tổng quan Báo cáo & Doanh thu | 1. Nhấn vào module "Thống kê"<br>2. Xem doanh thu theo ngày/tháng | Hiển thị biểu đồ doanh thu, vé bán ra, rạp hoạt động và hiệu suất từng phim |
| **TC-AD-04** | Tìm kiếm & Quản lý Người dùng | 1. Nhấn vào module "Quản lý Người dùng"<br>2. Nhập từ khóa tìm kiếm | Danh sách cập nhật realtime danh sách tài khoản theo từ khóa |
| **TC-AD-05** | Khóa / Kích hoạt tài khoản | 1. Nhấn nút chuyển đổi trạng thái của một người dùng<br>2. Xác nhận trong Dialog | Trạng thái người dùng chuyển thành `BLOCKED` hoặc `ACTIVE`, hiển thị SnackBar thông báo thành công |
| **TC-AD-06** | Đăng xuất Quản trị viên | 1. Nhấn icon Logout trên thanh AppBar | Xoá token khỏi SecureStorage và chuyển hướng về màn hình đăng nhập |
