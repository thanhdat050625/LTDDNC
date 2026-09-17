# PR Review Workflow (`Flutter Mobile`)

Quy trình đánh giá và kiểm thử Pull Request dành cho Mobile App CINEPLEX.

---

## 1. Automated Checklist trước khi tạo PR
- [ ] Chạy `flutter analyze` không còn lỗi syntax hoặc warning nghiêm trọng.
- [ ] Chạy `flutter test` vượt qua 100% các unit test hiện có.
- [ ] Không có file `.dart` nào chứa hardcoded API keys hoặc token bí mật.
- [ ] Không có widget nào vượt quá 250 dòng code mà chưa được tách nhỏ.

---

## 2. Review kiến trúc & Hiệu năng
- Kiểm tra các controllers (AnimationController, TextEditingController, ScrollController) có được `dispose()` đầy đủ không.
- Kiểm tra kết nối Socket.IO có được `leave_room` và ngắt lắng nghe khi thoát màn hình không.
- Kiểm tra các widget tĩnh có gắn từ khóa `const` không.
