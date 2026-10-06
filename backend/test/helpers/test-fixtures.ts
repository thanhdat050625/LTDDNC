import { EBookingStatus, EBookingSource, ESeatHoldStatus } from '../../src/module/booking/enums/booking.enum';
import { EPaymentMethod, EPaymentStatus, EPaymentChannel } from '../../src/module/payment/enums/payment.enum';
import { Booking } from '../../src/module/booking/entities/booking.entity';
import { Payment } from '../../src/module/payment/entities/payment.entity';
import { SeatHold } from '../../src/module/booking/entities/seat-hold.entity';
import { BookingConcession } from '../../src/module/booking/entities/booking-concession.entity';
import { User } from '../../src/module/users/entities/user.entity';
import { Showtime } from '../../src/module/showtime/entities/showtime.entity';
import { Movie } from '../../src/module/movie/entities/movie.entity';
import { Room } from '../../src/module/cinema/entities/room.entity';
import { Seat } from '../../src/module/cinema/entities/seat.entity';
import { Ticket } from '../../src/module/ticket/entities/ticket.entity';

export function createMockUser(override?: Partial<User>): User {
  return {
    id: 1,
    fullName: 'Nguyễn Văn A',
    email: 'khachhang@cineplex.vn',
    password: 'hashed-password',
    phoneNumber: '0901234567',
    role: 'USER' as any,
    loyaltyPoints: 50000,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...override,
  } as User;
}

export function createMockMovie(override?: Partial<Movie>): Movie {
  return {
    id: 1,
    title: 'Dune: Hành Tinh Cát - Phần 2',
    description: 'Phim khoa học viễn tưởng hoành tráng',
    durationMinutes: 166,
    posterUrl: 'https://cdn.cineplex.vn/poster/dune2.jpg',
    trailerUrl: 'https://youtube.com/watch?v=dune2',
    director: 'Denis Villeneuve',
    cast: 'Timothée Chalamet, Zendaya',
    ageRating: 'P' as any,
    releaseDate: new Date('2026-03-01'),
    endDate: new Date('2026-04-30'),
    status: 'NOW_SHOWING' as any,
    genres: [],
    showtimes: [],
    promotions: [],
    createdAt: new Date(),
    updatedAt: new Date(),
    ...override,
  } as Movie;
}

export function createMockRoom(override?: Partial<Room>): Room {
  return {
    id: 1,
    cinemaId: 1,
    name: 'Phòng 01 (IMAX Laser)',
    roomType: 'IMAX',
    totalSeats: 120,
    rows: 10,
    columns: 12,
    isCouple: false,
    status: 'ACTIVE' as any,
    seats: [],
    showtimes: [],
    createdAt: new Date(),
    updatedAt: new Date(),
    ...override,
  } as Room;
}

export function createMockSeat(id: number, row: string, number: number, override?: Partial<Seat>): Seat {
  return {
    id,
    roomId: 1,
    row,
    number,
    seatType: 'VIP' as any,
    isActive: true,
    ...override,
  } as Seat;
}

export function createMockShowtime(override?: Partial<Showtime>): Showtime {
  const future = new Date(Date.now() + 2 * 60 * 60 * 1000); // 2 tiếng sau
  return {
    id: 101,
    movieId: 1,
    roomId: 1,
    format: '2D',
    publicStartTime: future,
    publicEndTime: new Date(future.getTime() + 166 * 60 * 1000),
    status: 'SCHEDULED' as any,
    movie: createMockMovie(),
    room: createMockRoom(),
    seatHolds: [],
    bookings: [],
    createdAt: new Date(),
    updatedAt: new Date(),
    ...override,
  } as Showtime;
}

export function createMockSeatHold(seatId: number, userId: number, bookingId?: number, override?: Partial<SeatHold>): SeatHold {
  const now = new Date();
  return {
    id: seatId,
    showtimeId: 101,
    seatId,
    userId,
    bookingId,
    heldAt: now,
    expiredAt: new Date(now.getTime() + 5 * 60 * 1000),
    status: ESeatHoldStatus.CONFIRMED,
    seat: createMockSeat(seatId, 'F', seatId),
    ...override,
  } as SeatHold;
}

export function createMockBookingConcession(productId: number, quantity: number, unitPrice: number): BookingConcession {
  return {
    id: productId,
    bookingId: 1,
    productId,
    quantity,
    unitPrice,
    subtotal: quantity * unitPrice,
    product: {
      id: productId,
      name: 'Combo Bắp Nước 1',
      price: unitPrice,
      stockQuantity: 100,
    } as any,
  } as BookingConcession;
}

