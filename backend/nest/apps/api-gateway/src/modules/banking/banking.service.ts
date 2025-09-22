import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { PartnerBankEntity, BankStatus } from './partner-bank.entity';
import { BankBrandingEntity } from './bank-branding.entity';
import { AssetProposalEntity, ProposalStatus } from './asset-proposal.entity';
import { BankSettlementEntity, SettlementStatus } from './bank-settlement.entity';
import { AssetEntity, AssetType } from '../assets/asset.entity';

@Injectable()
export class BankingService {
  constructor(
    @InjectRepository(PartnerBankEntity)
    private bankRepository: Repository<PartnerBankEntity>,

    @InjectRepository(BankBrandingEntity)
    private brandingRepository: Repository<BankBrandingEntity>,

    @InjectRepository(AssetProposalEntity)
    private proposalRepository: Repository<AssetProposalEntity>,

    @InjectRepository(BankSettlementEntity)
    private settlementRepository: Repository<BankSettlementEntity>,

    @InjectRepository(AssetEntity)
    private assetRepository: Repository<AssetEntity>,
  ) {}

  // ===================
  // MASTER ADMIN METHODS
  // ===================

  /**
   * Get all partner banks with pagination and filtering
   */
  async getAllBanks(options: {
    page?: number;
    limit?: number;
    status?: BankStatus;
    country?: string;
  }) {
    const { page = 1, limit = 20, status, country } = options;
    const offset = (page - 1) * limit;

    const query = this.bankRepository.createQueryBuilder('bank')
      .leftJoinAndSelect('bank.branding', 'branding');

    if (status) {
      query.andWhere('bank.status = :status', { status });
    }

    if (country) {
      query.andWhere('bank.country = :country', { country });
    }

    const [banks, total] = await query
      .skip(offset)
      .take(limit)
      .orderBy('bank.createdAt', 'DESC')
      .getManyAndCount();

    return {
      banks,
      total,
      page,
      limit,
      hasMore: offset + banks.length < total,
    };
  }

  /**
   * Get bank by ID with full details
   */
  async getBankById(bankId: string): Promise<PartnerBankEntity> {
    const bank = await this.bankRepository.findOne({
      where: { id: bankId },
      relations: ['branding'],
    });

    if (!bank) {
      throw new NotFoundException(`Bank with ID ${bankId} not found`);
    }

    return bank;
  }

  /**
   * Create new partner bank
   */
  async createBank(bankData: {
    name: string;
    legalName: string;
    registrationNumber: string;
    country: string;
    domain: string;
    subdomain?: string;
    commissionRateBps?: number;
    revenueShareBps?: number;
    contractStartDate: Date;
    contractEndDate?: Date;
    description?: string;
    contactInfo?: any;
    complianceDocs?: any;
  }): Promise<PartnerBankEntity> {
    // Check if domain already exists
    const existingBank = await this.bankRepository.findOne({
      where: { domain: bankData.domain },
    });

    if (existingBank) {
      throw new BadRequestException(`Bank with domain ${bankData.domain} already exists`);
    }

    const bank = this.bankRepository.create({
      ...bankData,
      status: BankStatus.pending,
    });

    return await this.bankRepository.save(bank);
  }

  /**
   * Update bank details
   */
  async updateBank(bankId: string, updateData: Partial<PartnerBankEntity>): Promise<PartnerBankEntity> {
    const bank = await this.getBankById(bankId);

    Object.assign(bank, updateData);
    return await this.bankRepository.save(bank);
  }

  /**
   * Approve bank (change status to active)
   */
  async approveBank(bankId: string, approvedBy: string): Promise<PartnerBankEntity> {
    const bank = await this.getBankById(bankId);

    if (bank.status !== BankStatus.pending) {
      throw new BadRequestException(`Bank must be in pending status to approve`);
    }

    bank.status = BankStatus.active;
    return await this.bankRepository.save(bank);
  }

  /**
   * Suspend bank
   */
  async suspendBank(bankId: string, reason?: string): Promise<PartnerBankEntity> {
    const bank = await this.getBankById(bankId);
    bank.status = BankStatus.suspended;
    return await this.bankRepository.save(bank);
  }

  /**
   * Terminate bank partnership
   */
  async terminateBank(bankId: string, reason?: string): Promise<PartnerBankEntity> {
    const bank = await this.getBankById(bankId);
    bank.status = BankStatus.terminated;
    bank.contractEndDate = new Date();
    return await this.bankRepository.save(bank);
  }

  // ===================
  // ASSET PROPOSAL METHODS
  // ===================

