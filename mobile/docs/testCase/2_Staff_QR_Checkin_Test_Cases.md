# Test Cases: Soát vé qua QR Code (`Staff Check-in App`)

Tài liệu kiểm thử dành riêng cho chức năng quét mã QR vé xem phim của Nhân viên rạp trong ứng dụng `cineplex_staff`.

---

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi |
| :--- | :--- | :--- | :--- |
| **TC-ST-01** | Đăng nhập tài khoản Nhân viên | 1. Đăng nhập với role `STAFF`<br>2. Kiểm tra điều hướng | App mở màn hình Quét vé QR Check-in (`StaffScannerScreen`) |
| **TC-ST-02** | Quét vé hợp lệ | 1. Hướng camera vào mã QR vé chưa sử dụng (hoặc nhập mã TKT-... thủ công)<br>2. Hệ thống kiểm tra | Báo thành công (màu xanh), hiển thị tên ghế và mã vé |
| **TC-ST-03** | Chống quét vé lặp lại (Double check-in) | 1. Quét lại mã QR vừa check-in ở TC-ST-02 | Báo cảnh báo (màu vàng): "Vé đã được sử dụng" |
| **TC-ST-04** | Quét nhầm mã đặt vé (BK-) | 1. Quét mã QR của mã đơn đặt (BK-...) | Báo cảnh báo hướng dẫn quét mã vé con (TKT-...) |
| **TC-ST-05** | Quét mã QR không hợp lệ hoặc giả mạo | 1. Quét một mã QR bất kỳ không thuộc hệ thống CINEPLEX | Báo lỗi (màu đỏ): "Mã vé không tồn tại hoặc không hợp lệ" |
| **TC-ST-06** | Đăng xuất Nhân viên | 1. Nhấn icon Logout trên thanh AppBar | Xoá phiên đăng nhập và chuyển hướng về màn hình đăng nhập nhân viên |
