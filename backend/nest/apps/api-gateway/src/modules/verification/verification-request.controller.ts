import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
  UseGuards,
  Request,
  ParseIntPipe
} from '@nestjs/common';
import {
  VerificationRequestService,
  CreateVerificationRequestDto,
  CreateProposalDto,
  CreateReportDto,
  VerificationRequestFilters
} from './verification-request.service';
import {
  VerificationRequestEntity,
  VerificationRequestType,
  VerificationRequestStatus,
  VerificationRequestUrgency
} from './verification-request.entity';
import {
  VerificationProposalEntity,
  VerificationReportEntity
} from './verification-request.entity';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { RolesGuard, Roles } from '../auth/roles.guard';

@ApiTags('verification-requests')
@Controller('verification-requests')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class VerificationRequestController {
  constructor(private readonly verificationRequestService: VerificationRequestService) {}

  @Post()
  @ApiOperation({ summary: 'Create a verification request' })
  @ApiResponse({ status: 201, description: 'Verification request created successfully' })
  @Roles('investor', 'investor_agent')
  @UseGuards(RolesGuard)
  async createRequest(
    @Request() req: any,
    @Body() createDto: CreateVerificationRequestDto
  ): Promise<VerificationRequestEntity> {
    return await this.verificationRequestService.createRequest(req.user.id, createDto);
  }

  @Post(':id/proposals')
  @ApiOperation({ summary: 'Submit a proposal for a verification request' })
  @ApiResponse({ status: 201, description: 'Proposal submitted successfully' })
  @Roles('verifier')
  @UseGuards(RolesGuard)
  async createProposal(
    @Request() req: any,
    @Param('id', ParseIntPipe) requestId: number,
    @Body() createDto: Omit<CreateProposalDto, 'request_id'>
  ): Promise<VerificationProposalEntity> {
    const proposalDto: CreateProposalDto = {
      ...createDto,
      request_id: requestId
    };
    return await this.verificationRequestService.createProposal(req.user.id, proposalDto);
  }

  @Post('proposals/:proposalId/accept')
  @ApiOperation({ summary: 'Accept a proposal for verification request' })
  @ApiResponse({ status: 200, description: 'Proposal accepted successfully' })
  @Roles('investor', 'investor_agent')
  @UseGuards(RolesGuard)
  async acceptProposal(
    @Request() req: any,
    @Param('proposalId', ParseIntPipe) proposalId: number
  ): Promise<VerificationRequestEntity> {
    return await this.verificationRequestService.acceptProposal(req.user.id, proposalId);
  }

  @Post(':id/start')
  @ApiOperation({ summary: 'Start working on assigned verification' })
  @ApiResponse({ status: 200, description: 'Verification started successfully' })
  @Roles('verifier')
  @UseGuards(RolesGuard)
  async startVerification(
    @Request() req: any,
    @Param('id', ParseIntPipe) requestId: number
  ): Promise<VerificationRequestEntity> {
    return await this.verificationRequestService.startVerification(req.user.id, requestId);
  }

  @Post(':id/reports')
  @ApiOperation({ summary: 'Submit verification report' })
  @ApiResponse({ status: 201, description: 'Report submitted successfully' })
  @Roles('verifier')
  @UseGuards(RolesGuard)
  async submitReport(
    @Request() req: any,
    @Param('id', ParseIntPipe) requestId: number,
    @Body() createDto: Omit<CreateReportDto, 'request_id'>
  ): Promise<VerificationReportEntity> {
    const reportDto: CreateReportDto = {
      ...createDto,
      request_id: requestId
    };
    return await this.verificationRequestService.submitReport(req.user.id, reportDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get verification requests with filters' })
  @ApiResponse({ status: 200, description: 'Verification requests retrieved successfully' })
  async getRequests(
    @Query('type') type?: VerificationRequestType,
    @Query('status') status?: VerificationRequestStatus,
    @Query('urgency') urgency?: VerificationRequestUrgency,
    @Query('asset_id') asset_id?: number,
    @Query('budget_min') budget_min?: number,
    @Query('budget_max') budget_max?: number,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number
  ): Promise<{ requests: VerificationRequestEntity[], total: number }> {
    const filters: VerificationRequestFilters = {
      type,
      status,
      urgency,
      asset_id,
      budget_min,
      budget_max,
      limit: limit || 50,
      offset: offset || 0
    };
    return await this.verificationRequestService.getRequests(filters);
  }

  @Get('my-requests')
  @ApiOperation({ summary: 'Get current user\'s verification requests' })
  @ApiResponse({ status: 200, description: 'User verification requests retrieved successfully' })
  @Roles('investor', 'investor_agent')
  @UseGuards(RolesGuard)
  async getMyRequests(
    @Request() req: any,
    @Query('status') status?: VerificationRequestStatus,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number
  ): Promise<{ requests: VerificationRequestEntity[], total: number }> {
    const filters: VerificationRequestFilters = {
      requester_id: req.user.id,
      status,
      limit: limit || 50,
      offset: offset || 0
    };
    return await this.verificationRequestService.getRequests(filters);
  }

  @Get('my-assignments')
  @ApiOperation({ summary: 'Get verifier\'s assigned requests' })
  @ApiResponse({ status: 200, description: 'Assigned verification requests retrieved successfully' })
  @Roles('verifier')
  @UseGuards(RolesGuard)
  async getMyAssignments(
    @Request() req: any,
    @Query('status') status?: VerificationRequestStatus,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number
  ): Promise<{ requests: VerificationRequestEntity[], total: number }> {
    const filters: VerificationRequestFilters = {
      assigned_verifier_id: req.user.id,
      status,
      limit: limit || 50,
      offset: offset || 0
    };
    return await this.verificationRequestService.getRequests(filters);
  }

  @Get('available')
  @ApiOperation({ summary: 'Get available verification requests for verifiers' })
  @ApiResponse({ status: 200, description: 'Available verification requests retrieved successfully' })
  @Roles('verifier')
  @UseGuards(RolesGuard)
  async getAvailableRequests(
    @Request() req: any,
    @Query('type') type?: VerificationRequestType,
    @Query('urgency') urgency?: VerificationRequestUrgency,
    @Query('budget_min') budget_min?: number,
    @Query('budget_max') budget_max?: number,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number
  ): Promise<{ requests: VerificationRequestEntity[], total: number }> {
    const filters: VerificationRequestFilters = {
      type,
      urgency,
      budget_min,
      budget_max,
      limit: limit || 50,
      offset: offset || 0
    };
    return await this.verificationRequestService.getAvailableRequests(req.user.id, filters);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get verification request by ID' })
  @ApiResponse({ status: 200, description: 'Verification request retrieved successfully' })
  async getRequestById(@Param('id', ParseIntPipe) id: number): Promise<VerificationRequestEntity> {
    return await this.verificationRequestService.getRequestById(id);
  }

  @Get(':id/proposals')
  @ApiOperation({ summary: 'Get proposals for a verification request' })
  @ApiResponse({ status: 200, description: 'Proposals retrieved successfully' })
  async getProposals(@Param('id', ParseIntPipe) requestId: number): Promise<VerificationProposalEntity[]> {
    return await this.verificationRequestService.getProposalsForRequest(requestId);
  }

  @Get(':id/report')
  @ApiOperation({ summary: 'Get verification report for a request' })
  @ApiResponse({ status: 200, description: 'Report retrieved successfully' })
  async getReport(@Param('id', ParseIntPipe) requestId: number): Promise<VerificationReportEntity | null> {
    return await this.verificationRequestService.getReportForRequest(requestId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Cancel verification request' })
  @ApiResponse({ status: 200, description: 'Verification request cancelled successfully' })
  @Roles('investor', 'investor_agent')
  @UseGuards(RolesGuard)
  async cancelRequest(
    @Request() req: any,
    @Param('id', ParseIntPipe) requestId: number
  ): Promise<VerificationRequestEntity> {
    return await this.verificationRequestService.cancelRequest(req.user.id, requestId);
  }

  @Get('analytics/dashboard')
  @ApiOperation({ summary: 'Get verification analytics dashboard data' })
  @ApiResponse({ status: 200, description: 'Analytics data retrieved successfully' })
  @Roles('admin')
  @UseGuards(RolesGuard)
  async getDashboardAnalytics(): Promise<any> {
    // This would implement analytics for admin dashboard
    // For now, return placeholder data
    return {
      total_requests: 0,
      pending_requests: 0,
      in_progress_requests: 0,
      completed_requests: 0,
      average_completion_time: 0,
      average_cost: 0,
      top_verifiers: []
    };
  }
}