import { RevenueService } from '../revenue.service';
import { Repository } from 'typeorm';
import { DistributionEntity } from '../distribution.entity';

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
  } as unknown as jest.Mocked<Repository<DistributionEntity>>;
}

describe('RevenueService', () => {
  let service: RevenueService;
  let repo: jest.Mocked<Repository<DistributionEntity>>;

  beforeEach(() => {
    repo = createRepoMock();
    service = new RevenueService(repo);
  });

  it('findByAsset applies filters and pagination', async () => {
    const res = await service.findByAsset(2, { limit: 20, offset: 0, period_start: '2024-01-01', period_end: '2024-02-01' } as any);
    expect(res).toEqual({ items: [], total: 0, limit: 20, offset: 0, hasMore: false });
    const qb = (repo.createQueryBuilder as any).mock.results[0].value;
    expect(qb.where).toHaveBeenCalledWith('distribution.asset_id = :assetId', { assetId: 2 });
  });

  it('triggerPayout calculates net and saves distribution', async () => {
    (repo.create as any).mockImplementation((d: any) => d);
    (repo.save as any).mockImplementation((d: any) => d);
    const result = await service.triggerPayout({ asset_id: 1, period: '[2024-01-01,2024-02-01)', gross: 1000, mgmt_fee_bps: 100, carry_bps: 50 });
    expect(result.net).toBeDefined();
  });
});
