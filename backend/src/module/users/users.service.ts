import { Injectable, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { Booking } from '../booking/entities/booking.entity';
import { EBookingStatus } from '../booking/enums/booking.enum';
import { ApiResponse } from '../../core/dto/ApiResponse.dto';
import { CustomException } from '../../core/exceptions/custom.exception';
import { EUserRole, EUserStatus } from './enums/user.enum';
import { CreateStaffDto, GetUsersQueryDto, UpdateProfileDto, UpdateStaffDto } from './dto/users.dto';
import * as bcrypt from 'bcrypt';

import { ENotificationType } from '../notification/enums/notification.enum';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { CloudinaryService } from '../cloudinary/cloudinary.service';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Booking)
    private readonly bookingRepository: Repository<Booking>,
    private readonly eventEmitter: EventEmitter2,
    private readonly cloudinaryService: CloudinaryService,
  ) {}

  async getAllUsers(query: GetUsersQueryDto = {}): Promise<ApiResponse<User[]>> {
    const page = Math.max(1, Number(query.page || 1));
    const pageSize = Math.max(1, Number(query.pageSize || 10));
    const skip = (page - 1) * pageSize;

    const qb = this.userRepository.createQueryBuilder('user');

    if (query.role) {
      qb.andWhere('user.role = :role', { role: query.role });
    }

    if (query.status) {
      qb.andWhere('user.status = :status', { status: query.status });
    }

    if (query.keyword && query.keyword.trim().length > 0) {
      const kw = `%${query.keyword.trim()}%`;
      qb.andWhere('(user.fullName LIKE :kw OR user.email LIKE :kw OR user.phone LIKE :kw)', { kw });
    }

    qb.orderBy('user.id', 'DESC').skip(skip).take(pageSize);

    const [users, totalItems] = await qb.getManyAndCount();
    const totalPages = Math.ceil(totalItems / pageSize) || 1;

    // Aggregate summary stats for the dashboard tabs
    const [totalAll, totalCustomers, totalStaff, totalBlocked] = await Promise.all([
      this.userRepository.count(),
      this.userRepository.count({ where: { role: EUserRole.CUSTOMER } }),
      this.userRepository.count({ where: { role: EUserRole.STAFF } }),
      this.userRepository.count({ where: { status: EUserStatus.BLOCKED } }),
    ]);

    const response = new ApiResponse(true, 'Lấy danh sách người dùng thành công', users);
    response.pagination = { page, pageSize, totalItems, totalPages };
    (response as any).stats = {
      totalAll,
      totalCustomers,
      totalStaff,
      totalBlocked,
    };
    return response;
  }

  async createStaff(dto: CreateStaffDto, avatar?: Express.Multer.File): Promise<ApiResponse<User>> {
    const email = dto.email.trim().toLowerCase();
    const existing = await this.userRepository.findOne({ where: { email } });
    if (existing) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'USER_EXISTS', 'Email đã được sử dụng trong hệ thống');
    }

    let avatarUrl: string | undefined = dto.avatar?.trim() || undefined;
    if (avatar) {
      const uploadRes = await this.cloudinaryService.uploadImage(avatar);
      avatarUrl = uploadRes.secure_url;
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);
    const newStaff = this.userRepository.create({
      fullName: dto.fullName.trim(),
      email,
      phone: dto.phone?.trim() || undefined,
      avatar: avatarUrl,
      password: hashedPassword,
      role: EUserRole.STAFF,
      status: EUserStatus.ACTIVE,
      tokenVersion: 0,
    });

    const savedStaff = await this.userRepository.save(newStaff);

    // Phát sự kiện thông báo chào mừng nhân viên
    this.eventEmitter.emit('notification.create', {
      userId: savedStaff.id,
      subject: 'Tài khoản nhân viên được kích hoạt',
      content: 'Chào mừng bạn đến với đội ngũ CINEPLEX. Vui lòng đăng nhập ứng dụng Cineplex Staff.',
      type: ENotificationType.SYSTEM,
    });

    return new ApiResponse(true, 'Tạo tài khoản nhân viên thành công', savedStaff);
  }

  async updateStaff(
    staffId: number,
    dto: UpdateStaffDto,
    avatar?: Express.Multer.File,
  ): Promise<ApiResponse<User>> {
    const staff = await this.userRepository.findOne({ where: { id: staffId } });
    if (!staff) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'Không tìm thấy người dùng');
    }
    if (staff.role !== EUserRole.STAFF) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'INVALID_ROLE', 'Chỉ có thể chỉnh sửa tài khoản nhân viên');
    }

    if (dto.email && dto.email.trim().toLowerCase() !== staff.email.toLowerCase()) {
      const newEmail = dto.email.trim().toLowerCase();
      const existing = await this.userRepository.findOne({ where: { email: newEmail } });
      if (existing && existing.id !== staffId) {
        throw new CustomException(HttpStatus.BAD_REQUEST, 'USER_EXISTS', 'Email đã được sử dụng trong hệ thống');
      }
      staff.email = newEmail;
    }

    if (dto.fullName) {
      staff.fullName = dto.fullName.trim();
    }

    if (dto.phone !== undefined) {
      staff.phone = dto.phone ? dto.phone.trim() : (null as any);
    }

    if (dto.password && dto.password.trim().length >= 6) {
      staff.password = await bcrypt.hash(dto.password.trim(), 10);
    }

    if (avatar) {
      const uploadRes = await this.cloudinaryService.uploadImage(avatar);
      staff.avatar = uploadRes.secure_url;
    } else if (dto.avatar !== undefined) {
      staff.avatar = dto.avatar ? dto.avatar.trim() : (null as any);
    }

    const saved = await this.userRepository.save(staff);
    return new ApiResponse(true, 'Cập nhật tài khoản nhân viên thành công', saved);
  }

  async updateUserStatus(userId: number, status: EUserStatus, currentUserId?: number): Promise<ApiResponse<User>> {
    if (currentUserId && currentUserId === userId && status === EUserStatus.BLOCKED) {
      throw new CustomException(HttpStatus.BAD_REQUEST, 'CANNOT_BLOCK_SELF', 'Bạn không thể khóa tài khoản của chính mình');
    }

    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'Không tìm thấy người dùng');
    }
    user.status = status;
    const updated = await this.userRepository.save(user);

    // Phát sự kiện thông báo khóa/mở khóa tài khoản
    const statusMessage = status === EUserStatus.BLOCKED ? 'bị khóa' : 'được mở khóa';
    this.eventEmitter.emit('notification.create', {
      userId,
      subject: 'Thay đổi trạng thái tài khoản',
      content: `Tài khoản của bạn đã ${statusMessage}. Nếu có thắc mắc, vui lòng liên hệ CSKH.`,
      type: ENotificationType.SYSTEM,
    });

    return new ApiResponse(true, `Cập nhật trạng thái người dùng thành ${status}`, updated);
  }

  async getProfile(userId: number): Promise<ApiResponse<User>> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'Không tìm thấy người dùng');
    }
    return new ApiResponse(true, 'Lấy thông tin cá nhân thành công', user);
  }

  async updateProfile(userId: number, dto: UpdateProfileDto, avatar?: Express.Multer.File): Promise<ApiResponse<User>> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'Khong tim thay nguoi dung');
    }

    const updateData: Record<string, unknown> = {};

    if (avatar) {
      const uploadRes = await this.cloudinaryService.uploadImage(avatar);
      updateData.avatar = uploadRes.secure_url;
    } else if (dto.avatar !== undefined) {
      updateData.avatar = dto.avatar?.trim() || null;
    }

    if (dto.fullName !== undefined) {
      const fullName = dto.fullName.trim();
      if (!fullName) {
        throw new CustomException(HttpStatus.BAD_REQUEST, 'VALIDATION_FAILED', 'Vui long nhap ho va ten');
      }
      updateData.fullName = fullName;
    }

    if (dto.phone !== undefined) {
      updateData.phone = dto.phone?.trim() || null;
    }

    if (dto.gender !== undefined) {
      updateData.gender = dto.gender?.trim() || null;
    }

    if (dto.dateOfBirth !== undefined) {
      updateData.dateOfBirth = dto.dateOfBirth ? new Date(dto.dateOfBirth) : null;
    }

    Object.assign(user, updateData);

    const updated = await this.userRepository.save(user);

    this.eventEmitter.emit('notification.create', {
      userId,
      subject: 'Cập nhật hồ sơ',
      content: 'Thông tin cá nhân của bạn đã được cập nhật thành công.',
      type: ENotificationType.ACCOUNT,
      link: '/profile',
    });

    return new ApiResponse(true, 'Cập nhật thông tin cá nhân thành công', updated);
  }

  /**
   * Trả về thông tin điểm tích lũy cho frontend:
   * - Số điểm hiện tại
   * - Tỷ lệ tích điểm (10%)
   * - Giới hạn giảm giá bằng điểm (20%)
   * - 1 điểm = 1 VNĐ
   */
  async getLoyaltyInfo(userId: number): Promise<ApiResponse<any>> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'Không tìm thấy người dùng');
    }
    return new ApiResponse(true, 'Lấy thông tin điểm tích lũy thành công', {
      loyaltyPoints: user.loyaltyPoints,
      pointValue: 1,           // 1 điểm = 1 VNĐ
      earnRate: 0.10,           // 10% giá trị đơn hàng
      maxDiscountRate: 0.20,    // Tối đa 20% tổng đơn
      policy: {
        earnRate: 0.10,
        earnRatePercent: 10,
        pointValue: 1,
        maxDiscountRate: 0.20,
        maxDiscountPercent: 20,
      },
    });
  }

  async getLoyaltyHistory(userId: number, page: number = 1, pageSize: number = 20): Promise<ApiResponse<any>> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new CustomException(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'Không tìm thấy người dùng');
    }

    const bookings = await this.bookingRepository.find({
      where: { userId },
      relations: ['showtime', 'showtime.movie', 'payment'],
      order: { createdAt: 'DESC' },
    });

    const history: Array<{
      id: string;
      bookingId: number;
      bookingCode: string;
      movieTitle?: string;
      type: 'EARN' | 'REDEEM' | 'REFUND';
      points: number;
      title: string;
      description: string;
      createdAt: Date;
    }> = [];

    for (const b of bookings) {
      const movieTitle = b.showtime?.movie?.title;

      // 1. Dùng điểm giảm giá (REDEEM)
      if (b.pointsUsed && b.pointsUsed > 0) {
        history.push({
          id: `redeem-${b.id}`,
          bookingId: b.id,
          bookingCode: b.bookingCode,
          movieTitle,
          type: 'REDEEM',
          points: -b.pointsUsed,
          title: 'Dùng điểm thanh toán',
          description: `Đơn hàng #${b.bookingCode}${movieTitle ? ` - ${movieTitle}` : ''}`,
          createdAt: b.createdAt,
        });
      }

      // 2. Tích lũy điểm khi thanh toán thành công (EARN)
      if (b.status === EBookingStatus.PAID) {
        const pointsEarned = Math.floor(b.totalAmount * 0.10);
        if (pointsEarned > 0) {
          history.push({
            id: `earn-${b.id}`,
            bookingId: b.id,
            bookingCode: b.bookingCode,
            movieTitle,
            type: 'EARN',
            points: pointsEarned,
            title: 'Tích lũy từ đơn vé',
            description: `Đơn hàng #${b.bookingCode}${movieTitle ? ` - ${movieTitle}` : ''}`,
            createdAt: b.payment?.createdAt || b.createdAt,
          });
        }
      }

      // 3. Hoàn lại điểm khi đơn bị hủy hoặc quá hạn (REFUND)
      if ((b.status === EBookingStatus.CANCELLED || b.status === EBookingStatus.EXPIRED) && b.pointsUsed && b.pointsUsed > 0) {
        history.push({
          id: `refund-${b.id}`,
          bookingId: b.id,
          bookingCode: b.bookingCode,
          movieTitle,
          type: 'REFUND',
          points: b.pointsUsed,
          title: 'Hoàn trả điểm tích lũy',
          description: `Đơn hàng #${b.bookingCode} bị hủy/hết hạn`,
          createdAt: b.expiredAt || b.createdAt,
        });
      }
    }

    history.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

    const totalItems = history.length;
    const totalPages = Math.ceil(totalItems / pageSize) || 1;
    const start = (page - 1) * pageSize;
    const items = history.slice(start, start + pageSize);

    const response = new ApiResponse(true, 'Lấy lịch sử điểm tích lũy thành công', {
      loyaltyPoints: user.loyaltyPoints,
      policy: {
        earnRatePercent: 10,
        pointValue: 1,
        maxDiscountPercent: 20,
      },
      items,
    });
    response.pagination = { page: Number(page), pageSize: Number(pageSize), totalItems, totalPages };
    return response;
  }

  async searchUser(keyword: string): Promise<ApiResponse<User[]>> {
    if (!keyword || keyword.trim() === '') {
      return new ApiResponse(true, 'Kết quả rỗng', []);
    }
    const qb = this.userRepository.createQueryBuilder('user');
    qb.where('user.email LIKE :keyword', { keyword: `%${keyword}%` })
      .orWhere('user.phone LIKE :keyword', { keyword: `%${keyword}%` })
      .take(10);
    const users = await qb.getMany();
    return new ApiResponse(true, 'Tìm kiếm thành công', users);
  }
}
