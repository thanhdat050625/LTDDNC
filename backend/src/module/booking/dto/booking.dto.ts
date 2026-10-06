import {
  IsNumber,
  IsNotEmpty,
  IsArray,
  IsOptional,
  IsString,
  IsEnum,
  Min,
  ArrayMinSize,
  ArrayMaxSize,
  ArrayUnique,
} from 'class-validator';
import { Type } from 'class-transformer';
import { EBookingSource } from '../enums/booking.enum';
import { MAX_SEATS_PER_BOOKING } from '../constants/booking.constant';

export class HoldSeatsDto {
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  showtimeId: number;

  @IsArray()
  @ArrayMinSize(1, { message: 'Phải chọn ít nhất 1 ghế' })
  @ArrayMaxSize(MAX_SEATS_PER_BOOKING, { message: `Chỉ được chọn tối đa ${MAX_SEATS_PER_BOOKING} ghế mỗi đơn` })
  @ArrayUnique({ message: 'Danh sách ghế không được trùng lặp' })
  @IsNumber({}, { each: true })
  @IsNotEmpty()
  seatIds: number[];

  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  customerId?: number;
}

export class ConcessionItemDto {
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  productId: number;

  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  @Min(1)
  quantity: number;
}

export class CreateBookingDto {
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  showtimeId: number;

  @IsArray()
  @ArrayMinSize(1, { message: 'Phải chọn ít nhất 1 ghế' })
  @ArrayMaxSize(MAX_SEATS_PER_BOOKING, { message: `Chỉ được chọn tối đa ${MAX_SEATS_PER_BOOKING} ghế mỗi đơn` })
  @ArrayUnique({ message: 'Danh sách ghế không được trùng lặp' })
  @IsNumber({}, { each: true })
  @IsNotEmpty()
  seatIds: number[];

  @IsArray()
  @IsOptional()
  @Type(() => ConcessionItemDto)
  concessions?: ConcessionItemDto[];

  @IsString()
  @IsOptional()
  promotionCode?: string;

  @IsEnum(EBookingSource)
  @IsOptional()
  source?: EBookingSource;

  /**
   * Số điểm tích lũy muốn sử dụng để giảm giá đơn hàng.
   * 1 điểm = 1 VNĐ. Tối đa 20% tổng giá trị đơn hàng.
   */
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  @Min(0)
  pointsToUse?: number;

  /**
   * ID của sản phẩm combo muốn đổi bằng điểm tích lũy.
   * Nếu cung cấp, toàn bộ giá của combo đó sẽ được thanh toán bằng điểm.
   */
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  redeemConcessionId?: number;

  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  customerId?: number;
}

export class ReleaseSeatsDto {
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  showtimeId: number;

  @IsArray()
  @ArrayMinSize(1, { message: 'Phải chọn ít nhất 1 ghế để hủy giữ' })
  @IsNumber({}, { each: true })
  @IsNotEmpty()
  seatIds: number[];
}

export class ApplyPromotionDto {
  @IsNotEmpty({ message: 'Mã khuyến mãi không được để trống' })
  @IsString({ message: 'Mã khuyến mãi phải là chuỗi' })
  code: string;
}
