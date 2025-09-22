import { Controller, Get, Param, Post, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { RevenueService } from './revenue.service';

@Controller()
export class RevenueController {
  constructor(private readonly revenue: RevenueService) {}

  @Get('distributions/:assetId')
  list(@Param('assetId') assetId: string) { 
    return this.revenue.findByAsset(Number(assetId));
  }

  @Post('admin/distributions/trigger')
  @UseGuards(JwtAuthGuard)
  trigger(@Body() body: any) { 
    return this.revenue.triggerPayout(body);
  }
}


