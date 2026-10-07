import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  ParseIntPipe,
  UseGuards,
  HttpCode,
  HttpStatus,
  Request,
} from '@nestjs/common';
import { ShiftService } from './shift.service';
import {
  CreateShiftDto,
  UpdateShiftDto,
  CreateStaffScheduleDto,
  UpdateStaffScheduleDto,
  GetSchedulesQueryDto,
} from './dto/shift.dto';
import { JwtAuthGuard } from '../../core/security/jwt/jwt-auth.guard';
import { RolesGuard } from '../../core/security/roles/roles.guard';
import { Roles } from '../../core/security/roles/roles.decorator';
import { EUserRole } from '../users/enums/user.enum';

@Controller('shifts')
export class ShiftController {
  constructor(private readonly shiftService: ShiftService) {}

  // --- SHIFTS MASTER DATA ---
  @Get()
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async getAllShifts() {
    const data = await this.shiftService.getAllShifts();
    return { success: true, message: 'Lấy danh sách ca làm việc thành công', data };
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  async createShift(@Body() dto: CreateShiftDto) {
    const data = await this.shiftService.createShift(dto);
    return { success: true, message: 'Tạo ca làm việc thành công', data };
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  async updateShift(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateShiftDto,
  ) {
    const data = await this.shiftService.updateShift(id, dto);
    return { success: true, message: 'Cập nhật ca làm việc thành công', data };
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  async deleteShift(@Param('id', ParseIntPipe) id: number) {
    return this.shiftService.deleteShift(id);
  }

  // --- STAFF SCHEDULES ---
  @Get('schedules/me')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.STAFF, EUserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  async getMySchedule(
    @Request() req,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const data = await this.shiftService.getMySchedule(req.user.id, startDate, endDate);
    return { success: true, message: 'Lấy lịch làm việc cá nhân thành công', data };
  }

  @Get('schedules')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN, EUserRole.STAFF)
  @HttpCode(HttpStatus.OK)
  async getSchedules(@Query() query: GetSchedulesQueryDto) {
    const data = await this.shiftService.getSchedules(query);
    return { success: true, message: 'Lấy danh sách lịch phân ca thành công', data };
  }

  @Post('schedules')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  async createSchedule(
    @Body() dto: CreateStaffScheduleDto,
    @Request() req,
  ) {
    const data = await this.shiftService.createSchedule(dto, req.user?.id);
    return { success: true, message: 'Phân ca làm việc thành công', data };
  }

  @Put('schedules/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  async updateSchedule(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateStaffScheduleDto,
  ) {
    const data = await this.shiftService.updateSchedule(id, dto);
    return { success: true, message: 'Cập nhật phân ca thành công', data };
  }

  @Delete('schedules/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(EUserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  async deleteSchedule(@Param('id', ParseIntPipe) id: number) {
    return this.shiftService.deleteSchedule(id);
  }
}