export function createMockBooking(override?: Partial<Booking>): Booking {
  const now = new Date();
  return {
    id: 1,
    userId: 1,
    showtimeId: 101,
    bookingCode: 'BK-TEST-1234',
    totalAmount: 200000,
    discountAmount: 0,
    pointsUsed: 0,
    status: EBookingStatus.PENDING,
    source: EBookingSource.ONLINE,
    expiredAt: new Date(now.getTime() + 5 * 60 * 1000), // còn 5 phút
    createdAt: now,
    updatedAt: now,
    seatHolds: [
      createMockSeatHold(1, 1, 1),
      createMockSeatHold(2, 1, 1),
    ],
    bookingConcessions: [],
    tickets: [],
    showtime: createMockShowtime(),
    user: createMockUser(),
    ...override,
  } as Booking;
}

export function createMockTicket(booking: Booking, seatHold: SeatHold): Ticket {
  return {
    id: seatHold.seatId,
    bookingId: booking.id,
    seatId: seatHold.seatId,
    qrCode: `TICKET-${booking.bookingCode}-${seatHold.seatId}`,
    ticketPrice: 100000,
    status: 'VALID' as any,
    createdAt: new Date(),
    updatedAt: new Date(),
    booking,
    seat: seatHold.seat,
  } as unknown as Ticket;
}

/**
 * Mock QueryRunner có transaction atomic
 */
export function createMockQueryRunner(initialBooking?: Booking) {
  let inTransaction = false;
  let currentBooking = initialBooking ? { ...initialBooking } : null;
  const updates: Record<string, any>[] = [];

  const manager = {
    findOne: jest.fn().mockImplementation((entityClass, options) => {
      if (options?.where?.id === currentBooking?.id) {
        return Promise.resolve(currentBooking);
      }
      return Promise.resolve(null);
    }),
    find: jest.fn().mockImplementation((entityClass, options) => {
      if (entityClass === BookingConcession) {
        return Promise.resolve(currentBooking?.bookingConcessions || []);
      }
      return Promise.resolve([]);
    }),
    create: jest.fn().mockImplementation((entityClass, data) => ({
      id: Math.floor(Math.random() * 1000) + 1,
      ...data,
    })),
    save: jest.fn().mockImplementation((entityClass, data) => {
      return Promise.resolve(data);
    }),
    update: jest.fn().mockImplementation((entityClass, criteria, partialEntity) => {
      updates.push({ entityClass, criteria, partialEntity });
      if (currentBooking && (criteria.id === currentBooking.id || criteria === currentBooking.id)) {
        Object.assign(currentBooking, partialEntity);
      }
      return Promise.resolve({ affected: 1 });
    }),
    delete: jest.fn().mockResolvedValue({ affected: 1 }),
    createQueryBuilder: jest.fn().mockReturnValue({
      update: jest.fn().mockReturnThis(),
      set: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      execute: jest.fn().mockResolvedValue({ affected: 1 }),
    }),
  };

  return {
    manager,
    connect: jest.fn().mockResolvedValue(undefined),
    startTransaction: jest.fn().mockImplementation(() => {
      inTransaction = true;
      return Promise.resolve();
    }),
    commitTransaction: jest.fn().mockImplementation(() => {
      inTransaction = false;
      return Promise.resolve();
    }),
    rollbackTransaction: jest.fn().mockImplementation(() => {
      inTransaction = false;
      return Promise.resolve();
    }),
    release: jest.fn().mockResolvedValue(undefined),
    get isInTransaction() {
      return inTransaction;
    },
    getCurrentBooking() {
      return currentBooking;
    },
    getUpdates() {
      return updates;
    },
  };
}

export function createMockTicketPrice(roomType: any = 'IMAX', dayType: any = 'WEEKDAY', price: number = 100000) {
  return {
    id: 1,
    roomType,
    dayType,
    price,
    tickets: [],
  };
}

export function createMockPromotion(override?: any) {
  const now = new Date();
  const startDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  const endDate = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
  return {
    id: 1,
    code: 'GIAM20K',
    description: 'Giảm 20.000đ cho đơn hàng',
    discountType: 'FIXED_AMOUNT',
    discountValue: 20000,
    startDate,
    endDate,
    maxUsage: 100,
    usedCount: 5,
    isActive: true,
    movieId: undefined,
    movie: undefined,
    bookings: [],
    createdAt: new Date(),
    updatedAt: new Date(),
    ...override,
  };
}

export function createMockConcessionProduct(override?: any) {
  return {
    id: 1,
    name: 'Combo Bắp Nước 1 (1 Bắp ngọt + 1 Nước ngọt)',
    price: 65000,
    stockQuantity: 50,
    description: 'Bắp rang bơ thơm ngon kèm nước ngọt có gas',
    imageUrl: 'https://cdn.cineplex.vn/concession/combo1.jpg',
    bookingConcessions: [],
    ...override,
  };
}
