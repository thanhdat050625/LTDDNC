import { IsDateString, IsEmail, IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, Min, MinLength } from 'class-validator';
import { EUserRole, EUserStatus } from '../enums/user.enum';
import { Type } from 'class-transformer';

export class GetUsersQueryDto {
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  @Min(1)
  page?: number = 1;

  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  @Min(1)
  pageSize?: number = 10;

  @IsEnum(EUserRole)
  @IsOptional()
  role?: EUserRole;

  @IsEnum(EUserStatus)
  @IsOptional()
  status?: EUserStatus;

  @IsString()
  @IsOptional()
  keyword?: string;
}

export class CreateStaffDto {
  @IsString()
  @IsNotEmpty({ message: 'Vui lòng nhập họ và tên' })
  fullName: string;

  @IsEmail({}, { message: 'Email không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập email' })
  email: string;

  @IsString()
  @MinLength(6, { message: 'Mật khẩu phải có ít nhất 6 ký tự' })
  password: string;

  @IsString()
  @IsOptional()
  phone?: string;

  @IsString()
  @IsOptional()
  avatar?: string;
}

export class UpdateStaffDto {
  @IsString()
  @IsNotEmpty({ message: 'Vui lòng nhập họ và tên' })
  @IsOptional()
  fullName?: string;

  @IsEmail({}, { message: 'Email không hợp lệ' })
  @IsOptional()
  email?: string;

  @IsString()
  @MinLength(6, { message: 'Mật khẩu phải có ít nhất 6 ký tự' })
  @IsOptional()
  password?: string;

  @IsString()
  @IsOptional()
  phone?: string;

  @IsString()
  @IsOptional()
  avatar?: string;
}

export class UpdateUserStatusDto {
  @IsEnum(EUserStatus)
  status: EUserStatus;
}

export class UpdateProfileDto {
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  fullName?: string;

  @IsString()
  @IsOptional()
  phone?: string | null;

  @IsString()
  @IsOptional()
  gender?: string | null;

  @IsDateString()
  @IsOptional()
  dateOfBirth?: string | null;

  @IsString()
  @IsOptional()
  avatar?: string | null;
}
