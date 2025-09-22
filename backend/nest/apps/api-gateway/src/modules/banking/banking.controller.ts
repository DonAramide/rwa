import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  HttpStatus,
  ParseUUIDPipe,
  ForbiddenException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { BankingService } from './banking.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../users/user.entity';

// DTOs for Bank Admin operations
class SubmitAssetProposalDto {
  assetDetails!: {
    type: 'land' | 'truck' | 'hotel' | 'house' | 'real_estate' | 'other';
    title: string;
    description: string;
    location: {
      address: string;
      coordinates?: { lat: number; lng: number };
      country: string;
      state?: string;
      city?: string;
    };
    financials: {
      estimatedValue: number;
      currency: string;
      expectedAnnualReturn?: number;
      initialInvestmentTarget: number;
    };
    legal: {
      ownershipType: string;
      registrationNumber?: string;
      legalDocuments: string[];
    };
    verification: {
      selfVerified: boolean;
      professionalVerificationRequired: boolean;
      thirdPartyVerificationRequired: boolean;
    };
    additional?: Record<string, any>;
  };
  documents?: string[];
}

class UpdateBankProfileDto {
  name?: string;
  description?: string;
  contactInfo?: {
    primaryContact: string;
    email: string;
    phone: string;
    address: string;
  };
}

class UpdateBankBrandingDto {
  logoUrl?: string;
  faviconUrl?: string;
  primaryColor?: string;
  secondaryColor?: string;
  themeConfig?: {
    colors?: {
      accent?: string;
      success?: string;
      warning?: string;
      error?: string;
      background?: string;
      surface?: string;
      onPrimary?: string;
      onSecondary?: string;
    };
    typography?: {
      fontFamily?: string;
      headingFont?: string;
      bodyFont?: string;
    };
    layout?: {
      borderRadius?: string;
      spacing?: string;
      shadows?: boolean;
    };
    branding?: {
      showLogo?: boolean;
      logoPosition?: 'left' | 'center' | 'right';
      tagline?: string;
    };
  };
  customDomain?: string;
  customCss?: {
    variables?: Record<string, string>;
    rules?: string[];
  };
  emailTemplates?: {
    welcome?: string;
    kyc_approval?: string;
    investment_confirmation?: string;
    payout_notification?: string;
  };
}

@ApiTags('Bank Admin - Operations')
@Controller('bank')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
@Roles(UserRole.bank_admin, UserRole.bank_operations)
export class BankingController {
  constructor(private readonly bankingService: BankingService) {}

  // ===================
  // BANK PROFILE MANAGEMENT
  // ===================

  @Get('profile')
  @ApiOperation({ summary: 'Get bank profile' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank profile data' })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, description: 'User not associated with a bank' })
  async getBankProfile(@Request() req: any) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    return await this.bankingService.getBankById(req.user.bankId);
  }

  @Patch('profile')
  @ApiOperation({ summary: 'Update bank profile' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank profile updated successfully' })
  async updateBankProfile(
    @Body() updateDto: UpdateBankProfileDto,
    @Request() req: any,
  ) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    return await this.bankingService.updateBank(req.user.bankId, updateDto);
  }

  @Patch('branding')
  @ApiOperation({ summary: 'Update bank branding' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank branding updated successfully' })
  async updateBankBranding(
    @Body() brandingDto: UpdateBankBrandingDto,
    @Request() req: any,
  ) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    // This would need to be implemented in the service
    return {
      message: 'Bank branding update functionality coming soon',
      bankId: req.user.bankId,
      branding: brandingDto,
    };
  }

  // ===================
  // ASSET PROPOSAL MANAGEMENT
  // ===================

  @Get('asset-proposals')
  @ApiOperation({ summary: 'Get bank asset proposals' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'under_review', 'approved', 'rejected'] })
  @ApiResponse({ status: HttpStatus.OK, description: 'List of bank asset proposals' })
  async getBankProposals(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
    @Request() req: any,
  ) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    return await this.bankingService.getAllProposals({
      page: page ? parseInt(page.toString()) : undefined,
      limit: limit ? parseInt(limit.toString()) : undefined,
      status: status as any,
      bankId: req.user.bankId,
    });
  }

  @Post('asset-proposals')
  @ApiOperation({ summary: 'Submit new asset proposal' })
  @ApiResponse({ status: HttpStatus.CREATED, description: 'Asset proposal submitted successfully' })
  async submitAssetProposal(
    @Body() proposalDto: SubmitAssetProposalDto,
    @Request() req: any,
  ) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    const proposal = await this.bankingService.createProposal({
      proposerType: 'bank',
      proposerId: req.user.id,
      bankId: req.user.bankId,
      assetDetails: proposalDto.assetDetails,
      documents: proposalDto.documents || [],
    });

    return {
      message: 'Asset proposal submitted successfully',
      proposal,
      status: 'pending_master_admin_review',
    };
  }

  @Get('asset-proposals/:proposalId')
  @ApiOperation({ summary: 'Get asset proposal details' })
  @ApiResponse({ status: HttpStatus.OK, description: 'Proposal details' })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, description: 'Proposal not found' })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, description: 'Access denied to this proposal' })
  async getProposalById(
    @Param('proposalId', ParseUUIDPipe) proposalId: string,
    @Request() req: any,
  ) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    const proposal = await this.bankingService.getProposalById(proposalId);

    // Ensure proposal belongs to user's bank
    if (proposal.bankId !== req.user.bankId) {
      throw new ForbiddenException('Access denied to this proposal');
    }

    return proposal;
  }

  // ===================
  // ANALYTICS & REPORTING
  // ===================

  @Get('analytics/dashboard')
  @ApiOperation({ summary: 'Get bank dashboard analytics' })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: HttpStatus.OK, description: 'Bank dashboard analytics' })
  async getBankDashboard(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Request() req: any,
  ) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    const period = {
      startDate: startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
      endDate: endDate ? new Date(endDate) : new Date(),
    };

    return await this.bankingService.getBankAnalytics(req.user.bankId, period);
  }

  @Get('settlements')
  @ApiOperation({ summary: 'Get bank settlements' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'processed', 'paid', 'failed'] })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: HttpStatus.OK, description: 'List of bank settlements' })
  async getBankSettlements(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Request() req: any,
  ) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    return await this.bankingService.getAllSettlements({
      page: page ? parseInt(page.toString()) : undefined,
      limit: limit ? parseInt(limit.toString()) : undefined,
      status: status as any,
      bankId: req.user.bankId,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
    });
  }

  // ===================
  // CUSTOMER MANAGEMENT (Placeholder)
  // ===================

  @Get('customers')
  @ApiOperation({ summary: 'Get bank customers' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, type: String })
  @ApiResponse({ status: HttpStatus.OK, description: 'List of bank customers' })
  async getBankCustomers(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
    @Request() req: any,
  ) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    // Placeholder - would implement customer filtering by bankId
    return {
      message: 'Customer management functionality coming soon',
      bankId: req.user.bankId,
      filters: { page, limit, status },
    };
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Get bank transactions' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'type', required: false, type: String })
  @ApiResponse({ status: HttpStatus.OK, description: 'List of bank transactions' })
  async getBankTransactions(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('type') type?: string,
    @Request() req: any,
  ) {
    if (!req.user.bankId) {
      throw new ForbiddenException('User not associated with a bank');
    }

    // Placeholder - would implement transaction filtering by bankId
    return {
      message: 'Transaction management functionality coming soon',
      bankId: req.user.bankId,
      filters: { page, limit, type },
    };
  }
}