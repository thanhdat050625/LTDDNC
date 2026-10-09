import { Injectable, HttpStatus, Optional, Logger } from '@nestjs/common';
import { InjectRepository, InjectDataSource } from '@nestjs/typeorm';
import { Repository, In, DataSource } from 'typeorm';
import { Booking } from './entities/booking.entity';
import { BookingConcession } from './entities/booking-concession.entity';
import { SeatHold } from './entities/seat-hold.entity';
import { HoldSeatsDto, CreateBookingDto, ReleaseSeatsDto } from './dto/booking.dto';
import { ApiResponse } from '../../core/dto/ApiResponse.dto';
import { CustomException } from '../../core/exceptions/custom.exception';
import { RedisService } from '../redis/redis.service';
import { EBookingStatus, EBookingSource, ESeatHoldStatus } from './enums/booking.enum';
import { Seat } from '../cinema/entities/seat.entity';
import { ERoomType } from '../cinema/enums/cinema.enum';
import { Payment } from '../payment/entities/payment.entity';
import { EPaymentStatus } from '../payment/enums/payment.enum';
import { TicketPrice } from '../ticket/entities/ticket-price.entity';
import { ConcessionProduct } from '../concession/entities/concession-product.entity';
import { Promotion } from '../promotion/entities/promotion.entity';
import { EDiscountType } from '../promotion/enums/promotion.enum';
import { validatePromotion, calculateDiscount } from '../promotion/promotion.service';
import { Showtime } from '../showtime/entities/showtime.entity';
import { SeatGateway } from './seat.gateway';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { ENotificationType } from '../notification/enums/notification.enum';
import { User } from '../users/entities/user.entity';
import { BOOKING_ERROR_CODES, MAX_SEATS_PER_BOOKING } from './constants/booking.constant';

// ─── Constants ────────────────────────────────────────────────────────────────

/** Giá trị mỗi điểm theo VNĐ khi tiêu. 1 điểm = 1 VNĐ. */
const LOYALTY_POINT_VALUE = 1;
/** Giới hạn giảm giá tối đa bằng điểm: 20% tổng đơn. */
const LOYALTY_MAX_DISCOUNT_RATE = 0.20;

@Injectable()
export class BookingService {
  private readonly logger = new Logger(BookingService.name);

  constructor(
    @InjectRepository(Booking)
    private readonly bookingRepository: Repository<Booking>,

    @InjectRepository(SeatHold)
    private readonly seatHoldRepository: Repository<SeatHold>,
    @InjectRepository(Seat)
    private readonly seatRepository: Repository<Seat>,
    @InjectRepository(TicketPrice)
    private readonly ticketPriceRepository: Repository<TicketPrice>,
    @InjectRepository(Showtime)
    private readonly showtimeRepository: Repository<Showtime>,
    @InjectRepository(ConcessionProduct)
    private readonly concessionProductRepository: Repository<ConcessionProduct>,
    @InjectRepository(Promotion)
    private readonly promotionRepository: Repository<Promotion>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectDataSource()
    private readonly dataSource: DataSource,
    private readonly redisService: RedisService,
    @Optional() private readonly seatGateway: SeatGateway,
    private readonly eventEmitter: EventEmitter2,
  ) { }

  // ─── SEAT HOLD ────────────────────────────────────────────────────────

