# Test Cases: Khóa ghế thời gian thực (`Realtime Seat Lock`)

Tài liệu kiểm thử tính năng giữ ghế qua WebSocket và Redis Distributed Lock trên 2 thiết bị cùng lúc.

---

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi |
| :--- | :--- | :--- | :--- |
| **TC-RT-01** | Đồng bộ hóa ghế chọn giữa 2 máy | 1. Máy A và Máy B cùng mở sơ đồ ghế của Suất chiếu X<br>2. Máy A bấm chọn ghế B5 | Trên Máy B, ghế B5 chuyển sang màu vàng (đang bị giữ) ngay lập tức (< 300ms) |
| **TC-RT-02** | Chặn chọn trùng ghế | 1. Máy B cố tình click vào ghế B5 vừa bị Máy A giữ | App Máy B hiển thị thông báo: "Ghế này đang có người chọn" |
| **TC-RT-03** | Hết hạn giữ ghế 5 phút | 1. Máy A giữ ghế nhưng không bấm thanh toán<br>2. Chờ hết 5 phút đếm ngược | Ghế B5 tự động nhả ra trạng thái trống trên cả 2 máy; Máy A nhận thông báo hết phiên |
| **TC-RT-04** | Người dùng back ra khỏi màn hình | 1. Máy A chọn ghế C1, C2<br>2. Bấm nút Back thoát ra danh sách phim | Sự kiện `leave_room` được gửi đi, các ghế C1, C2 lập tức được giải phóng cho người khác chọn |
