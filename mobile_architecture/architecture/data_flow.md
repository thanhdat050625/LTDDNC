# Luồng Dữ Liệu Ứng Dụng (`Mobile Data Flow`)

Tài liệu này mô tả chi tiết luồng tương tác và truyền tải dữ liệu giữa các thành phần trong ứng dụng Flutter CINEPLEX.

---

## 1. Luồng HTTP Request & State Update

```mermaid
graph TD
    UserAction[User bấm nút: Đăng nhập / Chọn suất chiếu / Thanh toán] --> Widget[Flutter UI Widget]
    Widget --> Bloc[BLoC / Cubit Dispatch Event]
    Bloc --> Repo[Feature Repository Implementation]
    Repo --> RemoteSource[Remote DataSource: Dio API Client]
    RemoteSource --> Backend[(CINEPLEX NestJS Backend)]
    Backend --> RemoteSource
    RemoteSource --> Model[Parse JSON -> Dart Model]
    Model --> Repo
    Repo --> Bloc[Emit State: Loading -> Success / Error]
    Bloc --> Widget[BlocBuilder / BlocConsumer re-render UI]
```

---

## 2. Luồng Real-time WebSocket (Giữ ghế sơ đồ phòng chiếu)

```mermaid
graph TD
    UserSelect[User click chọn Ghế A1] --> SeatWidget[SeatLayoutWidget]
    SeatWidget --> SeatCubit[SeatBookingCubit]
    SeatCubit --> SocketClient[SocketManager / Socket.IO Client]
    SocketClient -->|Emit: hold_seat| SeatGateway[(NestJS SeatGateway)]
    SeatGateway -->|Broadcast: seat_status_changed| SocketClient
    SocketClient -->|Stream Event| SeatCubit
    SeatCubit -->|Emit SeatHeldState| SeatWidget
    SeatWidget -->|Update UI: Ghế chuyển màu vàng - Giữ trong 5 phút| OtherUsers[Toàn bộ Users khác thấy Ghế bị khóa]
```

---

## 3. Quy tắc bắt buộc về luồng
1. **Một chiều (Unidirectional Data Flow):** Dữ liệu chỉ chảy từ State -> UI, sự kiện chỉ chảy từ UI -> BLoC -> Repository.
2. **Không mutate State:** Mọi State của BLoC/Cubit phải là immutable (`copyWith` hoặc `freezed`).
3. **Quản lý Stream Socket:** Bắt buộc `cancel` subscription hoặc `leaveRoom` khi `dispose` màn hình sơ đồ ghế để tránh memory leak.
