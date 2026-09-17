# Test Cases: Soát vé qua QR Code (`Staff Check-in`)

Tài liệu kiểm thử dành riêng cho chức năng quét mã QR vé xem phim của Nhân viên rạp (Staff).

---

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi |
| :--- | :--- | :--- | :--- |
| **TC-ST-01** | Đăng nhập tài khoản Nhân viên | 1. Đăng nhập với role `STAFF`<br>2. Kiểm tra điều hướng | App mở màn hình Quét vé QR Check-in |
| **TC-ST-02** | Quét vé hợp lệ | 1. Hướng camera vào mã QR vé chưa sử dụng<br>2. Hệ thống quét tự động | Báo thành công (màu xanh), hiển thị tên phim, phòng chiếu, số ghế |
| **TC-ST-03** | Chống quét vé lặp lại (Double check-in) | 1. Quét lại mã QR vừa check-in ở TC-ST-02 | Báo lỗi cảnh báo (màu đỏ): "Vé đã được sử dụng lúc hh:mm" |
| **TC-ST-04** | Quét mã QR không hợp lệ hoặc giả mạo | 1. Quét một mã QR bất kỳ không thuộc hệ thống CINEPLEX | Báo lỗi: "Mã vé không tồn tại hoặc chữ ký không hợp lệ" |
