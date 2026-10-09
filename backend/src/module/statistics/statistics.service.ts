import { Injectable, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Booking } from '../booking/entities/booking.entity';
import { Movie } from '../movie/entities/movie.entity';
import { Showtime } from '../showtime/entities/showtime.entity';
import { Ticket } from '../ticket/entities/ticket.entity';
import { Cinema } from '../cinema/entities/cinema.entity';
import { ApiResponse } from '../../core/dto/ApiResponse.dto';
import { CustomException } from '../../core/exceptions/custom.exception';
import { EBookingStatus } from '../booking/enums/booking.enum';

@Injectable()
export class StatisticsService {
  constructor(
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
    @InjectRepository(Movie)
    private movieRepository: Repository<Movie>,
    @InjectRepository(Showtime)
    private showtimeRepository: Repository<Showtime>,
    @InjectRepository(Ticket)
    private ticketRepository: Repository<Ticket>,
    @InjectRepository(Cinema)
    private cinemaRepository: Repository<Cinema>,
  ) {}

  async getRevenueStatistics(
    filterType: string = 'year',
    year?: number,
    month?: number,
    startDate?: string,
    endDate?: string,
  ): Promise<ApiResponse<any>> {
    try {
      const now = new Date();
      const targetYear = year || now.getFullYear();
      const targetMonth = month || (now.getMonth() + 1);

      const queryBuilder = this.bookingRepository.createQueryBuilder('booking')
        .select('SUM(booking.totalAmount)', 'totalRevenue')
        .where('booking.status = :status', { status: EBookingStatus.PAID });

      const revenueMap = new Map<string, number>();

      if (filterType === 'year') {
        // Mode 1: Theo năm -> 12 tháng (01 đến 12)
        queryBuilder
          .andWhere('YEAR(booking.createdAt) = :year', { year: targetYear })
          .addSelect("DATE_FORMAT(booking.createdAt, '%Y-%m')", 'period')
          .groupBy("DATE_FORMAT(booking.createdAt, '%Y-%m')")
          .orderBy('period', 'ASC');

        const rawData = await queryBuilder.getRawMany();
        rawData.forEach((item) => {
          revenueMap.set(item.period, Number(item.totalRevenue) || 0);
        });

        const formattedData: { period: string; revenue: number }[] = [];
        for (let m = 1; m <= 12; m++) {
          const mStr = m < 10 ? `0${m}` : `${m}`;
          const period = `${targetYear}-${mStr}`;
          formattedData.push({
            period,
            revenue: revenueMap.get(period) || 0,
          });
        }
        return new ApiResponse(true, 'Lấy thống kê doanh thu theo năm thành công', formattedData);

      } else if (filterType === 'month') {
        // Mode 2: Theo tháng -> các ngày trong tháng (01 đến 28/29/30/31)
        queryBuilder
          .andWhere('YEAR(booking.createdAt) = :year', { year: targetYear })
          .andWhere('MONTH(booking.createdAt) = :month', { month: targetMonth })
          .addSelect("DATE_FORMAT(booking.createdAt, '%Y-%m-%d')", 'period')
          .groupBy("DATE_FORMAT(booking.createdAt, '%Y-%m-%d')")
          .orderBy('period', 'ASC');

        const rawData = await queryBuilder.getRawMany();
        rawData.forEach((item) => {
          revenueMap.set(item.period, Number(item.totalRevenue) || 0);
        });

        const daysInMonth = new Date(targetYear, targetMonth, 0).getDate();
        const mStr = targetMonth < 10 ? `0${targetMonth}` : `${targetMonth}`;
        const formattedData: { period: string; revenue: number }[] = [];
        for (let d = 1; d <= daysInMonth; d++) {
          const dStr = d < 10 ? `0${d}` : `${d}`;
          const period = `${targetYear}-${mStr}-${dStr}`;
          formattedData.push({
            period,
            revenue: revenueMap.get(period) || 0,
          });
        }
        return new ApiResponse(true, 'Lấy thống kê doanh thu theo tháng thành công', formattedData);

      } else {
        // Mode 3: Khoảng ngày từ startDate đến endDate
        let start = startDate ? new Date(startDate) : new Date(now.getTime() - 13 * 24 * 60 * 60 * 1000);
        let end = endDate ? new Date(endDate) : now;

        if (isNaN(start.getTime()) || isNaN(end.getTime())) {
          start = new Date(now.getTime() - 13 * 24 * 60 * 60 * 1000);
          end = now;
        }
        if (start > end) {
          const temp = start;
          start = end;
          end = temp;
        }

        const formatIsoDate = (d: Date) => {
          const y = d.getFullYear();
          const m = String(d.getMonth() + 1).padStart(2, '0');
          const day = String(d.getDate()).padStart(2, '0');
          return `${y}-${m}-${day}`;
        };

        const startStr = formatIsoDate(start);
        const endStr = formatIsoDate(end);

        queryBuilder
          .andWhere('booking.createdAt >= :startDateTime', { startDateTime: `${startStr} 00:00:00` })
          .andWhere('booking.createdAt <= :endDateTime', { endDateTime: `${endStr} 23:59:59` })
          .addSelect("DATE_FORMAT(booking.createdAt, '%Y-%m-%d')", 'period')
          .groupBy("DATE_FORMAT(booking.createdAt, '%Y-%m-%d')")
          .orderBy('period', 'ASC');

        const rawData = await queryBuilder.getRawMany();
        rawData.forEach((item) => {
          revenueMap.set(item.period, Number(item.totalRevenue) || 0);
        });

        const formattedData: { period: string; revenue: number }[] = [];
        const curr = new Date(start);
        curr.setHours(0, 0, 0, 0);
        const endBoundary = new Date(end);
        endBoundary.setHours(0, 0, 0, 0);

        while (curr <= endBoundary) {
          const period = formatIsoDate(curr);
          formattedData.push({
            period,
            revenue: revenueMap.get(period) || 0,
          });
          curr.setDate(curr.getDate() + 1);
        }
        return new ApiResponse(true, 'Lấy thống kê doanh thu theo khoảng ngày thành công', formattedData);
      }
    } catch (error) {
      console.error('getRevenueStatistics Error:', error);
      throw new CustomException(
        HttpStatus.INTERNAL_SERVER_ERROR,
        'STATISTICS_ERROR',
        'Lỗi khi lấy thống kê doanh thu',
      );
    }
  }