  async holdSeats(userId: number, dto: HoldSeatsDto): Promise<ApiResponse<any>> {
    if (!dto.seatIds || dto.seatIds.length === 0 || dto.seatIds.length > MAX_SEATS_PER_BOOKING) {
      throw new CustomException(
        HttpStatus.BAD_REQUEST,
        BOOKING_ERROR_CODES.MAX_SEATS_EXCEEDED,
        `Chỉ được chọn tối đa ${MAX_SEATS_PER_BOOKING} ghế mỗi đơn`,
      );
    }

    // Kiểm tra showtime còn có thể đặt vé không
    const showtime = await this.showtimeRepository.findOne({ where: { id: dto.showtimeId } });
    if (!showtime) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'SHOWTIME_NOT_FOUND', 'Không tìm thấy suất chiếu');
    }
    if (showtime.status === 'COMPLETED' || showtime.status === 'CANCELLED') {
      throw new CustomException(
        HttpStatus.BAD_REQUEST,
        'SHOWTIME_NOT_BOOKABLE',
        'Suất chiếu này đã kết thúc hoặc bị huỷ, không thể đặt vé',
      );
    }
    if (showtime.publicStartTime && new Date(showtime.publicStartTime) <= new Date()) {
      throw new CustomException(
        HttpStatus.BAD_REQUEST,
        BOOKING_ERROR_CODES.SHOWTIME_EXPIRED,
        'Suất chiếu đã bắt đầu hoặc quá hạn đặt vé',
      );
    }

    // E3.3: Kiểm tra mọi seatId thuộc phòng của suất chiếu
    const seats = await this.seatRepository.find({
      where: { id: In(dto.seatIds) },
    });
    if (seats.length !== dto.seatIds.length || seats.some(s => s.roomId !== showtime.roomId)) {
      throw new CustomException(
        HttpStatus.BAD_REQUEST,
        BOOKING_ERROR_CODES.SEAT_ROOM_MISMATCH,
        'Một số ghế không thuộc phòng chiếu của suất chiếu này',
      );
    }

    // BUG-01: Kiểm tra xem có ghế nào đã có SeatHold CONFIRMED (đơn đang chờ thanh toán hoặc đã bán)
    for (const seatId of dto.seatIds) {
      const confirmedHold = await this.seatHoldRepository.findOne({
        where: {
          showtimeId: dto.showtimeId,
          seatId,
          status: ESeatHoldStatus.CONFIRMED,
        },
        relations: ['booking'],
      });
      if (confirmedHold) {
        const now = new Date();
        const isCancelledOrExpired =
          confirmedHold.booking &&
          (confirmedHold.booking.status === EBookingStatus.CANCELLED ||
            confirmedHold.booking.status === EBookingStatus.EXPIRED ||
            (confirmedHold.booking.status === EBookingStatus.PENDING &&
              confirmedHold.booking.expiredAt &&
              new Date(confirmedHold.booking.expiredAt) <= now));

        if (isCancelledOrExpired) {
          await this.seatHoldRepository.update(
            { id: confirmedHold.id },
            { status: ESeatHoldStatus.RELEASED },
          );
        } else {
          throw new CustomException(
            HttpStatus.BAD_REQUEST,
            BOOKING_ERROR_CODES.SEAT_ALREADY_BOOKED,
            `Ghế ${seatId} đã được đặt/bán`,
          );
        }
      }
    }

    const failedSeats: number[] = [];
    const successSeats: number[] = [];

    for (const seatId of dto.seatIds) {
      const success = await this.redisService.holdSeat(dto.showtimeId, seatId, userId, 300);
      if (!success) {
        failedSeats.push(seatId);
      } else {
        successSeats.push(seatId);
      }
    }

    if (failedSeats.length > 0) {
      await this.redisService.releaseSeats(dto.showtimeId, successSeats);
      throw new CustomException(
        HttpStatus.BAD_REQUEST,
        'SEAT_ALREADY_HELD',
        `Ghế ${failedSeats.join(', ')} đã bị giữ bởi người khác`,
      );
    }

    const now = new Date();
    const expiredAt = new Date(now.getTime() + 5 * 60 * 1000);

    try {
      for (const seatId of dto.seatIds) {
        await this.seatHoldRepository.delete({
          showtimeId: dto.showtimeId,
          seatId,
          status: In([ESeatHoldStatus.HOLDING, ESeatHoldStatus.RELEASED]),
        });

        const seatHold = this.seatHoldRepository.create({
          showtimeId: dto.showtimeId,
          seatId,
          userId,
          heldAt: now,
          expiredAt,
          status: ESeatHoldStatus.HOLDING,
        });
        await this.seatHoldRepository.save(seatHold);
      }
    } catch (error) {
      await this.redisService.releaseSeats(dto.showtimeId, successSeats);
      throw error;
    }

    // Emit seat-update realtime cho tất cả client đang xem suất chiếu này
    await this.broadcastSeatUpdate(dto.showtimeId);

    return new ApiResponse(true, 'Giữ ghế thành công (5 phút)', {
      showtimeId: dto.showtimeId,
      seatIds: dto.seatIds,
      expiredAt,
    });
  }

  // ─── CREATE BOOKING ───────────────────────────────────────────────────

  async createBooking(userId: number | null, dto: CreateBookingDto | any, staffId?: number): Promise<ApiResponse<Booking>> {
    if (!dto.seatIds || dto.seatIds.length === 0 || dto.seatIds.length > MAX_SEATS_PER_BOOKING) {
      throw new CustomException(
        HttpStatus.BAD_REQUEST,
        BOOKING_ERROR_CODES.MAX_SEATS_EXCEEDED,
        `Chỉ được chọn tối đa ${MAX_SEATS_PER_BOOKING} ghế mỗi đơn`,
      );
    }

    const holderId = staffId || userId;
    // Verify tất cả ghế đang được hold bởi user này
    for (const seatId of dto.seatIds) {
      const holder = await this.redisService.getSeatHolder(dto.showtimeId, seatId);
      if (holder !== holderId) {
        throw new CustomException(
          HttpStatus.BAD_REQUEST,
          'SEAT_NOT_HELD',
          `Ghế ${seatId} chưa được giữ hoặc đã hết hạn`,
        );
      }
    }

    // Xác định showtime
    const showtime = await this.showtimeRepository.findOne({ where: { id: dto.showtimeId } });
    if (!showtime) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'SHOWTIME_NOT_FOUND', 'Không tìm thấy suất chiếu');
    }
    if (showtime.status === 'COMPLETED' || showtime.status === 'CANCELLED') {
      throw new CustomException(
        HttpStatus.BAD_REQUEST,
        'SHOWTIME_NOT_BOOKABLE',
        'Suất chiếu này đã kết thúc hoặc bị huỷ, không thể đặt vé',
      );
    }
    if (showtime.publicStartTime && new Date(showtime.publicStartTime) <= new Date()) {
      throw new CustomException(
        HttpStatus.BAD_REQUEST,
        BOOKING_ERROR_CODES.SHOWTIME_EXPIRED,
        'Suất chiếu đã bắt đầu hoặc quá hạn đặt vé',
      );
    }

    // Lấy thông tin ghế
    const seats = await this.seatRepository.find({
      where: { id: In(dto.seatIds) },
      relations: ['room'],
    });

    if (seats.filter(s => s.roomId === showtime.roomId).length !== dto.seatIds.length) {
      throw new CustomException(
        HttpStatus.BAD_REQUEST,
        BOOKING_ERROR_CODES.SEAT_ROOM_MISMATCH,
        'Một số ghế không thuộc phòng chiếu của suất chiếu này',
      );
    }

    const now = new Date();
    const dayOfWeek = new Date(showtime.publicStartTime).getDay();
    const dayType = (dayOfWeek === 0 || dayOfWeek === 6) ? 'WEEKEND' : 'WEEKDAY';

    // Tính tổng tiền vé
    let ticketTotal = 0;
    for (const seat of seats) {
      const isVipSeat =
        seat.room?.roomType === ERoomType.VIP ||
        (seat.room?.roomType === ERoomType.STANDARD &&
          (seat.room?.rows ?? 0) >= 6 &&
          ['D', 'E', 'F'].includes(seat.row.toUpperCase()));
      const isCoupleSeat =
        seat.room?.roomType === ERoomType.COUPLE ||
        (seat.room?.isCouple &&
          seat.row.toUpperCase() ===
            String.fromCharCode(65 + (seat.room?.rows ?? 0) - 1));
      const targetRoomType = isCoupleSeat
        ? ERoomType.COUPLE
        : isVipSeat
          ? ERoomType.VIP
          : seat.room?.roomType ?? ERoomType.STANDARD;

      let ticketPrice = await this.ticketPriceRepository.findOne({
        where: {
          roomType: targetRoomType,
          dayType: dayType as any,
        },
      });
      if (!ticketPrice) {
        ticketPrice = await this.ticketPriceRepository.findOne({
          where: {
            roomType: seat.room?.roomType,
            dayType: dayType as any,
          },
        });
      }
      if (!ticketPrice) {
        throw new CustomException(
          HttpStatus.BAD_REQUEST,
          'TICKET_PRICE_NOT_FOUND',
          'Chua cau hinh gia ve cho loai phong va ngay nay',
        );
      }
      ticketTotal += ticketPrice.price;
    }

    // Tính tổng tiền bắp nước
    const validatedConcessionData = await this.buildConcessionItems(dto.concessions || []);
    const concessionItems = [...validatedConcessionData.concessionItems];
    let concessionTotal = validatedConcessionData.concessionTotal;

    // Tính discount nếu có promotion
    let discountAmount = 0;
    let promotionId: number | undefined = undefined;

    if (dto.promotionCode) {
      if (ticketTotal + concessionTotal <= 0) {
        throw new CustomException(
          HttpStatus.BAD_REQUEST,
          'ORDER_TOTAL_ZERO',
          'Tổng tiền đơn hàng bằng 0 không thể áp dụng voucher',
        );
      }

      const promotion = await this.promotionRepository.findOne({
        where: { code: dto.promotionCode },
        relations: ['movie'],
      });

      const validatedPromo = validatePromotion(promotion, showtime.movieId);
      promotionId = validatedPromo.id;
      discountAmount = calculateDiscount(validatedPromo, ticketTotal + concessionTotal);
    }

    // ─── LOYALTY POINTS LOGIC ──────────────────────────────────────────────
    let pointsUsed = 0;
    let pointsDiscountAmount = 0;
    let redeemConcessionProduct: ConcessionProduct | null = null;

    const user = userId ? await this.userRepository.findOne({ where: { id: userId } }) : null;
    if (userId && !user) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'Không tìm thấy người dùng');
    }

    if (!user && (dto.redeemConcessionId || (dto.pointsToUse && dto.pointsToUse > 0))) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'USER_REQUIRED', 'Phải cung cấp tài khoản khách hàng để sử dụng điểm tích lũy');
    }

    // Trường hợp 1: Dùng điểm để đổi 1 combo cụ thể (redeemConcessionId)
    if (user && dto.redeemConcessionId) {
      redeemConcessionProduct = await this.concessionProductRepository.findOne({
        where: { id: dto.redeemConcessionId },
      });
      if (!redeemConcessionProduct) {
        throw new CustomException(HttpStatus.NOT_FOUND, 'PRODUCT_NOT_FOUND', 'Sản phẩm combo không tồn tại');
      }
      const pointsRequired = redeemConcessionProduct.price;
      if (user.loyaltyPoints < pointsRequired) {
        throw new CustomException(
          HttpStatus.BAD_REQUEST,
          'INSUFFICIENT_POINTS',
          `Không đủ điểm để đổi "${redeemConcessionProduct.name}". Cần ${pointsRequired.toLocaleString()} điểm, bạn có ${user.loyaltyPoints.toLocaleString()} điểm.`,
        );
      }
      pointsUsed = pointsRequired;
      // Thêm combo vào concession list nếu chưa có
      const alreadyInList = concessionItems.some(c => c.productId === dto.redeemConcessionId);
      if (!alreadyInList) {
        concessionItems.push({
          productId: redeemConcessionProduct.id,
          quantity: 1,
          unitPrice: redeemConcessionProduct.price,
          subtotal: redeemConcessionProduct.price,
        });
        concessionTotal += redeemConcessionProduct.price;
      }
      // Điểm giảm đúng bằng giá combo (trả combo free)
      pointsDiscountAmount = redeemConcessionProduct.price;
    }
    // Trường hợp 2: Dùng điểm để giảm giá trực tiếp tổng đơn
    else if (user && dto.pointsToUse && dto.pointsToUse > 0) {
      if (user.loyaltyPoints < dto.pointsToUse) {
        throw new CustomException(
          HttpStatus.BAD_REQUEST,
          'INSUFFICIENT_POINTS',
          `Không đủ điểm. Bạn có ${user.loyaltyPoints.toLocaleString()} điểm, yêu cầu ${dto.pointsToUse.toLocaleString()} điểm.`,
        );
      }
      const subTotal = ticketTotal + concessionTotal;
      const maxPointDiscount = Math.floor(subTotal * LOYALTY_MAX_DISCOUNT_RATE);
      const requestedDiscount = Math.floor(dto.pointsToUse * LOYALTY_POINT_VALUE);
      pointsDiscountAmount = Math.min(requestedDiscount, maxPointDiscount);
      pointsUsed = Math.ceil(pointsDiscountAmount / LOYALTY_POINT_VALUE);

      if (pointsUsed > user.loyaltyPoints) {
        pointsUsed = user.loyaltyPoints;
        pointsDiscountAmount = Math.floor(pointsUsed * LOYALTY_POINT_VALUE);
      }
    }

    // Trừ điểm ngay lúc tạo Booking (PENDING) để tránh double-spending
    if (userId && pointsUsed > 0) {
      await this.userRepository.update({ id: userId }, {
        loyaltyPoints: () => `loyaltyPoints - ${pointsUsed}`,
      });
    }

    const totalAmount = ticketTotal + concessionTotal - discountAmount - pointsDiscountAmount;
    const bookingCode = this.generateBookingCode();
    // Đồng bộ timeout 5 phút với Redis seat hold TTL
    const expiredAt = new Date(now.getTime() + 5 * 60 * 1000);

    // Toàn bộ tạo booking, seat holds, concessions trong 1 transaction
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    let savedBooking: Booking;

    try {
      const booking = queryRunner.manager.create(Booking, {
        userId: userId || undefined,
        staffId: staffId || undefined,
        showtimeId: dto.showtimeId,
        promotionId,
        bookingCode,
        totalAmount: Math.max(totalAmount, 0),
        discountAmount: discountAmount + pointsDiscountAmount,
        pointsUsed,
        status: EBookingStatus.PENDING,
        source: dto.source || EBookingSource.ONLINE,
        expiredAt,
      });

      savedBooking = await queryRunner.manager.save(Booking, booking);

      // Cập nhật seat holds với bookingId (pessimistic: đã kiểm tra Redis hold ở trên)
      await queryRunner.manager.update(
        SeatHold,
        {
          showtimeId: dto.showtimeId,
          seatId: In(dto.seatIds),
          userId: holderId,
          status: ESeatHoldStatus.HOLDING,
        },
        {
          bookingId: savedBooking.id,
          status: ESeatHoldStatus.CONFIRMED,
        },
      );

      // Tạo booking concessions
      if (concessionItems.length > 0) {
        const bookingConcessions = concessionItems.map(item =>
          queryRunner.manager.create(BookingConcession, {
            bookingId: savedBooking.id,
            productId: item.productId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            subtotal: item.subtotal,
          }),
        );
        await queryRunner.manager.save(BookingConcession, bookingConcessions);
      }

      // Tăng atomic usedCount nếu có promotion
      if (promotionId) {
        const updatePromoRes = await queryRunner.manager
          .createQueryBuilder(Promotion, 'promotion')
          .update()
          .set({ usedCount: () => 'usedCount + 1' })
          .where('id = :id AND (maxUsage IS NULL OR usedCount < maxUsage)', { id: promotionId })
          .execute();

        if (!updatePromoRes || updatePromoRes.affected === 0) {
          throw new CustomException(
            HttpStatus.BAD_REQUEST,
            'PROMOTION_MAX_USAGE',
            'Mã khuyến mãi đã hết lượt sử dụng',
          );
        }
      }

      await queryRunner.commitTransaction();
    } catch (err) {
      await queryRunner.rollbackTransaction();
      if (err instanceof CustomException) {
        throw err;
      }
      throw new CustomException(
        HttpStatus.INTERNAL_SERVER_ERROR,
        'BOOKING_CREATE_FAILED',
        'Tạo đơn đặt vé thất bại, vui lòng thử lại',
      );
    } finally {
      await queryRunner.release();
    }

    // Load full booking data
    const fullBooking = await this.bookingRepository.findOne({
      where: { id: savedBooking!.id },
      relations: ['bookingConcessions', 'seatHolds'],
    });

    // Emit seat-update realtime sau khi booking được xác nhận
    await this.broadcastSeatUpdate(dto.showtimeId);

    // Gửi thông báo yêu cầu thanh toán
    if (userId) {
      const pointsMsg = pointsUsed > 0 ? ` (Đã dùng ${pointsUsed.toLocaleString()} điểm tích lũy)` : '';
      this.eventEmitter.emit('notification.create', {
        userId,
        subject: 'Đơn đặt vé chờ thanh toán',
        content: `Bạn đã tạo đơn đặt vé mã ${bookingCode}. Vui lòng thanh toán ${Math.max(totalAmount, 0).toLocaleString()} VNĐ trong vòng 5 phút để hoàn tất.${pointsMsg}`,
        type: ENotificationType.SYSTEM,
        link: `/my-tickets/${savedBooking!.id}`,
      });
    }

    return new ApiResponse(true, 'Tạo đơn đặt vé thành công', fullBooking!);
  }

  // ─── QUERIES ──────────────────────────────────────────────────────────

  async getBookedSeatsForShowtime(showtimeId: number): Promise<ApiResponse<any>> {
    // Ghế đang bị hold trong Redis
    const heldSeatIds = await this.redisService.getHeldSeatIds(showtimeId);

    // Ghế đã được đặt (booking PAID hoặc PENDING còn hạn)
    const bookedSeats = await this.seatHoldRepository.find({
      where: {
        showtimeId,
        status: In([ESeatHoldStatus.CONFIRMED]),
      },
      relations: ['seat', 'booking'],
    });

    const now = new Date();
    const activeBookedSeats = bookedSeats.filter(h => {
      if (!h.booking) return true;
      if (h.booking.status === EBookingStatus.CANCELLED || h.booking.status === EBookingStatus.EXPIRED) {
        return false;
      }
      if (h.booking.status === EBookingStatus.PENDING && h.booking.expiredAt && new Date(h.booking.expiredAt) < now) {
        return false;
      }
      return true;
    });

    // Dọn dẹp các SeatHold thuộc đơn đã hủy hoặc hết hạn
    const invalidHoldIds = bookedSeats
      .filter(h => h.booking && (
        h.booking.status === EBookingStatus.CANCELLED ||
        h.booking.status === EBookingStatus.EXPIRED ||
        (h.booking.status === EBookingStatus.PENDING && h.booking.expiredAt && new Date(h.booking.expiredAt) < now)
      ))
      .map(h => h.id);

    if (invalidHoldIds.length > 0) {
      await this.seatHoldRepository.update(
        { id: In(invalidHoldIds) },
        { status: ESeatHoldStatus.RELEASED },
      );
    }

    const bookedSeatIds = activeBookedSeats.map(h => h.seatId);

    return new ApiResponse(true, 'Lấy danh sách ghế đã đặt/giữ thành công', {
      heldSeatIds,
      bookedSeatIds,
      allUnavailableSeatIds: [...new Set([...heldSeatIds, ...bookedSeatIds])],
    });
  }

  async getAllBookings(page: number = 1, pageSize: number = 10): Promise<ApiResponse<Booking[]>> {
    const currentPage = Number(page) || 1;
    const currentPageSize = Number(pageSize) || 10;
    const skip = (currentPage - 1) * currentPageSize;

    const [bookings, totalItems] = await this.bookingRepository.findAndCount({
      relations: [
        'user',
        'staff',
        'showtime',
        'showtime.movie',
        'showtime.room',
        'seatHolds',
        'seatHolds.seat',
        'tickets',
        'tickets.seat',
        'bookingConcessions',
        'bookingConcessions.product',
        'payment',
      ],
      order: { createdAt: 'DESC' },
      skip,
      take: currentPageSize,
    });

    const totalPages = Math.ceil(totalItems / currentPageSize);
    const response = new ApiResponse(true, 'Lấy danh sách đặt vé thành công', bookings);
    response.pagination = {
      page: currentPage,
      pageSize: currentPageSize,
      totalItems,
      totalPages,
    };
    return response;
  }

  async getBookingById(id: number, user?: any): Promise<ApiResponse<Booking>> {
    const booking = await this.bookingRepository.findOne({
      where: { id },
      relations: [
        'user',
        'staff',
        'showtime',
        'showtime.movie',
        'showtime.room',
        'seatHolds',
        'seatHolds.seat',
        'tickets',
        'tickets.seat',
        'bookingConcessions',
        'bookingConcessions.product',
        'payment',
      ],
    });
    if (!booking) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'BOOKING_NOT_FOUND', 'Không tìm thấy đơn đặt vé');
    }
    return new ApiResponse(true, 'Lấy chi tiết đơn đặt vé thành công', booking);
  }

  async getBookingByCode(bookingCode: string, user?: any): Promise<ApiResponse<Booking>> {
    const booking = await this.bookingRepository.findOne({
      where: { bookingCode },
      relations: [
        'user',
        'staff',
        'showtime',
        'showtime.movie',
        'showtime.room',
        'seatHolds',
        'seatHolds.seat',
        'tickets',
        'tickets.seat',
        'bookingConcessions',
        'bookingConcessions.product',
        'payment',
      ],
    });
    if (!booking) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'BOOKING_NOT_FOUND', 'Không tìm thấy đơn đặt vé');
    }
    return new ApiResponse(true, 'Lấy chi tiết đơn đặt vé thành công', booking);
  }

  async getUserBookingHistory(userId: number, page: number = 1, pageSize: number = 10): Promise<ApiResponse<Booking[]>> {
    const skip = (page - 1) * pageSize;
    const [bookings, totalItems] = await this.bookingRepository.findAndCount({
      where: { userId },
      relations: [
        'showtime',
        'showtime.movie',
        'showtime.room',
        'seatHolds',
        'seatHolds.seat',
        'tickets',
        'tickets.seat',
        'bookingConcessions',
        'payment',
      ],
      order: { createdAt: 'DESC' },
      skip,
      take: pageSize,
    });
    const totalPages = Math.ceil(totalItems / pageSize);
    const response = new ApiResponse(true, 'Lấy lịch sử đặt vé thành công', bookings);
    response.pagination = { page: Number(page), pageSize: Number(pageSize), totalItems, totalPages };
    return response;
  }

  async updateBookingConcessions(bookingId: number, userId: number, dto: any): Promise<ApiResponse<any>> {
    const booking = await this.bookingRepository.findOne({
      where: { id: bookingId },
      relations: ['bookingConcessions', 'promotion'],
    });

    if (!booking) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'BOOKING_NOT_FOUND', 'Không tìm thấy đơn đặt vé');
    }

    if (booking.userId !== userId && booking.staffId !== userId) {
      throw new CustomException(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Bạn không có quyền cập nhật đơn này');
    }

    if (booking.status !== EBookingStatus.PENDING) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'INVALID_STATUS', 'Chỉ có thể cập nhật đơn chờ thanh toán');
    }

    if (booking.expiredAt && new Date(booking.expiredAt) < new Date()) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_EXPIRED', 'Đơn đặt vé đã quá hạn giữ chỗ');
    }

    const oldConcessionsTotal = booking.bookingConcessions.reduce((sum, bc) => sum + bc.subtotal, 0);
    const ticketTotal = booking.totalAmount + booking.discountAmount - oldConcessionsTotal;

    const validatedConcessionData = await this.buildConcessionItems(dto.concessions || []);
    const concessionItems = [...validatedConcessionData.concessionItems];
    let newConcessionTotal = validatedConcessionData.concessionTotal;

    let promotionDiscount = 0;
    if (booking.promotion) {
      promotionDiscount = calculateDiscount(booking.promotion, ticketTotal + newConcessionTotal);
    }

    let pointsUsed = booking.pointsUsed || 0;
    let pointsDiscountAmount = 0;
    const user = booking.userId ? await this.userRepository.findOne({ where: { id: booking.userId } }) : null;

    if (!user && (dto.redeemConcessionId || (dto.pointsToUse && dto.pointsToUse > 0))) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'USER_REQUIRED', 'Phải cung cấp tài khoản khách hàng để sử dụng điểm tích lũy');
    }

    if (user && dto.redeemConcessionId) {
      const redeemConcessionProduct = await this.concessionProductRepository.findOne({
        where: { id: dto.redeemConcessionId },
      });
      if (!redeemConcessionProduct) {
        throw new CustomException(HttpStatus.NOT_FOUND, 'PRODUCT_NOT_FOUND', 'Sản phẩm combo không tồn tại');
      }
      const pointsRequired = redeemConcessionProduct.price;
      const availablePoints = user.loyaltyPoints + (booking.pointsUsed || 0);
      if (availablePoints < pointsRequired) {
        throw new CustomException(HttpStatus.BAD_REQUEST, 'INSUFFICIENT_POINTS', 'Không đủ điểm để đổi combo');
      }
      pointsUsed = pointsRequired;
      pointsDiscountAmount = redeemConcessionProduct.price;

      const alreadyInList = concessionItems.some(c => c.productId === dto.redeemConcessionId);
      if (!alreadyInList) {
        concessionItems.push({
          productId: redeemConcessionProduct.id,
          quantity: 1,
          unitPrice: redeemConcessionProduct.price,
          subtotal: redeemConcessionProduct.price,
        });
        newConcessionTotal += redeemConcessionProduct.price;
      }
    } else if (user && dto.pointsToUse && dto.pointsToUse > 0) {
      const availablePoints = user.loyaltyPoints + (booking.pointsUsed || 0);
      if (availablePoints < dto.pointsToUse) {
        throw new CustomException(HttpStatus.BAD_REQUEST, 'INSUFFICIENT_POINTS', 'Không đủ điểm');
      }
      const LOYALTY_MAX_DISCOUNT_RATE = 0.20;
      const LOYALTY_POINT_VALUE = 1;
      const subTotal = ticketTotal + newConcessionTotal;
      const maxPointDiscount = Math.floor(subTotal * LOYALTY_MAX_DISCOUNT_RATE);
      const requestedDiscount = Math.floor(dto.pointsToUse * LOYALTY_POINT_VALUE);
      pointsDiscountAmount = Math.min(requestedDiscount, maxPointDiscount);
      pointsUsed = Math.ceil(pointsDiscountAmount / LOYALTY_POINT_VALUE);

      if (pointsUsed > availablePoints) {
        pointsUsed = availablePoints;
        pointsDiscountAmount = Math.floor(pointsUsed * LOYALTY_POINT_VALUE);
      }
    } else {
      pointsUsed = 0;
    }

    const totalDiscountAmount = promotionDiscount + pointsDiscountAmount;
    const newTotalAmount = ticketTotal + newConcessionTotal - totalDiscountAmount;
    const pointsDifference = pointsUsed - (booking.pointsUsed || 0);

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      await queryRunner.manager.delete(BookingConcession, { bookingId });

      if (concessionItems.length > 0) {
        const newBookingConcessions = concessionItems.map(item =>
          queryRunner.manager.create(BookingConcession, {
            bookingId,
            productId: item.productId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            subtotal: item.subtotal,
          }),
        );
        await queryRunner.manager.save(BookingConcession, newBookingConcessions);
      }

      await queryRunner.manager.update(Booking, bookingId, {
        totalAmount: Math.max(newTotalAmount, 0),
        discountAmount: totalDiscountAmount,
        pointsUsed,
      });

      if (user && pointsDifference !== 0) {
        await queryRunner.manager.update(User, user.id, {
          loyaltyPoints: () => `loyaltyPoints - ${pointsDifference}`,
        });
      }

      await queryRunner.commitTransaction();
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw new CustomException(
        HttpStatus.INTERNAL_SERVER_ERROR,
        'BOOKING_UPDATE_FAILED',
        'Cập nhật bắp nước thất bại',
      );
    } finally {
      await queryRunner.release();
    }

    this.eventEmitter.emit('notification.create', {
      userId,
      subject: 'Cập nhật dịch vụ thành công',
      content: 'Đơn đặt vé của bạn đã được cập nhật thông tin bắp nước thành công.',
      type: ENotificationType.SYSTEM,
      link: `/my-tickets/${booking.id}`,
    });

    const estimatedPointsEarned = Math.floor(Math.max(newTotalAmount, 0) * 0.10);

    return new ApiResponse(true, 'Cập nhật bắp nước thành công', {
      ticketTotal,
      concessionTotal: newConcessionTotal,
      promotionDiscount,
      pointsDiscountAmount,
      comboRedeemAmount: dto.redeemConcessionId ? pointsDiscountAmount : 0,
      totalDiscountAmount,
      pointsUsed,
      totalAmount: Math.max(newTotalAmount, 0),
      estimatedPointsEarned,
      loyaltyPoints: user ? user.loyaltyPoints + (booking.pointsUsed || 0) : 0,
    });
  }

  private async buildConcessionItems(
    concessions: Array<{ productId: number; quantity: number }> = [],
  ): Promise<{
    concessionItems: { productId: number; quantity: number; unitPrice: number; subtotal: number }[];
    concessionTotal: number;
  }> {
    const quantityByProduct = new Map<number, number>();

    for (const item of concessions) {
      const productId = Number(item.productId);
      const quantity = Number(item.quantity);

      if (!Number.isInteger(productId) || !Number.isInteger(quantity) || quantity < 0) {
        throw new CustomException(
          HttpStatus.BAD_REQUEST,
          'INVALID_CONCESSION_QUANTITY',
          'So luong bap nuoc khong hop le',
        );
      }

      // Bỏ qua item quantity = 0
      if (quantity === 0) continue;

      quantityByProduct.set(productId, (quantityByProduct.get(productId) ?? 0) + quantity);
    }

    let concessionTotal = 0;
    const concessionItems: { productId: number; quantity: number; unitPrice: number; subtotal: number }[] = [];

    for (const [productId, quantity] of quantityByProduct.entries()) {
      const product = await this.concessionProductRepository.findOne({
        where: { id: productId },
      });

      if (!product) {
        throw new CustomException(
          HttpStatus.BAD_REQUEST,
          'PRODUCT_NOT_FOUND',
          `San pham #${productId} khong ton tai`,
        );
      }

      if (product.stockQuantity < quantity) {
        throw new CustomException(
          HttpStatus.BAD_REQUEST,
          'INSUFFICIENT_CONCESSION_STOCK',
          `San pham "${product.name}" chi con ${product.stockQuantity}`,
        );
      }

      const subtotal = product.price * quantity;
      concessionTotal += subtotal;
      concessionItems.push({
        productId,
        quantity,
        unitPrice: product.price,
        subtotal,
      });
    }

    return { concessionItems, concessionTotal };
  }

  // ─── RELEASE SEATS (UC07 A3.1) ─────────────────────────────────────────
  async releaseSeats(userId: number, dto: ReleaseSeatsDto): Promise<ApiResponse<any>> {
    const { showtimeId, seatIds } = dto;
    const releasedSeatIds: number[] = [];

    for (const seatId of seatIds) {
      const holder = await this.redisService.getSeatHolder(showtimeId, seatId);
      if (!holder || Number(holder) === Number(userId)) {
        await this.redisService.releaseSeat(showtimeId, seatId);
        await this.seatHoldRepository.update(
          { showtimeId, seatId, status: ESeatHoldStatus.HOLDING },
          { status: ESeatHoldStatus.RELEASED },
        );
        releasedSeatIds.push(seatId);
      }
    }

    if (releasedSeatIds.length > 0) {
      await this.broadcastSeatUpdate(showtimeId);
    }

    return new ApiResponse(true, 'Nhả ghế thành công', { releasedSeatIds });
  }

  // ─── CANCEL BOOKING ──────────────────────────────────────────────────
  async cancelBooking(userId: number, bookingId: number): Promise<ApiResponse<any>> {
    const booking = await this.bookingRepository.findOne({
      where: { id: bookingId },
      relations: ['payment', 'seatHolds'],
    });

    if (!booking) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'BOOKING_NOT_FOUND', 'Không tìm thấy đơn đặt vé');
    }

    if (booking.userId && booking.userId !== userId && booking.staffId !== userId) {
      throw new CustomException(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Bạn không có quyền hủy đơn này');
    }

    if (booking.status === EBookingStatus.PAID) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_ALREADY_PAID', 'Đơn hàng đã thanh toán, không thể hủy trực tiếp');
    }

    if (booking.status === EBookingStatus.CANCELLED || booking.status === EBookingStatus.EXPIRED) {
      return new ApiResponse(true, 'Đơn hàng đã ở trạng thái hủy/hết hạn', {
        bookingId: booking.id,
        status: booking.status,
      });
    }

    await this.bookingRepository.update({ id: booking.id }, { status: EBookingStatus.CANCELLED });

    if (booking.payment && booking.payment.status !== EPaymentStatus.SUCCESS) {
      await this.dataSource.getRepository(Payment).update({ id: booking.payment.id }, { status: EPaymentStatus.FAILED });
    }

    if (booking.promotionId) {
      await this.dataSource
        .createQueryBuilder()
        .update(Promotion)
        .set({ usedCount: () => 'GREATEST(usedCount - 1, 0)' })
        .where('id = :id', { id: booking.promotionId })
        .execute();
    }

    if (booking.pointsUsed > 0 && booking.userId) {
      await this.userRepository.update(
        { id: booking.userId },
        { loyaltyPoints: () => `loyaltyPoints + ${booking.pointsUsed}` },
      );
    }

    await this.seatHoldRepository.update(
      { bookingId: booking.id },
      { status: ESeatHoldStatus.RELEASED },
    );

    const showtimeId = booking.showtimeId;
    const seatHolds = booking.seatHolds?.length
      ? booking.seatHolds
      : await this.seatHoldRepository.find({ where: { bookingId: booking.id } });
    const seatIds = seatHolds.map(h => h.seatId);

    if (seatIds.length > 0) {
      await this.redisService.releaseSeats(showtimeId, seatIds);
    }

    await this.broadcastSeatUpdate(showtimeId);

    return new ApiResponse(true, 'Hủy đơn hàng thành công, ghế đã được giải phóng', {
      bookingId: booking.id,
      status: EBookingStatus.CANCELLED,
    });
  }

  // ─── APPLY PROMOTION (BUG-05) ─────────────────────────────────────────
  async applyPromotionToBooking(userId: number, bookingId: number, code: string): Promise<ApiResponse<any>> {
    const booking = await this.bookingRepository.findOne({
      where: { id: bookingId },
      relations: ['showtime', 'showtime.movie', 'bookingConcessions', 'promotion'],
    });

    if (!booking) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'BOOKING_NOT_FOUND', 'Không tìm thấy đơn đặt vé');
    }

    if (booking.userId !== userId) {
      throw new CustomException(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Bạn không có quyền thao tác trên đơn này');
    }

    if (booking.status !== EBookingStatus.PENDING) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_NOT_PENDING', 'Chỉ có thể áp dụng mã cho đơn chờ thanh toán');
    }

    if (booking.expiredAt && new Date(booking.expiredAt) < new Date()) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_EXPIRED', 'Đơn hàng đã hết hạn thanh toán');
    }

    const originalOrderTotal = booking.totalAmount + booking.discountAmount + (booking.pointsUsed || 0);

    if (originalOrderTotal <= 0) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'ORDER_TOTAL_ZERO', 'Tổng tiền đơn hàng bằng 0 không thể áp dụng voucher');
    }

    const promotion = await this.promotionRepository.findOne({
      where: { code },
      relations: ['movie'],
    });

    const validatedPromo = validatePromotion(promotion, booking.showtime?.movieId);

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      if (booking.promotionId && booking.promotionId !== validatedPromo.id) {
        await queryRunner.manager
          .createQueryBuilder(Promotion, 'promotion')
          .update()
          .set({ usedCount: () => 'GREATEST(usedCount - 1, 0)' })
          .where('id = :id', { id: booking.promotionId })
          .execute();
      }

      if (booking.promotionId !== validatedPromo.id) {
        const updateRes = await queryRunner.manager
          .createQueryBuilder(Promotion, 'promotion')
          .update()
          .set({ usedCount: () => 'usedCount + 1' })
          .where('id = :id AND (maxUsage IS NULL OR usedCount < maxUsage)', { id: validatedPromo.id })
          .execute();

        if (!updateRes || updateRes.affected === 0) {
          throw new CustomException(
            HttpStatus.BAD_REQUEST,
            'PROMOTION_MAX_USAGE',
            'Mã khuyến mãi đã hết lượt sử dụng',
          );
        }
      }

      const discountAmount = calculateDiscount(validatedPromo, originalOrderTotal);
      const newTotalAmount = Math.max(0, originalOrderTotal - discountAmount - (booking.pointsUsed || 0));

      await queryRunner.manager.update(Booking, { id: booking.id }, {
        promotionId: validatedPromo.id,
        discountAmount,
        totalAmount: newTotalAmount,
      });

      await queryRunner.commitTransaction();

      await this.bookingRepository.update({ id: booking.id }, {
        promotionId: validatedPromo.id,
        discountAmount,
        totalAmount: newTotalAmount,
      });

      return new ApiResponse(true, 'Áp dụng mã khuyến mãi thành công', {
        totalAmount: newTotalAmount,
        discountAmount,
        promotionCode: validatedPromo.code,
      });
    } catch (err) {
      this.logger.error(`applyPromotionToBooking failed for booking ${bookingId}, code ${code}:`, err);
      if (queryRunner.isTransactionActive) {
        await queryRunner.rollbackTransaction();
      }
      if (err instanceof CustomException) throw err;
      throw new CustomException(HttpStatus.INTERNAL_SERVER_ERROR, 'APPLY_PROMOTION_FAILED', 'Áp dụng mã khuyến mãi thất bại');
    } finally {
      await queryRunner.release();
    }
  }

  // ─── REMOVE PROMOTION (UC09 A2.1 / BUG-05) ────────────────────────────
  async removePromotionFromBooking(userId: number, bookingId: number): Promise<ApiResponse<any>> {
    const booking = await this.bookingRepository.findOne({
      where: { id: bookingId },
      relations: ['promotion'],
    });

    if (!booking) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'BOOKING_NOT_FOUND', 'Không tìm thấy đơn đặt vé');
    }

    if (booking.userId !== userId) {
      throw new CustomException(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Bạn không có quyền thao tác trên đơn này');
    }

    if (booking.status !== EBookingStatus.PENDING) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_NOT_PENDING', 'Chỉ có thể gỡ mã cho đơn chờ thanh toán');
    }

    if (booking.expiredAt && new Date(booking.expiredAt) < new Date()) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_EXPIRED', 'Đơn hàng đã hết hạn thanh toán');
    }

    if (!booking.promotionId) {
      return new ApiResponse(true, 'Đơn hàng chưa áp dụng mã khuyến mãi', {
        totalAmount: booking.totalAmount,
        discountAmount: 0,
      });
    }

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      await queryRunner.manager
        .createQueryBuilder(Promotion, 'promotion')
        .update()
        .set({ usedCount: () => 'GREATEST(usedCount - 1, 0)' })
        .where('id = :id', { id: booking.promotionId })
        .execute();

      const newTotalAmount = booking.totalAmount + booking.discountAmount;

      await queryRunner.manager.update(Booking, { id: booking.id }, {
        promotionId: null as any,
        discountAmount: 0,
        totalAmount: newTotalAmount,
      });

      await queryRunner.commitTransaction();

      await this.bookingRepository.update({ id: booking.id }, {
        promotionId: null as any,
        discountAmount: 0,
        totalAmount: newTotalAmount,
      });

      return new ApiResponse(true, 'Gỡ bỏ mã khuyến mãi thành công', {
        totalAmount: newTotalAmount,
        discountAmount: 0,
      });
    } catch (err) {
      this.logger.error(`removePromotionFromBooking failed for booking ${bookingId}:`, err);
      if (queryRunner.isTransactionActive) {
        await queryRunner.rollbackTransaction();
      }
      if (err instanceof CustomException) throw err;
      throw new CustomException(HttpStatus.INTERNAL_SERVER_ERROR, 'REMOVE_PROMOTION_FAILED', 'Gỡ bỏ mã khuyến mãi thất bại');
    } finally {
      await queryRunner.release();
    }
  }

  // ─── APPLY LOYALTY POINTS TO BOOKING ──────────────────────────────────
  async applyLoyaltyPointsToBooking(userId: number, bookingId: number, pointsToUse: number): Promise<ApiResponse<any>> {
    const booking = await this.bookingRepository.findOne({
      where: { id: bookingId },
      relations: ['promotion'],
    });

    if (!booking) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'BOOKING_NOT_FOUND', 'Không tìm thấy đơn đặt vé');
    }

    if (booking.userId !== userId) {
      throw new CustomException(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Bạn không có quyền thao tác trên đơn này');
    }

    if (booking.status !== EBookingStatus.PENDING) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_NOT_PENDING', 'Chỉ có thể áp dụng điểm cho đơn chờ thanh toán');
    }

    if (booking.expiredAt && new Date(booking.expiredAt) < new Date()) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_EXPIRED', 'Đơn hàng đã hết hạn thanh toán');
    }

    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'Không tìm thấy người dùng');
    }

    if (pointsToUse <= 0) {
      return this.removeLoyaltyPointsFromBooking(userId, bookingId);
    }

    const availablePoints = user.loyaltyPoints + (booking.pointsUsed || 0);
    if (availablePoints < pointsToUse) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'INSUFFICIENT_POINTS', 'Số điểm tích lũy không đủ');
    }

    const originalOrderTotal = booking.totalAmount + booking.discountAmount + (booking.pointsUsed || 0);
    const maxPointDiscount = Math.floor(originalOrderTotal * LOYALTY_MAX_DISCOUNT_RATE);
    const requestedDiscount = Math.floor(pointsToUse * LOYALTY_POINT_VALUE);
    const pointsDiscountAmount = Math.min(requestedDiscount, maxPointDiscount);
    const actualPointsUsed = Math.min(Math.ceil(pointsDiscountAmount / LOYALTY_POINT_VALUE), availablePoints);

    const newTotalAmount = Math.max(0, originalOrderTotal - booking.discountAmount - actualPointsUsed);
    const pointsDifference = actualPointsUsed - (booking.pointsUsed || 0);

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      await queryRunner.manager.update(Booking, { id: booking.id }, {
        pointsUsed: actualPointsUsed,
        totalAmount: newTotalAmount,
      });

      if (pointsDifference !== 0) {
        await queryRunner.manager.update(User, { id: user.id }, {
          loyaltyPoints: () => `loyaltyPoints - ${pointsDifference}`,
        });
      }

      await queryRunner.commitTransaction();

      return new ApiResponse(true, 'Áp dụng điểm tích lũy thành công', {
        totalAmount: newTotalAmount,
        discountAmount: booking.discountAmount,
        pointsUsed: actualPointsUsed,
        loyaltyPoints: availablePoints - actualPointsUsed,
      });
    } catch (err) {
      await queryRunner.rollbackTransaction();
      if (err instanceof CustomException) throw err;
      throw new CustomException(HttpStatus.INTERNAL_SERVER_ERROR, 'APPLY_POINTS_FAILED', 'Áp dụng điểm tích lũy thất bại');
    } finally {
      await queryRunner.release();
    }
  }

  // ─── REMOVE LOYALTY POINTS FROM BOOKING ───────────────────────────────
  async removeLoyaltyPointsFromBooking(userId: number, bookingId: number): Promise<ApiResponse<any>> {
    const booking = await this.bookingRepository.findOne({
      where: { id: bookingId },
    });

    if (!booking) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'BOOKING_NOT_FOUND', 'Không tìm thấy đơn đặt vé');
    }

    if (booking.userId !== userId) {
      throw new CustomException(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Bạn không có quyền thao tác trên đơn này');
    }

    if (booking.status !== EBookingStatus.PENDING) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_NOT_PENDING', 'Chỉ có thể gỡ điểm cho đơn chờ thanh toán');
    }

    if (booking.expiredAt && new Date(booking.expiredAt) < new Date()) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'BOOKING_EXPIRED', 'Đơn hàng đã hết hạn thanh toán');
    }

    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!booking.pointsUsed || booking.pointsUsed <= 0) {
      return new ApiResponse(true, 'Đơn hàng chưa sử dụng điểm tích lũy', {
        totalAmount: booking.totalAmount,
        discountAmount: booking.discountAmount,
        pointsUsed: 0,
        loyaltyPoints: user ? user.loyaltyPoints : 0,
      });
    }

    const pointsToRefund = booking.pointsUsed;
    const newTotalAmount = booking.totalAmount + pointsToRefund;

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      await queryRunner.manager.update(Booking, { id: booking.id }, {
        pointsUsed: 0,
        totalAmount: newTotalAmount,
      });

      if (user) {
        await queryRunner.manager.update(User, { id: user.id }, {
          loyaltyPoints: () => `loyaltyPoints + ${pointsToRefund}`,
        });
      }

      await queryRunner.commitTransaction();

      return new ApiResponse(true, 'Gỡ bỏ điểm tích lũy thành công', {
        totalAmount: newTotalAmount,
        discountAmount: booking.discountAmount,
        pointsUsed: 0,
        loyaltyPoints: user ? user.loyaltyPoints + pointsToRefund : 0,
      });
    } catch (err) {
      await queryRunner.rollbackTransaction();
      if (err instanceof CustomException) throw err;
      throw new CustomException(HttpStatus.INTERNAL_SERVER_ERROR, 'REMOVE_POINTS_FAILED', 'Gỡ bỏ điểm tích lũy thất bại');
    } finally {
      await queryRunner.release();
    }
  }

  private generateBookingCode(): string {
    const prefix = 'BK';
    const timestamp = Date.now().toString(36).toUpperCase();
    const random = Math.random().toString(36).substring(2, 6).toUpperCase();
    return `${prefix}-${timestamp}-${random}`;
  }

  // ─── Socket Broadcast Helper ──────────────────────────────────────────

  /**
   * Lấy trạng thái ghế hiện tại từ Redis + DB rồi broadcast tới
   * tất cả client đang xem suất chiếu đó qua WebSocket.
   * Nếu SeatGateway chưa được khởi tạo thì bỏ qua (optional injection).
   */
  private async broadcastSeatUpdate(showtimeId: number): Promise<void> {
    if (!this.seatGateway) return;

    // Ghế đang bị giữ trong Redis (hold tạm)
    const heldSeatIds = await this.redisService.getHeldSeatIds(showtimeId);

    // Ghế đã được đặt chính thức (CONFIRMED)
    const confirmedHolds = await this.seatHoldRepository.find({
      where: { showtimeId, status: ESeatHoldStatus.CONFIRMED },
      relations: ['booking'],
    });
    const now = new Date();
    const validConfirmed = confirmedHolds.filter((h) => {
      if (!h.booking) return true;
      if (h.booking.status === EBookingStatus.CANCELLED || h.booking.status === EBookingStatus.EXPIRED) return false;
      if (h.booking.status === EBookingStatus.PENDING && h.booking.expiredAt && new Date(h.booking.expiredAt) < now) return false;
      return true;
    });
    const bookedSeatIds = validConfirmed.map((h) => h.seatId);
    this.seatGateway.emitSeatUpdate(showtimeId, heldSeatIds, bookedSeatIds);
  }

  async staffHoldSeats(staffId: number, dto: HoldSeatsDto | any): Promise<ApiResponse<any>> {
    return this.holdSeats(staffId, dto);
  }

  async staffCreateBooking(staffId: number, dto: CreateBookingDto | any): Promise<ApiResponse<Booking>> {
    const customerId = dto.customerId || null;
    return this.createBooking(customerId, dto, staffId);
  }
}
