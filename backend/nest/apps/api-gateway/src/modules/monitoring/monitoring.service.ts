import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FlagEntity, FlagType, FlagStatus, FlagSeverity } from './flag.entity';
import { FlagVoteEntity, VoteType } from './flag-vote.entity';
import { UserEntity } from '../users/user.entity';
import { AssetEntity } from '../assets/asset.entity';
// import { InvestorAgentService } from '../users/investor-agent.service';

export interface CreateFlagDto {
  asset_id: number;
  type: FlagType;
  severity: FlagSeverity;
  title: string;
  description: string;
  evidence?: any;
  is_anonymous?: boolean;
}

export interface UpdateFlagDto {
  status?: FlagStatus;
  admin_notes?: string;
  resolution_notes?: string;
  assigned_admin_id?: number;
}

export interface FlagFilters {
  asset_id?: number;
  flagger_id?: number;
  status?: FlagStatus;
  type?: FlagType;
  severity?: FlagSeverity;
  limit?: number;
  offset?: number;
}

@Injectable()
export class MonitoringService {
  constructor(
    @InjectRepository(FlagEntity)
    private flagRepository: Repository<FlagEntity>,
    @InjectRepository(FlagVoteEntity)
    private flagVoteRepository: Repository<FlagVoteEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(AssetEntity)
    private assetRepository: Repository<AssetEntity>,
    // private investorAgentService: InvestorAgentService,
  ) {}

  async createFlag(flagger_id: string, createFlagDto: CreateFlagDto): Promise<FlagEntity> {
    // Verify flagger exists and is an investor or investor-agent
    const flagger = await this.userRepository.findOne({
      where: { id: flagger_id },
      select: ['id', 'role']
    });
    if (!flagger) {
      throw new NotFoundException('Flagger not found');
    }
    if (!['investor', 'investor_agent'].includes(flagger.role)) {
      throw new BadRequestException('Only investors and investor-agents can create flags');
    }

    // Verify asset exists
    const asset = await this.assetRepository.findOne({
      where: { id: createFlagDto.asset_id }
    });
    if (!asset) {
      throw new NotFoundException('Asset not found');
    }

    // Check for duplicate flags from same user on same asset
    const existingFlag = await this.flagRepository.findOne({
      where: {
        asset_id: createFlagDto.asset_id,
        flagger_id: flagger_id,
        status: FlagStatus.PENDING
      }
    });
    if (existingFlag) {
      throw new BadRequestException('You already have a pending flag for this asset');
    }

    const flag = this.flagRepository.create({
      ...createFlagDto,
      flagger_id,
      status: FlagStatus.PENDING
    });

    return await this.flagRepository.save(flag);
  }

  async voteOnFlag(flag_id: number, voter_id: string, vote_type: VoteType): Promise<FlagEntity> {
    // Verify flag exists
    const flag = await this.flagRepository.findOne({ where: { id: flag_id } });
    if (!flag) {
      throw new NotFoundException('Flag not found');
    }

    // Verify voter is an investor-agent
    const voter = await this.userRepository.findOne({
      where: { id: voter_id },
      select: ['id', 'role']
    });
    if (!voter || !['investor', 'investor_agent'].includes(voter.role)) {
      throw new BadRequestException('Only investor-agents can vote on flags');
    }

    // Check if user already voted
    const existingVote = await this.flagVoteRepository.findOne({
      where: { flag_id, voter_id }
    });

    if (existingVote) {
      // Update existing vote
      if (existingVote.vote_type !== vote_type) {
        // Update vote counts
        if (existingVote.vote_type === VoteType.UPVOTE) {
          flag.upvotes--;
          flag.downvotes++;
        } else {
          flag.downvotes--;
          flag.upvotes++;
        }
        existingVote.vote_type = vote_type;
        await this.flagVoteRepository.save(existingVote);
      }
    } else {
      // Create new vote
      const vote = this.flagVoteRepository.create({
        flag_id,
        voter_id,
        vote_type
      });
      await this.flagVoteRepository.save(vote);

      // Update vote counts
      if (vote_type === VoteType.UPVOTE) {
        flag.upvotes++;
      } else {
        flag.downvotes++;
      }
    }

    await this.flagRepository.save(flag);

    // Auto-escalate if high upvote ratio
    const totalVotes = flag.upvotes + flag.downvotes;
    if (totalVotes >= 5 && flag.upvotes / totalVotes >= 0.8) {
      flag.status = FlagStatus.ESCALATED;
      await this.flagRepository.save(flag);
    }

    return flag;
  }

  async getFlags(filters: FlagFilters = {}): Promise<{ flags: FlagEntity[], total: number }> {
    const query = this.flagRepository.createQueryBuilder('flag')
      .leftJoinAndSelect('flag.asset', 'asset')
      .leftJoinAndSelect('flag.flagger', 'flagger')
      .leftJoinAndSelect('flag.assigned_admin', 'admin');

    if (filters.asset_id) {
      query.andWhere('flag.asset_id = :asset_id', { asset_id: filters.asset_id });
    }
    if (filters.flagger_id) {
      query.andWhere('flag.flagger_id = :flagger_id', { flagger_id: filters.flagger_id });
    }
    if (filters.status) {
      query.andWhere('flag.status = :status', { status: filters.status });
    }
    if (filters.type) {
      query.andWhere('flag.type = :type', { type: filters.type });
    }
    if (filters.severity) {
      query.andWhere('flag.severity = :severity', { severity: filters.severity });
    }

    query.orderBy('flag.created_at', 'DESC');

    const total = await query.getCount();

    if (filters.limit) {
      query.limit(filters.limit);
    }
    if (filters.offset) {
      query.offset(filters.offset);
    }

    const flags = await query.getMany();

    return { flags, total };
  }

  async getFlagById(id: number): Promise<FlagEntity> {
    const flag = await this.flagRepository.findOne({
      where: { id },
      relations: ['asset', 'flagger', 'assigned_admin']
    });
    if (!flag) {
      throw new NotFoundException('Flag not found');
    }
    return flag;
  }

  async updateFlag(id: number, updateFlagDto: UpdateFlagDto): Promise<FlagEntity> {
    const flag = await this.getFlagById(id);
    const oldStatus = flag.status;

    Object.assign(flag, updateFlagDto);

    const updatedFlag = await this.flagRepository.save(flag);

    // Update investor-agent stats if flag was resolved
    if (oldStatus !== FlagStatus.RESOLVED && updatedFlag.status === FlagStatus.RESOLVED) {
      // await this.investorAgentService.updateStats(flag.flagger_id, true);
    } else if (oldStatus !== FlagStatus.DISMISSED && updatedFlag.status === FlagStatus.DISMISSED) {
      // await this.investorAgentService.updateStats(flag.flagger_id, false);
    }

    return updatedFlag;
  }

  async deleteFlag(id: number): Promise<void> {
    const result = await this.flagRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Flag not found');
    }
  }

  async getInvestorAgentStats(user_id: number): Promise<any> {
    const flags = await this.flagRepository.find({
      where: { flagger_id: user_id },
      relations: ['asset']
    });

    const resolvedFlags = flags.filter(f => f.status === FlagStatus.RESOLVED);
    const accuracy = flags.length > 0 ? resolvedFlags.length / flags.length : 0;

    return {
      total_flags: flags.length,
      resolved_flags: resolvedFlags.length,
      accuracy_rate: accuracy,
      reputation_score: Math.round(accuracy * 100),
      total_upvotes: flags.reduce((sum, f) => sum + f.upvotes, 0),
      total_downvotes: flags.reduce((sum, f) => sum + f.downvotes, 0)
    };
  }
}