  async getMoviePerformance(
    filterType: string = 'year',
    year?: number,
    month?: number,
    startDate?: string,
    endDate?: string,
  ): Promise<ApiResponse<any>> {
    try {
      const now = new Date();
      const targetYear = year || now.getFullYear();
      const targetMonth = month || (now.getMonth() + 1);

      const queryBuilder = this.movieRepository.createQueryBuilder('movie')
        .innerJoin('movie.showtimes', 'showtime')
        .innerJoin('showtime.tickets', 'ticket', 'ticket.status != :ticketStatus', { ticketStatus: 'CANCELLED' })
        .innerJoin('ticket.booking', 'booking', 'booking.status = :bookingStatus', { bookingStatus: EBookingStatus.PAID })
        .select('movie.id', 'id')
        .addSelect('movie.title', 'title')
        .addSelect('movie.posterUrl', 'poster')
        .addSelect('COUNT(ticket.id)', 'ticketsSold')
        .addSelect('SUM(ticket.price)', 'revenue');

      let startStr = '';
      let endStr = '';

      if (filterType === 'year') {
        queryBuilder.andWhere('YEAR(booking.createdAt) = :year', { year: targetYear });
      } else if (filterType === 'month') {
        queryBuilder
          .andWhere('YEAR(booking.createdAt) = :year', { year: targetYear })
          .andWhere('MONTH(booking.createdAt) = :month', { month: targetMonth });
      } else {
        let start = startDate ? new Date(startDate) : new Date(now.getTime() - 13 * 24 * 60 * 60 * 1000);
        let end = endDate ? new Date(endDate) : now;

        if (isNaN(start.getTime()) || isNaN(end.getTime())) {
          start = new Date(now.getTime() - 13 * 24 * 60 * 60 * 1000);
          end = now;
        }
        if (start > end) {
          const temp = start;
          start = end;
          end = temp;
        }

        const formatIsoDate = (d: Date) => {
          const y = d.getFullYear();
          const m = String(d.getMonth() + 1).padStart(2, '0');
          const day = String(d.getDate()).padStart(2, '0');
          return `${y}-${m}-${day}`;
        };

        startStr = formatIsoDate(start);
        endStr = formatIsoDate(end);

        queryBuilder
          .andWhere('booking.createdAt >= :startDateTime', { startDateTime: `${startStr} 00:00:00` })
          .andWhere('booking.createdAt <= :endDateTime', { endDateTime: `${endStr} 23:59:59` });
      }

      queryBuilder
        .groupBy('movie.id')
        .addGroupBy('movie.title')
        .addGroupBy('movie.posterUrl')
        .orderBy('ticketsSold', 'DESC')
        .addOrderBy('revenue', 'DESC')
        .limit(20);

      const moviesStats = await queryBuilder.getRawMany();

      const performanceData: any[] = [];

      for (const stat of moviesStats) {
        const movieId = stat.id;
        
        const showtimeQuery = this.showtimeRepository.createQueryBuilder('showtime')
          .leftJoinAndSelect('showtime.room', 'room')
          .where('showtime.movieId = :movieId', { movieId });

        if (filterType === 'year') {
          showtimeQuery.andWhere('YEAR(showtime.publicStartTime) = :year', { year: targetYear });
        } else if (filterType === 'month') {
          showtimeQuery
            .andWhere('YEAR(showtime.publicStartTime) = :year', { year: targetYear })
            .andWhere('MONTH(showtime.publicStartTime) = :month', { month: targetMonth });
        } else if (startStr && endStr) {
          showtimeQuery
            .andWhere('showtime.publicStartTime >= :startDateTime', { startDateTime: `${startStr} 00:00:00` })
            .andWhere('showtime.publicStartTime <= :endDateTime', { endDateTime: `${endStr} 23:59:59` });
        }

        const showtimes = await showtimeQuery.getMany();

        let totalCapacity = 0;
        showtimes.forEach(st => {
          if (st.room && st.room.totalSeats) {
            totalCapacity += st.room.totalSeats;
          }
        });

        const ticketsSold = Number(stat.ticketsSold) || 0;
        let occupancyRate = 0;
        if (totalCapacity > 0) {
          occupancyRate = Math.min(100, Math.round((ticketsSold / totalCapacity) * 100));
        }

        performanceData.push({
          id: movieId,
          title: stat.title,
          poster: stat.poster,
          ticketsSold,
          revenue: Number(stat.revenue) || 0,
          occupancyRate,
        });
      }

      return new ApiResponse(true, 'Lấy thống kê hiệu suất phim thành công', performanceData);
    } catch (error) {
      console.error('getMoviePerformance Error: ', error);
      throw new CustomException(
        HttpStatus.INTERNAL_SERVER_ERROR,
        'STATISTICS_ERROR',
        'Lỗi khi lấy thống kê hiệu suất phim',
      );
    }
  }

