import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MarketplaceController } from './marketplace.controller';
import { OrdersService } from './orders.service';
import { OrderEntity } from './order.entity';

@Module({
  imports: [TypeOrmModule.forFeature([OrderEntity])],
  controllers: [MarketplaceController],
  providers: [OrdersService],
  exports: [OrdersService],
})
export class MarketplaceModule {}


