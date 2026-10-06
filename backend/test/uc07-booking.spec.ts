import { Test, TestingModule } from '@nestjs/testing';
import { HttpStatus } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { EventEmitter2 } from '@nestjs/event-emitter';

import { BookingService } from '../src/module/booking/booking.service';
import { BookingController } from '../src/module/booking/booking.controller';
import { JwtAuthGuard } from '../src/core/security/jwt/jwt-auth.guard';
import { Booking } from '../src/module/booking/entities/booking.entity';
import { SeatHold } from '../src/module/booking/entities/seat-hold.entity';
import { Seat } from '../src/module/cinema/entities/seat.entity';
import { TicketPrice } from '../src/module/ticket/entities/ticket-price.entity';
import { Showtime } from '../src/module/showtime/entities/showtime.entity';
import { ConcessionProduct } from '../src/module/concession/entities/concession-product.entity';
import { Promotion } from '../src/module/promotion/entities/promotion.entity';
import { User } from '../src/module/users/entities/user.entity';

import { RedisService } from '../src/module/redis/redis.service';
import { SeatGateway } from '../src/module/booking/seat.gateway';

import { EBookingStatus, ESeatHoldStatus, EBookingSource } from '../src/module/booking/enums/booking.enum';
import { CustomException } from '../src/core/exceptions/custom.exception';

import {
  createMockBooking,
  createMockUser,
  createMockShowtime,
  createMockSeat,
  createMockSeatHold,
  createMockTicketPrice,
  createMockQueryRunner,
} from './helpers/test-fixtures';

// Các mã lỗi đề xuất cho các tính năng chưa có trong mã nguồn (Missing Features)
export const PROPOSED_ERROR_CODES = {
  MAX_SEATS_EXCEEDED: 'MAX_SEATS_EXCEEDED',
  SEAT_ALREADY_BOOKED: 'SEAT_ALREADY_BOOKED',
  SEAT_ROOM_MISMATCH: 'SEAT_ROOM_MISMATCH',
  SHOWTIME_EXPIRED: 'SHOWTIME_EXPIRED',
};

