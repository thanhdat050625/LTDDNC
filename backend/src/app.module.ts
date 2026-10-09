import { Module } from '@nestjs/common';
import { ThrottlerModule } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { CustomThrottlerGuard } from './core/security/throttler/custom-throttler.guard';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { join } from 'path';
import { ENV_VARS } from './constants/env.constants';

// Infrastructure Modules
import { RedisModule } from './module/redis/redis.module';

// Feature Modules
import { AuthModule } from './module/auth/auth.module';
import { HomeModule } from './module/home/home.module';
import { MovieModule } from './module/movie/movie.module';
import { BookingModule } from './module/booking/booking.module';
import { CinemaModule } from './module/cinema/cinema.module';
import { ConcessionModule } from './module/concession/concession.module';
import { NotificationModule } from './module/notification/notification.module';
import { PaymentModule } from './module/payment/payment.module';
import { PromotionModule } from './module/promotion/promotion.module';
import { ShowtimeModule } from './module/showtime/showtime.module';
import { TicketModule } from './module/ticket/ticket.module';
import { UsersModule } from './module/users/users.module';
import { StatisticsModule } from './module/statistics/statistics.module';
import { ShiftModule } from './module/shift/shift.module';

@Module({
  imports: [
    EventEmitterModule.forRoot(),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([
      {
        ttl: 1000,
        limit: 10,
      },
    ]),

    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', 'backend/.env'],
      expandVariables: true,
    }),

    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const host = config.get<string>(ENV_VARS.DB_HOST);
        const port = config.get<number>(ENV_VARS.DB_PORT);
        const username = config.get<string>(ENV_VARS.DB_USER);
        const password = config.get<string>(ENV_VARS.DB_PASS);
        const database = config.get<string>(ENV_VARS.DB_NAME);

        if (!host || !port || !username || !password || !database) {
          throw new Error('Thiếu biến môi trường kết nối cơ sở dữ liệu: DB_HOST, DB_PORT, DB_USER, DB_PASS, DB_NAME');
        }

        return {
          type: 'mysql',
          host,
          port,
          username,
          password,
          database,
          autoLoadEntities: true,
          synchronize: config.get<string>('NODE_ENV') !== 'production',
          migrationsRun: true,
          migrations: [
            join(__dirname, 'migrations/*.js'),
            join(__dirname, 'migrations/*.ts'),
          ],
        };
      },
    }),

    RedisModule,

    AuthModule,
    HomeModule,
    MovieModule,
    BookingModule,
    CinemaModule,
    ConcessionModule,
    NotificationModule,
    PaymentModule,
    PromotionModule,
    ShowtimeModule,
    TicketModule,
    UsersModule,
    StatisticsModule,
    ShiftModule,
  ],
  controllers: [],
  providers: [
    {
      provide: APP_GUARD,
      useClass: CustomThrottlerGuard,
    },
  ],
})
export class AppModule { }
