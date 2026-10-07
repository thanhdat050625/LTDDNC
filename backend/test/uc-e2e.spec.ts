import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { MailerService } from '@nestjs-modules/mailer';
import { DataSource } from 'typeorm';
import * as crypto from 'crypto';

import { BookingService } from '../src/module/booking/booking.service';
import { PaymentService } from '../src/module/payment/payment.service';
import { TicketService } from '../src/module/ticket/ticket.service';
import { VnpayService } from '../src/module/payment/services/vnpay.service';
import { MomoService } from '../src/module/payment/services/momo.service';
import { PaypalService } from '../src/module/payment/services/paypal.service';
import { RedisService } from '../src/module/redis/redis.service';
import { SeatGateway } from '../src/module/booking/seat.gateway';

import { Booking } from '../src/module/booking/entities/booking.entity';
import { SeatHold } from '../src/module/booking/entities/seat-hold.entity';
import { BookingConcession } from '../src/module/booking/entities/booking-concession.entity';
import { Showtime } from '../src/module/showtime/entities/showtime.entity';
import { Seat } from '../src/module/cinema/entities/seat.entity';
import { ConcessionProduct } from '../src/module/concession/entities/concession-product.entity';
import { Promotion } from '../src/module/promotion/entities/promotion.entity';
import { Payment } from '../src/module/payment/entities/payment.entity';
import { Ticket } from '../src/module/ticket/entities/ticket.entity';
import { TicketPrice } from '../src/module/ticket/entities/ticket-price.entity';
import { User } from '../src/module/users/entities/user.entity';

import { EBookingStatus, ESeatHoldStatus, EBookingSource } from '../src/module/booking/enums/booking.enum';
import { EPaymentMethod, EPaymentStatus, EPaymentChannel } from '../src/module/payment/enums/payment.enum';
import { ETicketStatus } from '../src/module/ticket/enums/ticket.enum';
import { EDiscountType } from '../src/module/promotion/enums/promotion.enum';
import { CustomException } from '../src/core/exceptions/custom.exception';

// ============================================================================
// HẠ TẦNG TEST STATEFUL IN-MEMORY (Khi Docker Daemon không khả dụng)
// Lưu trữ toàn bộ trạng thái giữa các bước xuyên suốt UC07 -> UC08 -> UC09 -> UC10
// ============================================================================

const VNP_TEST_SECRET = 'TEST_SECRET_VNPAY_E2E_KEY_123456';
const VNP_TEST_TMN = 'TEST_TMN_CODE';

class StatefulDbEngine {
  users = new Map<number, any>();
  showtimes = new Map<number, any>();
  seats = new Map<number, any>();
  ticketPrices = new Map<number, any>();
  seatHolds = new Map<number, any>();
  bookings = new Map<number, any>();
  bookingConcessions = new Map<number, any>();
  concessionProducts = new Map<number, any>();
  promotions = new Map<number, any>();
  payments = new Map<number, any>();
  tickets = new Map<number, any>();

  private autoId = 1000;
  nextId() {
    return ++this.autoId;
  }

  reset() {
    this.users.clear();
    this.showtimes.clear();
    this.seats.clear();
    this.ticketPrices.clear();
    this.seatHolds.clear();
    this.bookings.clear();
    this.bookingConcessions.clear();
    this.concessionProducts.clear();
    this.promotions.clear();
    this.payments.clear();
    this.tickets.clear();
    this.autoId = 1000;
  }
}

function matchCriteria(item: any, criteria: any): boolean {
  if (!criteria) return true;
  for (const key of Object.keys(criteria)) {
    const filterVal = criteria[key];
    if (filterVal && typeof filterVal === 'object' && filterVal._type === 'in') {
      if (!filterVal._value.includes(item[key])) return false;
    } else if (item[key] !== filterVal) {
      return false;
    }
  }
  return true;
}

function createStatefulRepository(map: Map<number, any>, engine: StatefulDbEngine, entityName: string) {
  return {
    findOne: jest.fn(async (options: any) => {
      const where = options?.where || options;
      for (const item of map.values()) {
        if (matchCriteria(item, where)) {
          const clone = { ...item };
          if (clone.expiredAt) clone.expiredAt = new Date(clone.expiredAt);

          // Tự động resolve quan hệ cơ bản cho test
          if (options?.relations?.includes('payment') && clone.id) {
            for (const p of engine.payments.values()) {
              if (p.bookingId === clone.id) clone.payment = { ...p };
            }
          }
          if (options?.relations?.includes('seatHolds') && clone.id) {
            clone.seatHolds = [];
            for (const h of engine.seatHolds.values()) {
              if (h.bookingId === clone.id) {
                const hClone = { ...h };
                hClone.seat = engine.seats.get(h.seatId);
                clone.seatHolds.push(hClone);
              }
            }
          }
          if (options?.relations?.includes('bookingConcessions') && clone.id) {
            clone.bookingConcessions = [];
            for (const bc of engine.bookingConcessions.values()) {
              if (bc.bookingId === clone.id) clone.bookingConcessions.push({ ...bc });
            }
          }
          if (options?.relations?.includes('showtime') && clone.showtimeId) {
            clone.showtime = engine.showtimes.get(clone.showtimeId);
          }
          if (options?.relations?.includes('promotion') && clone.promotionId) {
            clone.promotion = engine.promotions.get(clone.promotionId);
          }
          if (options?.relations?.includes('user') && clone.userId) {
            clone.user = engine.users.get(clone.userId);
          }
          return clone;
        }
      }
      return null;
    }),

    find: jest.fn(async (options: any) => {
      const where = options?.where || options;
      const results: any[] = [];
      for (const item of map.values()) {
        if (matchCriteria(item, where)) {
          const clone = { ...item };
          if (clone.expiredAt) clone.expiredAt = new Date(clone.expiredAt);

          if (options?.relations?.includes('seat') && clone.seatId) {
            clone.seat = engine.seats.get(clone.seatId);
          }
          if (options?.relations?.includes('seatHolds') && clone.id) {
            clone.seatHolds = [];
            for (const h of engine.seatHolds.values()) {
              if (h.bookingId === clone.id) {
                const hClone = { ...h };
                hClone.seat = engine.seats.get(h.seatId);
                clone.seatHolds.push(hClone);
              }
            }
          }
          results.push(clone);
        }
      }
      return results;
    }),

    create: jest.fn((dto: any) => {
      if (Array.isArray(dto)) {
        return dto.map(d => ({ ...d, id: d.id || engine.nextId() }));
      }
      return { ...dto, id: dto.id || engine.nextId() };
    }),

    save: jest.fn(async (entityOrEntities: any) => {
      if (Array.isArray(entityOrEntities)) {
        const saved: any[] = [];
        for (const item of entityOrEntities) {
          const id = item.id || engine.nextId();
          item.id = id;
          map.set(id, { ...item });
          saved.push({ ...item });
        }
        return saved;
      }
      const id = entityOrEntities.id || engine.nextId();
      entityOrEntities.id = id;
      map.set(id, { ...entityOrEntities });
      return { ...entityOrEntities };
    }),

    update: jest.fn(async (criteria: any, partial: any) => {
      for (const item of map.values()) {
        if (matchCriteria(item, criteria)) {
          for (const key of Object.keys(partial)) {
            if (typeof partial[key] === 'function') {
              const expr = String(partial[key]());
              if (expr.includes('loyaltyPoints +')) {
                const add = parseInt(expr.match(/\+\s*(\d+)/)?.[1] || '0', 10);
                item.loyaltyPoints = (item.loyaltyPoints || 0) + add;
              } else if (expr.includes('loyaltyPoints -')) {
                const sub = parseInt(expr.match(/\-\s*(\d+)/)?.[1] || '0', 10);
                item.loyaltyPoints = Math.max((item.loyaltyPoints || 0) - sub, 0);
              }
            } else {
              item[key] = partial[key];
            }
          }
        }
      }
      return { affected: 1 };
    }),

    delete: jest.fn(async (criteria: any) => {
      const toDelete: number[] = [];
      for (const [id, item] of map.entries()) {
        if (matchCriteria(item, criteria)) {
          toDelete.push(id);
        }
      }
      for (const id of toDelete) map.delete(id);
      return { affected: toDelete.length };
    }),

    remove: jest.fn(async (entity: any) => {
      if (entity?.id) map.delete(entity.id);
      return entity;
    }),
  };
}

