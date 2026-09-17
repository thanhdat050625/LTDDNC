# Phân tích Rủi ro Lỗi (`Bug & Risk Analysis`)

Tài liệu phân tích các điểm rủi ro kỹ thuật tiềm ẩn trong ứng dụng Mobile Flutter và biện pháp phòng ngừa.

---

## 1. Mất kết nối mạng đột ngột khi đang giữ ghế
- **Rủi ro:** Người dùng đang ở màn hình chọn ghế hoặc thanh toán thì bị mất mạng (WiFi rớt, vào thang máy).
- **Hậu quả:** Ghế bị khóa 5 phút trong Redis mà người dùng không thể tiếp tục thanh toán.
- **Biện pháp phòng ngừa:**
  - Socket.IO tự động reconnect khi có mạng lại.
  - Sau 5 phút, cơ chế TTL của Redis tự động thu hồi ghế, không lo deadlock hệ thống.

---

## 2. Race condition khi bấm thanh toán nhiều lần liên tiếp
- **Rủi ro:** Mạng lag, người dùng sốt ruột bấm nút "Thanh toán" liên tục nhiều lần.
- **Hậu quả:** Tạo ra nhiều đơn hàng trùng lặp hoặc trừ tiền nhiều lần.
- **Biện pháp phòng ngừa:**
  - Disable nút "Thanh toán" ngay sau click đầu tiên và hiển thị loading indicator.
  - Backend sử dụng Idempotency Key hoặc Database Transaction kiểm tra trạng thái Booking trước khi tạo URL thanh toán.

---

## 3. Rò rỉ bộ nhớ từ Camera Quét QR (Staff Check-in)
- **Rủi ro:** Màn hình quét QR sử dụng Camera liên tục nếu không tạm dừng (pause/dispose) khi chuyển tab sẽ gây nóng máy và hao pin nhanh chóng.
- **Biện pháp phòng ngừa:**
  - Tạm dừng controller camera (`cameraController.pauseCamera()`) khi widget inactive hoặc rời màn hình.