  /**
   * Get all asset proposals for Master Admin review
   */
  async getAllProposals(options: {
    page?: number;
    limit?: number;
    status?: ProposalStatus;
    bankId?: string;
    proposerType?: string;
  }) {
    const { page = 1, limit = 20, status, bankId, proposerType } = options;
    const offset = (page - 1) * limit;

    const query = this.proposalRepository.createQueryBuilder('proposal')
      .leftJoinAndSelect('proposal.bank', 'bank');

    if (status) {
      query.andWhere('proposal.status = :status', { status });
    }

    if (bankId) {
      query.andWhere('proposal.bankId = :bankId', { bankId });
    }

    if (proposerType) {
      query.andWhere('proposal.proposerType = :proposerType', { proposerType });
    }

    const [proposals, total] = await query
      .skip(offset)
      .take(limit)
      .orderBy('proposal.createdAt', 'DESC')
      .getManyAndCount();

    return {
      proposals,
      total,
      page,
      limit,
      hasMore: offset + proposals.length < total,
    };
  }

  /**
   * Get proposal by ID
   */
  async getProposalById(proposalId: string): Promise<AssetProposalEntity> {
    const proposal = await this.proposalRepository.findOne({
      where: { id: proposalId },
      relations: ['bank'],
    });

    if (!proposal) {
      throw new NotFoundException(`Proposal with ID ${proposalId} not found`);
    }

    return proposal;
  }

  /**
   * Approve asset proposal
   */
  async approveProposal(
    proposalId: string,
    approvedBy: string,
    conditions?: any
  ): Promise<AssetProposalEntity> {
    const proposal = await this.getProposalById(proposalId);

    if (proposal.status !== ProposalStatus.pending && proposal.status !== ProposalStatus.under_review) {
      throw new BadRequestException(`Proposal must be pending or under review to approve`);
    }

    // Create the actual asset from the proposal
    const createdAsset = await this.createAssetFromProposal(proposal, conditions);

    proposal.status = ProposalStatus.approved;
    proposal.reviewedBy = approvedBy;
    proposal.reviewedAt = new Date();
    proposal.approvalConditions = conditions;
    proposal.createdAssetId = createdAsset.id;

    return await this.proposalRepository.save(proposal);
  }

  /**
   * Reject asset proposal
   */
  async rejectProposal(
    proposalId: string,
    rejectedBy: string,
    rejectionReasons: any,
    notes?: string
  ): Promise<AssetProposalEntity> {
    const proposal = await this.getProposalById(proposalId);

    proposal.status = ProposalStatus.rejected;
    proposal.reviewedBy = rejectedBy;
    proposal.reviewedAt = new Date();
    proposal.rejectionReasons = rejectionReasons;
    proposal.masterAdminNotes = notes;

    return await this.proposalRepository.save(proposal);
  }

  // ===================
  // ANALYTICS & REPORTING
  // ===================

