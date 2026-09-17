---
name: cm-newTesting
description: >-
  Quy chuẩn tạo file test trong Backend (NestJS) để mô phỏng tương tác từ Client/Admin/Staff (API Integration & E2E Test với Jest & Supertest).
---

# cm-newTesting

Mục đích: Quy định chuẩn hóa quy trình tạo file `*.spec.ts` hoặc `*.e2e-spec.ts` trong Backend nhằm kiểm thử tích hợp (API Integration Test, DTO Validation, Auth Guards, Role Permissions).

## Dependencies (Quy tắc phải tuân thủ)
- [Shared Workflow](../rules/shared-workflow.md)
- [Realtime Socket Architecture Rules](../../mobile_architecture/architecture/realtime_socket_rules.md)
- [Backend API Rules](../../backend_architecture/api_rules.md)

---

## Quy trình thực hiện (Workflow)

### Step 1 — Xác định kịch bản kiểm thử (Test Scenario & Actor)
1. Xác định Controller, API Endpoint và phương thức cần test (ví dụ: `POST /products`, `POST /auth/login`, `GET /cart`).
2. Xác định Actor thực hiện hành động:
   - **Client / User:** Gửi token có role `USER` hoặc cookie `accessToken`.
   - **Staff / Admin:** Gửi token có role `ADMIN` hoặc `STAFF`.
   - **Anonymous / Guest:** Không kèm authorization header/cookie.
3. Thu thập định dạng Payload thực tế:
   - Đọc DTO của frontend (`web/src/features/.../dto`) hoặc backend DTO (`backend/src/module/.../dto`) để đảm bảo payload gửi trong test **100% giống với app thực tế**.

---

### Step 2 — Tạo file Test trong Backend (`backend/test/` hoặc `backend/src/.../*.spec.ts`)

1. **Vị trí file:**
   - Unit/Integration test: Cùng thư mục với controller/service (`src/module/<feature>/<feature>.controller.spec.ts`).
   - E2E Integration test: Đặt trong thư mục `test/` (ví dụ: `test/products.e2e-spec.ts`).
2. **Sử dụng `supertest` & `@nestjs/testing`:**
   - Khởi tạo `TestingModule` với Controller và Service (hoặc mock Repository).
   - Thiết lập `ValidationPipe` và `HttpExceptionFilter` tương tự `main.ts` để kiểm thử chính xác luồng validation và error handling.
   - Assert HTTP Status code (200, 201, 400, 401, 403, 404) và cấu trúc `ApiResponse<T>`: `{ success, data, error }`.

**Mẫu code chuẩn (E2E / Integration Test):**
```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { HttpExceptionFilter } from '../src/core/common/filters/http-exception.filter';

describe('ProductsController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    app.useGlobalFilters(new HttpExceptionFilter());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('/products (GET) - Lấy danh sách sản phẩm', async () => {
    const response = await request(app.getHttpServer())
      .get('/products')
      .expect(200);

    expect(response.body.success).toBe(true);
    expect(Array.isArray(response.body.data)).toBe(true);
  });
});
```

---

### Step 3 — Thực thi và Kiểm tra (Verification)

1. Chạy test toàn bộ backend:
   ```powershell
   npm run test --prefix backend
   ```
2. Chạy test e2e:
   ```powershell
   npm run test:e2e --prefix backend
   ```
3. Chạy test kèm watch mode cho file cụ thể:
   ```powershell
   npm run test:watch --prefix backend -- products
   ```
