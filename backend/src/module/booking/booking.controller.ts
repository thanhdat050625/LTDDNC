import {
  Controller, Get, Post, Put, Delete, Body, Param, ParseIntPipe,
  Query, UseGuards, HttpCode, HttpStatus, Request,
} from '@nestjs/common';
import { BookingService } from './booking.service';
import { HoldSeatsDto, CreateBookingDto, ReleaseSeatsDto, ApplyPromotionDto, ApplyLoyaltyPointsDto } from './dto/booking.dto';
import { UpdateBookingConcessionsDto } from './dto/update-concessions.dto';
import { JwtAuthGuard } from '../../core/security/jwt/jwt-auth.guard';
import { RolesGuard } from '../../core/security/roles/roles.guard';
import { Roles } from '../../core/security/roles/roles.decorator';
import { EUserRole } from '../users/enums/user.enum';

@Controller('bookings')
export class BookingController {
  constructor(private readonly bookingService: BookingService) { }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN, EUserRole.STAFF)
  @HttpCode(HttpStatus.OK)
  async getAllBookings(
    @Query('page') page: number = 1,
    @Query('pageSize') pageSize: number = 10,
  ) {
    return this.bookingService.getAllBookings(page, pageSize);
  }

  @Post('hold-seats')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async holdSeats(@Request() req, @Body() dto: HoldSeatsDto) {
    return this.bookingService.holdSeats(req.user.id, dto);
  }

  @Post('release-seats')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async releaseSeats(@Request() req, @Body() dto: ReleaseSeatsDto) {
    return this.bookingService.releaseSeats(req.user.id, dto);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  async createBooking(@Request() req, @Body() dto: CreateBookingDto) {
    return this.bookingService.createBooking(req.user.id, dto);
  }

  @Post(':id/cancel')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async cancelBooking(
    @Request() req,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.bookingService.cancelBooking(req.user.id, id);
  }

  @Post(':id/promotion')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async applyPromotion(
    @Request() req,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ApplyPromotionDto,
  ) {
    return this.bookingService.applyPromotionToBooking(req.user.id, id, dto.code);
  }

  @Delete(':id/promotion')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async removePromotion(
    @Request() req,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.bookingService.removePromotionFromBooking(req.user.id, id);
  }

  @Post(':id/loyalty-points')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async applyLoyaltyPoints(
    @Request() req,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ApplyLoyaltyPointsDto,
  ) {
    return this.bookingService.applyLoyaltyPointsToBooking(req.user.id, id, dto.pointsToUse);
  }

  @Delete(':id/loyalty-points')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async removeLoyaltyPoints(
    @Request() req,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.bookingService.removeLoyaltyPointsFromBooking(req.user.id, id);
  }

  @Post('staff/hold-seats')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN, EUserRole.STAFF)
  @HttpCode(HttpStatus.OK)
  async staffHoldSeats(@Request() req, @Body() dto: HoldSeatsDto) {
    return this.bookingService.staffHoldSeats(req.user.id, dto);
  }

  @Post('staff')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN, EUserRole.STAFF)
  @HttpCode(HttpStatus.CREATED)
  async staffCreateBooking(@Request() req, @Body() dto: CreateBookingDto) {
    return this.bookingService.staffCreateBooking(req.user.id, dto);
  }

  @Put(':id/concessions')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async updateBookingConcessions(
    @Request() req,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateBookingConcessionsDto,
  ) {
    return this.bookingService.updateBookingConcessions(id, req.user.id, dto);
  }

  @Get('showtime/:showtimeId/seats')
  @HttpCode(HttpStatus.OK)
  async getBookedSeatsForShowtime(@Param('showtimeId', ParseIntPipe) showtimeId: number) {
    return this.bookingService.getBookedSeatsForShowtime(showtimeId);
  }

  @Get('my-bookings')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async getUserBookingHistory(
    @Request() req,
    @Query('page') page: number = 1,
    @Query('pageSize') pageSize: number = 10,
  ) {
    return this.bookingService.getUserBookingHistory(req.user.id, page, pageSize);
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async getBookingById(
    @Request() req,
    @Param('id') id: string,
  ) {
    const numId = Number(id);
    if (!isNaN(numId)) {
      return this.bookingService.getBookingById(numId, req.user);
    }
    return this.bookingService.getBookingByCode(id, req.user);
  }
}
