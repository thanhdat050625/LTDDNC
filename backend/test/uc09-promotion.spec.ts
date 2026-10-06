import { Test, TestingModule } from '@nestjs/testing';
import { HttpStatus } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { EventEmitter2 } from '@nestjs/event-emitter';

import { PromotionService } from '../src/module/promotion/promotion.service';
import { BookingService } from '../src/module/booking/booking.service';

import { Promotion } from '../src/module/promotion/entities/promotion.entity';
import { Booking } from '../src/module/booking/entities/booking.entity';
import { SeatHold } from '../src/module/booking/entities/seat-hold.entity';
import { Seat } from '../src/module/cinema/entities/seat.entity';
import { TicketPrice } from '../src/module/ticket/entities/ticket-price.entity';
import { Showtime } from '../src/module/showtime/entities/showtime.entity';
import { ConcessionProduct } from '../src/module/concession/entities/concession-product.entity';
import { User } from '../src/module/users/entities/user.entity';

import { RedisService } from '../src/module/redis/redis.service';
import { SeatGateway } from '../src/module/booking/seat.gateway';

import { EDiscountType } from '../src/module/promotion/enums/promotion.enum';
import { EBookingStatus, EBookingSource } from '../src/module/booking/enums/booking.enum';
import { CustomException } from '../src/core/exceptions/custom.exception';

import {
  createMockBooking,
  createMockUser,
  createMockShowtime,
  createMockSeat,
  createMockTicketPrice,
  createMockPromotion,
  createMockQueryRunner,
} from './helpers/test-fixtures';

