import { Controller, Get, Param, Post, Body, Delete, UseGuards, Query } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { OrdersService } from './orders.service';

@Controller()
export class MarketplaceController {
  constructor(private readonly orders: OrdersService) {}
  @Get('orderbook/:assetId')
  orderbook(@Param('assetId') assetId: string) {
    // For now return all orders for asset
    return this.orders.findByAsset(Number(assetId));
  }

  @Post('orders')
  @UseGuards(JwtAuthGuard)
  postOrder(@Body() body: any) { return this.orders.create(body); }

  @Get('orders')
  @UseGuards(JwtAuthGuard)
  myOrders(@Query('user_id') userId: string) { return this.orders.findByUser(Number(userId)); }

  @Delete('orders/:id')
  @UseGuards(JwtAuthGuard)
  cancel(@Param('id') id: string) { return this.orders.cancel(Number(id)); }
}


