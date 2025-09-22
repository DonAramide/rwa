import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  VerificationRequestEntity,
  VerificationRequestType,
  VerificationRequestStatus,
  VerificationRequestUrgency
} from './verification-request.entity';
import {
  VerificationProposalEntity
} from './verification-request.entity';
import {
  VerificationReportEntity
} from './verification-request.entity';
import { UserEntity, UserRole } from '../users/user.entity';
import { AssetEntity } from '../assets/asset.entity';

export interface CreateVerificationRequestDto {
  asset_id: number;
  type: VerificationRequestType;
  urgency: VerificationRequestUrgency;
  title: string;
  description: string;
  requirements?: any;
  location?: any;
  budget: string;
  currency?: string;
  deadline?: Date;
  deliverables?: any;
  notes?: string;
}

export interface CreateProposalDto {
  request_id: number;
  proposed_price: string;
  currency?: string;
  proposal_message: string;
  estimated_completion: Date;
  methodology?: any;
}

export interface CreateReportDto {
  request_id: number;
  title: string;
  summary: string;
  findings: any;
  photos?: any;
  documents?: any;
  gps_data?: any;
}

export interface VerificationRequestFilters {
  type?: VerificationRequestType;
  status?: VerificationRequestStatus;
  urgency?: VerificationRequestUrgency;
  requester_id?: number;
  assigned_verifier_id?: number;
  asset_id?: number;
  budget_min?: number;
  budget_max?: number;
  location_radius?: number; // For geographic filtering
  location_center?: { lat: number; lng: number };
  limit?: number;
  offset?: number;
}

@Injectable()
export class VerificationRequestService {
  constructor(
    @InjectRepository(VerificationRequestEntity)
    private requestRepository: Repository<VerificationRequestEntity>,
    @InjectRepository(VerificationProposalEntity)
    private proposalRepository: Repository<VerificationProposalEntity>,
    @InjectRepository(VerificationReportEntity)
    private reportRepository: Repository<VerificationReportEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(AssetEntity)
    private assetRepository: Repository<AssetEntity>,
  ) {}

  async createRequest(requester_id: number, dto: CreateVerificationRequestDto): Promise<VerificationRequestEntity> {
    // Verify requester is an investor or investor-agent
    const requester = await this.userRepository.findOne({
      where: { id: requester_id },
      select: ['id', 'role']
    });
    if (!requester) {
      throw new NotFoundException('Requester not found');
    }
    if (!['investor', 'investor_agent'].includes(requester.role)) {
      throw new BadRequestException('Only investors and investor-agents can create verification requests');
    }

    // Verify asset exists
    const asset = await this.assetRepository.findOne({
      where: { id: dto.asset_id }
    });
    if (!asset) {
      throw new NotFoundException('Asset not found');
    }

    const request = this.requestRepository.create({
      ...dto,
      requester_id,
      status: VerificationRequestStatus.PENDING,
      currency: dto.currency || 'USD'
    });

    return await this.requestRepository.save(request);
  }

  async createProposal(verifier_id: number, dto: CreateProposalDto): Promise<VerificationProposalEntity> {
    // Verify verifier is a verifier
    const verifier = await this.userRepository.findOne({
      where: { id: verifier_id },
      select: ['id', 'role']
    });
    if (!verifier || verifier.role !== UserRole.verifier) {
      throw new BadRequestException('Only verifiers can create proposals');
    }

    // Verify request exists and is in correct status
    const request = await this.requestRepository.findOne({
      where: { id: dto.request_id }
    });
    if (!request) {
      throw new NotFoundException('Verification request not found');
    }
    if (request.status !== VerificationRequestStatus.PENDING) {
      throw new BadRequestException('This request is no longer accepting proposals');
    }

    // Check if verifier already has a proposal for this request
    const existingProposal = await this.proposalRepository.findOne({
      where: { request_id: dto.request_id, verifier_id }
    });
    if (existingProposal) {
      throw new BadRequestException('You have already submitted a proposal for this request');
    }

    const proposal = this.proposalRepository.create({
      ...dto,
      verifier_id,
      currency: dto.currency || 'USD'
    });

    return await this.proposalRepository.save(proposal);
  }

  async acceptProposal(requester_id: number, proposal_id: number): Promise<VerificationRequestEntity> {
    const proposal = await this.proposalRepository.findOne({
      where: { id: proposal_id },
      relations: ['request', 'verifier']
    });
    if (!proposal) {
      throw new NotFoundException('Proposal not found');
    }

    // Verify requester owns the request
    if (proposal.request.requester_id !== requester_id) {
      throw new ForbiddenException('You can only accept proposals for your own requests');
    }

    // Update proposal as accepted
    proposal.is_accepted = true;
    await this.proposalRepository.save(proposal);

    // Update request status and assign verifier
    proposal.request.status = VerificationRequestStatus.ASSIGNED;
    proposal.request.assigned_verifier_id = proposal.verifier_id;

    return await this.requestRepository.save(proposal.request);
  }

  async startVerification(verifier_id: number, request_id: number): Promise<VerificationRequestEntity> {
    const request = await this.requestRepository.findOne({
      where: { id: request_id }
    });
    if (!request) {
      throw new NotFoundException('Request not found');
    }

    if (request.assigned_verifier_id !== verifier_id) {
      throw new ForbiddenException('You are not assigned to this verification');
    }

    if (request.status !== VerificationRequestStatus.ASSIGNED) {
      throw new BadRequestException('This verification cannot be started');
    }

    request.status = VerificationRequestStatus.IN_PROGRESS;
    return await this.requestRepository.save(request);
  }

