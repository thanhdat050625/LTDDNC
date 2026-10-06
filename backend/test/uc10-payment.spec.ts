import { Test, TestingModule } from '@nestjs/testing';
import { HttpStatus } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { MailerService } from '@nestjs-modules/mailer';

import { PaymentService } from '../src/module/payment/payment.service';
import { Payment } from '../src/module/payment/entities/payment.entity';
import { Booking } from '../src/module/booking/entities/booking.entity';
import { SeatHold } from '../src/module/booking/entities/seat-hold.entity';
import { User } from '../src/module/users/entities/user.entity';

import { MomoService } from '../src/module/payment/services/momo.service';
import { VnpayService } from '../src/module/payment/services/vnpay.service';
import { PaypalService } from '../src/module/payment/services/paypal.service';
import { TicketService } from '../src/module/ticket/ticket.service';
import { RedisService } from '../src/module/redis/redis.service';
import { SeatGateway } from '../src/module/booking/seat.gateway';

import { EBookingStatus, ESeatHoldStatus } from '../src/module/booking/enums/booking.enum';
import { EPaymentMethod, EPaymentStatus, EPaymentChannel } from '../src/module/payment/enums/payment.enum';
import { CustomException } from '../src/core/exceptions/custom.exception';

import {
  createMockBooking,
  createMockUser,
  createMockSeatHold,
  createMockBookingConcession,
  createMockTicket,
  createMockQueryRunner,
} from './helpers/test-fixtures';

