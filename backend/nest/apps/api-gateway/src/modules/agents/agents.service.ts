import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AgentEntity, AgentStatus } from './agent.entity';

@Injectable()
export class AgentsService {
  constructor(@InjectRepository(AgentEntity) private readonly repo: Repository<AgentEntity>) {}

  async findAll(filters?: { 
    regions?: string[]; 
    skills?: string[];
    rating_gte?: number; 
    limit?: number;
    offset?: number;
  }) {
    const qb = this.repo.createQueryBuilder('agent');
    
    if (filters?.regions && filters.regions.length > 0) {
      qb.andWhere('agent.regions && :regions', { regions: filters.regions });
    }
    if (filters?.skills && filters.skills.length > 0) {
      qb.andWhere('agent.skills && :skills', { skills: filters.skills });
    }
    if (filters?.rating_gte) qb.andWhere('agent.rating_avg >= :rating', { rating: filters.rating_gte });
    
    // Pagination
    if (filters?.limit) qb.take(filters.limit);
    if (filters?.offset) qb.skip(filters.offset);
    
    // Default ordering by rating
    qb.orderBy('agent.rating_avg', 'DESC')
      .addOrderBy('agent.rating_count', 'DESC')
      .addOrderBy('agent.createdAt', 'DESC');
    
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

  create(data: Partial<AgentEntity>) {
    const agent = this.repo.create(data);
    return this.repo.save(agent);
  }

  update(id: number, data: Partial<AgentEntity>) {
    return this.repo.update(id, data);
  }
}



