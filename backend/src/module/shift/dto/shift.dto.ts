import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsEnum,
  IsNumber,
  IsBoolean,
  Matches,
} from 'class-validator';
import { Type } from 'class-transformer';
import { EStaffShiftRole, EScheduleStatus } from '../enums/shift.enum';

export class CreateShiftDto {
  @IsNotEmpty({ message: 'Tên ca làm việc không được để trống' })
  @IsString()
  name: string;

  @IsNotEmpty({ message: 'Giờ bắt đầu không được để trống' })
  @IsString()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/, {
    message: 'Giờ bắt đầu phải có định dạng HH:mm hoặc HH:mm:ss',
  })
  startTime: string;

  @IsNotEmpty({ message: 'Giờ kết thúc không được để trống' })
  @IsString()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/, {
    message: 'Giờ kết thúc phải có định dạng HH:mm hoặc HH:mm:ss',
  })
  endTime: string;

  @IsOptional()
  @IsString()
  description?: string;
}

export class UpdateShiftDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/, {
    message: 'Giờ bắt đầu phải có định dạng HH:mm hoặc HH:mm:ss',
  })
  startTime?: string;

  @IsOptional()
  @IsString()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/, {
    message: 'Giờ kết thúc phải có định dạng HH:mm hoặc HH:mm:ss',
  })
  endTime?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class CreateStaffScheduleDto {
  @IsNotEmpty({ message: 'staffId không được để trống' })
  @Type(() => Number)
  @IsNumber()
  staffId: number;

  @IsNotEmpty({ message: 'cinemaId không được để trống' })
  @Type(() => Number)
  @IsNumber()
  cinemaId: number;

  @IsNotEmpty({ message: 'shiftId không được để trống' })
  @Type(() => Number)
  @IsNumber()
  shiftId: number;

  @IsNotEmpty({ message: 'workDate không được để trống' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'workDate phải có định dạng YYYY-MM-DD' })
  workDate: string;

  @IsOptional()
  @IsEnum(EStaffShiftRole, { message: 'assignedRole không hợp lệ' })
  assignedRole?: EStaffShiftRole;

  @IsOptional()
  @IsString()
  note?: string;
}

export class UpdateStaffScheduleDto {
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  cinemaId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  shiftId?: number;

  @IsOptional()
  @IsEnum(EStaffShiftRole, { message: 'assignedRole không hợp lệ' })
  assignedRole?: EStaffShiftRole;

  @IsOptional()
  @IsEnum(EScheduleStatus, { message: 'status không hợp lệ' })
  status?: EScheduleStatus;

  @IsOptional()
  @IsString()
  note?: string;
}

export class GetSchedulesQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  cinemaId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  staffId?: number;

  @IsOptional()
  @IsString()
  startDate?: string;

  @IsOptional()
  @IsString()
  endDate?: string;
}