describe('UC10 - Thanh toán trực tuyến (Payment Online Integration)', () => {
  let service: PaymentService;

  // Mock Repositories
  let mockPaymentRepo: any;
  let mockBookingRepo: any;
  let mockSeatHoldRepo: any;
  let mockUserRepo: any;
  let mockDataSource: any;
  let mockQueryRunner: any;

  // Mock External Services
  let mockMomoService: any;
  let mockVnpayService: any;
  let mockPaypalService: any;
  let mockTicketService: any;
  let mockRedisService: any;
  let mockSeatGateway: any;
  let mockEventEmitter: any;
  let mockMailerService: any;

  beforeEach(async () => {
    mockQueryRunner = createMockQueryRunner();

    mockPaymentRepo = {
      findOne: jest.fn(),
      create: jest.fn((dto) => ({ id: 1, ...dto })),
      save: jest.fn((entity) => Promise.resolve({ id: 1, ...entity })),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockBookingRepo = {
      findOne: jest.fn(),
      find: jest.fn().mockResolvedValue([]),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockSeatHoldRepo = {
      find: jest.fn().mockResolvedValue([]),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockUserRepo = {
      findOne: jest.fn(),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    mockDataSource = {
      createQueryRunner: jest.fn().mockReturnValue(mockQueryRunner),
    };

    mockMomoService = {
      buildPaymentUrl: jest.fn().mockResolvedValue('https://test-payment.momo.vn/v2/gateway/pay?token=momo123'),
      verifyIpnSignature: jest.fn().mockReturnValue(true),
    };

    mockVnpayService = {
      buildPaymentUrl: jest.fn().mockReturnValue('https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?vnp_Amount=20000000'),
      verifyIpnSignature: jest.fn().mockReturnValue(true),
    };

    mockPaypalService = {
      buildPaymentUrl: jest.fn().mockResolvedValue({
        approveUrl: 'https://www.sandbox.paypal.com/checkoutnow?token=paypal123',
        paypalOrderId: 'PAYPAL-ORDER-999',
      }),
      captureOrder: jest.fn().mockResolvedValue(true),
    };

    mockTicketService = {
      generateTicketsForBooking: jest.fn().mockImplementation((booking) => {
        return booking.seatHolds.map((h: any) => createMockTicket(booking, h));
      }),
    };

    mockRedisService = {
      releaseSeats: jest.fn().mockResolvedValue(undefined),
      getHeldSeatIds: jest.fn().mockResolvedValue([]),
    };

    mockSeatGateway = {
      emitSeatUpdate: jest.fn(),
    };

    mockEventEmitter = {
      emit: jest.fn(),
    };

    mockMailerService = {
      sendMail: jest.fn().mockResolvedValue(true),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PaymentService,
        { provide: getRepositoryToken(Payment), useValue: mockPaymentRepo },
        { provide: getRepositoryToken(Booking), useValue: mockBookingRepo },
        { provide: getRepositoryToken(SeatHold), useValue: mockSeatHoldRepo },
        { provide: getRepositoryToken(User), useValue: mockUserRepo },
        { provide: DataSource, useValue: mockDataSource },
        { provide: MomoService, useValue: mockMomoService },
        { provide: VnpayService, useValue: mockVnpayService },
        { provide: PaypalService, useValue: mockPaypalService },
        { provide: TicketService, useValue: mockTicketService },
        { provide: RedisService, useValue: mockRedisService },
        { provide: SeatGateway, useValue: mockSeatGateway },
        { provide: EventEmitter2, useValue: mockEventEmitter },
        { provide: MailerService, useValue: mockMailerService },
      ],
    }).compile();

    service = module.get<PaymentService>(PaymentService);
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
  // 1. PRE-CONDITIONS & PREPARE CHECKOUT
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Pre-conditions & Prepare Checkout', () => {
    it('UC10 - Pre.1 - Đơn đặt vé không tồn tại -> từ chối với mã lỗi BOOKING_NOT_FOUND (404)', async () => {
      // Arrange
      mockBookingRepo.findOne.mockResolvedValue(null);

      // Act & Assert
      await expectCustomException(
        () => service.prepareCheckout(1, 9999),
        HttpStatus.NOT_FOUND,
        'BOOKING_NOT_FOUND',
      );
    });

    it('UC10 - Pre.2 - Khách hàng không có quyền thanh toán đơn của người khác -> từ chối với FORBIDDEN (403)', async () => {
      // Arrange
      const booking = createMockBooking({ userId: 99 }); // thuộc user 99
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Act & Assert (User 1 cố truy cập đơn của User 99)
      await expectCustomException(
        () => service.prepareCheckout(1, booking.id),
        HttpStatus.FORBIDDEN,
        'FORBIDDEN',
      );
    });

    it('UC10 - Pre.3 - Đơn đặt vé không ở trạng thái PENDING -> từ chối với BOOKING_NOT_PENDING (400)', async () => {
      // Arrange
      const booking = createMockBooking({ userId: 1, status: EBookingStatus.PAID });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Act & Assert
      await expectCustomException(
        () => service.prepareCheckout(1, booking.id),
        HttpStatus.BAD_REQUEST,
        'BOOKING_NOT_PENDING',
      );
    });

    it('UC10 - Pre.4 - Đơn đặt vé đã quá hạn giữ chỗ (expiredAt < now) -> từ chối với BOOKING_EXPIRED (400)', async () => {
      // Arrange (đã hết hạn 10 phút trước)
      const pastTime = new Date(Date.now() - 10 * 60 * 1000);
      const booking = createMockBooking({ userId: 1, expiredAt: pastTime });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Act & Assert
      await expectCustomException(
        () => service.prepareCheckout(1, booking.id),
        HttpStatus.BAD_REQUEST,
        'BOOKING_EXPIRED',
      );
    });

    it('UC10 - Main.1 - Chuẩn bị thanh toán: Lấy tóm tắt đơn hàng hiển thị đúng chi tiết ghế, bắp nước, tổng tiền và thời gian còn lại', async () => {
      // Arrange
      const booking = createMockBooking({
        userId: 1,
        totalAmount: 260000,
        discountAmount: 20000,
        bookingConcessions: [createMockBookingConcession(1, 1, 60000)],
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Act
      const result = await service.prepareCheckout(1, booking.id);

      // Assert
      expect(result.success).toBe(true);
      expect(result.data.bookingId).toBe(booking.id);
      expect(result.data.bookingCode).toBe(booking.bookingCode);
      expect(result.data.totalAmount).toBe(260000);
      expect(result.data.discountAmount).toBe(20000);
      expect(result.data.seats.length).toBe(2);
      expect(result.data.concessions.length).toBe(1);
      expect(result.data.secondsRemaining).toBeGreaterThan(0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. MAIN FLOW - TẠO PAYMENT URL
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Main Flow - Tạo Payment URL (MoMo, VNPay, PayPal)', () => {
    it('UC10 - Main.2a - Tạo URL thanh toán MoMo thành công -> status PENDING_PAYMENT, trả về payUrl', async () => {
      // Arrange
      const booking = createMockBooking({ userId: 1, totalAmount: 200000 });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Act
      const result = await service.createPaymentUrl(1, { bookingId: booking.id, method: EPaymentMethod.MOMO }, '127.0.0.1');

      // Assert
      expect(result.success).toBe(true);
      expect(mockMomoService.buildPaymentUrl).toHaveBeenCalledWith(booking.bookingCode, 200000);
      expect(result.data?.payUrl).toContain('test-payment.momo.vn');
      expect(mockQueryRunner.manager.save).toHaveBeenCalledWith(
        Payment,
        expect.objectContaining({
          bookingId: booking.id,
          method: EPaymentMethod.MOMO,
          status: EPaymentStatus.PENDING_PAYMENT,
          amount: 200000,
        }),
      );
    });

    it('UC10 - Main.2b - Tạo URL thanh toán VNPay thành công -> status PENDING_PAYMENT, trả về payUrl', async () => {
      // Arrange
      const booking = createMockBooking({ userId: 1, totalAmount: 200000 });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Act
      const result = await service.createPaymentUrl(1, { bookingId: booking.id, method: EPaymentMethod.VNPAY }, '192.168.1.1');

      // Assert
      expect(result.success).toBe(true);
      expect(mockVnpayService.buildPaymentUrl).toHaveBeenCalledWith(booking.bookingCode, 200000, '192.168.1.1');
      expect(result.data?.payUrl).toContain('sandbox.vnpayment.vn');
    });

    it('UC10 - Main.2c - Tạo URL thanh toán PayPal thành công -> status PENDING_PAYMENT, lưu gatewayOrderId', async () => {
      // Arrange
      const booking = createMockBooking({ userId: 1, totalAmount: 200000 });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Act
      const result = await service.createPaymentUrl(1, { bookingId: booking.id, method: EPaymentMethod.PAYPAL }, '127.0.0.1');

      // Assert
      expect(result.success).toBe(true);
      expect(mockPaypalService.buildPaymentUrl).toHaveBeenCalledWith(booking.bookingCode, 200000);
      expect(result.data?.payUrl).toContain('sandbox.paypal.com');
      expect(mockQueryRunner.manager.save).toHaveBeenCalledWith(
        Payment,
        expect.objectContaining({
          gatewayOrderId: 'PAYPAL-ORDER-999',
          status: EPaymentStatus.PENDING_PAYMENT,
        }),
      );
    });

    it('UC10 - Main.2d - Idempotency khi tạo payment URL -> nếu đã có payUrl PENDING_PAYMENT thì tái sử dụng, không tạo trùng', async () => {
      // Arrange
      const existingPayUrl = 'https://test-payment.momo.vn/v2/gateway/pay?token=already-created';
      const booking = createMockBooking({
        userId: 1,
        totalAmount: 200000,
        payment: {
          id: 10,
          bookingId: 1,
          payUrl: existingPayUrl,
          status: EPaymentStatus.PENDING_PAYMENT,
          method: EPaymentMethod.MOMO,
          amount: 200000,
        } as Payment,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Act
      const result = await service.createPaymentUrl(1, { bookingId: booking.id, method: EPaymentMethod.MOMO }, '127.0.0.1');

      // Assert
      expect(result.success).toBe(true);
      expect(result.data?.payUrl).toBe(existingPayUrl);
      expect(mockMomoService.buildPaymentUrl).not.toHaveBeenCalled(); // Không gọi gateway tạo mới
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. MAIN FLOW - NHẬN IPN / WEBHOOK THÀNH CÔNG
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Main Flow - Nhận IPN Webhook thành công (MoMo, VNPay, PayPal Capture)', () => {
    it('UC10 - Main.6a - Nhận IPN MoMo hợp lệ -> chuyển status PAID, trừ kho bắp nước, cộng điểm loyalty, sinh vé QR, gửi email xác nhận', async () => {
      // Arrange
      const concessionItem = createMockBookingConcession(1, 2, 60000);
      const booking = createMockBooking({
        bookingCode: 'MOMO-BK-001',
        totalAmount: 320000,
        status: EBookingStatus.PENDING,
        bookingConcessions: [concessionItem],
      });
      mockBookingRepo.findOne.mockImplementation(({ where }) => {
        if (where?.bookingCode === 'MOMO-BK-001' || where?.id === booking.id) {
          return Promise.resolve(booking);
        }
        return Promise.resolve(null);
      });
      mockQueryRunner = createMockQueryRunner(booking);
      mockDataSource.createQueryRunner.mockReturnValue(mockQueryRunner);

      const ipnData = {
        orderId: 'MOMO-BK-001',
        resultCode: 0,
        amount: 320000,
        transId: 'MOMO-TRANS-98765',
      };

      // Act
      await service.processMoMoIPN(ipnData);

      // Assert
      expect(mockMomoService.verifyIpnSignature).toHaveBeenCalledWith(ipnData);
      expect(mockQueryRunner.manager.update).toHaveBeenCalledWith(
        Booking,
        { id: booking.id },
        { status: EBookingStatus.PAID },
      );
      // Trừ tồn kho bắp nước
      expect(mockQueryRunner.manager.createQueryBuilder).toHaveBeenCalled();
      // Tích điểm loyalty (10% của 320.000 = 32.000 điểm)
      expect(mockUserRepo.update).toHaveBeenCalledWith(
        { id: 1 },
        expect.objectContaining({ loyaltyPoints: expect.any(Function) }),
      );
      // Sinh vé QR
      expect(mockTicketService.generateTicketsForBooking).toHaveBeenCalled();
      // Gửi email vé điện tử E-ticket kèm QR
      expect(mockMailerService.sendMail).toHaveBeenCalledWith(
        expect.objectContaining({
          to: 'khachhang@cineplex.vn',
          subject: expect.stringContaining('Xac nhan dat ve thanh cong'),
        }),
      );
    });

    it('UC10 - Main.6b - Nhận IPN VNPay hợp lệ (responseCode 00) -> chuyển status PAID, tạo mã giao dịch và sinh vé QR', async () => {
      // Arrange
      const booking = createMockBooking({
        bookingCode: 'VNPAY-BK-002',
        totalAmount: 200000,
        status: EBookingStatus.PENDING,
      });
      mockBookingRepo.findOne.mockImplementation(({ where }) => {
        if (where?.bookingCode === 'VNPAY-BK-002' || where?.id === booking.id) {
          return Promise.resolve(booking);
        }
        return Promise.resolve(null);
      });
      mockQueryRunner = createMockQueryRunner(booking);
      mockDataSource.createQueryRunner.mockReturnValue(mockQueryRunner);

      const vnpayQuery = {
        vnp_TxnRef: 'VNPAY-BK-002',
        vnp_ResponseCode: '00',
        vnp_Amount: '20000000', // VNPay x100 = 20.000.000
        vnp_TransactionNo: 'VNPAY-TXN-12345',
      };

      // Act
      const response = await service.processVnpayIPN(vnpayQuery);

      // Assert
      expect(response).toEqual({ RspCode: '00', Message: 'Confirm Success' });
      expect(mockVnpayService.verifyIpnSignature).toHaveBeenCalledWith(vnpayQuery);
      expect(mockQueryRunner.manager.update).toHaveBeenCalledWith(
        Booking,
        { id: booking.id },
        { status: EBookingStatus.PAID },
      );
    });

    it('UC10 - Main.6c - PayPal capture thành công -> chuyển status PAID, xác nhận đơn hàng thành công', async () => {
      // Arrange
      const booking = createMockBooking({
        bookingCode: 'PAYPAL-BK-003',
        totalAmount: 200000,
        status: EBookingStatus.PENDING,
        payment: {
          id: 3,
          gatewayOrderId: 'PAYPAL-ORDER-999',
          status: EPaymentStatus.PENDING_PAYMENT,
        } as Payment,
      });
      mockBookingRepo.findOne.mockImplementation(({ where }) => {
        if (where?.bookingCode === 'PAYPAL-BK-003' || where?.id === booking.id) {
          return Promise.resolve(booking);
        }
        return Promise.resolve(null);
      });
      mockQueryRunner = createMockQueryRunner(booking);
      mockDataSource.createQueryRunner.mockReturnValue(mockQueryRunner);

      // Act
      const result = await service.capturePayPalOrder('PAYPAL-BK-003');

      // Assert
      expect(result).toBe('PAYPAL-BK-003');
      expect(mockPaypalService.captureOrder).toHaveBeenCalledWith('PAYPAL-ORDER-999');
      expect(mockQueryRunner.manager.update).toHaveBeenCalledWith(
        Booking,
        { id: booking.id },
        { status: EBookingStatus.PAID },
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. BẢO MẬT & TOÀN VẸN DỮ LIỆU (SIGNATURE & AMOUNT VALIDATION)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Bảo mật & Toàn vẹn dữ liệu (Signature & Amount Mismatch)', () => {
    it('UC10 - Security.1a - MoMo IPN sai chữ ký (invalid signature) -> từ chối ngay lập tức, không cập nhật đơn hàng', async () => {
      // Arrange
      mockMomoService.verifyIpnSignature.mockReturnValue(false); // Chữ ký giả mạo
      const ipnData = {
        orderId: 'MOMO-FAKE-001',
        resultCode: 0,
        amount: 200000,
      };

      // Act
      await service.processMoMoIPN(ipnData);

      // Assert
      expect(mockBookingRepo.findOne).not.toHaveBeenCalled(); // Từ chối ngay lập tức
      expect(mockDataSource.createQueryRunner).not.toHaveBeenCalled();
    });

    it('UC10 - Security.1b - VNPay IPN sai chữ ký / checksum -> từ chối, trả về RspCode 97', async () => {
      // Arrange
      mockVnpayService.verifyIpnSignature.mockReturnValue(false); // Checksum sai
      const vnpayQuery = {
        vnp_TxnRef: 'VNPAY-FAKE-002',
        vnp_ResponseCode: '00',
        vnp_Amount: '20000000',
      };

      // Act
      const response = await service.processVnpayIPN(vnpayQuery);

      // Assert
      expect(response).toEqual({ RspCode: '97', Message: 'Invalid signature' });
      expect(mockBookingRepo.findOne).not.toHaveBeenCalled();
    });

    it('UC10 - Security.2a - MoMo IPN số tiền không khớp với đơn hàng -> từ chối, cảnh báo giả mạo số tiền', async () => {
      // Arrange: Đơn hàng 200.000đ nhưng hacker gửi IPN chỉ có 2.000đ
      const booking = createMockBooking({
        bookingCode: 'MOMO-HACK-003',
        totalAmount: 200000,
        status: EBookingStatus.PENDING,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const ipnData = {
        orderId: 'MOMO-HACK-003',
        resultCode: 0,
        amount: 2000, // Sai lệch số tiền
      };

      // Act
      await service.processMoMoIPN(ipnData);

      // Assert
      expect(mockDataSource.createQueryRunner).not.toHaveBeenCalled(); // Không set PAID
    });

    it('UC10 - Security.2b - VNPay IPN số tiền không khớp với đơn hàng -> từ chối, trả về RspCode 04', async () => {
      // Arrange: Đơn hàng 200.000đ nhưng IPN gửi 100.000đ (* 100 = 10.000.000)
      const booking = createMockBooking({
        bookingCode: 'VNPAY-HACK-004',
        totalAmount: 200000,
        status: EBookingStatus.PENDING,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const vnpayQuery = {
        vnp_TxnRef: 'VNPAY-HACK-004',
        vnp_ResponseCode: '00',
        vnp_Amount: '10000000', // Chỉ 100.000đ
      };

      // Act
      const response = await service.processVnpayIPN(vnpayQuery);

      // Assert
      expect(response).toEqual({ RspCode: '04', Message: 'Invalid amount' });
      expect(mockDataSource.createQueryRunner).not.toHaveBeenCalled();
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. IDEMPOTENCY (CHỐNG XỬ LÝ LẶP IPN)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Idempotency - Gửi trùng IPN nhiều lần', () => {
    it('UC10 - Idempotent.1a - MoMo IPN gửi trùng khi đơn đã PAID -> bỏ qua (idempotent skip), không cộng điểm loyalty lần 2', async () => {
      // Arrange: Đơn hàng ĐÃ Ở TRẠNG THÁI PAID từ IPN trước đó
      const booking = createMockBooking({
        bookingCode: 'MOMO-IDEM-001',
        totalAmount: 200000,
        status: EBookingStatus.PAID,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const ipnData = {
        orderId: 'MOMO-IDEM-001',
        resultCode: 0,
        amount: 200000,
      };

      // Act
      await service.processMoMoIPN(ipnData);

      // Assert
      expect(mockDataSource.createQueryRunner).not.toHaveBeenCalled();
      expect(mockUserRepo.update).not.toHaveBeenCalled(); // Không cộng điểm lần 2
      expect(mockTicketService.generateTicketsForBooking).not.toHaveBeenCalled(); // Không sinh vé lần 2
    });

    it('UC10 - Idempotent.1b - VNPay IPN gửi trùng khi đơn đã PAID -> trả về RspCode 02 (Order already confirmed)', async () => {
      // Arrange
      const booking = createMockBooking({
        bookingCode: 'VNPAY-IDEM-002',
        totalAmount: 200000,
        status: EBookingStatus.PAID,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const vnpayQuery = {
        vnp_TxnRef: 'VNPAY-IDEM-002',
        vnp_ResponseCode: '00',
        vnp_Amount: '20000000',
      };

      // Act
      const response = await service.processVnpayIPN(vnpayQuery);

      // Assert
      expect(response).toEqual({ RspCode: '02', Message: 'Order already confirmed' });
      expect(mockDataSource.createQueryRunner).not.toHaveBeenCalled();
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. ALTERNATE FLOW & EXCEPTION FLOW (KHÁCH HỦY & LỖI CỔNG THANH TOÁN)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Alternate Flow & Exception Flow - Khách hủy và Lỗi thanh toán', () => {
    it('UC10 - A5.1 - Khách hủy giao dịch PayPal khi đơn đã hết hạn -> đánh dấu payment FAILED, hủy đơn và hoàn điểm loyalty nếu có', async () => {
      // Arrange: Khách dùng 10.000 điểm khi tạo đơn, đơn đã hết hạn
      const booking = createMockBooking({
        bookingCode: 'PAYPAL-CANCEL-001',
        status: EBookingStatus.PENDING,
        expiredAt: new Date(Date.now() - 1000),
        pointsUsed: 10000,
        userId: 1,
        payment: { id: 1, status: EPaymentStatus.PENDING_PAYMENT } as Payment,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      // Act
      await service.cancelPayPalOrder('PAYPAL-CANCEL-001');

      // Assert
      expect(mockBookingRepo.update).toHaveBeenCalledWith(
        { id: booking.id, status: EBookingStatus.PENDING },
        { status: EBookingStatus.CANCELLED },
      );
      expect(mockPaymentRepo.update).toHaveBeenCalledWith({ id: 1 }, { status: EPaymentStatus.FAILED });
      // Hoàn lại 10.000 điểm loyalty cho user
      expect(mockUserRepo.update).toHaveBeenCalledWith(
        { id: 1 },
        expect.objectContaining({ loyaltyPoints: expect.any(Function) }),
      );
      // Giải phóng ghế Redis
      expect(mockRedisService.releaseSeats).toHaveBeenCalled();
    });

    /**
     * [BUG-06] UC10 - A5.1: Theo đặc tả UC10 A5.1, khi khách hủy tại cổng MoMo/VNPay,
     * đơn hàng chưa hoàn tất nhưng PHẢI CHO PHÉP KHÁCH THỬ LẠI PHƯƠNG THỨC KHÁC NẾU CÒN THỜI GIAN GIỮ GHẾ.
     */
    it('[BUG-06] UC10 - A5.1 - Khách hủy tại cổng thanh toán -> đơn giữ nguyên PENDING, cho phép thử lại phương thức khác nếu còn hạn', async () => {
      const booking = createMockBooking({
        bookingCode: 'PAYPAL-CANCEL-RETRY',
        status: EBookingStatus.PENDING,
        expiredAt: new Date(Date.now() + 4 * 60 * 1000), // còn 4 phút giữ ghế
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      await service.cancelPayPalOrder('PAYPAL-CANCEL-RETRY');

      // Theo UC: Không được hủy đơn (CANCELLED) và không được release ghế khi còn hạn
      expect(mockBookingRepo.update).not.toHaveBeenCalledWith(
        expect.anything(),
        { status: EBookingStatus.CANCELLED },
      );
      expect(mockRedisService.releaseSeats).not.toHaveBeenCalled();
    });

    it('UC10 - E6.1a - MoMo IPN báo thanh toán thất bại khi đã hết hạn -> hủy đơn, cập nhật FAILED và hoàn điểm loyalty', async () => {
      // Arrange
      const booking = createMockBooking({
        bookingCode: 'MOMO-FAIL-001',
        totalAmount: 200000,
        status: EBookingStatus.PENDING,
        expiredAt: new Date(Date.now() - 1000), // đã hết hạn
        pointsUsed: 5000,
        userId: 1,
        payment: { id: 5, status: EPaymentStatus.PENDING_PAYMENT } as Payment,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const ipnData = {
        orderId: 'MOMO-FAIL-001',
        resultCode: 1006, // Người dùng từ chối thanh toán
        amount: 200000,
      };

      // Act
      await service.processMoMoIPN(ipnData);

      // Assert
      expect(mockBookingRepo.update).toHaveBeenCalledWith(
        { id: booking.id, status: EBookingStatus.PENDING },
        { status: EBookingStatus.CANCELLED },
      );
      expect(mockPaymentRepo.update).toHaveBeenCalledWith({ id: 5 }, { status: EPaymentStatus.FAILED });
      expect(mockUserRepo.update).toHaveBeenCalledWith(
        { id: 1 },
        expect.objectContaining({ loyaltyPoints: expect.any(Function) }),
      );
      expect(mockRedisService.releaseSeats).toHaveBeenCalled();
    });

    it('UC10 - E6.1b - VNPay IPN báo thanh toán thất bại khi đã hết hạn -> hủy đơn, cập nhật FAILED', async () => {
      // Arrange
      const booking = createMockBooking({
        bookingCode: 'VNPAY-FAIL-002',
        totalAmount: 200000,
        status: EBookingStatus.PENDING,
        expiredAt: new Date(Date.now() - 1000), // đã hết hạn
        payment: { id: 6, status: EPaymentStatus.PENDING_PAYMENT } as Payment,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const vnpayQuery = {
        vnp_TxnRef: 'VNPAY-FAIL-002',
        vnp_ResponseCode: '24', // Khách hàng hủy giao dịch
        vnp_Amount: '20000000',
      };

      // Act
      const response = await service.processVnpayIPN(vnpayQuery);

      // Assert
      expect(response).toEqual({ RspCode: '00', Message: 'Confirm Success' });
      expect(mockBookingRepo.update).toHaveBeenCalledWith(
        { id: booking.id, status: EBookingStatus.PENDING },
        { status: EBookingStatus.CANCELLED },
      );
      expect(mockPaymentRepo.update).toHaveBeenCalledWith({ id: 6 }, { status: EPaymentStatus.FAILED });
    });

    /**
     * [BUG-06] UC10 - E6.1: Theo đặc tả UC10 E6.1, khi thanh toán thất bại nhưng còn hạn,
     * khách hàng có thể chọn phương thức khác để tiếp tục thanh toán.
     */
    it('[BUG-06] UC10 - E6.1 - Thanh toán thất bại tại cổng nhưng còn hạn -> cho phép khách đổi phương thức khác mà không hủy đơn ngay', async () => {
      const booking = createMockBooking({
        bookingCode: 'MOMO-FAIL-CAN-RETRY',
        totalAmount: 200000,
        status: EBookingStatus.PENDING,
        expiredAt: new Date(Date.now() + 3 * 60 * 1000), // còn 3 phút
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      await service.processMoMoIPN({
        orderId: 'MOMO-FAIL-CAN-RETRY',
        resultCode: 1001, // Lỗi mạng
        amount: 200000,
      });

      // Theo UC: Không được hủy đơn (CANCELLED) và không được release ghế khi còn hạn
      expect(mockBookingRepo.update).not.toHaveBeenCalledWith(
        expect.anything(),
        { status: EBookingStatus.CANCELLED },
      );
      expect(mockRedisService.releaseSeats).not.toHaveBeenCalled();
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 7. EXCEPTION FLOW - QUÁ HẠN GIỮ GHẾ & THANH TOÁN TRỄ (REFUND)
  // ─────────────────────────────────────────────────────────────────────────────
  describe('Exception Flow - Quá hạn giữ ghế & Thanh toán trễ (Refund)', () => {
    // CURRENT-BEHAVIOR: sẽ cần cập nhật khi sửa flow E7.1 (chỉ từ chối set PAID, chưa xử lý hoàn tiền)
    it('UC10 - E7.1a - MoMo IPN báo thành công nhưng Booking đã EXPIRED -> từ chối cập nhật PAID', async () => {
      // Arrange
      const booking = createMockBooking({
        bookingCode: 'MOMO-EXPIRED-001',
        totalAmount: 200000,
        status: EBookingStatus.EXPIRED,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const ipnData = {
        orderId: 'MOMO-EXPIRED-001',
        resultCode: 0,
        amount: 200000,
        transId: 'MOMO-LATE-123',
      };

      // Act
      await service.processMoMoIPN(ipnData);

      // Assert
      expect(mockDataSource.createQueryRunner).not.toHaveBeenCalled(); // Không set PAID
    });

    // CURRENT-BEHAVIOR: sẽ cần cập nhật khi sửa flow E7.1 (chỉ từ chối set PAID, chưa xử lý hoàn tiền)
    it('UC10 - E7.1b - VNPay IPN báo thành công nhưng Booking đã EXPIRED -> từ chối cập nhật PAID, trả về RspCode 02', async () => {
      // Arrange
      const booking = createMockBooking({
        bookingCode: 'VNPAY-EXPIRED-002',
        totalAmount: 200000,
        status: EBookingStatus.EXPIRED,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      const vnpayQuery = {
        vnp_TxnRef: 'VNPAY-EXPIRED-002',
        vnp_ResponseCode: '00',
        vnp_Amount: '20000000',
      };

      // Act
      const response = await service.processVnpayIPN(vnpayQuery);

      // Assert
      expect(response).toEqual({ RspCode: '02', Message: 'Order expired' });
      expect(mockDataSource.createQueryRunner).not.toHaveBeenCalled();
    });

    /**
     * [MISSING-FEATURE] UC10 - E7.1: Theo đặc tả UC10 E7.1:
     * "Thanh toán thành công nhưng bị trễ (Quá giờ giữ ghế): IPN báo khách đã bị trừ tiền thành công,
     * nhưng do mạng lag hoặc khách ngâm trang thanh toán quá lâu khiến Booking bị tự động hủy từ trước.
     * Hệ thống ghi nhận trạng thái 'Thanh toán bất thường', giữ tiền vào trạng thái Chờ Hoàn (Refund)".
     * Code hiện tại: Chỉ ghi logger.warn rồi bỏ qua!
     */
    it("[BUG-04] UC10 - E7.1 - IPN thành công nhưng Booking đã hết hạn -> ghi nhận trạng thái 'Thanh toán bất thường', chuyển tiền vào 'Chờ Hoàn' (Refund)", async () => {
      // Code cần sửa: Khi booking.status === EXPIRED và resultCode === 0, cần tạo bản ghi Refund / Payment Anomaly để nhân viên xử lý hoàn tiền cho khách.
      const booking = createMockBooking({
        bookingCode: 'MOMO-REFUND-001',
        totalAmount: 200000,
        status: EBookingStatus.EXPIRED,
        payment: { id: 8, status: EPaymentStatus.PENDING_PAYMENT } as Payment,
      });
      mockBookingRepo.findOne.mockResolvedValue(booking);

      await service.processMoMoIPN({
        orderId: 'MOMO-REFUND-001',
        resultCode: 0,
        amount: 200000,
        transId: 'MOMO-LATE-REFUND-999',
      });

      // Kỳ vọng theo UC: Cập nhật payment trạng thái ghi nhận hoàn tiền / thanh toán bất thường
      // Sử dụng regex linh hoạt để không phụ thuộc vào tên enum cụ thể (REFUND_PENDING, PAYMENT_ANOMALY, WAITING_REFUND...)
      expect(mockPaymentRepo.update).toHaveBeenCalledWith(
        { id: 8 },
        expect.objectContaining({
          status: expect.stringMatching(/REFUND|ANOMAL/i),
        }),
      );
    });

    it('UC10 - Timeout - Cron quét tự động expire các đơn PENDING quá hạn 5 phút -> đổi EXPIRED, hoàn điểm loyalty, giải phóng ghế Redis & DB', async () => {
      // Arrange: 1 đơn hàng PENDING đã quá hạn
      const pastTime = new Date(Date.now() - 6 * 60 * 1000);
      const overdueBooking = createMockBooking({
        id: 77,
        bookingCode: 'CRON-EXP-001',
        status: EBookingStatus.PENDING,
        expiredAt: pastTime,
        pointsUsed: 8000,
        userId: 1,
        seatHolds: [
          createMockSeatHold(10, 1, 77, { status: ESeatHoldStatus.HOLDING }),
          createMockSeatHold(11, 1, 77, { status: ESeatHoldStatus.HOLDING }),
        ],
        payment: { id: 9, status: EPaymentStatus.PENDING_PAYMENT } as Payment,
      });

      mockBookingRepo.find.mockResolvedValue([overdueBooking]);
      mockQueryRunner = createMockQueryRunner(overdueBooking);
      mockDataSource.createQueryRunner.mockReturnValue(mockQueryRunner);

      // Act
      await service.expireOverdueBookings();

      // Assert
      expect(mockQueryRunner.manager.update).toHaveBeenCalledWith(
        Booking,
        { id: 77 },
        { status: EBookingStatus.EXPIRED },
      );
      expect(mockQueryRunner.manager.update).toHaveBeenCalledWith(
        Payment,
        { id: 9 },
        { status: EPaymentStatus.FAILED },
      );
      // Chuyển seat hold thành RELEASED
      expect(mockQueryRunner.manager.update).toHaveBeenCalledWith(
        SeatHold,
        { id: expect.any(Object) },
        { status: ESeatHoldStatus.RELEASED },
      );
      // Hoàn lại 8.000 điểm loyalty
      expect(mockUserRepo.update).toHaveBeenCalledWith(
        { id: 1 },
        expect.objectContaining({ loyaltyPoints: expect.any(Function) }),
      );
      // Giải phóng ghế Redis
      expect(mockRedisService.releaseSeats).toHaveBeenCalledWith(101, [10, 11]);
    });
  });
});
