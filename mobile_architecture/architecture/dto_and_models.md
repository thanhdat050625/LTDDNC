# DTO & Models Conventions (`Flutter / Dart`)

Tài liệu này quy định việc định nghĩa Models và Serialization trong ứng dụng Mobile Flutter.

---

## 1. Cấu trúc chuẩn của một Model

Mỗi Model đại diện cho đối tượng dữ liệu nhận từ API Backend hoặc lưu local.

### Quy tắc:
- Mọi thuộc tính khai báo `final` để đảm bảo Immutability.
- Cung cấp `fromJson(Map<String, dynamic> json)` và `toJson()`.
- Cung cấp phương thức `copyWith(...)` để sao chép đối tượng với trường thay đổi.
- Xử lý giá trị null an toàn (Default values hoặc Nullable types `?`).

```dart
// Ví dụ: MovieModel
class MovieModel {
  final String id;
  final String title;
  final String posterUrl;
  final int durationMinutes;
  final double rating;
  final List<String> genres;
  final DateTime releaseDate;

  const MovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.durationMinutes,
    required this.rating,
    required this.genres,
    required this.releaseDate,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      posterUrl: json['posterUrl'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      releaseDate: json['releaseDate'] != null 
          ? DateTime.parse(json['releaseDate'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'posterUrl': posterUrl,
      'durationMinutes': durationMinutes,
      'rating': rating,
      'genres': genres,
      'releaseDate': releaseDate.toIso8601String(),
    };
  }
}
```

---

## 2. Chuẩn hóa API Response Wrapper

Mọi phản hồi từ NestJS Backend tuân theo format:
```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
```