  async getSummary(): Promise<ApiResponse<any>> {
    try {
      const rawRevenue = await this.bookingRepository.createQueryBuilder('booking')
        .select('SUM(booking.totalAmount)', 'totalRevenue')
        .where('booking.status = :status', { status: EBookingStatus.PAID })
        .getRawOne();
      const totalRevenue = rawRevenue ? rawRevenue.totalRevenue : 0;

      const totalTickets = await this.ticketRepository.count({
        where: { booking: { status: EBookingStatus.PAID } },
        relations: ['booking'],
      });

      const checkedInTickets = await this.ticketRepository.count({
        where: { isCheckedIn: true },
      });

      const totalCinemas = await this.cinemaRepository.count();

      const activeMovies = await this.movieRepository.createQueryBuilder('movie')
        .where('movie.status IN (:...statuses)', { statuses: ['NOW_SHOWING', 'ACTIVE', 'SHOWING'] })
        .getCount();

      return new ApiResponse(true, 'Lấy tổng quan thành công', {
        revenue: Number(totalRevenue) || 0,
        tickets: totalTickets,
        checkedInTickets,
        cinemas: totalCinemas,
        activeMovies,
      });
    } catch (error) {
      throw new CustomException(
        HttpStatus.INTERNAL_SERVER_ERROR,
        'STATISTICS_ERROR',
        'Lỗi khi lấy tổng quan',
      );
    }
  }
}
