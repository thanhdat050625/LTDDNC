import { Test, TestingModule } from '@nestjs/testing';
import { HttpStatus } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { EventEmitter2 } from '@nestjs/event-emitter';

import { ConcessionService } from '../src/module/concession/concession.service';
import { ConcessionProduct } from '../src/module/concession/entities/concession-product.entity';
import { CloudinaryService } from '../src/module/cloudinary/cloudinary.service';

import { BookingService } from '../src/module/booking/booking.service';
import { Booking } from '../src/module/booking/entities/booking.entity';
import { BookingConcession } from '../src/module/booking/entities/booking-concession.entity';
import { SeatHold } from '../src/module/booking/entities/seat-hold.entity';
import { Seat } from '../src/module/cinema/entities/seat.entity';
import { TicketPrice } from '../src/module/ticket/entities/ticket-price.entity';
import { Showtime } from '../src/module/showtime/entities/showtime.entity';
import { Promotion } from '../src/module/promotion/entities/promotion.entity';
import { User } from '../src/module/users/entities/user.entity';

import { RedisService } from '../src/module/redis/redis.service';
import { SeatGateway } from '../src/module/booking/seat.gateway';

import { EBookingStatus, ESeatHoldStatus } from '../src/module/booking/enums/booking.enum';
import { EDiscountType } from '../src/module/promotion/enums/promotion.enum';
import { CustomException } from '../src/core/exceptions/custom.exception';

import {
  createMockBooking,
  createMockUser,
  createMockShowtime,
  createMockSeat,
  createMockSeatHold,
  createMockTicketPrice,
  createMockConcessionProduct,
  createMockPromotion,
  createMockQueryRunner,
} from './helpers/test-fixtures';

// Các mã lỗi đề xuất cho các tính năng chưa có trong mã nguồn (Missing Features)
export const PROPOSED_CONCESSION_ERROR_CODES = {
  BOOKING_EXPIRED: 'BOOKING_EXPIRED',
  CONCESSION_TEMPORARILY_CLOSED: 'CONCESSION_TEMPORARILY_CLOSED',
  CONCESSION_PRODUCT_INACTIVE: 'CONCESSION_PRODUCT_INACTIVE',
};

