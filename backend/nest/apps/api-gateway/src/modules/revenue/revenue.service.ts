import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DistributionEntity } from './distribution.entity';

@Injectable()
export class RevenueService {
  constructor(@InjectRepository(DistributionEntity) private readonly repo: Repository<DistributionEntity>) {}

  findByAsset(assetId: number) {
    return this.repo.find({ where: { asset_id: assetId } });
  }

  create(data: Partial<DistributionEntity>) {
    const distribution = this.repo.create(data);
    return this.repo.save(distribution);
  }

  triggerPayout(data: { asset_id: number; period: string; gross: number; mgmt_fee_bps?: number; carry_bps?: number }) {
    const managementFeeBps = data.mgmt_fee_bps || 0;
    const carryFeeBps = data.carry_bps || 0;
    const net = data.gross - managementFeeBps * data.gross / 10000 - carryFeeBps * data.gross / 10000;
    return this.create({
      asset_id: data.asset_id,
      period: data.period as any, // tstzrange
      gross: data.gross.toString(),
      mgmtFeeBps: managementFeeBps,
      carryBps: carryFeeBps,
      net: net.toString(),
    });
  }
}