  /**
   * Get global platform analytics
   */
  async getGlobalAnalytics(period: { startDate: Date; endDate: Date }) {
    const { startDate, endDate } = period;

    // Get bank counts by status
    const bankStats = await this.bankRepository
      .createQueryBuilder('bank')
      .select('bank.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .groupBy('bank.status')
      .getRawMany();

    // Get proposal stats
    const proposalStats = await this.proposalRepository
      .createQueryBuilder('proposal')
      .select('proposal.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .where('proposal.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .groupBy('proposal.status')
      .getRawMany();

    // Get top performing banks by proposal volume
    const topBanks = await this.proposalRepository
      .createQueryBuilder('proposal')
      .select('bank.name', 'bankName')
      .addSelect('COUNT(*)', 'proposalCount')
      .leftJoin('proposal.bank', 'bank')
      .where('proposal.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .groupBy('bank.id, bank.name')
      .orderBy('COUNT(*)', 'DESC')
      .limit(10)
      .getRawMany();

    return {
      period: { startDate, endDate },
      banks: {
        total: bankStats.reduce((sum, stat) => sum + parseInt(stat.count), 0),
        byStatus: bankStats,
      },
      proposals: {
        total: proposalStats.reduce((sum, stat) => sum + parseInt(stat.count), 0),
        byStatus: proposalStats,
      },
      topBanks,
    };
  }

  /**
   * Get bank-specific analytics
   */
  async getBankAnalytics(bankId: string, period: { startDate: Date; endDate: Date }) {
    const bank = await this.getBankById(bankId);
    const { startDate, endDate } = period;

    // Get proposal metrics for this bank
    const proposalMetrics = await this.proposalRepository
      .createQueryBuilder('proposal')
      .select('proposal.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .addSelect('AVG(EXTRACT(EPOCH FROM (proposal.reviewedAt - proposal.createdAt)))', 'avgReviewTime')
      .where('proposal.bankId = :bankId', { bankId })
      .andWhere('proposal.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .groupBy('proposal.status')
      .getRawMany();

    // Get recent settlements
    const settlements = await this.settlementRepository.find({
      where: {
        bankId,
        periodStart: Between(startDate, endDate),
      },
      order: { periodStart: 'DESC' },
      take: 10,
    });

    return {
      bank: {
        id: bank.id,
        name: bank.name,
        status: bank.status,
      },
      period: { startDate, endDate },
      proposals: proposalMetrics,
      settlements,
      totalRevenue: settlements.reduce((sum, s) => sum + Number(s.netPayout), 0),
    };
  }

  // ===================
  // SETTLEMENT MANAGEMENT
  // ===================

  /**
   * Get all settlements with filtering
   */
  async getAllSettlements(options: {
    page?: number;
    limit?: number;
    status?: SettlementStatus;
    bankId?: string;
    startDate?: Date;
    endDate?: Date;
  }) {
    const { page = 1, limit = 20, status, bankId, startDate, endDate } = options;
    const offset = (page - 1) * limit;

    const query = this.settlementRepository.createQueryBuilder('settlement')
      .leftJoinAndSelect('settlement.bank', 'bank');

    if (status) {
      query.andWhere('settlement.status = :status', { status });
    }

    if (bankId) {
      query.andWhere('settlement.bankId = :bankId', { bankId });
    }

    if (startDate && endDate) {
      query.andWhere('settlement.periodStart BETWEEN :startDate AND :endDate', { startDate, endDate });
    }

    const [settlements, total] = await query
      .skip(offset)
      .take(limit)
      .orderBy('settlement.periodStart', 'DESC')
      .getManyAndCount();

    return {
      settlements,
      total,
      page,
      limit,
      hasMore: offset + settlements.length < total,
    };
  }

  /**
   * Create settlement for a bank
   */
  async createSettlement(settlementData: {
    bankId: string;
    periodStart: Date;
    periodEnd: Date;
    totalVolume: number;
    commissionEarned: number;
    revenueShare: number;
    platformFees: number;
    netPayout: number;
    currency: string;
    breakdown?: any;
    notes?: string;
  }): Promise<BankSettlementEntity> {
    const settlement = this.settlementRepository.create({
      ...settlementData,
      status: SettlementStatus.pending,
    });

    return await this.settlementRepository.save(settlement);
  }

  /**
   * Process settlement (mark as processed)
   */
  async processSettlement(settlementId: string, processedBy: string): Promise<BankSettlementEntity> {
    const settlement = await this.settlementRepository.findOne({
      where: { id: settlementId },
    });

    if (!settlement) {
      throw new NotFoundException(`Settlement with ID ${settlementId} not found`);
    }

    settlement.status = SettlementStatus.processed;
    settlement.processedBy = processedBy;
    settlement.processedAt = new Date();

    return await this.settlementRepository.save(settlement);
  }

  // ===================
  // ASSET CREATION METHODS
  // ===================

  /**
   * Create an actual asset from an approved proposal
   */
  private async createAssetFromProposal(
    proposal: AssetProposalEntity,
    conditions?: any
  ): Promise<AssetEntity> {
    const { assetDetails } = proposal;

    // Map proposal asset type to AssetEntity enum
    const assetTypeMapping: Record<string, AssetType> = {
      'land': AssetType.land,
      'truck': AssetType.truck,
      'hotel': AssetType.hotel,
      'house': AssetType.house,
      'real_estate': AssetType.house, // Map real_estate to house for now
      'other': AssetType.other
    };

    const asset = this.assetRepository.create({
      type: assetTypeMapping[assetDetails.type] || AssetType.other,
      title: assetDetails.title,
      spv_id: `SPV-${proposal.bankId.slice(0, 8)}-${Date.now()}`, // Generate SPV ID
      status: 'active',
      nav: assetDetails.financials.estimatedValue.toString(),
      verification_required: assetDetails.verification.professionalVerificationRequired ||
                           assetDetails.verification.thirdPartyVerificationRequired
    });

    return await this.assetRepository.save(asset);
  }

  /**
   * Create asset proposal for banks/users to submit
   */
  async createProposal(proposalData: {
    proposerType: 'bank' | 'investor' | 'agent' | 'verifier';
    proposerId: string;
    bankId: string;
    assetDetails: any;
    documents?: string[];
  }): Promise<AssetProposalEntity> {
    const proposal = this.proposalRepository.create({
      ...proposalData,
      status: ProposalStatus.pending,
      documents: proposalData.documents || []
    });

    return await this.proposalRepository.save(proposal);
  }
}