describe('UC08 - Đặt bắp nước (Concessions Selection & Cart Update)', () => {
  let concessionService: ConcessionService;
  let bookingService: BookingService;

  // Mock Repositories
  let mockConcessionProductRepo: any;
  let mockCloudinaryService: any;

  let mockBookingRepo: any;
  let mockSeatHoldRepo: any;
  let mockSeatRepo: any;
  let mockTicketPriceRepo: any;
  let mockShowtimeRepo: any;
  let mockPromotionRepo: any;
  let mockUserRepo: any;
  let mockDataSource: any;
  let mockQueryRunner: any;

  let mockRedisService: any;
  let mockSeatGateway: any;
  let mockEventEmitter: any;

  async function expectCustomException(
    fn: () => Promise<any>,
    expectedStatus: HttpStatus,
    expectedCode: string,
  ) {
    try {
      await fn();
      throw new Error(`Expected CustomException with code ${expectedCode}, but no exception was thrown`);
    } catch (err: any) {
      expect(err).toBeInstanceOf(CustomException);
      expect(err.getStatus()).toBe(expectedStatus);
      const res = err.getResponse() as any;
      expect(res?.error?.code).toBe(expectedCode);
    }
  }

  beforeEach(async () => {
    mockQueryRunner = createMockQueryRunner();

    // Mock ConcessionProduct Repo
    mockConcessionProductRepo = {
      findAndCount: jest.fn().mockResolvedValue([
        [
          createMockConcessionProduct({ id: 1, name: 'Combo Bắp Nước 1', price: 65000, stockQuantity: 50 }),
          createMockConcessionProduct({ id: 2, name: 'Bắp rang bơ phô mai', price: 45000, stockQuantity: 30 }),
        ],
        2,
      ]),
      find: jest.fn().mockResolvedValue([]),
      findOne: jest.fn().mockImplementation(({ where }) => {
        if (where?.id === 1) {
          return Promise.resolve(createMockConcessionProduct({ id: 1, name: 'Combo Bắp Nước 1', price: 65000, stockQuantity: 50 }));
        }
        if (where?.id === 2) {
          return Promise.resolve(createMockConcessionProduct({ id: 2, name: 'Bắp rang bơ phô mai', price: 45000, stockQuantity: 30 }));
        }
        if (where?.id === 999) {
          return Promise.resolve(null);
        }
        return Promise.resolve(createMockConcessionProduct({ id: where?.id, price: 50000, stockQuantity: 20 }));
      }),
      create: jest.fn((dto) => ({ id: 1, ...dto })),
      save: jest.fn((entity) => Promise.resolve({ id: 1, ...entity })),
      remove: jest.fn().mockResolvedValue(undefined),
    };

    mockCloudinaryService = {
      uploadImage: jest.fn().mockResolvedValue({ secure_url: 'https://cdn.cineplex.vn/sample.jpg' }),
    };

    // Mock Booking Repos
    mockBookingRepo = {
      findOne: jest.fn(),
      findAndCount: jest.fn().mockResolvedValue([[], 0]),
      create: jest.fn((dto) => ({ id: 1, ...dto })),
      save: jest.fn((entity) => Promise.resolve({ id: 1, ...entity })),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockSeatHoldRepo = {
      find: jest.fn().mockResolvedValue([]),
      findOne: jest.fn(),
      delete: jest.fn().mockResolvedValue({ affected: 1 }),
      save: jest.fn((entity) => Promise.resolve(entity)),
    };

    mockSeatRepo = {
      find: jest.fn().mockResolvedValue([createMockSeat(1, 'F', 1)]),
      findOne: jest.fn(),
    };

    mockTicketPriceRepo = {
      findOne: jest.fn().mockResolvedValue(createMockTicketPrice('IMAX', 'WEEKDAY', 100000)),
    };

    mockShowtimeRepo = {
      findOne: jest.fn().mockResolvedValue(createMockShowtime()),
    };

    mockPromotionRepo = {
      findOne: jest.fn(),
      save: jest.fn((p) => Promise.resolve(p)),
    };

    mockUserRepo = {
      findOne: jest.fn().mockResolvedValue(createMockUser({ id: 1, loyaltyPoints: 50000 })),
      save: jest.fn((u) => Promise.resolve(u)),
    };

    mockDataSource = {
      createQueryRunner: jest.fn().mockReturnValue(mockQueryRunner),
    };

    mockRedisService = {
      holdSeat: jest.fn().mockResolvedValue(true),
      getSeatHolder: jest.fn().mockResolvedValue(1),
      releaseSeat: jest.fn().mockResolvedValue(true),
      getSeatHoldsByShowtime: jest.fn().mockResolvedValue([]),
    };

    mockSeatGateway = {
      broadcastSeatHold: jest.fn(),
      broadcastSeatRelease: jest.fn(),
      broadcastSeatUpdate: jest.fn(),
    };

    mockEventEmitter = {
      emit: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ConcessionService,
        BookingService,
        { provide: getRepositoryToken(ConcessionProduct), useValue: mockConcessionProductRepo },
        { provide: CloudinaryService, useValue: mockCloudinaryService },
        { provide: getRepositoryToken(Booking), useValue: mockBookingRepo },
        { provide: getRepositoryToken(SeatHold), useValue: mockSeatHoldRepo },
        { provide: getRepositoryToken(Seat), useValue: mockSeatRepo },
        { provide: getRepositoryToken(TicketPrice), useValue: mockTicketPriceRepo },
        { provide: getRepositoryToken(Showtime), useValue: mockShowtimeRepo },
        { provide: getRepositoryToken(Promotion), useValue: mockPromotionRepo },
        { provide: getRepositoryToken(User), useValue: mockUserRepo },
        { provide: DataSource, useValue: mockDataSource },
        { provide: RedisService, useValue: mockRedisService },
        { provide: SeatGateway, useValue: mockSeatGateway },
        { provide: EventEmitter2, useValue: mockEventEmitter },
      ],
    }).compile();

    concessionService = module.get<ConcessionService>(ConcessionService);
    bookingService = module.get<BookingService>(BookingService);
  });

  // =========================================================================
  // 1. PRE-CONDITIONS: Cập nhật bắp nước cho đơn hàng
  // =========================================================================
  describe('Pre-conditions (Booking Validation)', () => {
    it('UC08 - Pre.1 - Đơn đặt vé không tồn tại -> từ chối với BOOKING_NOT_FOUND (404)', async () => {
      mockBookingRepo.findOne.mockResolvedValue(null);

      await expectCustomException(
        () => bookingService.updateBookingConcessions(999, 1, { concessions: [{ productId: 1, quantity: 1 }] }),
        HttpStatus.NOT_FOUND,
        'BOOKING_NOT_FOUND',
      );
    });

    it('UC08 - Pre.2 - Đơn đặt vé không thuộc về khách hàng yêu cầu -> từ chối với FORBIDDEN (403)', async () => {
      const alienBooking = createMockBooking({ id: 1, userId: 999 }); // thuộc user 999
      mockBookingRepo.findOne.mockResolvedValue(alienBooking);

      await expectCustomException(
        () => bookingService.updateBookingConcessions(1, 1, { concessions: [{ productId: 1, quantity: 1 }] }), // khách 1 gọi
        HttpStatus.FORBIDDEN,
        'FORBIDDEN',
      );
    });

    it('UC08 - Pre.3 - Đơn đặt vé không ở trạng thái PENDING (đã PAID) -> từ chối với INVALID_STATUS (400)', async () => {
      const paidBooking = createMockBooking({ id: 1, userId: 1, status: EBookingStatus.PAID });
      mockBookingRepo.findOne.mockResolvedValue(paidBooking);

      await expectCustomException(
        () => bookingService.updateBookingConcessions(1, 1, { concessions: [{ productId: 1, quantity: 1 }] }),
        HttpStatus.BAD_REQUEST,
        'INVALID_STATUS',
      );
    });

    it(
      'UC08 - E4.1 - Đơn đặt vé đã quá hạn giữ chỗ (expiredAt < now) nhưng status vẫn là PENDING -> từ chối với BOOKING_EXPIRED (400)',
      async () => {
        // Kịch bản: Đơn hàng hết hạn 5 phút trước nhưng Cron Job chưa kịp đổi status sang EXPIRED
        const expiredBooking = createMockBooking({
          id: 1,
          userId: 1,
          status: EBookingStatus.PENDING,
          expiredAt: new Date(Date.now() - 60 * 1000), // đã quá hạn 1 phút
        });
        mockBookingRepo.findOne.mockResolvedValue(expiredBooking);

        // HIỆN TẠI: updateBookingConcessions không kiểm tra expiredAt, chỉ kiểm tra status === PENDING
        // ĐẶC TẢ UC08 (E4.1): Hết thời gian giữ chỗ thì hệ thống phải chặn cập nhật và thông báo hết giờ
        await expectCustomException(
          () => bookingService.updateBookingConcessions(1, 1, { concessions: [{ productId: 1, quantity: 1 }] }),
          HttpStatus.BAD_REQUEST,
          PROPOSED_CONCESSION_ERROR_CODES.BOOKING_EXPIRED,
        );
      },
    );
  });

  // =========================================================================
  // 2. MAIN FLOW - Danh sách bắp nước (ConcessionService.findAll)
  // =========================================================================
  describe('Main Flow - Lấy danh sách bắp nước (Step 1)', () => {
    it('UC08 - Main.1 - Lấy danh sách sản phẩm bắp nước phân trang thành công', async () => {
      const result = await concessionService.findAll(1, 10);

      expect(result.success).toBe(true);
      expect(result.data).toHaveLength(2);
      expect(result.pagination).toBeDefined();
      expect(result.pagination?.totalItems).toBe(2);
      expect(mockConcessionProductRepo.findAndCount).toHaveBeenCalledWith({
        skip: 0,
        take: 10,
        order: { id: 'DESC' },
      });
    });

    it.failing(
      '[MISSING-FEATURE][BUG-12] UC08 - Main.1b - Danh sách bắp nước phải lọc chỉ lấy món đang kinh doanh (isActive = true)',
      async () => {
        // ĐẶC TẢ UC08: Danh sách chỉ gồm các món/combo đang mở bán (isActive = true)
        // HIỆN TẠI: ConcessionProduct entity không có trường isActive, findAll không có điều kiện where: { isActive: true }
        await concessionService.findAll(1, 10);

        expect(mockConcessionProductRepo.findAndCount).toHaveBeenCalledWith(
          expect.objectContaining({
            where: expect.objectContaining({ isActive: true }),
          }),
        );
      },
    );

    it.failing(
      '[MISSING-FEATURE][BUG-12] UC08 - CinemaFilter - Lọc danh sách bắp nước theo rạp chiếu (concession_products không có cinemaId)',
      async () => {
        // ĐẶC TẢ UC08: Mỗi rạp có thể có menu bắp nước và giá riêng hoặc tình trạng kho riêng
        // HIỆN TẠI: ConcessionService.findAll(page, pageSize) không nhận tham số cinemaId
        const cinemaId = 1;
        await (concessionService as any).findAll(1, 10, cinemaId);

        expect(mockConcessionProductRepo.findAndCount).toHaveBeenCalledWith(
          expect.objectContaining({
            where: expect.objectContaining({ cinemaId }),
          }),
        );
      },
    );

    it.failing(
      '[MISSING-FEATURE] UC08 - E1.1 - Rạp tạm ngưng dịch vụ bắp nước -> Hệ thống thông báo và từ chối với CONCESSION_TEMPORARILY_CLOSED (400)',
      async () => {
        // ĐẶC TẢ UC08 - E1.1: Quầy bắp nước của rạp đang bảo trì hoặc tạm ngưng phục vụ
        // HIỆN TẠI: Backend chưa có trạng thái tạm ngưng quầy bắp nước theo rạp
        const cinemaId = 99; // rạp đang bảo trì quầy
        await expectCustomException(
          () => (concessionService as any).findAll(1, 10, cinemaId),
          HttpStatus.BAD_REQUEST,
          PROPOSED_CONCESSION_ERROR_CODES.CONCESSION_TEMPORARILY_CLOSED,
        );
      },
    );
  });

  // =========================================================================
  // 3. MAIN FLOW - Toàn vẹn giá & Tính toán (Step 2 - 4)
  // =========================================================================
  describe('Main Flow - Tính tổng tiền & Toàn vẹn giá (Step 2-4)', () => {
    it('UC08 - Main.2-3 - Tổng tiền bắp nước do Server tính từ DB, KHÔNG tin giá client gửi lên (Chống giả mạo giá)', async () => {
      // Kịch bản: Client cố tình can thiệp request gửi giá 1.000đ cho Combo 65.000đ
      const booking = createMockBooking({
        id: 1,
        userId: 1,
        totalAmount: 200000, // 2 vé 100k
        discountAmount: 0,
        bookingConcessions: [],
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Client gửi payload có thuộc tính price giả mạo (1.000đ)
      const fakePriceDto: any = {
        concessions: [
          { productId: 1, quantity: 2, price: 1000, unitPrice: 1000 },
        ],
      };

      const result = await bookingService.updateBookingConcessions(1, 1, fakePriceDto);

      // Server phải tra cứu giá trong DB (Combo 1 giá 65.000đ)
      // Tổng bắp nước = 2 * 65.000 = 130.000đ
      // Tổng đơn hàng = 200.000 (vé) + 130.000 (bắp) = 330.000đ
      expect(result.success).toBe(true);

      const updates = mockQueryRunner.getUpdates();
      const bookingUpdate = updates.find((u: any) => u.criteria === 1 || u.criteria?.id === 1);
      expect(bookingUpdate).toBeDefined();
      expect(bookingUpdate.partialEntity.totalAmount).toBe(330000); // Server tính đúng 330.000đ, không phải 202.000đ
    });

    it('UC08 - Main.4 - Lưu bắp nước vào đơn hàng và cập nhật totalAmount = vé + bắp nước - giảm giá', async () => {
      const booking = createMockBooking({
        id: 1,
        userId: 1,
        totalAmount: 200000, // 200.000đ tiền vé
        discountAmount: 0,
        bookingConcessions: [],
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const dto = {
        concessions: [
          { productId: 1, quantity: 1 }, // 65.000đ
          { productId: 2, quantity: 2 }, // 2 * 45.000đ = 90.000đ
        ],
      };

      const result = await bookingService.updateBookingConcessions(1, 1, dto);

      expect(result.success).toBe(true);
      const updates = mockQueryRunner.getUpdates();
      const bookingUpdate = updates.find((u: any) => u.criteria === 1 || u.criteria?.id === 1);
      // Vé (200k) + Combo 1 (65k) + Combo 2 (90k) = 355.000đ
      expect(bookingUpdate.partialEntity.totalAmount).toBe(355000);
      expect(bookingUpdate.partialEntity.discountAmount).toBe(0);
    });

    it('UC08 - Main.4b - Idempotency: Gọi cập nhật bắp nước 2 lần liên tiếp không bị nhân đôi số tiền hay nhân đôi bản ghi', async () => {
      // Lần 1: Đã có 1 combo 65.000đ trong đơn hàng
      const initialConcession = {
        id: 1,
        bookingId: 1,
        productId: 1,
        quantity: 1,
        unitPrice: 65000,
        subtotal: 65000,
      };
      const booking = createMockBooking({
        id: 1,
        userId: 1,
        totalAmount: 265000, // 200k vé + 65k bắp nước
        discountAmount: 0,
        bookingConcessions: [initialConcession as any],
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Khách đổi ý, cập nhật lại thành 2 bắp phô mai (productId: 2, giá 45k)
      const updateDto = {
        concessions: [
          { productId: 2, quantity: 2 }, // 2 * 45k = 90k
        ],
      };

      await bookingService.updateBookingConcessions(1, 1, updateDto);

      // Kiểm tra transaction delete bản ghi cũ trước khi insert bản ghi mới
      expect(mockQueryRunner.manager.delete).toHaveBeenCalledWith(
        BookingConcession,
        { bookingId: 1 },
      );

      const updates = mockQueryRunner.getUpdates();
      const bookingUpdate = updates.find((u: any) => u.criteria === 1 || u.criteria?.id === 1);
      // Tổng mới = 200k (vé) + 90k (bắp mới) = 290.000đ (KHÔNG bị cộng dồn thành 200k + 65k + 90k = 355k)
      expect(bookingUpdate.partialEntity.totalAmount).toBe(290000);
    });
  });

  // =========================================================================
  // 4. ALTERNATE FLOW & BOUNDARY TESTING (Biên số lượng & Sản phẩm)
  // =========================================================================
  describe('Alternate Flow & Boundary Testing (Số lượng, Rỗng, Ngưng bán)', () => {
    it('UC08 - A2.1 - Khách bỏ qua bắp nước hoặc xóa hết bắp nước (concessions: []) -> đơn hàng được cập nhật về 0đ bắp nước', async () => {
      // Đơn hàng trước đó đang có bắp nước
      const existingConcession = {
        id: 1,
        bookingId: 1,
        productId: 1,
        quantity: 1,
        unitPrice: 65000,
        subtotal: 65000,
      };
      const booking = createMockBooking({
        id: 1,
        userId: 1,
        totalAmount: 265000, // 200k vé + 65k bắp
        discountAmount: 0,
        bookingConcessions: [existingConcession as any],
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Khách bấm "Bỏ qua" hoặc xóa hết món -> gửi concessions: []
      const result = await bookingService.updateBookingConcessions(1, 1, { concessions: [] });

      expect(result.success).toBe(true);
      expect(mockQueryRunner.manager.delete).toHaveBeenCalledWith(
        BookingConcession,
        { bookingId: 1 },
      );

      const updates = mockQueryRunner.getUpdates();
      const bookingUpdate = updates.find((u: any) => u.criteria === 1 || u.criteria?.id === 1);
      // Trả lại đúng tiền vé ban đầu: 200.000đ
      expect(bookingUpdate.partialEntity.totalAmount).toBe(200000);
    });

    // BEHAVIOR ĐÃ SỬA THEO UC A2.1 / BUG-10: Backend bỏ qua item quantity=0 và chỉ từ chối số âm
    it('UC08 - Boundary.ZeroQuantity - Gửi item có quantity = 0 -> Backend bỏ qua không lỗi và xóa bắp nước', async () => {
      const booking = createMockBooking({ id: 1, userId: 1 });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const result = await bookingService.updateBookingConcessions(1, 1, {
        concessions: [{ productId: 1, quantity: 0 }],
      });

      expect(result.success).toBe(true);
      expect(result.data.concessionTotal).toBe(0);
    });

    it('UC08 - Boundary.NegativeQuantity - Gửi item có quantity âm (< 0) -> Backend từ chối với INVALID_CONCESSION_QUANTITY (400)', async () => {
      const booking = createMockBooking({ id: 1, userId: 1 });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      await expectCustomException(
        () => bookingService.updateBookingConcessions(1, 1, {
          concessions: [{ productId: 1, quantity: -2 }],
        }),
        HttpStatus.BAD_REQUEST,
        'INVALID_CONCESSION_QUANTITY',
      );
    });

    it('UC08 - Exception.ProductNotFound - Chọn sản phẩm không tồn tại trong DB -> từ chối với PRODUCT_NOT_FOUND (400)', async () => {
      const booking = createMockBooking({ id: 1, userId: 1 });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      await expectCustomException(
        () => bookingService.updateBookingConcessions(1, 1, {
          concessions: [{ productId: 999, quantity: 1 }],
        }),
        HttpStatus.BAD_REQUEST,
        'PRODUCT_NOT_FOUND',
      );
    });

    it.failing(
      '[MISSING-FEATURE][BUG-12] UC08 - InactiveProduct - Cố tình thêm món bắp nước đã ngưng kinh doanh vào đơn hàng -> từ chối với CONCESSION_PRODUCT_INACTIVE (400)',
      async () => {
        // Kịch bản: Sản phẩm đã bị quản lý rạp tắt bán (isActive = false)
        // HIỆN TẠI: buildConcessionItems chỉ kiểm tra product tồn tại và đủ tồn kho, không kiểm tra isActive
        mockConcessionProductRepo.findOne.mockResolvedValue(
          createMockConcessionProduct({ id: 1, name: 'Món ngưng bán', isActive: false }),
        );
        const booking = createMockBooking({ id: 1, userId: 1 });
        mockBookingRepo.findOne.mockResolvedValue(booking);

        await expectCustomException(
          () => bookingService.updateBookingConcessions(1, 1, {
            concessions: [{ productId: 1, quantity: 1 }],
          }),
          HttpStatus.BAD_REQUEST,
          PROPOSED_CONCESSION_ERROR_CODES.CONCESSION_PRODUCT_INACTIVE,
        );
      },
    );
  });

  // =========================================================================
  // 5. TỒN KHO & CONCURRENCY (Stock Management)
  // =========================================================================
  describe('Tồn kho & Quản lý số lượng (Stock Management)', () => {
    it('UC08 - Stock.Insufficient - Đặt số lượng vượt tồn kho hiện có trong DB -> từ chối với INSUFFICIENT_CONCESSION_STOCK (400)', async () => {
      // Sản phẩm 1 chỉ còn 5 phần trong kho
      mockConcessionProductRepo.findOne.mockResolvedValue(
        createMockConcessionProduct({ id: 1, name: 'Combo Bắp Nước 1', stockQuantity: 5 }),
      );
      const booking = createMockBooking({ id: 1, userId: 1 });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Khách yêu cầu đặt 6 phần
      await expectCustomException(
        () => bookingService.updateBookingConcessions(1, 1, {
          concessions: [{ productId: 1, quantity: 6 }],
        }),
        HttpStatus.BAD_REQUEST,
        'INSUFFICIENT_CONCESSION_STOCK',
      );
    });

    it('UC08 - Stock.AggregateQuantity - Gửi nhiều item cùng 1 productId có tổng số lượng vượt tồn kho -> gom nhóm và từ chối với INSUFFICIENT_CONCESSION_STOCK (400)', async () => {
      // Sản phẩm 1 còn 5 phần trong kho
      mockConcessionProductRepo.findOne.mockResolvedValue(
        createMockConcessionProduct({ id: 1, name: 'Combo Bắp Nước 1', stockQuantity: 5 }),
      );
      const booking = createMockBooking({ id: 1, userId: 1 });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Client gửi 2 dòng cùng productId: 1 (dòng 1: 3 phần, dòng 2: 3 phần -> tổng là 6 phần)
      await expectCustomException(
        () => bookingService.updateBookingConcessions(1, 1, {
          concessions: [
            { productId: 1, quantity: 3 },
            { productId: 1, quantity: 3 },
          ],
        }),
        HttpStatus.BAD_REQUEST,
        'INSUFFICIENT_CONCESSION_STOCK',
      );
    });
  });

  // =========================================================================
  // 6. TƯƠNG TÁC VỚI UC09 (Áp dụng khuyến mãi & Đổi điểm Loyalty)
  // =========================================================================
  describe('Tương tác với UC09 (Áp dụng khuyến mãi khi cập nhật bắp nước)', () => {
    it('UC08 - Interaction.PercentagePromo - Đơn đã áp voucher PERCENTAGE (10%) -> khi thêm bắp nước, tiền giảm giá và tổng tiền được tính lại chính xác', async () => {
      // Đơn hàng có voucher giảm 10%
      const promo10Percent = createMockPromotion({
        id: 1,
        code: 'SALE10',
        discountType: EDiscountType.PERCENTAGE,
        discountValue: 10, // 10%
      });
      const booking = createMockBooking({
        id: 1,
        userId: 1,
        totalAmount: 180000, // 200k vé - 20k giảm giá = 180k
        discountAmount: 20000,
        promotion: promo10Percent as any,
        bookingConcessions: [],
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Thêm 2 combo bắp nước: 2 * 65.000 = 130.000đ
      // Tổng tiền trước giảm: 200k (vé) + 130k (bắp) = 330.000đ
      // Giảm giá mới (10%): 330.000 * 10% = 33.000đ
      // Tổng thanh toán mới: 330.000 - 33.000 = 297.000đ
      const dto = {
        concessions: [{ productId: 1, quantity: 2 }],
      };

      const result = await bookingService.updateBookingConcessions(1, 1, dto);

      expect(result.success).toBe(true);
      const updates = mockQueryRunner.getUpdates();
      const bookingUpdate = updates.find((u: any) => u.criteria === 1 || u.criteria?.id === 1);
      expect(bookingUpdate.partialEntity.discountAmount).toBe(33000);
      expect(bookingUpdate.partialEntity.totalAmount).toBe(297000);
    });

    it('UC08 - Interaction.FixedPromo - Đơn đã áp voucher FIXED_AMOUNT (20.000đ) -> khi thêm bắp nước, tiền giảm giữ nguyên và tổng tiền tăng tương ứng', async () => {
      // Đơn hàng có voucher giảm cố định 20.000đ
      const promoFixed20k = createMockPromotion({
        id: 1,
        code: 'GIAM20K',
        discountType: EDiscountType.FIXED_AMOUNT,
        discountValue: 20000,
      });
      const booking = createMockBooking({
        id: 1,
        userId: 1,
        totalAmount: 180000, // 200k vé - 20k giảm giá = 180k
        discountAmount: 20000,
        promotion: promoFixed20k as any,
        bookingConcessions: [],
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Thêm 1 combo bắp nước: 65.000đ
      // Tổng thanh toán mới: 200k (vé) + 65k (bắp) - 20k (giảm) = 245.000đ
      const dto = {
        concessions: [{ productId: 1, quantity: 1 }],
      };

      const result = await bookingService.updateBookingConcessions(1, 1, dto);

      expect(result.success).toBe(true);
      const updates = mockQueryRunner.getUpdates();
      const bookingUpdate = updates.find((u: any) => u.criteria === 1 || u.criteria?.id === 1);
      expect(bookingUpdate.partialEntity.discountAmount).toBe(20000);
      expect(bookingUpdate.partialEntity.totalAmount).toBe(245000);
    });

    it('UC08 - Interaction.LoyaltyPoints - Đổi combo bắp nước bằng điểm tích lũy -> trừ đúng số điểm tương ứng của sản phẩm', async () => {
      // Khách hàng có 50.000 điểm loyalty
      const user = createMockUser({ id: 1, loyaltyPoints: 50000 });
      mockUserRepo.findOne.mockResolvedValue(user);

      const booking = createMockBooking({
        id: 1,
        userId: 1,
        totalAmount: 200000,
        discountAmount: 0,
        bookingConcessions: [],
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Đổi sản phẩm 2 (giá 45.000đ = 45.000 điểm)
      const dto = {
        concessions: [],
        redeemConcessionId: 2,
      };

      const result = await bookingService.updateBookingConcessions(1, 1, dto);

      expect(result.success).toBe(true);
      const updates = mockQueryRunner.getUpdates();
      const bookingUpdate = updates.find((u: any) => u.criteria === 1 || u.criteria?.id === 1);
      // Combo được thêm vào danh sách bắp nước và được giảm 100% bằng điểm
      expect(bookingUpdate.partialEntity.pointsUsed).toBe(45000);
      expect(bookingUpdate.partialEntity.discountAmount).toBe(45000);
      expect(bookingUpdate.partialEntity.totalAmount).toBe(200000); // Khách chỉ trả 200k tiền vé
    });

    it('UC08 - Interaction.LoyaltyPoints.Twice - Gọi updateBookingConcessions 2 lần trên đơn có dùng điểm loyalty -> điểm không bị trừ 2 lần (Lưu ý: đổi combo bằng điểm là hành vi ngoài UC08)', async () => {
      // Khách hàng có 50.000 điểm loyalty
      const user = createMockUser({ id: 1, loyaltyPoints: 50000 });
      mockUserRepo.findOne.mockResolvedValue(user);

      // Đơn hàng đang có pointsUsed = 20.000 điểm (đã trừ 20k điểm trước đó)
      const booking = createMockBooking({
        id: 1,
        userId: 1,
        totalAmount: 180000,
        discountAmount: 20000,
        pointsUsed: 20000,
        bookingConcessions: [],
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Lần 2: Khách cập nhật thêm bắp nước nhưng vẫn giữ nguyên dùng 20.000 điểm
      const dto = {
        concessions: [{ productId: 1, quantity: 1 }], // Combo 65k
        pointsToUse: 20000,
      };

      const result = await bookingService.updateBookingConcessions(1, 1, dto);

      expect(result.success).toBe(true);
      const updates = mockQueryRunner.getUpdates();
      // Điểm chênh lệch: pointsDifference = 20000 - 20000 = 0
      // Do đó không thực hiện query trừ thêm loyaltyPoints của User
      const userPointsUpdate = updates.find((u: any) => u.entityClass === User);
      expect(userPointsUpdate).toBeUndefined(); // Không bị trừ điểm lần 2!
    });
  });
});
