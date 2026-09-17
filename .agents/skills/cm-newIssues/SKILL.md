---
name: cm-newIssues
description: >-
  Đọc mô tả bug, phân tích nguyên nhân gốc rễ trong codebase và tạo link GitHub Issue kèm đầy đủ thông tin (title, description, label) để tạo issue nhanh chóng.
---

# cm-newIssues

Mục đích: Tiếp nhận mô tả lỗi/bug từ người dùng hoặc quá trình testing, phân tích nguyên nhân kỹ thuật trong codebase và tạo URL GitHub Issue được điền sẵn đầy đủ thông tin để người dùng click tạo Issue ngay lập tức.

## Dependencies
- [Shared Workflow](../rules/shared-workflow.md)
- [Shared Architecture Rules](../rules/shared-architecture-rules.md)
- [Shared Git Rules](../rules/shared-git-rules.md)

## Quy trình thực hiện (Workflow)

### Step 1 — Tiếp nhận và làm rõ mô tả Bug
1. Đọc kỹ mô tả lỗi do người dùng cung cấp (hoặc kết quả kiểm thử):
   - Triệu chứng lỗi (Symptom / Actual behavior).
   - Hành vi kỳ vọng (Expected behavior).
   - Module hoặc nền tảng bị ảnh hưởng (Frontend `web` hay Backend `backend`).
2. Nếu thiếu thông tin quan trọng để tái hiện hoặc định vị lỗi, đặt câu hỏi làm rõ ngắn gọn.

### Step 2 — Truy vết và phân tích Root Cause trong Codebase
1. Sử dụng các công cụ tìm kiếm (`grep_search`, `view_file`) để truy vết luồng xử lý liên quan:
   - Frontend: `UI Component -> Hook / Store -> Repository / API Client -> Interceptor`.
   - Backend: `Controller -> Service -> Repository / Prisma / Entity -> Database / External Service`.
2. Xác định chính xác:
   - File và dòng code gây ra lỗi (kèm file link).
   - Nguyên nhân kỹ thuật cốt lõi (Root Cause) thay vì chỉ nhìn vào triệu chứng bề ngoài.
3. Đề xuất phương án khắc phục (Proposed Fix) an toàn, tránh gây side effects hoặc regression.

### Step 3 — Xác định Issue ID và Title
- Format Title bắt buộc: `[CM-xxx] <Tóm tắt ngắn gọn lỗi>`
  - `CM-xxx`: Mã định danh bug/issue (Ví dụ: `[CM-001]`, `[CM-002]`,...).
  - Nếu người dùng đã cung cấp mã ID, sử dụng mã đó. Nếu chưa có, hãy gợi ý mã ID tiếp theo hoặc mặc định bắt đầu từ `[CM-001]`.
  - Tiêu đề phải rõ ràng, súc tích, phản ánh đúng bản chất lỗi.

### Step 4 — Soạn thảo nội dung Issue Description (Body)
Cấu trúc nội dung Issue theo template chuẩn Markdown:

```markdown
## 📌 Mô tả lỗi (Description / Symptom)
- **Hiện tượng:** [Mô tả chi tiết lỗi xảy ra như thế nào]
- **Kỳ vọng:** [Hành vi đúng đáng lẽ phải diễn ra]
- **Phạm vi ảnh hưởng:** [Frontend (web) / Backend / Cả hai]

---

## 🔁 Các bước tái hiện (Steps to Reproduce)
1. [Bước 1...]
2. [Bước 2...]
3. [Bước 3...]
4. **Kết quả thực tế:** [Lỗi hiển thị / HTTP Status code / Log lỗi]

---

## 🔍 Nguyên nhân gây lỗi (Root Cause Analysis)
- **Vị trí lỗi:** [Tên file và dòng code liên quan, ví dụ: `web/src/...` hoặc `backend/src/...`]
- **Giải thích kỹ thuật:** [Phân tích chi tiết tại sao đoạn code đó gây ra lỗi, logic sai ở đâu]

---

## 💡 Đề xuất phương án khắc phục (Proposed Fix)
- [Mô tả các bước cần sửa chữa trong code]
- [Lưu ý về side effects hoặc test case cần bổ sung]
```

### Step 5 — Tạo GitHub Issue URL
1. Lấy thông tin GitHub Repository (từ `git remote -v`, mặc định là `https://github.com/chuonghoai/Cineplex`).
2. Xác định các Labels phù hợp (ví dụ: `bug`, `frontend`, `backend`, `high-priority`,...).
3. Encode URI các tham số `title`, `body`, và `labels`:
   - Định dạng URL:
     ```
     https://github.com/{owner}/{repo}/issues/new?title={encodedTitle}&body={encodedBody}&labels={encodedLabels}
     ```
4. Xuất kết quả cho người dùng:
   - **Clickable Link trực tiếp:** Đưa link để người dùng click mở thẳng trang tạo Issue trên trình duyệt.
   - **Nội dung Issue Markdown dự phòng:** Hiển thị trọn vẹn Title, Body, Labels để người dùng có thể dễ dàng copy thủ công trong trường hợp URL quá dài.