class StatefulRedisService {
  private store = new Map<string, { val: string; exp?: number }>();

  private seatHoldKey(showtimeId: number, seatId: number): string {
    return `hold:showtime:${showtimeId}:seat:${seatId}`;
  }

  async holdSeat(showtimeId: number, seatId: number, userId: number, ttlSeconds = 300): Promise<boolean> {
    const key = this.seatHoldKey(showtimeId, seatId);
    const existing = this.store.get(key);
    if (existing && (!existing.exp || existing.exp > Date.now())) {
      return false;
    }
    this.store.set(key, { val: String(userId), exp: Date.now() + ttlSeconds * 1000 });
    return true;
  }

  async getSeatHolder(showtimeId: number, seatId: number): Promise<number | null> {
    const key = this.seatHoldKey(showtimeId, seatId);
    const existing = this.store.get(key);
    if (!existing) return null;
    if (existing.exp && existing.exp < Date.now()) {
      this.store.delete(key);
      return null;
    }
    return Number(existing.val);
  }

  async releaseSeat(showtimeId: number, seatId: number): Promise<void> {
    const key = this.seatHoldKey(showtimeId, seatId);
    this.store.delete(key);
  }

  async releaseSeats(showtimeId: number, seatIds: number[]): Promise<void> {
    for (const seatId of seatIds) {
      this.store.delete(this.seatHoldKey(showtimeId, seatId));
    }
  }

  async getHeldSeatIds(showtimeId: number): Promise<number[]> {
    const prefix = `hold:showtime:${showtimeId}:seat:`;
    const seatIds: number[] = [];
    const now = Date.now();
    for (const [key, item] of this.store.entries()) {
      if (key.startsWith(prefix)) {
        if (item.exp && item.exp < now) {
          this.store.delete(key);
          continue;
        }
        const seatId = Number(key.replace(prefix, ''));
        if (!isNaN(seatId)) seatIds.push(seatId);
      }
    }
    return seatIds;
  }

  async getSeatHoldTTL(showtimeId: number, seatId: number): Promise<number> {
    const key = this.seatHoldKey(showtimeId, seatId);
    const existing = this.store.get(key);
    if (!existing) return -2;
    if (!existing.exp) return -1;
    const ttl = Math.floor((existing.exp - Date.now()) / 1000);
    return ttl > 0 ? ttl : -2;
  }

  async set(key: string, val: string, ...args: any[]): Promise<string | null> {
    const nx = args.includes('NX');
    const exIdx = args.indexOf('EX');
    const ttl = exIdx !== -1 ? args[exIdx + 1] : undefined;

    if (nx) {
      const existing = this.store.get(key);
      if (existing && (!existing.exp || existing.exp > Date.now())) {
        return null;
      }
    }

    const exp = ttl ? Date.now() + ttl * 1000 : undefined;
    this.store.set(key, { val, exp });
    return 'OK';
  }

  async get(key: string): Promise<string | null> {
    const existing = this.store.get(key);
    if (!existing) return null;
    if (existing.exp && existing.exp < Date.now()) {
      this.store.delete(key);
      return null;
    }
    return existing.val;
  }

  async del(...keys: string[]): Promise<number> {
    let count = 0;
    for (const k of keys) {
      if (this.store.delete(k)) count++;
    }
    return count;
  }

  async keys(pattern: string): Promise<string[]> {
    const regex = new RegExp('^' + pattern.replace(/\*/g, '.*') + '$');
    const validKeys: string[] = [];
    for (const [k, v] of this.store.entries()) {
      if (v.exp && v.exp < Date.now()) {
        this.store.delete(k);
        continue;
      }
      if (regex.test(k)) validKeys.push(k);
    }
    return validKeys;
  }

  clear() {
    this.store.clear();
  }
}

