import { OrdersService } from '../orders.service';
import { Repository } from 'typeorm';
import { OrderEntity } from '../order.entity';

function createRepoMock() {
  return {
    createQueryBuilder: jest.fn(() => {
      const qb: any = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        getManyAndCount: jest.fn().mockResolvedValue([[], 0]),
      };
      return qb;
    }),
    create: jest.fn(),
    save: jest.fn(),
    update: jest.fn(),
  } as unknown as jest.Mocked<Repository<OrderEntity>>;
}

describe('OrdersService', () => {
  let service: OrdersService;
  let repo: jest.Mocked<Repository<OrderEntity>>;

  beforeEach(() => {
    repo = createRepoMock();
    service = new OrdersService(repo);
  });

  it('findByUser applies filters and pagination', async () => {
    const res = await service.findByUser(1, { limit: 10, offset: 0, status: 'open', side: 'buy' } as any);
    expect(res).toEqual({ items: [], total: 0, limit: 10, offset: 0, hasMore: false });
    const qb = (repo.createQueryBuilder as any).mock.results[0].value;
    expect(qb.where).toHaveBeenCalledWith('order.user_id = :userId', { userId: 1 });
    expect(qb.andWhere).toHaveBeenCalledWith('order.status = :status', { status: 'open' });
    expect(qb.andWhere).toHaveBeenCalledWith('order.side = :side', { side: 'buy' });
  });

  it('findByAsset applies filters and pagination', async () => {
    const res = await service.findByAsset(10, { limit: 50, offset: 100, side: 'sell', status: 'open' } as any);
    expect(res).toEqual({ items: [], total: 0, limit: 50, offset: 100, hasMore: false });
    const qb = (repo.createQueryBuilder as any).mock.results[1].value;
    expect(qb.where).toHaveBeenCalledWith('order.asset_id = :assetId', { assetId: 10 });
    expect(qb.andWhere).toHaveBeenCalledWith('order.status = :status', { status: 'open' });
    expect(qb.andWhere).toHaveBeenCalledWith('order.side = :side', { side: 'sell' });
  });

  it('create and cancel delegate to repository', async () => {
    await service.create({ user_id: 1 } as any);
    expect(repo.create).toHaveBeenCalled();
    expect(repo.save).toHaveBeenCalled();
    await service.cancel(1);
    expect(repo.update).toHaveBeenCalled();
  });
});
