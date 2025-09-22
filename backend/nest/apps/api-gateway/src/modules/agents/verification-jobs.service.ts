import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

// Note: This would be a proper entity in production
interface VerificationJob {
  id: number;
  asset_id: number;
  investor_id: number;
  agent_id?: number;
  status: string;
  price: number;
  currency: string;
  created_at: Date;
}

@Injectable()
export class VerificationJobsService {
  // In-memory stub; replace with proper entity and repository
  private jobs: VerificationJob[] = [];
  private nextId = 1;

  create(data: Partial<VerificationJob>) {
    const job = { id: this.nextId++, ...data, created_at: new Date() } as VerificationJob;
    this.jobs.push(job);
    return job;
  }

  findOne(id: number) {
    return this.jobs.find(j => j.id === id);
  }

  update(id: number, data: Partial<VerificationJob>) {
    const index = this.jobs.findIndex(j => j.id === id);
    if (index >= 0) {
      this.jobs[index] = { ...this.jobs[index], ...data };
      return this.jobs[index];
    }
    return null;
  }

  findByAsset(assetId: number) {
    return this.jobs.filter(j => j.asset_id === assetId);
  }

  findByAgent(agentId: number) {
    return this.jobs.filter(j => j.agent_id === agentId);
  }
}



