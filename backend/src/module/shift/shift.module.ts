import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Shift } from './entities/shift.entity';
import { StaffSchedule } from './entities/staff-schedule.entity';
import { User } from '../users/entities/user.entity';
import { Cinema } from '../cinema/entities/cinema.entity';
import { ShiftService } from './shift.service';
import { ShiftController } from './shift.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Shift, StaffSchedule, User, Cinema]),
    AuthModule,
  ],
  controllers: [ShiftController],
  providers: [ShiftService],
  exports: [ShiftService],
})
export class ShiftModule {}
