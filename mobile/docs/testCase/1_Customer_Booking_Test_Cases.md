# Test Cases: Quy trình Đặt vé Khách hàng (`Customer Booking`)

Tài liệu này định nghĩa các kịch bản kiểm thử cho luồng đặt vé xem phim trên ứng dụng Mobile CINEPLEX.

---

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi |
| :--- | :--- | :--- | :--- |
| **TC-CB-01** | Xem danh sách phim đang chiếu | 1. Mở App vào màn hình Home<br>2. Xem danh sách tab "Đang chiếu" | Danh sách phim tải mượt mà kèm poster, thời lượng, độ tuổi |
| **TC-CB-02** | Xem lịch chiếu theo rạp và ngày | 1. Chọn 1 phim bất kỳ<br>2. Chọn ngày xem<br>3. Chọn chi nhánh rạp | Hiển thị các khung giờ chiếu kèm định dạng phòng (2D, 3D, IMAX) |
| **TC-CB-03** | Chọn ghế và kiểm tra đồng hồ đếm ngược | 1. Chọn 1 khung giờ chiếu<br>2. Click chọn ghế A1, A2 | Ghế chuyển sang trạng thái đã chọn; đồng hồ đếm ngược 5 phút bắt đầu chạy |
| **TC-CB-04** | Thêm combo bắp nước | 1. Tại bước bắp nước, bấm "+" Combo 1 Bắp 2 Nước | Tổng tiền tự động cập nhật chính xác |
| **TC-CB-05** | Thanh toán sandbox MoMo / VNPay | 1. Bấm Xác nhận thanh toán<br>2. Chọn cổng thanh toán VNPay<br>3. Hoàn tất giao dịch sandbox | App chuyển hướng đến màn hình Vé thành công kèm Mã QR vé |
