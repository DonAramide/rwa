import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { BankingService } from './banking.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../users/user.entity';

// DTOs for request/response
class CreateBankDto {
  name!: string;
  legalName!: string;
  registrationNumber!: string;
  country!: string;
  domain!: string;
  subdomain?: string;
  commissionRateBps?: number;
  revenueShareBps?: number;
  contractStartDate!: Date;
  contractEndDate?: Date;
  description?: string;
  contactInfo?: any;
  complianceDocs?: any;
}

class UpdateBankDto {
  name?: string;
  legalName?: string;
  registrationNumber?: string;
  country?: string;
  domain?: string;
  subdomain?: string;
  commissionRateBps?: number;
  revenueShareBps?: number;
  contractStartDate?: Date;
  contractEndDate?: Date;
  description?: string;
  contactInfo?: any;
  complianceDocs?: any;
}

class ProposalReviewDto {
  status!: 'approved' | 'rejected';
  notes?: string;
  rejectionReasons?: {
    categories: string[];
    details: string;
    suggestedImprovements?: string[];
  };
  approvalConditions?: {
    verificationRequired: boolean;
    additionalDocuments?: string[];
    modifiedFinancials?: {
      maxInvestmentTarget?: number;
      minInvestmentAmount?: number;
    };
    specialTerms?: string[];
  };
}

@ApiTags('Master Admin - Banking')
@Controller('master')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
@Roles(UserRole.master_admin)
export class MasterAdminController {
  constructor(private readonly bankingService: BankingService) {}

  // ===================
  // BANK MANAGEMENT
  // ===================

