import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller()
export class InvestController {
  @Post('wallet/link')
  @UseGuards(JwtAuthGuard)
  link(@Body() body: any) { return { ok: true }; }

  @Get('wallet/balances')
  @UseGuards(JwtAuthGuard)
  balances() { return { tokens: [] }; }

  @Post('invest/orders')
  @UseGuards(JwtAuthGuard)
  order(@Body() body: any) { return { ok: true, id: 'ord_1' }; }

  @Get('invest/holdings')
  holdings() { 
    return { 
      items: [
        {
          assetId: "1",
          assetTitle: "Downtown Commercial Land - Austin, TX",
          assetType: "land",
          balance: 0.15,
          lockedBalance: 0.05,
          value: 375000,
          returnPercent: 8.5,
          monthlyIncome: 2656.25,
          updatedAt: "2025-09-14T22:00:00Z"
        },
        {
          assetId: "2",
          assetTitle: "Fleet Truck #001 - Freightliner",
          assetType: "truck",
          balance: 0.08,
          lockedBalance: 0.02,
          value: 6800,
          returnPercent: 12.3,
          monthlyIncome: 69.67,
          updatedAt: "2025-09-14T22:00:00Z"
        },
        {
          assetId: "4",
          assetTitle: "Luxury Villa - Malibu, CA",
          assetType: "house",
          balance: 0.03,
          lockedBalance: 0.01,
          value: 105000,
          returnPercent: 6.8,
          monthlyIncome: 595.00,
          updatedAt: "2025-09-14T22:00:00Z"
        }
      ]
    }; 
  }

  @Get('invest/portfolio/summary')
  @UseGuards(JwtAuthGuard)
  portfolioSummary() {
    return {
      totalValue: 486800,
      totalReturn: 8.9,
      monthlyIncome: 3320.92,
      totalInvested: 450000,
      gainLoss: 36800,
      assetCount: 3,
      lastUpdated: "2025-09-14T22:00:00Z"
    };
  }
}


