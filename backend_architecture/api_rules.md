# API Rules & Layer Conventions (`CINEPLEX Backend`)

Tài liệu này quy định các tiêu chuẩn cấu trúc mã nguồn, phân chia trách nhiệm giữa các tầng (Layered Architecture) và quy ước viết mã trong Backend CINEPLEX.

---

## 1. Controller Layer (`*.controller.ts`)

**Nhiệm vụ:** Tiếp nhận HTTP Request, routing, áp dụng Guards phân quyền, parse/validate tham số qua DTO và trả về response chuẩn.

### DO (Nên làm):
- Gắn decorator HTTP method rõ ràng: `@Get()`, `@Post()`, `@Put()`, `@Delete()`, `@Patch()`.
- Chỉ định rõ HTTP status code: `@HttpCode(HttpStatus.OK)` hoặc `@HttpCode(HttpStatus.CREATED)`.
- Parse parameters bằng decorators: `@Body() dto: ExampleDto`, `@Param('id') id: string`, `@Query() query: PaginationQueryDto`, `@Req() req: any`.
- Áp dụng Guards ở cấp controller hoặc endpoint: `@UseGuards(JwtAuthGuard, RolesGuard)` và `@Roles(EUserRole.ADMIN, EUserRole.STAFF)`.
- Trả về cấu trúc response chuẩn `{ success: true, message: '...', data: ... }` hoặc đối tượng `ApiResponse<T>`.

### DON'T (Tuyệt đối KHÔNG):
- **KHÔNG** chứa Business Logic trong Controller (chuyển toàn bộ vào Service).
- **KHÔNG** inject hoặc gọi trực tiếp TypeORM Repository trong Controller.
- **KHÔNG** thao tác trực tiếp với database hay Redis từ Controller.
- **KHÔNG** tự catch Exception rồi trả về response lỗi thủ công (hãy throw Exception để `HttpExceptionFilter` xử lý tự động).

```typescript
// Mẫu Controller chuẩn
@Controller('movies')
export class MovieController {
  constructor(private readonly movieService: MovieService) {}

  @Get(':id')
  @UseGuards(OptionalJwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async getMovieById(@Param('id') id: string) {
    const data = await this.movieService.getMovieById(id);
    return { success: true, message: 'Lấy thông tin phim thành công', data };
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  async createMovie(@Body() dto: CreateMovieDto) {
    const data = await this.movieService.createMovie(dto);
    return { success: true, message: 'Tạo phim mới thành công', data };
  }
}
```

---

## 2. Service Layer (`*.service.ts`)

**Nhiệm vụ:** Nơi tập trung toàn bộ Business Logic, validation nghiệp vụ, điều phối nhiều Repository, thao tác Redis, gửi Email, kích hoạt WebSockets và xử lý lỗi.

### DO (Nên làm):
- Đánh dấu `@Injectable()`.
- Inject TypeORM Repositories bằng `@InjectRepository(EntityName) private readonly entityRepo: Repository<EntityName>`.
- Kiểm tra tính toàn vẹn dữ liệu, các điều kiện nghiệp vụ trước khi ghi dữ liệu.
- Ném lỗi bằng `CustomException` hoặc các NestJS Built-in Exceptions (`BadRequestException`, `UnauthorizedException`, `ForbiddenException`, `NotFoundException`, `ConflictException`).
- Sử dụng TypeORM Transaction (`DataSource.transaction` hoặc `QueryRunner`) cho các nghiệp vụ cập nhật nhiều bảng liên quan (ví dụ: Tạo Booking, trừ ghế, ghi nhận thanh toán, cấp vé điện tử).
- Tách các logic độc lập thành helper functions hoặc sub-services (như `RedisService`, `CloudinaryService`, `MailService`).

### DON'T (Tuyệt đối KHÔNG):
- **KHÔNG** truy cập trực tiếp các đối tượng HTTP request/response của Express (như `req`, `res`) trong Service. Hãy truyền thuần túy tham số DTO, ID, User ID từ Controller xuống.
- **KHÔNG** để sót unhandled promise rejections.
- **KHÔNG** lặp lại logic xác thực hoặc validation đã có ở Service khác (hãy inject và tái sử dụng Service đã tồn tại).