  @Get('banks')
  @ApiOperation({ summary: 'Get all partner banks' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'active', 'suspended', 'terminated'] })
  @ApiQuery({ name: 'country', required: false, type: String })
  @ApiResponse({ status: HttpStatus.OK, description: 'List of partner banks' })
  async getAllBanks(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
    @Query('country') country?: string,
  ) {
    return await this.bankingService.getAllBanks({
      page: page ? parseInt(page.toString()) : undefined,
      limit: limit ? parseInt(limit.toString()) : undefined,
      status: status as any,
      country,
    });
  }

  @Get('banks/:bankId')
  @ApiOperation({ summary: 'Get bank details by ID' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank details' })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, description: 'Bank not found' })
  async getBankById(@Param('bankId', ParseUUIDPipe) bankId: string) {
    return await this.bankingService.getBankById(bankId);
  }

  @Post('banks')
  @ApiOperation({ summary: 'Create new partner bank' })
  @ApiResponse({ status: HttpStatus.CREATED, description: 'Bank created successfully' })
  @ApiResponse({ status: HttpStatus.BAD_REQUEST, description: 'Invalid bank data or domain already exists' })
  async createBank(@Body() createBankDto: CreateBankDto) {
    return await this.bankingService.createBank(createBankDto);
  }

  @Patch('banks/:bankId')
  @ApiOperation({ summary: 'Update bank details' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank updated successfully' })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, description: 'Bank not found' })
  async updateBank(
    @Param('bankId', ParseUUIDPipe) bankId: string,
    @Body() updateBankDto: UpdateBankDto,
  ) {
    return await this.bankingService.updateBank(bankId, updateBankDto);
  }

  @Post('banks/:bankId/approve')
  @ApiOperation({ summary: 'Approve partner bank' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank approved successfully' })
  @ApiResponse({ status: HttpStatus.BAD_REQUEST, description: 'Bank not in pending status' })
  async approveBank(
    @Param('bankId', ParseUUIDPipe) bankId: string,
    @Request() req: any,
  ) {
    return await this.bankingService.approveBank(bankId, req.user.id);
  }

  @Post('banks/:bankId/suspend')
  @ApiOperation({ summary: 'Suspend partner bank' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank suspended successfully' })
  async suspendBank(
    @Param('bankId', ParseUUIDPipe) bankId: string,
    @Body() body: { reason?: string },
  ) {
    return await this.bankingService.suspendBank(bankId, body.reason);
  }

  @Post('banks/:bankId/terminate')
  @ApiOperation({ summary: 'Terminate partner bank' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank terminated successfully' })
  async terminateBank(
    @Param('bankId', ParseUUIDPipe) bankId: string,
    @Body() body: { reason?: string },
  ) {
    return await this.bankingService.terminateBank(bankId, body.reason);
  }

  // ===================
  // ASSET PROPOSAL MANAGEMENT
  // ===================

  @Get('asset-proposals')
  @ApiOperation({ summary: 'Get all asset proposals for review' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'under_review', 'approved', 'rejected'] })
  @ApiQuery({ name: 'bankId', required: false, type: String })
  @ApiQuery({ name: 'proposerType', required: false, enum: ['bank', 'investor', 'agent', 'verifier'] })
  @ApiResponse({ status: HttpStatus.OK, description: 'List of asset proposals' })
  async getAllProposals(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
    @Query('bankId') bankId?: string,
    @Query('proposerType') proposerType?: string,
  ) {
    return await this.bankingService.getAllProposals({
      page: page ? parseInt(page.toString()) : undefined,
      limit: limit ? parseInt(limit.toString()) : undefined,
      status: status as any,
      bankId,
      proposerType,
    });
  }

  @Get('asset-proposals/:proposalId')
  @ApiOperation({ summary: 'Get asset proposal details' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Proposal details' })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, description: 'Proposal not found' })
  async getProposalById(@Param('proposalId', ParseUUIDPipe) proposalId: string) {
    return await this.bankingService.getProposalById(proposalId);
  }

  @Post('asset-proposals/:proposalId/approve')
  @ApiOperation({ summary: 'Approve asset proposal' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Proposal approved successfully' })
  @ApiResponse({ status: HttpStatus.BAD_REQUEST, description: 'Proposal not in valid status for approval' })
  async approveProposal(
    @Param('proposalId', ParseUUIDPipe) proposalId: string,
    @Body() reviewDto: ProposalReviewDto,
    @Request() req: any,
  ) {
    if (reviewDto.status !== 'approved') {
      throw new Error('Invalid status for approval endpoint');
    }

    return await this.bankingService.approveProposal(
      proposalId,
      req.user.id,
      reviewDto.approvalConditions,
    );
  }

  @Post('asset-proposals/:proposalId/reject')
  @ApiOperation({ summary: 'Reject asset proposal' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Proposal rejected successfully' })
  async rejectProposal(
    @Param('proposalId', ParseUUIDPipe) proposalId: string,
    @Body() reviewDto: ProposalReviewDto,
    @Request() req: any,
  ) {
    if (reviewDto.status !== 'rejected') {
      throw new Error('Invalid status for rejection endpoint');
    }

    return await this.bankingService.rejectProposal(
      proposalId,
      req.user.id,
      reviewDto.rejectionReasons,
      reviewDto.notes,
    );
  }

  // ===================
  // ANALYTICS & REPORTING
  // ===================

  @Get('analytics/global')
  @ApiOperation({ summary: 'Get global platform analytics' })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: HttpStatus.OK, description: 'Global analytics data' })
  async getGlobalAnalytics(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const period = {
      startDate: startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
      endDate: endDate ? new Date(endDate) : new Date(),
    };

    return await this.bankingService.getGlobalAnalytics(period);
  }

  @Get('banks/:bankId/analytics')
  @ApiOperation({ summary: 'Get bank-specific analytics' })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank analytics data' })
  async getBankAnalytics(
    @Param('bankId', ParseUUIDPipe) bankId: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const period = {
      startDate: startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
      endDate: endDate ? new Date(endDate) : new Date(),
    };

    return await this.bankingService.getBankAnalytics(bankId, period);
  }

  // ===================
  // SETTLEMENT MANAGEMENT
  // ===================

  @Get('settlements')
  @ApiOperation({ summary: 'Get all bank settlements' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'processed', 'paid', 'failed'] })
  @ApiQuery({ name: 'bankId', required: false, type: String })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: HttpStatus.OK, description: 'List of settlements' })
  async getAllSettlements(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
    @Query('bankId') bankId?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return await this.bankingService.getAllSettlements({
      page: page ? parseInt(page.toString()) : undefined,
      limit: limit ? parseInt(limit.toString()) : undefined,
      status: status as any,
      bankId,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
    });
  }

  @Post('settlements/:settlementId/process')
  @ApiOperation({ summary: 'Process settlement (mark as processed)' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Settlement processed successfully' })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, description: 'Settlement not found' })
  async processSettlement(
    @Param('settlementId', ParseUUIDPipe) settlementId: string,
    @Request() req: any,
  ) {
    return await this.bankingService.processSettlement(settlementId, req.user.id);
  }

  @Post('settlements/trigger')
  @ApiOperation({ summary: 'Trigger settlement calculation for all banks' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Settlement calculation triggered' })
  async triggerSettlements(@Body() body: { periodStart: Date; periodEnd: Date }) {
    // This would trigger a background job to calculate settlements for all banks
    // For now, return success message
    return {
      message: 'Settlement calculation triggered for all active banks',
      period: body,
      triggered: true,
    };
  }
}