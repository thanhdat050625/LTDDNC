# Services & Repositories (`Flutter Networking`)

Tài liệu này quy định việc giao tiếp mạng qua Dio HTTP Client và triển khai Repository Pattern trong Flutter.

---

## 1. Cấu hình Dio Client (`core/api/dio_client.dart`)

- **Base URL:** Đọc từ biến môi trường `AppConfig.baseUrl` (Dev: IP máy host hoặc ngrok, Prod: Backend domain).
- **Timeouts:** `connectTimeout`: 15s, `receiveTimeout`: 15s.
- **Interceptors:**
  1. `AuthInterceptor`: Tự động lấy `accessToken` từ `FlutterSecureStorage` và gắn vào header `Authorization: Bearer <token>`. Nếu mã lỗi là `401 Unauthorized`, tự động gọi refresh token hoặc logout.
  2. `LoggingInterceptor`: Log request/response trong chế độ debug.

---

## 2. Repository Pattern

Mọi thao tác dữ liệu đều phải thông qua Interface Repository:

```dart
// 1. Domain Interface (Trừu tượng)
abstract class MovieRepository {
  Future<List<MovieModel>> getNowShowingMovies();
  Future<MovieModel> getMovieDetail(String id);
}

// 2. Data Implementation
class MovieRepositoryImpl implements MovieRepository {
  final DioClient dioClient;

  MovieRepositoryImpl({required this.dioClient});

  @override
  Future<List<MovieModel>> getNowShowingMovies() async {
    try {
      final response = await dioClient.get('/movies/now-showing');
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => MovieModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }
}
```

---

## 3. Cấm kỵ (DON'T)
- **CẤM** gọi `Dio().get(...)` hoặc `http.get(...)` trực tiếp trong Widget hoặc BLoC.
- **CẤM** bỏ qua xử lý lỗi mạng (`DioException` hoặc mất kết nối internet).
