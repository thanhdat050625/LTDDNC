# DTO & Models Conventions (`Flutter / Dart Monorepo`)

Tài liệu này quy định việc định nghĩa Models và Serialization trong ứng dụng Mobile Flutter và phân bổ giữa `mobile_shared` và các ứng dụng cụ thể.

---

## 1. Phân bổ Models trong Hệ sinh thái Monorepo

### A. Shared Models (`mobile_shared/lib/models/`)
Tất cả các Model đại diện cho thực thể kinh doanh cốt lõi của CINEPLEX được định nghĩa duy nhất tại `mobile_shared` và re-export qua `mobile_shared.dart`:

| Model | Mục đích | Các App sử dụng |
|---|---|---|
| `UserModel` | Thông tin người dùng, vai trò (CUSTOMER, STAFF, ADMIN), điểm loyalty | Client, Staff, Admin |
| `MovieModel` | Thông tin phim, poster, thể loại, thời lượng, độ tuổi | Client, Admin |
| `CinemaModel` | Cụm rạp chiếu, địa chỉ, số phòng chiếu | Client, Admin |
| `SeatModel` | Ghế ngồi, toạ độ hàng/cột, loại ghế (STANDARD, VIP, COUPLE), trạng thái (AVAILABLE, HELD, BOOKED) | Client, Staff, Admin |
| `ShowtimeModel` | Suất chiếu, định dạng (2D, 3D, IMAX), phòng chiếu, giá cơ bản | Client, Staff, Admin |
| `BookingModel` | Thông tin đơn đặt vé, tổng tiền, phương thức thanh toán, mã đơn | Client, Staff, Admin |
| `TicketModel` | Chi tiết từng vé, QR code chuỗi định danh, trạng thái soát vé | Client, Staff |
| `ConcessionModel` | Bắp nước, combo bắp nước kèm vé | Client, Staff, Admin |
| `HomeDataModel` | Tổng hợp phim đang chiếu, sắp chiếu, ưu đãi trang chủ | Client |
| `StatisticsModel` | `SummaryModel`, `RevenuePeriodModel`, `MoviePerformanceModel` | Admin |

### B. App-specific Models / DTOs
Chỉ những Model/DTO chỉ phục vụ riêng một màn hình đặc thù của 1 app (không bao giờ dùng chung) mới đặt trong thư mục `lib/features/<feature>/data/models/` của app đó.

---

## 2. Cấu trúc chuẩn của một Model

Mọi Model đều phải tuân thủ các nguyên tắc sau:
- Kế thừa `Equatable` để so sánh giá trị thuộc tính thay vì tham chiếu bộ nhớ.
- Mọi thuộc tính khai báo `final` để đảm bảo tính bất biến (Immutability).
- Cung cấp constructor `const`.
- Cung cấp factory `fromJson(Map<String, dynamic> json)` xử lý an toàn dữ liệu đầu vào (fallback null safe).
- Cung cấp phương thức `toJson()` để serialize khi gửi lên Backend.

```dart
import 'package:equatable/equatable.dart';

class MovieModel extends Equatable {
  final int id;
  final String title;
  final String? posterUrl;
  final int durationMinutes;
  final double rating;
  final List<String> genres;
  final DateTime? releaseDate;

  const MovieModel({
    required this.id,
    required this.title,
    this.posterUrl,
    required this.durationMinutes,
    required this.rating,
    required this.genres,
    this.releaseDate,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      posterUrl: json['posterUrl']?.toString(),
      durationMinutes: json['duration'] is int ? json['duration'] : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      releaseDate: json['releaseDate'] != null ? DateTime.tryParse(json['releaseDate'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'posterUrl': posterUrl,
      'duration': durationMinutes,
      'rating': rating,
      'genres': genres,
      'releaseDate': releaseDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, title, posterUrl, durationMinutes, rating, genres, releaseDate];
}
```
