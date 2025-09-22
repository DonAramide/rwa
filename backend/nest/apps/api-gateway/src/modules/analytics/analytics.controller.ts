import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../users/user.entity';
import { AnalyticsService } from './analytics.service';

@ApiTags('Analytics')
@Controller('analytics')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('dashboard')
  getDashboardStats(@Query('period') period?: string) {
    return this.analyticsService.getDashboardStats(period);
  }

  @Get('revenue')
  getRevenueAnalytics(
    @Query('period') period?: string,
    @Query('granularity') granularity?: string,
  ) {
    return this.analyticsService.getRevenueAnalytics(period, granularity);
  }

  @Get('users')
  getUserGrowthMetrics(
    @Query('period') period?: string,
    @Query('granularity') granularity?: string,
  ) {
    return this.analyticsService.getUserGrowthMetrics(period, granularity);
  }

  @Get('assets')
  getAssetPerformance(
    @Query('period') period?: string,
    @Query('type') assetType?: string,
  ) {
    return this.analyticsService.getAssetPerformance(period, assetType);
  }

  @Get('transactions')
  getTransactionVolume(
    @Query('period') period?: string,
    @Query('granularity') granularity?: string,
  ) {
    return this.analyticsService.getTransactionVolume(period, granularity);
  }

  @Get('geographic')
  getGeographicDistribution(@Query('metric') metric?: string) {
    return this.analyticsService.getGeographicDistribution(metric);
  }

  @Get('portfolio')
  getPortfolioAnalytics() {
    return this.analyticsService.getPortfolioAnalytics();
  }

  @Get('market')
  getMarketMetrics(@Query('period') period?: string) {
    return this.analyticsService.getMarketMetrics(period);
  }

  // ===================
  // MASTER ADMIN BANKING ANALYTICS
  // ===================

  @Get('banking/overview')
  @Roles(UserRole.master_admin)
  @ApiOperation({ summary: 'Get comprehensive banking partnership overview' })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: 200, description: 'Banking overview analytics' })
  getBankingOverview(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const period = {
      startDate: startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
      endDate: endDate ? new Date(endDate) : new Date(),
    };

    return this.analyticsService.getBankingOverview(period);
  }

  @Get('banking/performance')
  @Roles(UserRole.master_admin)
  @ApiOperation({ summary: 'Get bank performance metrics comparison' })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: 200, description: 'Bank performance comparison' })
  getBankPerformanceComparison(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const period = {
      startDate: startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
      endDate: endDate ? new Date(endDate) : new Date(),
    };

    return this.analyticsService.getBankPerformanceComparison(period);
  }

  @Get('banking/proposals')
  @Roles(UserRole.master_admin)
  @ApiOperation({ summary: 'Get asset proposal pipeline analytics' })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: 200, description: 'Proposal pipeline analytics' })
  getProposalPipelineAnalytics(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const period = {
      startDate: startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
      endDate: endDate ? new Date(endDate) : new Date(),
    };

    return this.analyticsService.getProposalPipelineAnalytics(period);
  }

  @Get('banking/revenue')
  @Roles(UserRole.master_admin)
  @ApiOperation({ summary: 'Get revenue sharing and commission analytics' })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: 200, description: 'Revenue and commission analytics' })
  getBankingRevenueAnalytics(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const period = {
      startDate: startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
      endDate: endDate ? new Date(endDate) : new Date(),
    };

    return this.analyticsService.getRevenueAnalytics(period);
  }
}