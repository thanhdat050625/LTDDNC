import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Cinema } from '../../cinema/entities/cinema.entity';
import { Shift } from './shift.entity';
import { EStaffShiftRole, EScheduleStatus } from '../enums/shift.enum';

@Entity('staff_schedules')
@Unique(['staffId', 'workDate', 'shiftId'])
export class StaffSchedule {
  @PrimaryGeneratedColumn()
  id: number;

  @Index()
  @Column()
  staffId: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'staffId' })
  staff: User;

  @Index()
  @Column()
  cinemaId: number;

  @ManyToOne(() => Cinema, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'cinemaId' })
  cinema: Cinema;

  @Index()
  @Column()
  shiftId: number;

  @ManyToOne(() => Shift, (shift) => shift.schedules, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'shiftId' })
  shift: Shift;

  @Index()
  @Column({ type: 'date' })
  workDate: string;

  @Column({
    type: 'enum',
    enum: EStaffShiftRole,
    default: EStaffShiftRole.GENERAL,
  })
  assignedRole: EStaffShiftRole;

  @Column({
    type: 'enum',
    enum: EScheduleStatus,
    default: EScheduleStatus.SCHEDULED,
  })
  status: EScheduleStatus;

  @Column({ type: 'text', nullable: true })
  note?: string;

  @Column({ nullable: true })
  assignedById?: number;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'assignedById' })
  assignedBy?: User;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;
}