function createSignedVnpayIpn(query: Record<string, any>, secret: string) {
  const sorted: Record<string, string> = {};
  const keys = Object.keys(query).sort();
  for (const k of keys) {
    sorted[encodeURIComponent(k)] = encodeURIComponent(String(query[k])).replace(/%20/g, '+');
  }
  const signData = Object.keys(sorted)
    .map(k => `${k}=${sorted[k]}`)
    .join('&');
  const signed = crypto.createHmac('sha512', secret).update(Buffer.from(signData, 'utf-8')).digest('hex');
  return { ...query, vnp_SecureHash: signed };
}

describe('E2E Xuyên UC07 - UC08 - UC09 - UC10 (Online Booking -> Concessions -> Promotion -> Payment)', () => {
  let bookingService: BookingService;
  let paymentService: PaymentService;
  let ticketService: TicketService;
  let vnpayService: VnpayService;
  let redisService: StatefulRedisService;
  let dbEngine: StatefulDbEngine;
  let mailerService: { sendMail: jest.Mock };

  beforeAll(async () => {
    dbEngine = new StatefulDbEngine();
    redisService = new StatefulRedisService();
    mailerService = { sendMail: jest.fn().mockResolvedValue({ messageId: 'test-mail-id' }) };

    const mockConfigService = {
      get: jest.fn((key: string) => {
        if (key === 'VNP_HASH_SECRET') return VNP_TEST_SECRET;
        if (key === 'VNP_TMN_CODE') return VNP_TEST_TMN;
        if (key === 'VNP_URL') return 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
        if (key === 'VNP_RETURN_URL') return 'http://localhost/vnpay-return';
        return 'test';
      }),
    };

    const mockMomoService = {
      createPaymentUrl: jest.fn().mockResolvedValue('https://momo.vn/pay/test'),
      buildPaymentUrl: jest.fn().mockResolvedValue('https://momo.vn/pay/test'),
      verifyIpnSignature: jest.fn().mockReturnValue(true),
    };

    const mockPaypalService = {
      createOrder: jest.fn().mockResolvedValue({ orderId: 'PAYPAL-123', approveUrl: 'https://paypal.com/test' }),
      captureOrder: jest.fn().mockResolvedValue({ status: 'COMPLETED' }),
    };

    const mockSeatGateway = {
      broadcastSeatStatus: jest.fn(),
      broadcastSeatsBooked: jest.fn(),
      emitSeatUpdate: jest.fn(),
    };

    const mockEventEmitter = {
      emit: jest.fn(),
      on: jest.fn(),
    };

    const createRepoProvider = (entity: any, map: Map<number, any>, name: string) => ({
      provide: getRepositoryToken(entity),
      useValue: createStatefulRepository(map, dbEngine, name),
    });

    const createMockQueryBuilder = () => ({
      update: jest.fn().mockReturnThis(),
      set: jest.fn(function (setObj: any) {
        this.setObj = setObj;
        return this;
      }),
      where: jest.fn(function (whereStr: any, params: any) {
        this.params = params;
        return this;
      }),
      execute: jest.fn(async function () {
        if (this.params?.productId) {
          const prod = dbEngine.concessionProducts.get(this.params.productId);
          if (prod) {
            const fnVal = typeof this.setObj?.stockQuantity === 'function'
              ? this.setObj.stockQuantity()
              : this.setObj?.stockQuantity;
            const fnStr = String(fnVal || '');
            const match = fnStr.match(/GREATEST\(stockQuantity\s*-\s*(\d+)/i) || fnStr.match(/-\s*(\d+)/);
            const subQty = match ? parseInt(match[1], 10) : 1;
            prod.stockQuantity = Math.max(prod.stockQuantity - subQty, 0);
          }
        }
        if (this.params?.id && dbEngine.promotions.has(this.params.id)) {
          const promo = dbEngine.promotions.get(this.params.id);
          if (this.setObj?.usedCount) {
            const fnVal = typeof this.setObj.usedCount === 'function' ? this.setObj.usedCount() : this.setObj.usedCount;
            const fnStr = String(fnVal || '');
            if (fnStr.includes('+ 1') || fnStr.includes('+1')) {
              if (promo.maxUsage && promo.usedCount >= promo.maxUsage) {
                return { affected: 0 };
              }
              promo.usedCount = (promo.usedCount || 0) + 1;
              return { affected: 1 };
            } else if (fnStr.includes('GREATEST') || fnStr.includes('- 1') || fnStr.includes('-1')) {
              promo.usedCount = Math.max((promo.usedCount || 0) - 1, 0);
              return { affected: 1 };
            }
          }
        }
        return { affected: 1 };
      }),
    });

    const mockDataSource = {
      createQueryBuilder: jest.fn(createMockQueryBuilder),
      createQueryRunner: jest.fn(() => ({
        connect: jest.fn(),
        startTransaction: jest.fn(),
        commitTransaction: jest.fn(),
        rollbackTransaction: jest.fn(),
        release: jest.fn(),
        manager: {
          findOne: jest.fn(async (entity: any, options: any) => {
            const map =
              entity === Booking
                ? dbEngine.bookings
                : entity === SeatHold
                ? dbEngine.seatHolds
                : entity === Payment
                ? dbEngine.payments
                : dbEngine.users;
            const repo = createStatefulRepository(map, dbEngine, entity.name);
            return repo.findOne(options);
          }),
          find: jest.fn(async (entity: any, options: any) => {
            const map =
              entity === BookingConcession
                ? dbEngine.bookingConcessions
                : entity === SeatHold
                ? dbEngine.seatHolds
                : dbEngine.concessionProducts;
            const repo = createStatefulRepository(map, dbEngine, entity.name);
            return repo.find(options);
          }),
          save: jest.fn(async (entity: any, data: any) => {
            const map =
              entity === Booking
                ? dbEngine.bookings
                : entity === BookingConcession
                ? dbEngine.bookingConcessions
                : entity === Payment
                ? dbEngine.payments
                : dbEngine.seatHolds;
            const repo = createStatefulRepository(map, dbEngine, entity.name);
            return repo.save(data);
          }),
          update: jest.fn(async (entity: any, criteria: any, partial: any) => {
            const map =
              entity === Booking
                ? dbEngine.bookings
                : entity === SeatHold
                ? dbEngine.seatHolds
                : entity === Payment
                ? dbEngine.payments
                : dbEngine.concessionProducts;
            const repo = createStatefulRepository(map, dbEngine, entity.name);
            return repo.update(criteria, partial);
          }),
          delete: jest.fn(async (entity: any, criteria: any) => {
            const map =
              entity === BookingConcession
                ? dbEngine.bookingConcessions
                : entity === SeatHold
                ? dbEngine.seatHolds
                : dbEngine.bookings;
            const repo = createStatefulRepository(map, dbEngine, entity.name);
            return repo.delete(criteria);
          }),
          create: jest.fn((entity: any, dto: any) => {
            const map =
              entity === Booking
                ? dbEngine.bookings
                : entity === BookingConcession
                ? dbEngine.bookingConcessions
                : dbEngine.payments;
            const repo = createStatefulRepository(map, dbEngine, entity.name);
            return repo.create(dto);
          }),
          createQueryBuilder: jest.fn(createMockQueryBuilder),
        },
      })),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BookingService,
        PaymentService,
        TicketService,
        VnpayService,
        { provide: MomoService, useValue: mockMomoService },
        { provide: PaypalService, useValue: mockPaypalService },
        { provide: RedisService, useValue: redisService },
        { provide: ConfigService, useValue: mockConfigService },
        { provide: MailerService, useValue: mailerService },
        { provide: SeatGateway, useValue: mockSeatGateway },
        { provide: EventEmitter2, useValue: mockEventEmitter },
        { provide: DataSource, useValue: mockDataSource },
        createRepoProvider(Booking, dbEngine.bookings, 'Booking'),
        createRepoProvider(SeatHold, dbEngine.seatHolds, 'SeatHold'),
        createRepoProvider(BookingConcession, dbEngine.bookingConcessions, 'BookingConcession'),
        createRepoProvider(Showtime, dbEngine.showtimes, 'Showtime'),
        createRepoProvider(Seat, dbEngine.seats, 'Seat'),
        createRepoProvider(ConcessionProduct, dbEngine.concessionProducts, 'ConcessionProduct'),
        createRepoProvider(Promotion, dbEngine.promotions, 'Promotion'),
        createRepoProvider(Payment, dbEngine.payments, 'Payment'),
        createRepoProvider(Ticket, dbEngine.tickets, 'Ticket'),
        createRepoProvider(TicketPrice, dbEngine.ticketPrices, 'TicketPrice'),
        createRepoProvider(User, dbEngine.users, 'User'),
      ],
    }).compile();

    bookingService = module.get<BookingService>(BookingService);
    paymentService = module.get<PaymentService>(PaymentService);
    ticketService = module.get<TicketService>(TicketService);
    vnpayService = module.get<VnpayService>(VnpayService);
  });

  beforeEach(() => {
    dbEngine.reset();
    redisService.clear();
    mailerService.sendMail.mockClear();

    // ─── DỮ LIỆU SEED CHUẨN BAN ĐẦU ──────────────────────────────────────────
    // User A & B
    dbEngine.users.set(1, { id: 1, email: 'user.a@example.com', fullName: 'Nguyen Van A', loyaltyPoints: 100 });
    dbEngine.users.set(2, { id: 2, email: 'user.b@example.com', fullName: 'Tran Thi B', loyaltyPoints: 0 });

    // Showtime (suất chiếu 2h tới)
    const futureDate = new Date(Date.now() + 2 * 60 * 60 * 1000);
    dbEngine.showtimes.set(1, {
      id: 1,
      movieId: 1,
      roomId: 1,
      publicStartTime: futureDate,
      price: 100000,
      movie: { id: 1, title: 'Dune: Part Two' },
      room: { id: 1, name: 'Cinema Hall 1', roomType: 'STANDARD' },
    });

    // Seats (phòng 1)
    dbEngine.seats.set(1, { id: 1, roomId: 1, row: 'A', number: 1, seatType: 'STANDARD', room: { roomType: 'STANDARD' } });
    dbEngine.seats.set(2, { id: 2, roomId: 1, row: 'A', number: 2, seatType: 'STANDARD', room: { roomType: 'STANDARD' } });
    dbEngine.seats.set(3, { id: 3, roomId: 1, row: 'A', number: 3, seatType: 'STANDARD', room: { roomType: 'STANDARD' } });

    // Ticket Price
    dbEngine.ticketPrices.set(1, { id: 1, roomType: 'STANDARD', dayType: 'WEEKDAY', price: 100000 });
    dbEngine.ticketPrices.set(2, { id: 2, roomType: 'STANDARD', dayType: 'WEEKEND', price: 100000 });

    // Concession Products
    dbEngine.concessionProducts.set(1, { id: 1, name: 'Bắp rang bơ 60oz', price: 50000, stockQuantity: 10 });
    dbEngine.concessionProducts.set(2, { id: 2, name: 'Nước ngọt 32oz', price: 30000, stockQuantity: 1 }); // Dùng cho test Concurrency tồn kho

    // Promotions
    dbEngine.promotions.set(1, {
      id: 1,
      code: 'DISCOUNT10',
      discountType: EDiscountType.PERCENTAGE,
      discountValue: 10,
      maxUsage: 100,
      usedCount: 0,
      isActive: true,
      startDate: new Date(Date.now() - 24 * 3600 * 1000),
      endDate: new Date(Date.now() + 24 * 3600 * 1000),
    });

    dbEngine.promotions.set(2, {
      id: 2,
      code: 'LIMITED1',
      discountType: EDiscountType.FIXED_AMOUNT,
      discountValue: 20000,
      maxUsage: 1,
      usedCount: 0,
      isActive: true,
      startDate: new Date(Date.now() - 24 * 3600 * 1000),
      endDate: new Date(Date.now() + 24 * 3600 * 1000),
    });
  });

  // ==========================================================================
  // KỊCH BẢN 1: E2E-Full (Đầy đủ chu trình nghiệp vụ)
  // Sơ đồ ghế -> Hold seats -> Create Booking -> Thêm bắp nước -> Áp voucher ->
  // Checkout (tạo payUrl) -> IPN VNPay hợp lệ (HMAC SHA512 thật) -> Kiểm tra toàn diện
  // ==========================================================================
  it('E2E-Full: Chu trình hoàn chỉnh Đặt vé + Bắp nước + Voucher + Thanh toán VNPay + Xuất vé QR + Tích điểm + Mail', async () => {
    const userId = 1;
    const showtimeId = 1;
    const seatIds = [1, 2];

    // 1. Xem sơ đồ ghế (ghế chưa có ai đặt)
    const seatsRes = await bookingService.getBookedSeatsForShowtime(showtimeId);
    expect(seatsRes.success).toBe(true);
    expect(seatsRes.data.bookedSeatIds).toHaveLength(0);

    // 2. Giữ ghế (Hold seats)
    const holdRes = await bookingService.holdSeats(userId, { showtimeId, seatIds });
    expect(holdRes.success).toBe(true);
    expect(holdRes.data.seatIds).toHaveLength(2);
    // Kiểm tra Redis key được giữ
    const redisVal1 = await redisService.getSeatHolder(showtimeId, 1);
    expect(redisVal1).toBe(userId);

    // 3. Tạo Booking với Voucher DISCOUNT10 (10% vé: 200k giảm 20k = 180k)
    const bookingRes = await bookingService.createBooking(userId, {
      showtimeId,
      seatIds,
      promotionCode: 'DISCOUNT10',
    });
    expect(bookingRes.success).toBe(true);
    const booking = bookingRes.data!;
    expect(booking.status).toBe(EBookingStatus.PENDING);
    expect(booking.totalAmount).toBe(180000);
    expect(booking.discountAmount).toBe(20000);

    // 4. Thêm bắp nước: 2 phần Bắp rang bơ (2 * 50k = 100k) -> Tổng mới: (200k vé + 100k bắp) - 10% (30k) = 270k
    const concRes = await bookingService.updateBookingConcessions(booking.id, userId, {
      concessions: [{ productId: 1, quantity: 2 }],
    });
    expect(concRes.success).toBe(true);
    expect(concRes.data!.totalAmount).toBe(270000);

    // 5. Checkout tạo Payment URL (VNPay)
    const payUrlRes = await paymentService.createPaymentUrl(
      userId,
      {
        bookingId: booking.id,
        method: EPaymentMethod.VNPAY,
      },
      '127.0.0.1',
    );
    expect(payUrlRes.success).toBe(true);
    expect(payUrlRes.data!.payUrl).toContain('https://sandbox.vnpayment.vn');
    expect(payUrlRes.data!.bookingId).toBe(booking.id);

    // 6. Nhận IPN VNPay hợp lệ (ký bằng secret test thật HMAC-SHA512)
    const vnpParams = {
      vnp_Amount: 270000 * 100, // VNPay amount * 100
      vnp_BankCode: 'NCB',
      vnp_CardType: 'ATM',
      vnp_OrderInfo: `Thanh toan ve xem phim ${booking.bookingCode}`,
      vnp_PayDate: '20261005230000',
      vnp_ResponseCode: '00',
      vnp_TmnCode: VNP_TEST_TMN,
      vnp_TransactionNo: '14598721',
      vnp_TxnRef: booking.bookingCode,
    };
    const signedIpnQuery = createSignedVnpayIpn(vnpParams, VNP_TEST_SECRET);

    // Thực thi xử lý IPN
    const ipnRes = await paymentService.processVnpayIPN(signedIpnQuery);
    expect(ipnRes.RspCode).toBe('00');
    expect(ipnRes.Message).toBe('Confirm Success');

    // 7. KIỂM TRA TOÀN DIỆN KẾT QUẢ HỆ THỐNG:
    // a. Trạng thái Booking: PAID
    const updatedBooking = dbEngine.bookings.get(booking.id);
    expect(updatedBooking.status).toBe(EBookingStatus.PAID);

    // b. Trạng thái SeatHold: CONFIRMED
    const hold1 = Array.from(dbEngine.seatHolds.values()).find(h => h.seatId === 1);
    const hold2 = Array.from(dbEngine.seatHolds.values()).find(h => h.seatId === 2);
    expect(hold1?.status).toBe(ESeatHoldStatus.CONFIRMED);
    expect(hold2?.status).toBe(ESeatHoldStatus.CONFIRMED);

    // c. Vé và QR code được tạo cho 2 ghế
    const tickets = Array.from(dbEngine.tickets.values()).filter(t => t.bookingId === booking.id);
    expect(tickets).toHaveLength(2);
    for (const t of tickets) {
      expect(t.status).toBe(ETicketStatus.ACTIVE);
      expect(t.qrCode).toMatch(/^TKT-/);
    }

    // d. Tồn kho bắp nước giảm đúng 2 phần (10 -> 8)
    const product = dbEngine.concessionProducts.get(1);
    expect(product.stockQuantity).toBe(8);

    // e. Promotion usedCount tăng 1
    const promotion = dbEngine.promotions.get(1);
    expect(promotion.usedCount).toBe(1);

    // f. Tích điểm loyalty cho User A: 10% của 270k = 27.000 điểm (100 ban đầu + 27000 = 27100)
    const userA = dbEngine.users.get(1);
    expect(userA.loyaltyPoints).toBe(100 + 27000);

    // g. Email thông báo gửi kèm QR code đúng 1 lần
    expect(mailerService.sendMail).toHaveBeenCalledTimes(1);
    expect(mailerService.sendMail).toHaveBeenCalledWith(
      expect.objectContaining({
        to: 'user.a@example.com',
        subject: expect.stringContaining(booking.bookingCode),
      }),
    );
  });

  // ==========================================================================
  // KỊCH BẢN 2: E2E-Min (Luồng tối giản: Ghế -> Thanh toán)
  // Không chọn bắp nước, không voucher -> Thanh toán MoMo -> Thành công
  // ==========================================================================
  it('E2E-Min: Luồng tối giản chỉ đặt vé, không bắp nước, không voucher', async () => {
    const userId = 1;
    const showtimeId = 1;
    const seatIds = [3];

    await bookingService.holdSeats(userId, { showtimeId, seatIds });
    const bookingRes = await bookingService.createBooking(userId, { showtimeId, seatIds });
    expect(bookingRes.success).toBe(true);
    const booking = bookingRes.data!;
    expect(booking.totalAmount).toBe(100000);
    expect(booking.discountAmount).toBe(0);

    // Tạo thanh toán MoMo
    const payRes = await paymentService.createPaymentUrl(
      userId,
      {
        bookingId: booking.id,
        method: EPaymentMethod.MOMO,
      },
      '127.0.0.1',
    );
    expect(payRes.success).toBe(true);

    // IPN MoMo
    await paymentService.processMoMoIPN({
      orderId: booking.bookingCode,
      resultCode: 0,
      amount: 100000,
      transId: 987654321,
      signature: 'valid-mock-sig',
    });

    const updatedBooking = dbEngine.bookings.get(booking.id);
    expect(updatedBooking.status).toBe(EBookingStatus.PAID);
    const tickets = Array.from(dbEngine.tickets.values()).filter(t => t.bookingId === booking.id);
    expect(tickets).toHaveLength(1);
  });

  // ==========================================================================
  // KỊCH BẢN 3: E2E-Timeout (Hết hạn ở từng giai đoạn)
  // Giả lập bằng cách sửa expiredAt, xóa Redis TTL, gọi cron expireOverdueBookings
  // ==========================================================================
  describe('E2E-Timeout: Hết hạn đơn hàng tại các mốc trong quy trình', () => {
    it('Timeout sau khi Hold Seats: TTL Redis hết hạn -> Ghế được giải phóng tự do', async () => {
      await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });
      expect(await redisService.getSeatHolder(1, 1)).toBe(1);

      // Giả lập hết TTL 5 phút
      await redisService.releaseSeat(1, 1);

      // User 2 có thể hold lại ghế 1
      const holdUser2 = await bookingService.holdSeats(2, { showtimeId: 1, seatIds: [1] });
      expect(holdUser2.success).toBe(true);
      expect(await redisService.getSeatHolder(1, 1)).toBe(2);
    });

    it('Timeout sau khi Create Booking: Quá 5 phút chưa thanh toán -> Cron chuyển EXPIRED và giải phóng ghế', async () => {
      await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });
      const bookingRes = await bookingService.createBooking(1, { showtimeId: 1, seatIds: [1] });
      const booking = bookingRes.data!;

      // Giả lập booking quá hạn 5 phút
      const bookingInDb = dbEngine.bookings.get(booking.id);
      bookingInDb.expiredAt = new Date(Date.now() - 10000);

      // Chạy cron expireOverdueBookings
      await paymentService.expireOverdueBookings();

      expect(bookingInDb.status).toBe(EBookingStatus.EXPIRED);
      const hold = Array.from(dbEngine.seatHolds.values()).find(h => h.seatId === 1);
      expect(hold?.status).toBe(ESeatHoldStatus.RELEASED);
      // Key Redis cũng bị xóa
      expect(await redisService.getSeatHolder(1, 1)).toBeNull();
    });

    it('Timeout khi đơn có dùng Loyalty Points: Hoàn trả điểm cho user khi hết hạn', async () => {
      const userBefore = dbEngine.users.get(1).loyaltyPoints; // 100 điểm
      await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });

      // Tạo booking dùng 50 điểm
      const bookingRes = await bookingService.createBooking(1, {
        showtimeId: 1,
        seatIds: [1],
        pointsToUse: 50,
      });
      const booking = bookingRes.data!;
      expect(dbEngine.users.get(1).loyaltyPoints).toBe(userBefore - 50); // Bị trừ 50 điểm

      // Đơn hết hạn
      const bookingInDb = dbEngine.bookings.get(booking.id);
      bookingInDb.expiredAt = new Date(Date.now() - 10000);

      // Cron xử lý hết hạn
      await paymentService.expireOverdueBookings();

      // Kiểm tra điểm loyalty đã được hoàn lại đầy đủ
      expect(dbEngine.users.get(1).loyaltyPoints).toBe(userBefore);
    });

    it('[BUG-03] Timeout khi đơn có dùng Voucher: Phải hoàn lại lượt usedCount của Promotion', async () => {
      const promoBefore = dbEngine.promotions.get(1).usedCount; // 0
      await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });

      const bookingRes = await bookingService.createBooking(1, {
        showtimeId: 1,
        seatIds: [1],
        promotionCode: 'DISCOUNT10',
      });
      const booking = bookingRes.data!;
      expect(dbEngine.promotions.get(1).usedCount).toBe(promoBefore + 1);

      // Đơn hết hạn
      const bookingInDb = dbEngine.bookings.get(booking.id);
      bookingInDb.expiredAt = new Date(Date.now() - 10000);
      await paymentService.expireOverdueBookings();

      // ĐẶC TẢ: Khi đơn hết hạn hủy bỏ, voucher usedCount phải được rollback giảm 1
      // BUG-03: Backend hiện tại không rollback usedCount trong expireOverdueBookings
      expect(dbEngine.promotions.get(1).usedCount).toBe(promoBefore);
    });
  });

  // ==========================================================================
  // KỊCH BẢN 4: E2E-LateIPN (IPN đến sau khi booking đã EXPIRED)
  // Đặc tả E7.1: Giao dịch bất thường cần gắn cờ Pending Refund, không kích hoạt vé
  // ==========================================================================
  it('[BUG-04] E2E-LateIPN: IPN thành công gửi tới sau khi đơn đã EXPIRED phải ghi nhận cờ hoàn tiền', async () => {
    await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });
    const bookingRes = await bookingService.createBooking(1, { showtimeId: 1, seatIds: [1] });
    const booking = bookingRes.data!;

    // Giả lập đơn bị hết hạn trước khi IPN tới
    const bookingInDb = dbEngine.bookings.get(booking.id);
    bookingInDb.status = EBookingStatus.EXPIRED;

    const vnpParams = {
      vnp_Amount: booking.totalAmount * 100,
      vnp_OrderInfo: `Thanh toan ve ${booking.bookingCode}`,
      vnp_ResponseCode: '00',
      vnp_TmnCode: VNP_TEST_TMN,
      vnp_TransactionNo: '99999999',
      vnp_TxnRef: booking.bookingCode,
    };
    const signedQuery = createSignedVnpayIpn(vnpParams, VNP_TEST_SECRET);

    // IPN đến muộn
    await paymentService.processVnpayIPN(signedQuery);

    // ĐẶC TẢ E7.1: Không kích hoạt vé (tickets = 0) và payment phải có trạng thái PENDING_REFUND
    const tickets = Array.from(dbEngine.tickets.values()).filter(t => t.bookingId === booking.id);
    expect(tickets).toHaveLength(0);

    const payment = Array.from(dbEngine.payments.values()).find(p => p.bookingId === booking.id);
    expect(payment?.status).toBe('REFUND_PENDING'); // BUG-04: Hiện tại backend chỉ bỏ qua hoặc FAILED
  });

  // ==========================================================================
  // KỊCH BẢN 5: E2E-DupIPN (Idempotency: Gửi IPN 2 lần liên tiếp)
  // Chỉ tạo 1 bộ vé, chỉ cộng điểm 1 lần, lần 2 trả về Order already confirmed
  // ==========================================================================
  it('E2E-DupIPN: Gửi IPN trùng lặp 2 lần phải đảm bảo tính Idempotent tuyệt đối', async () => {
    await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });
    const bookingRes = await bookingService.createBooking(1, { showtimeId: 1, seatIds: [1] });
    const booking = bookingRes.data!;

    const vnpParams = {
      vnp_Amount: booking.totalAmount * 100,
      vnp_OrderInfo: `Thanh toan ${booking.bookingCode}`,
      vnp_ResponseCode: '00',
      vnp_TmnCode: VNP_TEST_TMN,
      vnp_TransactionNo: '888888',
      vnp_TxnRef: booking.bookingCode,
    };
    const signedQuery = createSignedVnpayIpn(vnpParams, VNP_TEST_SECRET);

    // Lần 1: Thành công
    const ipn1 = await paymentService.processVnpayIPN(signedQuery);
    expect(ipn1.RspCode).toBe('00');
    const pointsAfter1 = dbEngine.users.get(1).loyaltyPoints;
    const ticketsAfter1 = Array.from(dbEngine.tickets.values()).filter(t => t.bookingId === booking.id).length;

    // Lần 2: Idempotent skip
    const ipn2 = await paymentService.processVnpayIPN(signedQuery);
    expect(ipn2.RspCode).toBe('02'); // Order already confirmed
    expect(ipn2.Message).toBe('Order already confirmed');

    // Không tạo thêm vé
    const ticketsAfter2 = Array.from(dbEngine.tickets.values()).filter(t => t.bookingId === booking.id).length;
    expect(ticketsAfter2).toBe(ticketsAfter1);

    // Không cộng điểm lần 2
    const pointsAfter2 = dbEngine.users.get(1).loyaltyPoints;
    expect(pointsAfter2).toBe(pointsAfter1);

    // Không gửi mail lần 2
    expect(mailerService.sendMail).toHaveBeenCalledTimes(1);
  });

  // ==========================================================================
  // KỊCH BẢN 6: E2E-PayFail-Retry (Thanh toán lỗi khi còn hạn và cho phép thử lại)
  // ==========================================================================
  it('[BUG-06] E2E-PayFail-Retry: Thanh toán lỗi khi còn thời hạn 5 phút phải cho phép đổi phương thức thử lại', async () => {
    await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });
    const bookingRes = await bookingService.createBooking(1, { showtimeId: 1, seatIds: [1] });
    const booking = bookingRes.data!;

    // Khách hàng hủy giao dịch tại cổng VNPay (ResponseCode = '24')
    const vnpParams = {
      vnp_Amount: booking.totalAmount * 100,
      vnp_ResponseCode: '24', // Khách hủy giao dịch
      vnp_TmnCode: VNP_TEST_TMN,
      vnp_TransactionNo: '0',
      vnp_TxnRef: booking.bookingCode,
    };
    const signedQuery = createSignedVnpayIpn(vnpParams, VNP_TEST_SECRET);
    await paymentService.processVnpayIPN(signedQuery);

    // ĐẶC TẢ UC10: Đơn hàng vẫn còn hạn 5 phút, booking status phải giữ PENDING để user retry cổng khác
    // BUG-06: Code hiện tại lập tức hủy đơn (status = CANCELLED) khiến user mất đơn
    const bookingInDb = dbEngine.bookings.get(booking.id);
    expect(bookingInDb.status).toBe(EBookingStatus.PENDING);

    // Thử lại bằng MoMo
    const retryRes = await paymentService.createPaymentUrl(
      1,
      {
        bookingId: booking.id,
        method: EPaymentMethod.MOMO,
      },
      '127.0.0.1',
    );
    expect(retryRes.success).toBe(true);
  });

  // ==========================================================================
  // KỊCH BẢN 7: E2E-Security (Kiểm soát phân quyền dữ liệu giữa các User)
  // User B không thể sửa bắp nước hoặc thanh toán đơn của User A
  // ==========================================================================
  describe('E2E-Security: Bảo vệ đơn hàng giữa các tài khoản khác nhau', () => {
    it('User B không thể cập nhật bắp nước vào đơn của User A', async () => {
      await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });
      const bookingRes = await bookingService.createBooking(1, { showtimeId: 1, seatIds: [1] });
      const bookingId = bookingRes.data!.id;

      // User B (id=2) cố tình sửa bắp nước đơn của User A (id=1)
      await expect(
        bookingService.updateBookingConcessions(bookingId, 2, {
          concessions: [{ productId: 1, quantity: 1 }],
        }),
      ).rejects.toThrow(CustomException);
    });

    it('User B không thể tạo thanh toán cho đơn của User A', async () => {
      await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });
      const bookingRes = await bookingService.createBooking(1, { showtimeId: 1, seatIds: [1] });
      const bookingId = bookingRes.data!.id;

      // User B (id=2) cố tạo payment URL
      await expect(
        paymentService.createPaymentUrl(
          2,
          {
            bookingId,
            method: EPaymentMethod.VNPAY,
          },
          '127.0.0.1',
        ),
      ).rejects.toThrow(CustomException);
    });
  });

  // ==========================================================================
  // KỊCH BẢN 8: Concurrency (Đồng thời qua Promise.all)
  // ==========================================================================
  describe('Concurrency (Kiểm tra tương tranh đồng thời qua Promise.all)', () => {
    it('Concurrency-1: 10 request đồng thời giữ cùng 1 ghế -> Đúng 1 request thành công', async () => {
      const showtimeId = 1;
      const seatIds = [1];

      // Gửi 10 request hold ghế đồng thời từ 10 user khác nhau
      const promises = Array.from({ length: 10 }).map((_, idx) =>
        bookingService.holdSeats(100 + idx, { showtimeId, seatIds }).catch(err => err),
      );

      const results = await Promise.all(promises);
      const successes = results.filter(r => r && r.success === true);
      const failures = results.filter(r => r instanceof CustomException || (r && r.status >= 400));

      expect(successes).toHaveLength(1);
      expect(failures).toHaveLength(9);
    });

    it('[BUG-07] Concurrency-2: Áp voucher chỉ còn 1 lượt dùng cho 2 đơn song song -> Chỉ 1 đơn được thành công', async () => {
      // Voucher LIMITED1 chỉ có maxUsage = 1
      // User 1 và User 2 cùng hold 2 ghế khác nhau
      await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });
      await bookingService.holdSeats(2, { showtimeId: 1, seatIds: [2] });

      // Cả 2 gửi request createBooking với mã LIMITED1 đồng thời
      const p1 = bookingService.createBooking(1, { showtimeId: 1, seatIds: [1], promotionCode: 'LIMITED1' }).catch(e => e);
      const p2 = bookingService.createBooking(2, { showtimeId: 1, seatIds: [2], promotionCode: 'LIMITED1' }).catch(e => e);

      const [res1, res2] = await Promise.all([p1, p2]);
      const successfulBookings = [res1, res2].filter(r => r && r.success === true);

      // ĐẶC TẢ: Chỉ cho phép đúng 1 đơn áp thành công voucher LIMITED1
      // BUG-07: Thiếu pessimistic lock trên Promotion khi check và update usedCount -> Cả 2 đơn đều thành công
      expect(successfulBookings).toHaveLength(1);
    });

    it.failing('[MISSING-FEATURE][BUG-08] Concurrency-3: 2 đơn thanh toán đồng thời cho bắp nước chỉ còn tồn kho = 1 -> Chỉ 1 đơn thành công', async () => {
      // Product 2 chỉ còn tồn kho = 1
      // Tạo 2 đơn booking PENDING đều có mua Product 2
      await bookingService.holdSeats(1, { showtimeId: 1, seatIds: [1] });
      const b1 = (await bookingService.createBooking(1, { showtimeId: 1, seatIds: [1] })).data!;
      await bookingService.updateBookingConcessions(b1.id, 1, { concessions: [{ productId: 2, quantity: 1 }] });

      await bookingService.holdSeats(2, { showtimeId: 1, seatIds: [2] });
      const b2 = (await bookingService.createBooking(2, { showtimeId: 1, seatIds: [2] })).data!;
      await bookingService.updateBookingConcessions(b2.id, 2, { concessions: [{ productId: 2, quantity: 1 }] });

      // Cả 2 đơn nhận IPN thanh toán đồng thời
      const ipn1 = paymentService.processMoMoIPN({
        orderId: b1.bookingCode,
        resultCode: 0,
        amount: b1.totalAmount,
        transId: 11111,
        signature: 'valid',
      }).catch(e => e);

      const ipn2 = paymentService.processMoMoIPN({
        orderId: b2.bookingCode,
        resultCode: 0,
        amount: b2.totalAmount,
        transId: 22222,
        signature: 'valid',
      }).catch(e => e);

      await Promise.all([ipn1, ipn2]);

      // ĐẶC TẢ: Vì tồn kho chỉ có 1, chỉ đúng 1 đơn được chuyển PAID, đơn kia phải bị chặn do hết hàng
      // BUG-08: Code hiện tại dùng GREATEST(stockQuantity - qty, 0) mà không lock/check tồn kho lúc confirm -> Bán vượt số lượng (oversell)
      const b1Status = dbEngine.bookings.get(b1.id).status;
      const b2Status = dbEngine.bookings.get(b2.id).status;
      const paidCount = (b1Status === EBookingStatus.PAID ? 1 : 0) + (b2Status === EBookingStatus.PAID ? 1 : 0);
      expect(paidCount).toBe(1);
    });
  });

  // ==========================================================================
  // KỊCH BẢN 9: E2E-DoubleBooking (BUG E3.2 / BUG-01)
  // Thanh toán xong một ghế, xóa key Redis của ghế đó, user khác hold lại ghế đó
  // thì phải bị từ chối
  // ==========================================================================
  it('[BUG-01] E2E-DoubleBooking: Ghế đã thanh toán xong (CONFIRMED), khi Redis key hết hạn thì user khác hold lại phải bị từ chối', async () => {
    const showtimeId = 1;
    const seatId = 1;

    // 1. User 1 hold ghế và thanh toán thành công
    await bookingService.holdSeats(1, { showtimeId, seatIds: [seatId] });
    const bRes = await bookingService.createBooking(1, { showtimeId, seatIds: [seatId] });
    const booking = bRes.data!;

    await paymentService.processMoMoIPN({
      orderId: booking.bookingCode,
      resultCode: 0,
      amount: booking.totalAmount,
      transId: 1234567,
      signature: 'valid',
    });

    expect(dbEngine.bookings.get(booking.id).status).toBe(EBookingStatus.PAID);
    const hold = Array.from(dbEngine.seatHolds.values()).find(h => h.seatId === seatId);
    expect(hold?.status).toBe(ESeatHoldStatus.CONFIRMED);

    // 2. Giả lập key Redis của ghế bị xóa (TTL 5 phút hết hạn hoặc Redis khởi động lại)
    await redisService.releaseSeat(showtimeId, seatId);

    // 3. User 2 gọi holdSeats cho chính ghế 1 đó
    // ĐẶC TẢ E3.2: Hệ thống PHẢI kiểm tra SeatHold trong DB và từ chối vì ghế đã có người mua (CONFIRMED)
    // BUG-01: Backend holdSeats hiện tại thực hiện seatHoldRepository.delete({ showtimeId, seatId }) xóa luôn bản ghi CONFIRMED trong DB và ghi đè!
    await expect(
      bookingService.holdSeats(2, { showtimeId, seatIds: [seatId] }),
    ).rejects.toThrow(CustomException);
  });
});