describe('UC07 - Đặt vé trực tuyến (Online Ticket Booking & Realtime Seat Hold)', () => {
  let service: BookingService;

  // Mock Repositories
  let mockBookingRepo: any;
  let mockSeatHoldRepo: any;
  let mockSeatRepo: any;
  let mockTicketPriceRepo: any;
  let mockShowtimeRepo: any;
  let mockConcessionProductRepo: any;
  let mockPromotionRepo: any;
  let mockUserRepo: any;
  let mockDataSource: any;
  let mockQueryRunner: any;

  // Mock External Services
  let mockRedisService: any;
  let mockSeatGateway: any;
  let mockEventEmitter: any;

  // In-memory Redis simulation for seat locks
  let redisHoldMap: Map<string, number>;

  beforeEach(async () => {
    redisHoldMap = new Map();
    mockQueryRunner = createMockQueryRunner();

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
      create: jest.fn((dto) => ({ id: Math.floor(Math.random() * 1000) + 1, ...dto })),
      save: jest.fn((entity) => Promise.resolve({ id: 1, ...entity })),
      delete: jest.fn().mockResolvedValue({ affected: 1 }),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockSeatRepo = {
      find: jest.fn().mockImplementation(({ where }) => {
        const ids = where?.id?._value || [1, 2];
        return Promise.resolve(ids.map((id: number) => createMockSeat(id, 'F', id, { room: { roomType: 'IMAX' } as any })));
      }),
      findOne: jest.fn(),
    };

    mockTicketPriceRepo = {
      findOne: jest.fn().mockResolvedValue(createMockTicketPrice('IMAX', 'WEEKDAY', 100000)),
    };

    mockShowtimeRepo = {
      findOne: jest.fn().mockResolvedValue(createMockShowtime()),
    };

    mockConcessionProductRepo = {
      findOne: jest.fn(),
    };

    mockPromotionRepo = {
      findOne: jest.fn(),
      save: jest.fn((p) => Promise.resolve(p)),
    };

    mockUserRepo = {
      findOne: jest.fn().mockResolvedValue(createMockUser()),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockDataSource = {
      createQueryRunner: jest.fn().mockReturnValue(mockQueryRunner),
    };

    mockRedisService = {
      holdSeat: jest.fn().mockImplementation((showtimeId: number, seatId: number, userId: number) => {
        const key = `${showtimeId}:${seatId}`;
        if (redisHoldMap.has(key)) {
          return Promise.resolve(false); // Đã có người giữ
        }
        redisHoldMap.set(key, userId);
        return Promise.resolve(true);
      }),
      getSeatHolder: jest.fn().mockImplementation((showtimeId: number, seatId: number) => {
        const key = `${showtimeId}:${seatId}`;
        return Promise.resolve(redisHoldMap.get(key) || null);
      }),
      releaseSeats: jest.fn().mockImplementation((showtimeId: number, seatIds: number[]) => {
        for (const seatId of seatIds) {
          redisHoldMap.delete(`${showtimeId}:${seatId}`);
        }
        return Promise.resolve();
      }),
      releaseSeat: jest.fn().mockImplementation((showtimeId: number, seatId: number) => {
        redisHoldMap.delete(`${showtimeId}:${seatId}`);
        return Promise.resolve();
      }),
      getHeldSeatIds: jest.fn().mockImplementation((showtimeId: number) => {
        const held: number[] = [];
        for (const [key] of redisHoldMap.entries()) {
          const [stId, sId] = key.split(':');
          if (Number(stId) === showtimeId) held.push(Number(sId));
        }
        return Promise.resolve(held);
      }),
    };

    mockSeatGateway = {
      emitSeatUpdate: jest.fn(),
    };

    mockEventEmitter = {
      emit: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BookingService,
        { provide: getRepositoryToken(Booking), useValue: mockBookingRepo },
        { provide: getRepositoryToken(SeatHold), useValue: mockSeatHoldRepo },
        { provide: getRepositoryToken(Seat), useValue: mockSeatRepo },
        { provide: getRepositoryToken(TicketPrice), useValue: mockTicketPriceRepo },
        { provide: getRepositoryToken(Showtime), useValue: mockShowtimeRepo },
        { provide: getRepositoryToken(ConcessionProduct), useValue: mockConcessionProductRepo },
        { provide: getRepositoryToken(Promotion), useValue: mockPromotionRepo },
        { provide: getRepositoryToken(User), useValue: mockUserRepo },
        { provide: DataSource, useValue: mockDataSource },
        { provide: RedisService, useValue: mockRedisService },
        { provide: SeatGateway, useValue: mockSeatGateway },
        { provide: EventEmitter2, useValue: mockEventEmitter },
      ],
    }).compile();

    service = module.get<BookingService>(BookingService);
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
    it('UC07 - Pre.1 - Đăng nhập tài khoản: Endpoints hold-seats và createBooking được bảo vệ bởi JwtAuthGuard', () => {
      // Kiểm tra metadata Guard gắn trên BookingController
      const holdSeatsGuards = Reflect.getMetadata('__guards__', BookingController.prototype.holdSeats);
      const createBookingGuards = Reflect.getMetadata('__guards__', BookingController.prototype.createBooking);

      expect(holdSeatsGuards).toBeDefined();
      expect(holdSeatsGuards).toContain(JwtAuthGuard);

      expect(createBookingGuards).toBeDefined();
      expect(createBookingGuards).toContain(JwtAuthGuard);
    });

    it('UC07 - Pre.2a - Suất chiếu không tồn tại -> từ chối với SHOWTIME_NOT_FOUND (404)', async () => {
      // Arrange
      mockShowtimeRepo.findOne.mockResolvedValue(null);

      // Act & Assert
      await expectCustomException(
        () => service.holdSeats(1, { showtimeId: 9999, seatIds: [1, 2] }),
        HttpStatus.NOT_FOUND,
        'SHOWTIME_NOT_FOUND',
      );
    });

    it('UC07 - Pre.2b - Suất chiếu đã kết thúc (COMPLETED) -> từ chối với SHOWTIME_NOT_BOOKABLE (400)', async () => {
      // Arrange
      mockShowtimeRepo.findOne.mockResolvedValue(createMockShowtime({ status: 'COMPLETED' as any }));

      // Act & Assert
      await expectCustomException(
        () => service.holdSeats(1, { showtimeId: 101, seatIds: [1, 2] }),
        HttpStatus.BAD_REQUEST,
        'SHOWTIME_NOT_BOOKABLE',
      );
    });

    it('UC07 - Pre.2c - Suất chiếu bị hủy (CANCELLED) -> từ chối với SHOWTIME_NOT_BOOKABLE (400)', async () => {
      // Arrange
      mockShowtimeRepo.findOne.mockResolvedValue(createMockShowtime({ status: 'CANCELLED' as any }));

      // Act & Assert
      await expectCustomException(
        () => service.holdSeats(1, { showtimeId: 101, seatIds: [1, 2] }),
        HttpStatus.BAD_REQUEST,
        'SHOWTIME_NOT_BOOKABLE',
      );
    });

    /**
     * [MISSING-FEATURE] UC07 - Pre.2: Suất chiếu đã bắt đầu chiếu hoặc quá hạn
     * Đặc tả UC07: "Suất chiếu được chọn vẫn còn mở bán (chưa bắt đầu chiếu hoặc chưa hết hạn)".
     * Code hiện tại: Chỉ check showtime.status === 'COMPLETED' || showtime.status === 'CANCELLED',
     * KHÔNG so sánh publicStartTime với thời điểm hiện tại now.
     */
    it('UC07 - Pre.2 - Suất chiếu đã qua giờ bắt đầu chiếu (publicStartTime < now) nhưng status vẫn SCHEDULED -> từ chối đặt vé', async () => {
      // Code cần sửa: Trong holdSeats và createBooking, kiểm tra if (new Date(showtime.publicStartTime) <= new Date()) throw CustomException.
      const pastShowtime = createMockShowtime({
        publicStartTime: new Date(Date.now() - 30 * 60 * 1000), // Chiếu từ 30 phút trước
        status: 'SCHEDULED' as any,
      });
      mockShowtimeRepo.findOne.mockResolvedValue(pastShowtime);

      await expectCustomException(
        () => service.holdSeats(1, { showtimeId: 101, seatIds: [1, 2] }),
        HttpStatus.BAD_REQUEST,
        PROPOSED_ERROR_CODES.SHOWTIME_EXPIRED,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. MAIN FLOW - XEM SƠ ĐỒ GHẾ REALTIME (Step 1-2)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Main Flow - Xem sơ đồ ghế realtime (Step 1-2)', () => {
    it('UC07 - Main.1 - Lấy danh sách ghế đang giữ (Redis) và ghế đã bán (DB CONFIRMED) -> trả về allUnavailableSeatIds chính xác', async () => {
      // Arrange: Ghế 1 đang hold trong Redis; Ghế 2, 3 đã bán trong DB
      redisHoldMap.set('101:1', 99);
      mockSeatHoldRepo.find.mockResolvedValue([
        createMockSeatHold(2, 88, 10, { status: ESeatHoldStatus.CONFIRMED }),
        createMockSeatHold(3, 77, 11, { status: ESeatHoldStatus.CONFIRMED }),
      ]);

      // Act
      const result = await service.getBookedSeatsForShowtime(101);

      // Assert
      expect(result.success).toBe(true);
      expect(result.data.heldSeatIds).toEqual([1]);
      expect(result.data.bookedSeatIds).toEqual([2, 3]);
      expect(result.data.allUnavailableSeatIds).toEqual(expect.arrayContaining([1, 2, 3]));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. MAIN FLOW - CHỌN GHẾ & TẠM KHÓA GHẾ SEAT HOLD (Step 3-5)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Main Flow - Chọn ghế & Tạm khóa ghế Seat Hold (Step 3-5)', () => {
    it('UC07 - Main.3 - Giữ ghế thành công -> gọi Redis holdSeat với TTL 300s, lưu SeatHold HOLDING vào DB và broadcast Socket seat-update', async () => {
      // Arrange
      const dto = { showtimeId: 101, seatIds: [5, 6] };

      // Act
      const result = await service.holdSeats(1, dto);

      // Assert
      expect(result.success).toBe(true);
      expect(result.data.showtimeId).toBe(101);
      expect(result.data.seatIds).toEqual([5, 6]);
      expect(result.data.expiredAt).toBeDefined();

      // Kiểm tra gọi Redis holdSeat atomic với TTL 300s
      expect(mockRedisService.holdSeat).toHaveBeenCalledWith(101, 5, 1, 300);
      expect(mockRedisService.holdSeat).toHaveBeenCalledWith(101, 6, 1, 300);

      // Kiểm tra lưu DB
      expect(mockSeatHoldRepo.save).toHaveBeenCalledTimes(2);

      // Kiểm tra broadcast Socket realtime cho các client khác
      expect(mockSeatGateway.emitSeatUpdate).toHaveBeenCalledWith(
        101,
        expect.any(Array),
        expect.any(Array),
      );
    });

    it('UC07 - Main.5 - Tính tổng tiền vé chính xác theo loại phòng chiếu (IMAX) và loại ngày (WEEKDAY)', async () => {
      // Arrange: Đã hold ghế 1 và 2 trong Redis
      redisHoldMap.set('101:1', 1);
      redisHoldMap.set('101:2', 1);

      const bookingDto = {
        showtimeId: 101,
        seatIds: [1, 2],
      };

      // 100.000đ/vé x 2 = 200.000đ
      mockTicketPriceRepo.findOne.mockResolvedValue(createMockTicketPrice('IMAX', 'WEEKDAY', 100000));

      // Act
      const result = await service.createBooking(1, bookingDto);

      // Assert
      expect(result.success).toBe(true);
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({
          totalAmount: 200000,
          status: EBookingStatus.PENDING,
          source: EBookingSource.ONLINE,
        }),
      );
    });

    /**
     * [MISSING-FEATURE] UC07 - Main.5b: Giá vé phụ thuộc vào loại ghế (VIP / Thường / Đôi)
     * Đặc tả UC07: "Tính tổng tiền vé tạm tính = số vé × đơn giá tương ứng loại ghế/phòng/ngày".
     * Code hiện tại: Bảng ticket_prices chỉ có unique(roomType, dayType). Bảng seats không có cột seatType.
     * Giá vé hiện tại đồng nhất cho mọi ghế trong phòng, KHÔNG phân biệt ghế VIP / Regular.
     */
    it.failing('[MISSING-FEATURE] UC07 - Main.5b - Tính giá vé phụ thuộc vào loại ghế (Ghế VIP giá cao hơn ghế Thường) -> Hệ thống tính đúng đơn giá từng loại ghế', async () => {
      // Code cần sửa: Thêm cột seatType vào Seat, thêm seatType vào TicketPrice và tính giá vé theo cả seat.seatType.
      redisHoldMap.set('101:1', 1);
      redisHoldMap.set('101:2', 1);

      // Giả lập Ghế 1 là STANDARD (100k), Ghế 2 là VIP (120k)
      mockSeatRepo.find.mockResolvedValue([
        createMockSeat(1, 'F', 1, { seatType: 'STANDARD', room: { roomType: 'STANDARD' } } as any),
        createMockSeat(2, 'F', 2, { seatType: 'VIP', room: { roomType: 'STANDARD' } } as any),
      ]);

      const result = await service.createBooking(1, { showtimeId: 101, seatIds: [1, 2] });

      // Kỳ vọng tổng tiền = 100.000 + 120.000 = 220.000đ (thay vì 200.000đ do code chỉ query roomType)
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({ totalAmount: 220000 }),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. MAIN FLOW - TẠO ĐƠN HÀNG BOOKING (Step 6-10)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Main Flow - Tạo đơn hàng Booking (Step 6-10)', () => {
    it('UC07 - Main.6 - Tạo đơn đặt vé (createBooking) thành công -> sinh mã bookingCode BK-*, status PENDING, expiredAt 5 phút', async () => {
      // Arrange: Ghế 10, 11 đã được user 1 giữ trong Redis
      redisHoldMap.set('101:10', 1);
      redisHoldMap.set('101:11', 1);

      const dto = {
        showtimeId: 101,
        seatIds: [10, 11],
      };

      // Act
      const result = await service.createBooking(1, dto);

      // Assert
      expect(result.success).toBe(true);
      expect(mockQueryRunner.startTransaction).toHaveBeenCalled();
      expect(mockQueryRunner.commitTransaction).toHaveBeenCalled();
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({
          userId: 1,
          showtimeId: 101,
          bookingCode: expect.stringMatching(/^BK-[A-Z0-9]+-[A-Z0-9]+$/),
          status: EBookingStatus.PENDING,
        }),
      );

      // Ghế được liên kết với bookingId và chuyển status CONFIRMED (đã gắn vào đơn PENDING)
      expect(mockQueryRunner.manager.update).toHaveBeenCalledWith(
        SeatHold,
        expect.objectContaining({ showtimeId: 101, userId: 1 }),
        expect.objectContaining({ status: ESeatHoldStatus.CONFIRMED }),
      );

      // Socket broadcast cập nhật ghế
      expect(mockSeatGateway.emitSeatUpdate).toHaveBeenCalled();
    });

    it('UC07 - Main.6b - Tạo đơn đặt vé có sử dụng điểm tích lũy loyalty -> trừ điểm user ngay lập tức để chống double-spending', async () => {
      // Arrange: Khách muốn dùng 15.000 điểm
      redisHoldMap.set('101:1', 1);
      mockUserRepo.findOne.mockResolvedValue(createMockUser({ loyaltyPoints: 30000 }));

      const dto = {
        showtimeId: 101,
        seatIds: [1],
        pointsToUse: 15000,
      };

      // Act
      await service.createBooking(1, dto);

      // Assert: Trừ điểm ngay lập tức tại thời điểm tạo PENDING
      expect(mockUserRepo.update).toHaveBeenCalledWith(
        { id: 1 },
        expect.objectContaining({ loyaltyPoints: expect.any(Function) }),
      );
    });

    // CURRENT-BEHAVIOR: sẽ cần cập nhật nếu sửa luồng UC (UC-vs-CODE mismatch: đề xuất sửa UC)
    it('UC07 - Current-Behavior - createBooking chuyển SeatHold sang CONFIRMED và sơ đồ ghế hiển thị "booked" khi Booking còn PENDING', async () => {
      // Arrange: Ghế 1 đang do user 1 hold
      redisHoldMap.set('101:1', 1);

      // Act: Tạo booking (đơn PENDING)
      const result = await service.createBooking(1, { showtimeId: 101, seatIds: [1] });
      // console.log('DEBUG result:', result);

      // Assert 1: Đơn hàng mới tạo có bookingCode
      expect(result.success).toBe(true);
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({ status: EBookingStatus.PENDING }),
      );

      // Assert 2: Nhưng SeatHold trong DB đã được cập nhật thành CONFIRMED
      expect(mockQueryRunner.manager.update).toHaveBeenCalledWith(
        SeatHold,
        expect.objectContaining({ status: ESeatHoldStatus.HOLDING }),
        expect.objectContaining({ status: ESeatHoldStatus.CONFIRMED }),
      );

      // Assert 3: Sơ đồ ghế getBookedSeatsForShowtime coi ghế này là đã bán (booked) ngay cả khi chưa thanh toán
      mockSeatHoldRepo.find.mockResolvedValue([
        createMockSeatHold(1, 101, result.data?.id, { status: ESeatHoldStatus.CONFIRMED }),
      ]);
      const seatsResult = await service.getBookedSeatsForShowtime(101);
      expect(seatsResult.data.bookedSeatIds).toContain(1);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. ALTERNATE FLOW (HỦY CHỌN GHẾ & BỎ QUA DỊCH VỤ)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Alternate Flow (Hủy chọn ghế & Bỏ qua dịch vụ)', () => {
    /**
     * [MISSING-FEATURE] UC07 - A3.1: Hủy chọn ghế trên server
     * Đặc tả UC07: "Tại bước 3, Actor nhấn vào ghế đang chọn để hủy. Hệ thống bỏ khóa ghế đó và cập nhật lại tổng tiền."
     * Đề xuất REST endpoint: POST /bookings/release-seats (body: { showtimeId: number, seatIds: number[] })
     * Code hiện tại: BookingController KHÔNG có route release-seats để Client gọi nhả ghế real-time.
     */
    it('[BUG-14] UC07 - A3.1 - Khách hủy chọn ghế -> BookingController cung cấp endpoint POST /bookings/release-seats để nhả ghế tức thì', async () => {
      // Kiểm tra đề xuất route handler trên BookingController
      const releaseSeatsHandler = (BookingController.prototype as any).releaseSeats;
      expect(releaseSeatsHandler).toBeDefined();

      const controller = new BookingController(service);
      const res = await (controller as any).releaseSeats({ user: { id: 1 } }, { showtimeId: 101, seatIds: [9] });
      expect(res.success).toBe(true);
    });

    it('UC07 - A7.1/A8.1 - Bỏ qua bắp nước và voucher -> Đặt vé thành công với concessions rỗng, không giảm giá promotion', async () => {
      // Arrange
      redisHoldMap.set('101:1', 1);

      const dto = {
        showtimeId: 101,
        seatIds: [1],
        concessions: [], // Bỏ qua bắp nước
        promotionCode: undefined, // Bỏ qua voucher
      };

      // Act
      const result = await service.createBooking(1, dto);

      // Assert
      expect(result.success).toBe(true);
      expect(mockQueryRunner.manager.create).toHaveBeenCalledWith(
        Booking,
        expect.objectContaining({
          totalAmount: 100000,
          discountAmount: 0,
        }),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. EXCEPTION FLOW (RACE CONDITION, HẾT HẠN GIỮ GHẾ, VƯỢT QUÁ 8 GHẾ)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Exception Flow (Race Condition, Timeout, Quá 8 ghế)', () => {
    it('UC07 - E3.1a - Race condition khi hai khách cùng chọn một ghế (Redis SET NX) -> người thứ hai bị từ chối với SEAT_ALREADY_HELD (400)', async () => {
      // Arrange: Khách A (user 10) đã giữ ghế 5 trước đó vài mili-giây
      redisHoldMap.set('101:5', 10);

      // Khách B (user 20) gửi request giữ ghế 5
      const dto = { showtimeId: 101, seatIds: [5] };

      // Act & Assert
      await expectCustomException(
        () => service.holdSeats(20, dto),
        HttpStatus.BAD_REQUEST,
        'SEAT_ALREADY_HELD',
      );
    });

    it('UC07 - E3.1b - Chọn nhiều ghế mà có 1 ghế bị người khác giữ -> rollback toàn bộ các ghế đã giữ trước đó (atomic hold), ném SEAT_ALREADY_HELD (400)', async () => {
      // Arrange: Ghế 7 đang trống, nhưng ghế 8 đã bị user khác giữ
      redisHoldMap.set('101:8', 99);

      // User 1 cố giữ cả ghế 7 và 8
      const dto = { showtimeId: 101, seatIds: [7, 8] };

      // Act & Assert
      await expectCustomException(
        () => service.holdSeats(1, dto),
        HttpStatus.BAD_REQUEST,
        'SEAT_ALREADY_HELD',
      );

      // Khẳng định ghế 7 đã được rollback (nhả khỏi Redis), không bị chiếm dụng dở dang
      expect(redisHoldMap.has('101:7')).toBe(false);
      expect(mockRedisService.releaseSeats).toHaveBeenCalledWith(101, [7]);
    });

    it('UC07 - E5.1 - Hết thời gian giữ ghế (TTL Redis 300s hết hạn) -> getSeatHolder trả về null, createBooking từ chối với SEAT_NOT_HELD (400)', async () => {
      // Arrange: Ghế 1 đã hết hạn trong Redis (key bị expire mất)
      // redisHoldMap không có key 101:1 -> getSeatHolder trả về null
      const dto = { showtimeId: 101, seatIds: [1] };

      // Act & Assert
      await expectCustomException(
        () => service.createBooking(1, dto),
        HttpStatus.BAD_REQUEST,
        'SEAT_NOT_HELD',
      );
    });

    it('UC07 - E.SeatNotHeld - Cố tạo booking với ghế do người khác đang giữ -> từ chối với SEAT_NOT_HELD (400)', async () => {
      // Arrange: Ghế 1 đang do user 99 giữ
      redisHoldMap.set('101:1', 99);

      // User 1 cố tạo booking với ghế 1
      const dto = { showtimeId: 101, seatIds: [1] };

      // Act & Assert
      await expectCustomException(
        () => service.createBooking(1, dto),
        HttpStatus.BAD_REQUEST,
        'SEAT_NOT_HELD',
      );
    });

    /**
     * [MISSING-FEATURE] UC07 - E3.2: Giữ ghế đã ở trạng thái đã bán (SeatHold CONFIRMED)
     * Đặc tả UC07: Không được cho phép chọn hoặc giữ ghế đã bán.
     * Code hiện tại: BookingService.holdSeats chỉ check Redis holdSeat, KHÔNG check database xem ghế đã CONFIRMED hay chưa!
     * Hơn nữa, dòng 98 còn gọi seatHoldRepository.delete({ showtimeId, seatId }) làm mất bản ghi đã bán!
     */
    it('[BUG-01] UC07 - E3.2 - Khách cố giữ ghế đã ở trạng thái đã bán (SeatHold CONFIRMED) -> bị từ chối với SEAT_ALREADY_BOOKED (400)', async () => {
      // Code cần sửa: Trong holdSeats, truy vấn seatHoldRepository để kiểm tra status === ESeatHoldStatus.CONFIRMED trước khi gọi Redis hold.
      mockSeatHoldRepo.findOne.mockResolvedValue(
        createMockSeatHold(5, 101, 88, { status: ESeatHoldStatus.CONFIRMED }),
      );

      await expectCustomException(
        () => service.holdSeats(1, { showtimeId: 101, seatIds: [5] }),
        HttpStatus.BAD_REQUEST,
        PROPOSED_ERROR_CODES.SEAT_ALREADY_BOOKED,
      );
    });

    /**
     * [BUG-01] UC07 - E3.2b: Kiểm tra theo hành vi - holdSeats tuyệt đối không được xóa bản ghi SeatHold CONFIRMED
     * Kịch bản: Ghế 5 đã bán (SeatHold CONFIRMED trong DB), Redis key hết hạn 5 phút.
     * Người khác gọi holdSeats cho ghế 5 -> Code hiện tại dòng 98 gọi seatHoldRepository.delete làm mất vé đã bán!
     */
    it('[BUG-01] UC07 - E3.2b - holdSeats không được xóa bản ghi SeatHold CONFIRMED trong Database', async () => {
      // Arrange: Ghế 5 đã bán trong DB
      mockSeatHoldRepo.findOne.mockResolvedValue(
        createMockSeatHold(5, 101, 88, { status: ESeatHoldStatus.CONFIRMED }),
      );

      // Act: User 2 cố gọi holdSeats cho ghế 5
      try {
        await service.holdSeats(2, { showtimeId: 101, seatIds: [5] });
      } catch (e) {
        // Có thể ném lỗi hoặc không
      }

      // Assert theo hành vi: Tuyệt đối KHÔNG được gọi delete xóa ghế đã bán
      expect(mockSeatHoldRepo.delete).not.toHaveBeenCalledWith(
        expect.objectContaining({ seatId: 5 }),
      );
    });

    /**
     * [MISSING-FEATURE] UC07 - E3.3: Ghế không thuộc phòng chiếu của suất chiếu
     * Đặc tả UC07: Chỉ được phép chọn các ghế thuộc phòng chiếu của suất chiếu đã chọn.
     * Code hiện tại: holdSeats không truy vấn bảng seats để kiểm tra seat.roomId === showtime.roomId.
     */
    it('UC07 - E3.3 - Giữ ghế không thuộc phòng chiếu của suất đó -> từ chối với SEAT_ROOM_MISMATCH (400)', async () => {
      // Code cần sửa: Trong holdSeats, query seatRepository và validate seat.roomId === showtime.roomId.
      const showtime = createMockShowtime({ id: 101, roomId: 1 });
      mockShowtimeRepo.findOne.mockResolvedValue(showtime);

      // Ghế 99 thuộc roomId = 2 (khác phòng 1 của showtime)
      mockSeatRepo.find.mockResolvedValue([
        createMockSeat(99, 'A', 1, { roomId: 2 }),
      ]);

      await expectCustomException(
        () => service.holdSeats(1, { showtimeId: 101, seatIds: [99] }),
        HttpStatus.BAD_REQUEST,
        PROPOSED_ERROR_CODES.SEAT_ROOM_MISMATCH,
      );
    });

    /**
     * [MISSING-FEATURE][BUG-14] UC07 - E6.1: Vượt quá số lượng ghế quy định (tối đa 8 ghế)
     * Đặc tả UC07 E6.1: "Tại bước 6, nếu số ghế chọn vượt quá số lượng tối đa cho phép của 1 đơn (VD: 8 ghế),
     * hệ thống chặn và yêu cầu Actor giảm số lượng".
     * Code hiện tại: Backend HoldSeatsDto và holdSeats hoàn toàn KHÔNG kiểm tra độ dài mảng seatIds <= 8!
     */
    it('UC07 - E6.1 - Chọn vượt quá 8 ghế tối đa của 1 đơn hàng -> Backend từ chối với lỗi MAX_SEATS_EXCEEDED (400)', async () => {
      // Code cần sửa: Thêm validation @ArrayMaxSize(8) trong HoldSeatsDto và kiểm tra seatIds.length <= 8 trong BookingService.holdSeats.
      const dto = {
        showtimeId: 101,
        seatIds: [1, 2, 3, 4, 5, 6, 7, 8, 9], // 9 ghế
      };

      await expectCustomException(
        () => service.holdSeats(1, dto),
        HttpStatus.BAD_REQUEST,
        PROPOSED_ERROR_CODES.MAX_SEATS_EXCEEDED,
      );
    });
  });
});