  async submitReport(verifier_id: number, dto: CreateReportDto): Promise<VerificationReportEntity> {
    const request = await this.requestRepository.findOne({
      where: { id: dto.request_id }
    });
    if (!request) {
      throw new NotFoundException('Request not found');
    }

    if (request.assigned_verifier_id !== verifier_id) {
      throw new ForbiddenException('You are not assigned to this verification');
    }

    if (request.status !== VerificationRequestStatus.IN_PROGRESS) {
      throw new BadRequestException('This verification is not in progress');
    }

    const report = this.reportRepository.create({
      ...dto,
      verifier_id
    });

    const savedReport = await this.reportRepository.save(report);

    // Update request status
    request.status = VerificationRequestStatus.SUBMITTED;
    await this.requestRepository.save(request);

    return savedReport;
  }

  async getRequests(filters: VerificationRequestFilters = {}): Promise<{ requests: VerificationRequestEntity[], total: number }> {
    const query = this.requestRepository.createQueryBuilder('request')
      .leftJoinAndSelect('request.asset', 'asset')
      .leftJoinAndSelect('request.requester', 'requester')
      .leftJoinAndSelect('request.assigned_verifier', 'verifier');

    if (filters.type) {
      query.andWhere('request.type = :type', { type: filters.type });
    }
    if (filters.status) {
      query.andWhere('request.status = :status', { status: filters.status });
    }
    if (filters.urgency) {
      query.andWhere('request.urgency = :urgency', { urgency: filters.urgency });
    }
    if (filters.requester_id) {
      query.andWhere('request.requester_id = :requester_id', { requester_id: filters.requester_id });
    }
    if (filters.assigned_verifier_id) {
      query.andWhere('request.assigned_verifier_id = :assigned_verifier_id', { assigned_verifier_id: filters.assigned_verifier_id });
    }
    if (filters.asset_id) {
      query.andWhere('request.asset_id = :asset_id', { asset_id: filters.asset_id });
    }
    if (filters.budget_min) {
      query.andWhere('CAST(request.budget AS DECIMAL) >= :budget_min', { budget_min: filters.budget_min });
    }
    if (filters.budget_max) {
      query.andWhere('CAST(request.budget AS DECIMAL) <= :budget_max', { budget_max: filters.budget_max });
    }

    // Geographic filtering (if location data exists)
    if (filters.location_center && filters.location_radius) {
      // This would require PostGIS extension for proper geographic queries
      // For now, we'll skip this implementation
    }

    query.orderBy('request.created_at', 'DESC');

    const total = await query.getCount();

    if (filters.limit) {
      query.limit(filters.limit);
    }
    if (filters.offset) {
      query.offset(filters.offset);
    }

    const requests = await query.getMany();

    return { requests, total };
  }

  async getRequestById(id: number): Promise<VerificationRequestEntity> {
    const request = await this.requestRepository.findOne({
      where: { id },
      relations: ['asset', 'requester', 'assigned_verifier']
    });
    if (!request) {
      throw new NotFoundException('Request not found');
    }
    return request;
  }

  async getProposalsForRequest(request_id: number): Promise<VerificationProposalEntity[]> {
    return await this.proposalRepository.find({
      where: { request_id },
      relations: ['verifier'],
      order: { created_at: 'ASC' }
    });
  }

  async getReportForRequest(request_id: number): Promise<VerificationReportEntity | null> {
    return await this.reportRepository.findOne({
      where: { request_id },
      relations: ['verifier', 'reviewer']
    });
  }

  async cancelRequest(requester_id: number, request_id: number): Promise<VerificationRequestEntity> {
    const request = await this.getRequestById(request_id);

    if (request.requester_id !== requester_id) {
      throw new ForbiddenException('You can only cancel your own requests');
    }

    if ([VerificationRequestStatus.SUBMITTED, VerificationRequestStatus.APPROVED].includes(request.status)) {
      throw new BadRequestException('Cannot cancel request in current status');
    }

    request.status = VerificationRequestStatus.CANCELLED;
    return await this.requestRepository.save(request);
  }

  async getAvailableRequests(verifier_id: number, filters: VerificationRequestFilters = {}): Promise<{ requests: VerificationRequestEntity[], total: number }> {
    // Get requests that are pending and don't have existing proposals from this verifier
    const subQuery = this.proposalRepository.createQueryBuilder('proposal')
      .select('proposal.request_id')
      .where('proposal.verifier_id = :verifier_id', { verifier_id });

    const query = this.requestRepository.createQueryBuilder('request')
      .leftJoinAndSelect('request.asset', 'asset')
      .leftJoinAndSelect('request.requester', 'requester')
      .where('request.status = :status', { status: VerificationRequestStatus.PENDING })
      .andWhere(`request.id NOT IN (${subQuery.getQuery()})`)
      .setParameter('verifier_id', verifier_id);

    // Apply other filters
    if (filters.type) {
      query.andWhere('request.type = :type', { type: filters.type });
    }
    if (filters.urgency) {
      query.andWhere('request.urgency = :urgency', { urgency: filters.urgency });
    }
    if (filters.budget_min) {
      query.andWhere('CAST(request.budget AS DECIMAL) >= :budget_min', { budget_min: filters.budget_min });
    }
    if (filters.budget_max) {
      query.andWhere('CAST(request.budget AS DECIMAL) <= :budget_max', { budget_max: filters.budget_max });
    }

    query.orderBy('request.urgency', 'DESC')
      .addOrderBy('request.created_at', 'DESC');

    const total = await query.getCount();

    if (filters.limit) {
      query.limit(filters.limit);
    }
    if (filters.offset) {
      query.offset(filters.offset);
    }

    const requests = await query.getMany();

    return { requests, total };
  }
}