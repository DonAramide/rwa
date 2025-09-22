import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AssetEntity, AssetType } from './asset.entity';

@Injectable()
export class AssetsService {
  constructor(@InjectRepository(AssetEntity) private readonly repo: Repository<AssetEntity>) {}

  async findAll(filters?: { 
    type?: AssetType; 
    status?: string; 
    search?: string;
    limit?: number; 
    offset?: number 
  }) {
    const qb = this.repo.createQueryBuilder('asset');
    
    if (filters?.type) qb.andWhere('asset.type = :type', { type: filters.type });
    if (filters?.status) qb.andWhere('asset.status = :status', { status: filters.status });
    if (filters?.search) {
      qb.andWhere('asset.title ILIKE :search', { 
        search: `%${filters.search}%` 
      });
    }
    
    // Pagination
    if (filters?.limit) qb.take(filters.limit);
    if (filters?.offset) qb.skip(filters.offset);
    
    // Default ordering
    qb.orderBy('asset.createdAt', 'DESC');
    
    const [items, total] = await qb.getManyAndCount();
    return {
      items,
      total,
      limit: filters?.limit || 20,
      offset: filters?.offset || 0,
      hasMore: (filters?.offset || 0) + (filters?.limit || 20) < total
    };
  }

  findOne(id: number) {
    return this.repo.findOne({ where: { id } });
  }

  create(data: Partial<AssetEntity>) {
    const asset = this.repo.create(data);
    return this.repo.save(asset);
  }

  update(id: number, data: Partial<AssetEntity>) {
    return this.repo.update(id, data);
  }
}