describe('UC09 - Áp dụng khuyến mãi (Apply Promotion / Voucher)', () => {
  let promotionService: PromotionService;
  let bookingService: BookingService;

  // Mock Repositories
  let mockPromotionRepo: any;
  let mockBookingRepo: any;
  let mockSeatHoldRepo: any;
  let mockSeatRepo: any;
  let mockTicketPriceRepo: any;
  let mockShowtimeRepo: any;
  let mockConcessionProductRepo: any;
  let mockUserRepo: any;
  let mockDataSource: any;
  let mockQueryRunner: any;

  // Mock External Services
  let mockRedisService: any;
  let mockSeatGateway: any;
  let mockEventEmitter: any;

  beforeEach(async () => {
    mockQueryRunner = createMockQueryRunner();

    mockPromotionRepo = {
      findOne: jest.fn(),
      findAndCount: jest.fn().mockResolvedValue([[], 0]),
      create: jest.fn((dto) => ({ id: 1, ...dto })),
      save: jest.fn((entity) => Promise.resolve({ id: 1, ...entity })),
      remove: jest.fn().mockResolvedValue(undefined),
    };

    mockBookingRepo = {
      findOne: jest.fn(),
      find: jest.fn().mockResolvedValue([]),
      create: jest.fn((dto) => ({ id: 1, ...dto })),
      save: jest.fn((entity) => Promise.resolve({ id: 1, ...entity })),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockSeatHoldRepo = {
      find: jest.fn().mockResolvedValue([]),
      findOne: jest.fn(),
      create: jest.fn((dto) => ({ id: 1, ...dto })),
      save: jest.fn((entity) => Promise.resolve({ id: 1, ...entity })),
      delete: jest.fn().mockResolvedValue({ affected: 1 }),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockSeatRepo = {
      find: jest.fn().mockImplementation(({ where }) => {
        const ids = where?.id?._value || [1, 2];
        return Promise.resolve(ids.map((id: number) => createMockSeat(id, 'F', id, { room: { roomType: 'STANDARD' } as any })));
      }),
    };

    mockTicketPriceRepo = {
      findOne: jest.fn().mockResolvedValue(createMockTicketPrice('STANDARD', 'WEEKDAY', 100000)),
    };

    mockShowtimeRepo = {
      findOne: jest.fn().mockResolvedValue(createMockShowtime()),
    };

    mockConcessionProductRepo = {
      findOne: jest.fn(),
    };

    mockUserRepo = {
      findOne: jest.fn().mockResolvedValue(createMockUser()),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockDataSource = {
      createQueryRunner: jest.fn().mockReturnValue(mockQueryRunner),
    };

    mockRedisService = {
      getSeatHolder: jest.fn().mockResolvedValue(1), // Giả lập user 1 đang hold ghế
      holdSeat: jest.fn().mockResolvedValue(true),
      releaseSeats: jest.fn().mockResolvedValue(undefined),
      getHeldSeatIds: jest.fn().mockResolvedValue([]),
    };

    mockSeatGateway = {
      emitSeatUpdate: jest.fn(),
    };

    mockEventEmitter = {
      emit: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PromotionService,
        BookingService,
        { provide: getRepositoryToken(Promotion), useValue: mockPromotionRepo },
        { provide: getRepositoryToken(Booking), useValue: mockBookingRepo },
        { provide: getRepositoryToken(SeatHold), useValue: mockSeatHoldRepo },
        { provide: getRepositoryToken(Seat), useValue: mockSeatRepo },
        { provide: getRepositoryToken(TicketPrice), useValue: mockTicketPriceRepo },
        { provide: getRepositoryToken(Showtime), useValue: mockShowtimeRepo },
        { provide: getRepositoryToken(ConcessionProduct), useValue: mockConcessionProductRepo },
        { provide: getRepositoryToken(User), useValue: mockUserRepo },
        { provide: DataSource, useValue: mockDataSource },
        { provide: RedisService, useValue: mockRedisService },
        { provide: SeatGateway, useValue: mockSeatGateway },
        { provide: EventEmitter2, useValue: mockEventEmitter },
      ],
    }).compile();

    promotionService = module.get<PromotionService>(PromotionService);
    bookingService = module.get<BookingService>(BookingService);
  });

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

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. PRE-CONDITIONS
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Pre-conditions', () => {
    it('UC09 - Pre.1 - Đơn hàng hợp lệ và tổng tiền > 0 -> Có thể kiểm tra mã khuyến mãi thành công', async () => {
      // Arrange
      const validPromotion = createMockPromotion({ code: 'SALE10' });
      mockPromotionRepo.findOne.mockResolvedValue(validPromotion);

      // Act
      const result = await promotionService.checkPromotion({ code: 'SALE10' });

      // Assert
      expect(result.success).toBe(true);
      expect(result.data.code).toBe('SALE10');
      expect(result.data.discountValue).toBe(20000);
    });

    /**
     * [MISSING-FEATURE] UC09 - Pre.1b: Đơn hàng có tổng tiền = 0
     * Đặc tả UC09 Pre-Conditions: "Actor đang ở trong luồng Đặt vé trực tuyến (UC7) và tổng tiền đơn hàng > 0".
     * Code hiện tại: createBooking không kiểm tra nếu totalAmount trước giảm giá = 0 thì không cho phép áp voucher.
     */
    it.failing('[MISSING-FEATURE] UC09 - Pre.1b - Đơn hàng có tổng tiền ban đầu = 0 -> Từ chối áp dụng voucher với lỗi ORDER_TOTAL_ZERO (400)', async () => {
      // Code cần sửa: Trong createBooking, if ((ticketTotal + concessionTotal) <= 0 && dto.promotionCode) throw CustomException.
      mockTicketPriceRepo.findOne.mockResolvedValue(createMockTicketPrice('STANDARD', 'WEEKDAY', 0)); // Vé 0 đồng
      mockPromotionRepo.findOne.mockResolvedValue(createMockPromotion({ code: 'EXTRA10' }));

      await expectCustomException(
        () => bookingService.createBooking(1, { showtimeId: 101, seatIds: [1], promotionCode: 'EXTRA10' }),
        HttpStatus.BAD_REQUEST,
        'ORDER_TOTAL_ZERO',
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. MAIN FLOW - XÁC THỰC & ÁP DỤNG MÃ KHUYẾN MÃI (Step 1-5)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Main Flow - Xác thực & Áp dụng mã khuyến mãi (Step 1-5)', () => {
    /**
     * [MISSING-FEATURE] UC09 - Main.1: Ví Voucher (Voucher Wallet) của khách hàng
     * Đặc tả UC09 Step 1: "Hệ thống hiển thị popup/màn hình chứa ô nhập mã code và danh sách các Voucher khả dụng của Actor".
     * Code hiện tại: Backend hoàn toàn KHÔNG có bảng UserVoucher / Ví Voucher và không có endpoint GET /users/my-vouchers.
     */
    it.failing('[MISSING-FEATURE] UC09 - Main.1 - Lấy danh sách Voucher khả dụng trong ví của khách hàng -> Trả về danh sách voucher hợp lệ', async () => {
      // Code cần sửa: Tạo entity UserPromotion/UserVoucher và API GET /promotions/my-vouchers.
      const getMyVouchersMethod = (promotionService as any).getUserVouchers;
      expect(getMyVouchersMethod).toBeDefined();

      const vouchers = await getMyVouchersMethod.call(promotionService, 1);
      expect(Array.isArray(vouchers.data)).toBe(true);
    });

    it('UC09 - Main.3 - Response của PromotionService.checkPromotion trả về thông tin voucher (code, discountType, discountValue)', async () => {
      // Input: { code: 'SALE10', movieId: 1 }
      // Kiểm tra: Hàm checkPromotion nhận DTO gồm code và movieId (tùy chọn)
      const promo = createMockPromotion({
        code: 'SALE10',
        discountType: EDiscountType.PERCENTAGE,
        discountValue: 10,
        description: 'Giảm 10% tổng đơn',
      });
      mockPromotionRepo.findOne.mockResolvedValue(promo);

      const res = await promotionService.checkPromotion({ code: 'SALE10', movieId: 1 });

      expect(res.success).toBe(true);
      expect(res.data).toBeDefined();
      expect(res.data.code).toBe('SALE10');
      expect(res.data.discountType).toBe(EDiscountType.PERCENTAGE);
      expect(res.data.discountValue).toBe(10);
      // GHI NHẬN: Response hiện tại của checkPromotion KHÔNG trả về trường discountAmount (tiền giảm thực tế)
      expect((res.data as any).discountAmount).toBeUndefined();
    });

    it(
      '[BUG-09] UC09 - Main.3b - checkPromotion phải nhận orderTotal và trả về discountAmount đối chiếu khớp với createBooking',
      async () => {
        // ĐẶC TẢ UC09 Main.3-4: Khách nhập voucher trước khi thanh toán, hệ thống phải trả về số tiền được giảm
        // để hiển thị trực tiếp cho khách xem trước, và số tiền này PHẢI BẰNG số tiền giảm khi createBooking.
        // Kịch bản: Đơn 2 vé = 200.000đ, voucher SALE10 (10%).
        const promo = createMockPromotion({
          code: 'SALE10',
          discountType: EDiscountType.PERCENTAGE,
          discountValue: 10,
        });
        mockPromotionRepo.findOne.mockResolvedValue(promo);

        // 1. Tính số tiền giảm khi createBooking: 200.000 * 10% = 20.000đ
        await bookingService.createBooking(1, {
          showtimeId: 101,
          seatIds: [1, 2],
          promotionCode: 'SALE10',
        });
        const createdBookingCall = mockQueryRunner.manager.create.mock.calls.find(
          (c: any) => c[0] === Booking,
        );
        const bookingDiscountAmount = createdBookingCall[1].discountAmount; // 20.000đ

        // 2. Gọi checkPromotion với orderTotal = 200.000đ
        // HIỆN TẠI: CheckPromotionDto không có orderTotal và checkPromotion không trả discountAmount
        const checkRes = await (promotionService as any).checkPromotion({
          code: 'SALE10',
          movieId: 1,
          orderTotal: 200000,
        });

        // Đối chiếu: Số tiền giảm của checkPromotion PHẢI BẰNG số tiền giảm của createBooking
        expect(checkRes.data.discountAmount).toBeDefined();
        expect(checkRes.data.discountAmount).toBe(bookingDiscountAmount);
      },
    );

    it('UC09 - Main.4a - Áp dụng mã giảm theo số tiền cố định (FIXED_AMOUNT) -> Tính đúng discountAmount và trừ vào totalAmount', async () => {
      // Arrange: 2 vé 100.000đ = 200.000đ, voucher giảm cố định 30.000đ
      const fixedPromotion = createMockPromotion({
        code: 'GIAM30K',
        discountType: EDiscountType.FIXED_AMOUNT,
        discountValue: 30000,
        usedCount: 0,
      });
      mockPromotionRepo.findOne.mockResolvedValue(fixedPromotion);

      // Act
      const result = await bookingService.createBooking(1, {
        showtimeId: 101,
        seatIds: [1, 2],
        promotionCode: 'GIAM30K',
      });

      // Assert
      expect(result.success).toBe(true);
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({
          totalAmount: 170000, // 200.000 - 30.000 = 170.000đ
          discountAmount: 30000,
        }),
      );
    });

    it('UC09 - Main.4b - Áp dụng mã giảm theo phần trăm (PERCENTAGE) -> Tính đúng tỉ lệ giảm trên tổng tiền vé + bắp nước', async () => {
      // Arrange: 2 vé 100.000đ = 200.000đ, giảm 10% = 20.000đ
      const percentPromotion = createMockPromotion({
        code: 'SALE10PERCENT',
        discountType: EDiscountType.PERCENTAGE,
        discountValue: 10, // 10%
        usedCount: 1,
      });
      mockPromotionRepo.findOne.mockResolvedValue(percentPromotion);

      // Act
      const result = await bookingService.createBooking(1, {
        showtimeId: 101,
        seatIds: [1, 2],
        promotionCode: 'SALE10PERCENT',
      });

      // Assert
      expect(result.success).toBe(true);
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({
          totalAmount: 180000, // 200.000 - 20.000 (10%) = 180.000đ
          discountAmount: 20000,
        }),
      );
    });

    it('UC09 - Main.5 - Áp dụng voucher thành công -> Lưu promotionId vào Booking và tăng usedCount của Promotion lên 1', async () => {
      // Arrange
      const promo = createMockPromotion({ id: 77, code: 'COUNT_TEST', usedCount: 5 });
      mockPromotionRepo.findOne.mockResolvedValue(promo);

      // Act
      await bookingService.createBooking(1, {
        showtimeId: 101,
        seatIds: [1],
        promotionCode: 'COUNT_TEST',
      });

      // Assert: Gắn promotionId = 77 vào Booking
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({ promotionId: 77 }),
      );

      // Assert: Tăng usedCount bằng câu UPDATE atomic trong transaction
      expect(mockQueryRunner.manager.createQueryBuilder).toHaveBeenCalled();
    });

    it('UC09 - Main.Clamp - Giảm giá vượt quá tổng tiền đơn hàng -> Giữ totalAmount = 0 (không bị âm tiền)', async () => {
      // Arrange: 1 vé 100.000đ nhưng voucher giảm tới 150.000đ
      const bigPromotion = createMockPromotion({
        code: 'BIGDISCOUNT',
        discountType: EDiscountType.FIXED_AMOUNT,
        discountValue: 150000,
      });
      mockPromotionRepo.findOne.mockResolvedValue(bigPromotion);

      // Act
      const result = await bookingService.createBooking(1, {
        showtimeId: 101,
        seatIds: [1],
        promotionCode: 'BIGDISCOUNT',
      });

      // Assert: totalAmount = 0
      expect(result.success).toBe(true);
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({
          totalAmount: 0,
          discountAmount: 150000,
        }),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. ALTERNATE FLOW - HỦY / GỠ BỎ MÃ KHUYẾN MÃI (A2.1)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Alternate Flow - Hủy / Gỡ bỏ mã khuyến mãi (A2.1)', () => {
    it('UC09 - NoPromo - Không dùng voucher -> Đơn giữ nguyên giá gốc, discountAmount = 0', async () => {
      // Act
      const result = await bookingService.createBooking(1, {
        showtimeId: 101,
        seatIds: [1, 2],
        promotionCode: undefined, // Không dùng voucher
      });

      // Assert
      expect(result.success).toBe(true);
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({
          totalAmount: 200000,
          discountAmount: 0,
          promotionId: undefined,
        }),
      );
      expect(mockPromotionRepo.save).not.toHaveBeenCalled();
    });

    /**
     * [MISSING-FEATURE] UC09 - A2.1: Gỡ bỏ mã khuyến mãi đã áp dụng
     * Đặc tả UC09 A2.1: "Nếu trước đó Actor đã áp dụng một mã, Actor có thể nhấn 'Gỡ bỏ'.
     * Hệ thống hủy mã khỏi đơn hàng và tính lại tổng tiền về nguyên giá ban đầu."
     * Code hiện tại: Backend chỉ tính voucher 1 lần lúc createBooking, không có endpoint riêng gỡ voucher cho đơn PENDING.
     */
    it.failing('[MISSING-FEATURE][BUG-06] UC09 - A2.1 - Khách gỡ bỏ voucher khỏi đơn PENDING -> Hủy discount, khôi phục giá gốc và hoàn lại usedCount', async () => {
      // Code cần sửa: Thêm endpoint DELETE /bookings/:id/promotion để gỡ voucher và hoàn usedCount.
      const removePromoMethod = (bookingService as any).removePromotionFromBooking;
      expect(removePromoMethod).toBeDefined();

      await removePromoMethod.call(bookingService, 1, 100);
      expect(mockBookingRepo.update).toHaveBeenCalledWith(
        { id: 100 },
        expect.objectContaining({ promotionId: null, discountAmount: 0 }),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. EXCEPTION FLOW - MÃ KHÔNG HỢP LỆ, HẾT HẠN, HẾT LƯỢT, SAI ĐIỀU KIỆN (E4.1)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Exception Flow - Mã không hợp lệ, hết hạn, hết lượt, sai điều kiện (E4.1)', () => {
    describe('Đường 1: Xác thực qua PromotionService.checkPromotion', () => {
      it('UC09 - E4.1a - Mã khuyến mãi không tồn tại trong DB -> Từ chối với PROMOTION_NOT_FOUND (400)', async () => {
        // Arrange
        mockPromotionRepo.findOne.mockResolvedValue(null);

        // Act & Assert
        await expectCustomException(
          () => promotionService.checkPromotion({ code: 'KHONGTONTAI' }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_NOT_FOUND',
        );
      });

      // Code tại backend/src/module/promotion/promotion.service.ts dòng 92-94:
      // if (!promotion.isActive) throw new CustomException(HttpStatus.BAD_REQUEST, 'PROMOTION_INACTIVE', ...);
      it('UC09 - E4.1b - Mã khuyến mãi bị vô hiệu hóa (isActive = false) -> Từ chối với PROMOTION_INACTIVE (400)', async () => {
        // Arrange
        mockPromotionRepo.findOne.mockResolvedValue(createMockPromotion({ isActive: false }));

        // Act & Assert
        await expectCustomException(
          () => promotionService.checkPromotion({ code: 'INACTIVE_CODE' }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_INACTIVE',
        );
      });

      it('UC09 - E4.1c - Mã khuyến mãi đã hết hạn hoặc chưa bắt đầu -> Từ chối với PROMOTION_EXPIRED (400)', async () => {
        // Arrange: Hết hạn từ hôm qua
        const expiredPromo = createMockPromotion({
          startDate: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
          endDate: new Date(Date.now() - 24 * 60 * 60 * 1000),
        });
        mockPromotionRepo.findOne.mockResolvedValue(expiredPromo);

        // Act & Assert
        await expectCustomException(
          () => promotionService.checkPromotion({ code: 'EXPIRED_CODE' }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_EXPIRED',
        );
      });

      it('UC09 - E4.1d - Mã khuyến mãi đã hết lượt sử dụng (usedCount >= maxUsage) -> Từ chối với PROMOTION_MAX_USAGE (400)', async () => {
        // Arrange
        const outOfStockPromo = createMockPromotion({
          maxUsage: 10,
          usedCount: 10,
        });
        mockPromotionRepo.findOne.mockResolvedValue(outOfStockPromo);

        // Act & Assert
        await expectCustomException(
          () => promotionService.checkPromotion({ code: 'MAX_USAGE_CODE' }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_MAX_USAGE',
        );
      });

      it('UC09 - E4.1e - Mã khuyến mãi chỉ áp dụng cho phim A nhưng áp dụng cho phim B -> Từ chối với PROMOTION_MOVIE_MISMATCH (400)', async () => {
        // Arrange: Voucher chỉ cho phim ID = 99
        const moviePromo = createMockPromotion({
          movieId: 99,
        });
        mockPromotionRepo.findOne.mockResolvedValue(moviePromo);

        // Act & Assert (Khách đang đặt vé xem phim ID = 1)
        await expectCustomException(
          () => promotionService.checkPromotion({ code: 'MOVIE_SPECIFIC', movieId: 1 }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_MOVIE_MISMATCH',
        );
      });
    });

    describe('Đường 2: Xác thực lại qua BookingService.createBooking (Chốt đơn hàng)', () => {
      /**
       * [MISSING-FEATURE] UC09 - E4.1-Booking.NotFound: Mã không tồn tại khi chốt đơn
       * Code hiện tại: createBooking dòng 214-238 không ném lỗi nếu mã không tìm thấy, mà âm thầm bỏ qua và tính nguyên giá!
       */
      it('[BUG-05] UC09 - E4.1-Booking.NotFound - Gửi mã không tồn tại lúc createBooking -> Từ chối với PROMOTION_NOT_FOUND (400)', async () => {
        mockPromotionRepo.findOne.mockResolvedValue(null);

        await expectCustomException(
          () => bookingService.createBooking(1, { showtimeId: 101, seatIds: [1], promotionCode: 'INVALID_CODE' }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_NOT_FOUND',
        );
      });

      /**
       * UC09 - E4.1-Booking.Expired: Mã hết hạn khi chốt đơn
       * Code hiện tại: createBooking không ném lỗi nếu mã hết hạn, mà âm thầm tính nguyên giá!
       */
      it('[BUG-05] UC09 - E4.1-Booking.Expired - Gửi mã hết hạn lúc createBooking -> Từ chối với PROMOTION_EXPIRED (400)', async () => {
        const expiredPromo = createMockPromotion({
          code: 'EXP',
          startDate: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
          endDate: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
        });
        mockPromotionRepo.findOne.mockResolvedValue(expiredPromo);

        await expectCustomException(
          () => bookingService.createBooking(1, { showtimeId: 101, seatIds: [1], promotionCode: 'EXP' }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_EXPIRED',
        );
      });

      /**
       * UC09 - E4.1-Booking.MovieMismatch: Mã sai phim khi chốt đơn
       * Code hiện tại: createBooking dòng 214-238 HOÀN TOÀN KHÔNG SO SÁNH promotion.movieId với showtime.movieId!
       * Client có thể bỏ qua bước checkPromotion và áp mã giảm giá của phim khác vào đơn hàng!
       */
      it('[BUG-05] UC09 - E4.1-Booking.MovieMismatch - Gửi mã áp dụng cho phim khác lúc createBooking -> Từ chối với PROMOTION_MOVIE_MISMATCH (400)', async () => {
        const otherMoviePromo = createMockPromotion({
          code: 'OTHER_MOVIE',
          movieId: 999, // Phim khác
        });
        mockPromotionRepo.findOne.mockResolvedValue(otherMoviePromo);

        // Suất chiếu hiện tại là phim ID = 1
        mockShowtimeRepo.findOne.mockResolvedValue(createMockShowtime({ movieId: 1 }));

        await expectCustomException(
          () => bookingService.createBooking(1, { showtimeId: 101, seatIds: [1], promotionCode: 'OTHER_MOVIE' }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_MOVIE_MISMATCH',
        );
      });
    });

    describe('Điều kiện ràng buộc nâng cao (2D, VIP, Min Order)', () => {
      /**
       * [MISSING-FEATURE] UC09 - E4.1f: Điều kiện định dạng phòng chiếu (Chỉ áp dụng 2D, không dùng IMAX/3D)
       */
      it.failing('[MISSING-FEATURE] UC09 - E4.1f - Mã khuyến mãi chỉ áp dụng cho phòng 2D Standard nhưng khách xem phòng IMAX -> Từ chối với PROMOTION_FORMAT_NOT_ALLOWED (400)', async () => {
        const standardOnlyPromo = createMockPromotion({
          code: '2D_ONLY',
          applicableRoomTypes: ['STANDARD'],
        } as any);
        mockPromotionRepo.findOne.mockResolvedValue(standardOnlyPromo);

        mockShowtimeRepo.findOne.mockResolvedValue(
          createMockShowtime({ room: { roomType: 'IMAX' } as any }),
        );

        await expectCustomException(
          () => bookingService.createBooking(1, { showtimeId: 101, seatIds: [1], promotionCode: '2D_ONLY' }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_FORMAT_NOT_ALLOWED',
        );
      });

      /**
       * [MISSING-FEATURE] UC09 - E4.1g: Điều kiện loại ghế (Không áp dụng cho ghế VIP)
       */
      it.failing('[MISSING-FEATURE] UC09 - E4.1g - Mã khuyến mãi không áp dụng cho ghế VIP nhưng đơn hàng chọn toàn ghế VIP -> Từ chối với PROMOTION_SEAT_EXCLUDED (400)', async () => {
        const noVipPromo = createMockPromotion({
          code: 'NO_VIP',
          allowVipSeats: false,
        } as any);
        mockPromotionRepo.findOne.mockResolvedValue(noVipPromo);

        mockSeatRepo.find.mockResolvedValue([
          createMockSeat(1, 'F', 1, { seatType: 'VIP' } as any),
        ]);

        await expectCustomException(
          () => bookingService.createBooking(1, { showtimeId: 101, seatIds: [1], promotionCode: 'NO_VIP' }),
          HttpStatus.BAD_REQUEST,
          'PROMOTION_SEAT_EXCLUDED',
        );
      });

      /**
       * [MISSING-FEATURE] UC09 - E4.1h: Giá trị đơn hàng tối thiểu (minOrderValue)
       */
      it.failing('[MISSING-FEATURE] UC09 - E4.1h - Tổng tiền đơn hàng chưa đạt giá trị tối thiểu của voucher -> Từ chối với ORDER_BELOW_MIN_AMOUNT (400)', async () => {
        const minOrderPromo = createMockPromotion({
          code: 'MIN300K',
          minOrderValue: 300000,
        } as any);
        mockPromotionRepo.findOne.mockResolvedValue(minOrderPromo);

        await expectCustomException(
          () => bookingService.createBooking(1, { showtimeId: 101, seatIds: [1], promotionCode: 'MIN300K' }),
          HttpStatus.BAD_REQUEST,
          'ORDER_BELOW_MIN_AMOUNT',
        );
      });
    });
  });
});
