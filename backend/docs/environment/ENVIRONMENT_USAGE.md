# Hướng dẫn Chạy Backend (`CINEPLEX Developer Guide`)

Tài liệu này hướng dẫn cách chuyển đổi giữa môi trường phát triển (**Dev**) và môi trường phát hành (**Prod**) trên Backend CINEPLEX.

---

## 1. Môi trường Development (`.env.dev`)

**Mục đích**: Dành cho quá trình phát triển tính năng hằng ngày, hỗ trợ hot-reload khi lưu code.

**Các bước chạy**:
```bash
# Cách 1: Tại thư mục backend/
npm run start:dev

# Cách 2: Từ thư mục gốc Monorepo
npm run backend:dev
# hoặc lệnh tắt
npm run dev
```

**Kết quả**:
- Backend tự động lắng nghe tại `http://localhost:3000`.
- Kết nối tới MySQL (`localhost:3306`) và Redis (`localhost:6379`).
- WebSocket Gateway sẵn sàng kết nối tại `ws://localhost:3000`.

---

## 2. Môi trường Production (`.env.prod`)

**Mục đích**: Khởi chạy phiên bản build tối ưu để kiểm thử release hoặc deploy lên Cloud Server.

**Các bước chạy**:
1. **Build mã nguồn**:
   ```bash
   # Tại root
   npm run backend:build
   ```
2. **Khởi động Backend Production**:
   ```bash
   # Cách 1: Tại thư mục backend/
   npm run start:prod

   # Cách 2: Từ thư mục gốc Monorepo
   npm run backend:prod
   ```

**Kết quả**:
- Chạy bằng Node.js trực tiếp từ thư mục `dist/main.js`.
- Hiệu năng tối đa, không tốn tài nguyên cho watcher/transpiler.

---

## 3. Tổng kết lệnh chạy Backend

| Mục tiêu | Lệnh tại thư mục `backend/` | Lệnh tại Root Monorepo |
| :--- | :--- | :--- |
| **Phát triển (Dev)** | `npm run start:dev` | `npm run backend:dev` hoặc `npm run dev` |
| **Build mã nguồn** | `npm run build` | `npm run backend:build` |
| **Production** | `npm run start:prod` | `npm run backend:prod` |
| **Kiểm tra Lint** | `npm run lint` | `npm run backend:lint` |
| **Chạy Unit Test** | `npm run test` | `npm run backend:test` |
