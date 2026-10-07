---
trigger: always_on
---

# Quy định build Android khi phát triển

Trong giai đoạn phát triển, Agent chính và mọi Subagent **KHÔNG được chạy** các lệnh đóng gói Android, bao gồm `flutter build apk`, `flutter build appbundle` (AAB), hoặc Gradle task tương đương.

- Chỉ được chạy các lệnh trên khi user yêu cầu rõ ràng.
- `flutter analyze`, `flutter test` và các kiểm tra không tạo APK/AAB vẫn được phép chạy khi phù hợp.