```typescript
// Mẫu Service chuẩn với Transaction
@Injectable()
export class BookingService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(Booking)
    private readonly bookingRepository: Repository<Booking>,
    private readonly redisService: RedisService,
  ) {}

  async createBooking(userId: string, dto: CreateBookingDto) {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // 1. Kiểm tra khóa ghế trong Redis
      const isLocked = await this.redisService.checkSeatHold(dto.showtimeId, dto.seatIds, userId);
      if (!isLocked) {
        throw new BadRequestException('Ghế chưa được giữ hoặc phiên giữ ghế đã hết hạn');
      }

      // 2. Tạo Booking trong transaction
      const booking = queryRunner.manager.create(Booking, {
        userId,
        showtimeId: dto.showtimeId,
        totalPrice: dto.totalPrice,
        status: EBookingStatus.PENDING,
      });
      const savedBooking = await queryRunner.manager.save(booking);

      await queryRunner.commitTransaction();
      return savedBooking;
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }
}
```

---

## 3. DTO & Validation Layer (`dto/*.dto.ts`)

**Nhiệm vụ:** Định nghĩa cấu trúc dữ liệu đầu vào / đầu ra và ràng buộc xác thực dữ liệu qua `class-validator` và `class-transformer`.

### Quy tắc:
- Mọi trường dữ liệu nhận từ client **BẮT BUỘC** có decorator validation.
- Sử dụng `@IsString()`, `@IsNotEmpty()`, `@IsOptional()`, `@IsNumber()`, `@IsEmail()`, `@IsEnum()`, `@Min()`, `@Max()`, `@IsArray()`, v.v.
- Khi parse query parameters dạng số hoặc boolean, sử dụng `@Type(() => Number)` hoặc `@Transform()`.
- DTO cập nhật (`UpdateMovieDto`) nên kế thừa từ `PartialType(CreateMovieDto)`.

---

## 4. Entity Layer (`entities/*.entity.ts`)

**Nhiệm vụ:** Định nghĩa schema bảng trong cơ sở dữ liệu MySQL bằng TypeORM.

### Quy tắc:
- Đặt tên bảng rõ ràng bằng `@Entity('table_name')`.
- Sử dụng `@PrimaryGeneratedColumn('uuid')` hoặc `@PrimaryGeneratedColumn()`.
- Khai báo quan hệ dữ liệu rõ ràng: `@ManyToOne()`, `@OneToMany()`, `@ManyToMany()`, `@JoinColumn()`.
- Luôn bao gồm `@CreateDateColumn()` và `@UpdateDateColumn()` để theo dõi lịch sử bản ghi.
- Đặt index trên các cột thường xuyên tìm kiếm hoặc lọc: `@Index()` (ví dụ: `showtimeId`, `movieId`, `cinemaId`, `status`).

---

## 5. Chuẩn hóa Response & Error Response

### 5.1 Success Response (`ApiResponse<T>`)
```json
{
  "success": true,
  "message": "Thông điệp thành công",
  "data": { ... }
}
```

### 5.2 Error Response (Xử lý bởi `HttpExceptionFilter`)
```json
{
  "success": false,
  "error": {
    "code": "BAD_REQUEST",
    "message": "Ghế đã có người đặt hoặc phiên giữ ghế đã hết hạn"
  }
}
```

---

## 6. Chống trùng lặp code (Duplicate Prevention)

- **Search first:** Trước khi viết một hàm helper hoặc service method, luôn tìm kiếm trong codebase xem đã có hàm tương đương chưa (`utils/`, `core/`, `module/`).
- **Inject, don't duplicate:** Nếu cần chức năng từ module khác (ví dụ: gửi mail vé QR, upload ảnh Cloudinary, Redis lock), hãy import module tương ứng và inject service đó thay vì viết lại.
