import {
  Controller,
  Get,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { DashboardService } from './dashboard.service';
import { Transform } from 'class-transformer';
import { IsOptional } from 'class-validator';

class DashboardQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  month?: number;

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  year?: number;
}

@UseGuards(JwtAuthGuard)
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  private getMonthYear(query: DashboardQueryDto) {
    const now = new Date();
    const month = query.month || now.getMonth() + 1;
    const year = query.year || now.getFullYear();
    return { month, year };
  }

  @Get()
  getSummary(@CurrentUser('id') userId: number, @Query() query: DashboardQueryDto) {
    const { month, year } = this.getMonthYear(query);
    return this.dashboardService.getSummary(userId, month, year);
  }

  @Get('monthly-summary')
  getMonthlySummary(@CurrentUser('id') userId: number, @Query() query: DashboardQueryDto) {
    const { month, year } = this.getMonthYear(query);
    return this.dashboardService.getMonthlySummary(userId, month, year);
  }

  @Get('expenses-by-category')
  getExpensesByCategory(@CurrentUser('id') userId: number, @Query() query: DashboardQueryDto) {
    const { month, year } = this.getMonthYear(query);
    return this.dashboardService.getExpensesByCategory(userId, month, year);
  }

  @Get('last-6-months')
  getLast6Months(@CurrentUser('id') userId: number) {
    return this.dashboardService.getLast6Months(userId);
  }

  @Get('upcoming-expenses')
  getUpcomingExpenses(
    @CurrentUser('id') userId: number,
    @Query('days') days?: number,
  ) {
    return this.dashboardService.getUpcomingExpenses(userId, days ? parseInt(String(days)) : 7);
  }

  @Get('movement-history')
  getMovementHistory(@CurrentUser('id') userId: number, @Query() query: DashboardQueryDto) {
    const { month, year } = this.getMonthYear(query);
    return this.dashboardService.getMovementHistory(userId, month, year);
  }
}
