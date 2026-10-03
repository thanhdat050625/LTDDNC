import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { StatisticsService } from './statistics.service';
import { JwtAuthGuard } from '../../core/security/jwt/jwt-auth.guard';
import { RolesGuard } from '../../core/security/roles/roles.guard';
import { Roles } from '../../core/security/roles/roles.decorator';
import { EUserRole } from '../users/enums/user.enum';


@Controller('statistics')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(EUserRole.ADMIN)
export class StatisticsController {
  constructor(private readonly statisticsService: StatisticsService) {}

  @Get('revenue')
  async getRevenueStatistics(
    @Query('filterType') filterType?: string,
    @Query('timeFrame') timeFrame?: string,
    @Query('year') year?: string,
    @Query('month') month?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const parsedYear = year ? parseInt(year, 10) : undefined;
    const parsedMonth = month ? parseInt(month, 10) : undefined;
    const type = (startDate && endDate && !filterType) ? 'custom' : (filterType || timeFrame || 'year');
    return this.statisticsService.getRevenueStatistics(
      type,
      parsedYear,
      parsedMonth,
      startDate,
      endDate,
    );
  }

  @Get('movies')
  async getMoviePerformance() {
    return this.statisticsService.getMoviePerformance();
  }

  @Get('summary')
  async getSummary() {
    return this.statisticsService.getSummary();
  }
}
