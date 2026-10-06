import { Injectable, HttpStatus, Optional } from '@nestjs/common';
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
      });
      if (confirmedHold) {
        throw new CustomException(
          HttpStatus.BAD_REQUEST,
          BOOKING_ERROR_CODES.SEAT_ALREADY_BOOKED,
          `Ghế ${seatId} đã được đặt/bán`,
        );
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
      const ticketPrice = await this.ticketPriceRepository.findOne({
        where: {
          roomType: seat.room?.roomType,
          dayType: dayType as any,
        },
      });
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
          .set({ usedCount: () => 'used_count + 1' })
          .where('id = :id AND (max_usage IS NULL OR used_count < max_usage)', { id: promotionId })
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
        link: '/booking-history',
      });
    }

    return new ApiResponse(true, 'Tạo đơn đặt vé thành công', fullBooking!);
  }

  // ─── QUERIES ──────────────────────────────────────────────────────────

  async getBookedSeatsForShowtime(showtimeId: number): Promise<ApiResponse<any>> {
    // Ghế đang bị hold trong Redis
    const heldSeatIds = await this.redisService.getHeldSeatIds(showtimeId);

    // Ghế đã được đặt (booking PAID)
    const bookedSeats = await this.seatHoldRepository.find({
      where: {
        showtimeId,
        status: In([ESeatHoldStatus.CONFIRMED]),
      },
      relations: ['seat'],
    });

    const bookedSeatIds = bookedSeats.map(h => h.seatId);

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
      link: '/booking-history',
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
      select: ['seatId'],
    });
    const bookedSeatIds = confirmedHolds.map((h) => h.seatId);
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
