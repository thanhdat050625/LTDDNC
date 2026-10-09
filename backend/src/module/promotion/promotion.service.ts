import { Injectable, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { Promotion } from './entities/promotion.entity';
import { CreatePromotionDto, UpdatePromotionDto, CheckPromotionDto } from './dto/promotion.dto';
import { ApiResponse } from '../../core/dto/ApiResponse.dto';
import { CustomException } from '../../core/exceptions/custom.exception';
import { EDiscountType } from './enums/promotion.enum';

import { EventEmitter2 } from '@nestjs/event-emitter';

export function validatePromotion(promotion: Promotion | null, movieId?: number): Promotion {
  if (!promotion) {
    throw new CustomException(HttpStatus.BAD_REQUEST, 'PROMOTION_NOT_FOUND', 'Mã khuyến mãi không tồn tại');
  }

  if (!promotion.isActive) {
    throw new CustomException(HttpStatus.BAD_REQUEST, 'PROMOTION_INACTIVE', 'Mã khuyến mãi không còn hoạt động');
  }

  const now = new Date();
  const startDate = new Date(promotion.startDate);
  const endDate = new Date(promotion.endDate);

  if (now < startDate || now > endDate) {
    throw new CustomException(HttpStatus.BAD_REQUEST, 'PROMOTION_EXPIRED', 'Mã khuyến mãi đã hết hạn hoặc chưa bắt đầu');
  }

  if (promotion.maxUsage && promotion.usedCount >= promotion.maxUsage) {
    throw new CustomException(HttpStatus.BAD_REQUEST, 'PROMOTION_MAX_USAGE', 'Mã khuyến mãi đã hết lượt sử dụng');
  }

  if (promotion.movieId && movieId && promotion.movieId !== movieId) {
    throw new CustomException(HttpStatus.BAD_REQUEST, 'PROMOTION_MOVIE_MISMATCH', 'Mã khuyến mãi không áp dụng cho phim này');
  }

  return promotion;
}

export function calculateDiscount(promotion: Promotion, orderTotal: number): number {
  let discount = 0;
  if (promotion.discountType === EDiscountType.PERCENTAGE) {
    discount = Math.floor((orderTotal * promotion.discountValue) / 100);
  } else {
    discount = promotion.discountValue;
  }
  return Math.max(0, discount);
}

@Injectable()
export class PromotionService {
  constructor(
    @InjectRepository(Promotion)
    private readonly promotionRepository: Repository<Promotion>,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  async create(dto: CreatePromotionDto): Promise<ApiResponse<Promotion>> {
    const existing = await this.promotionRepository.findOne({ where: { code: dto.code } });
    if (existing) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'PROMOTION_CODE_EXISTS', 'Mã khuyến mãi đã tồn tại');
    }
    const promotion = this.promotionRepository.create({
      ...dto,
      isActive: dto.isActive ?? true,
      usedCount: 0,
    });
    const saved = await this.promotionRepository.save(promotion);

    if (saved.isActive) {
      this.eventEmitter.emit('promotion.created', saved);
    }

    return new ApiResponse(true, 'Tạo khuyến mãi thành công', saved);
  }

  async findAll(page: number = 1, pageSize: number = 10): Promise<ApiResponse<Promotion[]>> {
    const skip = (page - 1) * pageSize;
    const [promotions, totalItems] = await this.promotionRepository.findAndCount({
      skip,
      take: pageSize,
      order: { id: 'DESC' },
      relations: ['movie'],
    });
    const totalPages = Math.ceil(totalItems / pageSize);
    const response = new ApiResponse(true, 'Lấy danh sách khuyến mãi thành công', promotions);
    response.pagination = { page: Number(page), pageSize: Number(pageSize), totalItems, totalPages };
    return response;
  }

  async getActivePromotions(): Promise<ApiResponse<Promotion[]>> {
    const today = new Date();
    const promotions = await this.promotionRepository.find({
      where: {
        isActive: true,
        startDate: LessThanOrEqual(today),
        endDate: MoreThanOrEqual(today),
      },
      relations: ['movie'],
      order: { endDate: 'ASC' },
    });
    const available = promotions.filter(p => !p.maxUsage || p.usedCount < p.maxUsage);
    return new ApiResponse(true, 'Lấy danh sách khuyến mãi khả dụng thành công', available);
  }

  async findOne(id: number): Promise<ApiResponse<Promotion>> {
    const promotion = await this.promotionRepository.findOne({
      where: { id },
      relations: ['movie'],
    });
    if (!promotion) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'PROMOTION_NOT_FOUND', 'Không tìm thấy khuyến mãi');
    }
    return new ApiResponse(true, 'Lấy thông tin khuyến mãi thành công', promotion);
  }

  async update(id: number, dto: UpdatePromotionDto): Promise<ApiResponse<Promotion>> {
    const promotion = await this.promotionRepository.findOne({ where: { id } });
    if (!promotion) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'PROMOTION_NOT_FOUND', 'Không tìm thấy khuyến mãi');
    }
    Object.assign(promotion, dto);
    const updated = await this.promotionRepository.save(promotion);
    return new ApiResponse(true, 'Cập nhật khuyến mãi thành công', updated);
  }

  async remove(id: number): Promise<ApiResponse<null>> {
    const promotion = await this.promotionRepository.findOne({ where: { id } });
    if (!promotion) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'PROMOTION_NOT_FOUND', 'Không tìm thấy khuyến mãi');
    }
    await this.promotionRepository.remove(promotion);
    return new ApiResponse(true, 'Xóa khuyến mãi thành công');
  }

  async validatePromotion(code: string, movieId?: number): Promise<Promotion> {
    const promotion = await this.promotionRepository.findOne({
      where: { code },
      relations: ['movie'],
    });
    return validatePromotion(promotion, movieId);
  }

  calculateDiscount(promotion: Promotion, orderTotal: number): number {
    return calculateDiscount(promotion, orderTotal);
  }

  async checkPromotion(dto: CheckPromotionDto): Promise<ApiResponse<any>> {
    const promotion = await this.validatePromotion(dto.code, dto.movieId);

    let discountAmount: number | undefined;
    let totalAfterDiscount: number | undefined;

    if (dto.orderTotal !== undefined && dto.orderTotal !== null) {
      discountAmount = this.calculateDiscount(promotion, dto.orderTotal);
      totalAfterDiscount = Math.max(0, dto.orderTotal - discountAmount);
    }

    return new ApiResponse(true, 'Mã khuyến mãi hợp lệ', {
      id: promotion.id,
      code: promotion.code,
      discountType: promotion.discountType,
      discountValue: promotion.discountValue,
      description: promotion.description,
      ...(discountAmount !== undefined ? { discountAmount, totalAfterDiscount } : {}),
    });
  }
}
