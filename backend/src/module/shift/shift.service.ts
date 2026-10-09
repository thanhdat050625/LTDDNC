import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
  OnModuleInit,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { Shift } from './entities/shift.entity';
import { StaffSchedule } from './entities/staff-schedule.entity';
import { User } from '../users/entities/user.entity';
import { Cinema } from '../cinema/entities/cinema.entity';
import {
  CreateShiftDto,
  UpdateShiftDto,
  CreateStaffScheduleDto,
  UpdateStaffScheduleDto,
  GetSchedulesQueryDto,
} from './dto/shift.dto';
import { EUserRole } from '../users/enums/user.enum';

@Injectable()
export class ShiftService implements OnModuleInit {
  constructor(
    @InjectRepository(Shift)
    private readonly shiftRepo: Repository<Shift>,
    @InjectRepository(StaffSchedule)
    private readonly scheduleRepo: Repository<StaffSchedule>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(Cinema)
    private readonly cinemaRepo: Repository<Cinema>,
  ) {}



  // --- SHIFTS MASTER DATA ---
  async getAllShifts(): Promise<Shift[]> {
    return this.shiftRepo.find({
      order: { startTime: 'ASC' },
    });
  }

  async getShiftById(id: number): Promise<Shift> {
    const shift = await this.shiftRepo.findOne({ where: { id } });
    if (!shift) {
      throw new NotFoundException(`Không tìm thấy ca làm việc với ID ${id}`);
    }
    return shift;
  }

  async createShift(dto: CreateShiftDto): Promise<Shift> {
    const shift = this.shiftRepo.create(dto);
    return this.shiftRepo.save(shift);
  }

  async updateShift(id: number, dto: UpdateShiftDto): Promise<Shift> {
    const shift = await this.getShiftById(id);
    Object.assign(shift, dto);
    return this.shiftRepo.save(shift);
  }

  async deleteShift(id: number): Promise<{ success: boolean; message: string }> {
    const shift = await this.getShiftById(id);
    await this.shiftRepo.remove(shift);
    return { success: true, message: 'Xóa ca làm việc thành công' };
  }

  // --- STAFF SCHEDULES ---
  async getSchedules(query: GetSchedulesQueryDto): Promise<StaffSchedule[]> {
    const where: any = {};

    if (query.cinemaId) {
      where.cinemaId = query.cinemaId;
    }
    if (query.staffId) {
      where.staffId = query.staffId;
    }
    if (query.startDate && query.endDate) {
      where.workDate = Between(query.startDate, query.endDate);
    } else if (query.startDate) {
      where.workDate = MoreThanOrEqual(query.startDate);
    } else if (query.endDate) {
      where.workDate = LessThanOrEqual(query.endDate);
    }

    return this.scheduleRepo.find({
      where,
      relations: ['staff', 'cinema', 'shift', 'assignedBy'],
      order: { workDate: 'ASC', shift: { startTime: 'ASC' } },
    });
  }

  async getMySchedule(
    staffId: number,
    startDate?: string,
    endDate?: string,
  ): Promise<StaffSchedule[]> {
    const where: any = { staffId };

    if (startDate && endDate) {
      where.workDate = Between(startDate, endDate);
    } else if (startDate) {
      where.workDate = MoreThanOrEqual(startDate);
    } else if (endDate) {
      where.workDate = LessThanOrEqual(endDate);
    }

    return this.scheduleRepo.find({
      where,
      relations: ['cinema', 'shift'],
      order: { workDate: 'ASC', shift: { startTime: 'ASC' } },
    });
  }

  async createSchedule(
    dto: CreateStaffScheduleDto,
    assignedById?: number,
  ): Promise<StaffSchedule> {
    // 1. Kiểm tra staff tồn tại và là nhân viên
    const staff = await this.userRepo.findOne({ where: { id: dto.staffId } });
    if (!staff) {
      throw new NotFoundException(`Không tìm thấy nhân viên với ID ${dto.staffId}`);
    }
    if (staff.role !== EUserRole.STAFF && staff.role !== EUserRole.ADMIN) {
      throw new BadRequestException('Chỉ có thể xếp ca cho người dùng có vai trò Nhân viên hoặc Quản trị viên');
    }

    // 2. Kiểm tra rạp chiếu
    const cinema = await this.cinemaRepo.findOne({ where: { id: dto.cinemaId } });
    if (!cinema) {
      throw new NotFoundException(`Không tìm thấy rạp chiếu với ID ${dto.cinemaId}`);
    }

    // 3. Kiểm tra ca làm việc
    const shift = await this.shiftRepo.findOne({ where: { id: dto.shiftId } });
    if (!shift) {
      throw new NotFoundException(`Không tìm thấy ca làm việc với ID ${dto.shiftId}`);
    }
    if (!shift.isActive) {
      throw new BadRequestException('Ca làm việc này hiện đã ngưng kích hoạt');
    }

    // 4. Kiểm tra trùng ca trong cùng một ngày
    const existing = await this.scheduleRepo.findOne({
      where: {
        staffId: dto.staffId,
        workDate: dto.workDate,
        shiftId: dto.shiftId,
      },
    });
    if (existing) {
      throw new ConflictException(
        `Nhân viên ${staff.fullName} đã có lịch làm việc trong ${shift.name} ngày ${dto.workDate}`,
      );
    }

    const schedule = this.scheduleRepo.create({
      ...dto,
      assignedById,
    });

    const saved = await this.scheduleRepo.save(schedule);
    return this.scheduleRepo.findOne({
      where: { id: saved.id },
      relations: ['staff', 'cinema', 'shift', 'assignedBy'],
    }) as Promise<StaffSchedule>;
  }

  async updateSchedule(
    id: number,
    dto: UpdateStaffScheduleDto,
  ): Promise<StaffSchedule> {
    const schedule = await this.scheduleRepo.findOne({
      where: { id },
      relations: ['staff', 'cinema', 'shift'],
    });
    if (!schedule) {
      throw new NotFoundException(`Không tìm thấy lịch phân ca với ID ${id}`);
    }

    if (dto.cinemaId) {
      const cinema = await this.cinemaRepo.findOne({ where: { id: dto.cinemaId } });
      if (!cinema) throw new NotFoundException('Rạp chiếu không tồn tại');
      schedule.cinemaId = dto.cinemaId;
    }

    if (dto.shiftId) {
      const shift = await this.shiftRepo.findOne({ where: { id: dto.shiftId } });
      if (!shift) throw new NotFoundException('Ca làm việc không tồn tại');
      schedule.shiftId = dto.shiftId;
    }

    if (dto.assignedRole) schedule.assignedRole = dto.assignedRole;
    if (dto.status) schedule.status = dto.status;
    if (dto.note !== undefined) schedule.note = dto.note;

    await this.scheduleRepo.save(schedule);

    return this.scheduleRepo.findOne({
      where: { id },
      relations: ['staff', 'cinema', 'shift', 'assignedBy'],
    }) as Promise<StaffSchedule>;
  }

  async deleteSchedule(id: number): Promise<{ success: boolean; message: string }> {
    const schedule = await this.scheduleRepo.findOne({ where: { id } });
    if (!schedule) {
      throw new NotFoundException(`Không tìm thấy lịch phân ca với ID ${id}`);
    }
    await this.scheduleRepo.remove(schedule);
    return { success: true, message: 'Hủy phân ca làm việc thành công' };
  }
}
