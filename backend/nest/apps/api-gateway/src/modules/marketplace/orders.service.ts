import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { OrderEntity, OrderSide, OrderStatus } from './order.entity';

@Injectable()
export class OrdersService {
  constructor(@InjectRepository(OrderEntity) private readonly repo: Repository<OrderEntity>) {}

  findByUser(userId: number) {
    return this.repo.find({ where: { user_id: userId } });
  }

  findByAsset(assetId: number) {
    return this.repo.find({ where: { asset_id: assetId } });
  }

  create(data: Partial<OrderEntity>) {
    const order = this.repo.create(data);
    return this.repo.save(order);
  }

  update(id: number, data: Partial<OrderEntity>) {
    return this.repo.update(id, data);
  }

  cancel(id: number) {
    return this.repo.update(id, { status: OrderStatus.cancelled });
  }
}




