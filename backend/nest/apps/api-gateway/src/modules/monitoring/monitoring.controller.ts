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
import { MonitoringService, CreateFlagDto, UpdateFlagDto, FlagFilters } from './monitoring.service';
import { FlagEntity, FlagType, FlagStatus, FlagSeverity } from './flag.entity';
import { VoteType } from './flag-vote.entity';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { RolesGuard, Roles } from '../auth/roles.guard';
import { UserRole } from '../users/user.entity';
// import { InvestorAgentService } from '../users/investor-agent.service';

@ApiTags('monitoring')
@Controller('monitoring')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class MonitoringController {
  constructor(
    private readonly monitoringService: MonitoringService,
    // private readonly investorAgentService: InvestorAgentService
  ) {}

  @Post('flags')
  @ApiOperation({ summary: 'Create a new flag' })
  @ApiResponse({ status: 201, description: 'Flag created successfully' })
  @Roles(UserRole.investor, UserRole.investor_agent)
  @UseGuards(RolesGuard)
  async createFlag(
    @Request() req: any,
    @Body() createFlagDto: CreateFlagDto
  ): Promise<FlagEntity> {
    return await this.monitoringService.createFlag(req.user.id, createFlagDto);
  }

  @Post('flags/:id/vote')
  @ApiOperation({ summary: 'Vote on a flag' })
  @ApiResponse({ status: 200, description: 'Vote recorded successfully' })
  @Roles(UserRole.investor, UserRole.investor_agent)
  @UseGuards(RolesGuard)
  async voteOnFlag(
    @Request() req: any,
    @Param('id', ParseIntPipe) flagId: number,
    @Body('vote_type') voteType: VoteType
  ): Promise<FlagEntity> {
    return await this.monitoringService.voteOnFlag(flagId, req.user.id, voteType);
  }

  @Get('flags')
  @ApiOperation({ summary: 'Get flags with optional filters' })
  @ApiResponse({ status: 200, description: 'Flags retrieved successfully' })
  async getFlags(
    @Query('asset_id') asset_id?: number,
    @Query('status') status?: FlagStatus,
    @Query('type') type?: FlagType,
    @Query('severity') severity?: FlagSeverity,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number
  ): Promise<{ flags: FlagEntity[], total: number }> {
    const filters: FlagFilters = {
      asset_id,
      status,
      type,
      severity,
      limit: limit || 50,
      offset: offset || 0
    };
    return await this.monitoringService.getFlags(filters);
  }

  @Get('flags/my-flags')
  @ApiOperation({ summary: 'Get current user\'s flags' })
  @ApiResponse({ status: 200, description: 'User flags retrieved successfully' })
  @Roles(UserRole.investor, UserRole.investor_agent)
  @UseGuards(RolesGuard)
  async getMyFlags(
    @Request() req: any,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number
  ): Promise<{ flags: FlagEntity[], total: number }> {
    const filters: FlagFilters = {
      flagger_id: req.user.id,
      limit: limit || 50,
      offset: offset || 0
    };
    return await this.monitoringService.getFlags(filters);
  }

  @Get('flags/:id')
  @ApiOperation({ summary: 'Get flag by ID' })
  @ApiResponse({ status: 200, description: 'Flag retrieved successfully' })
  async getFlagById(@Param('id', ParseIntPipe) id: number): Promise<FlagEntity> {
    return await this.monitoringService.getFlagById(id);
  }

  @Put('flags/:id')
  @ApiOperation({ summary: 'Update flag (Admin only)' })
  @ApiResponse({ status: 200, description: 'Flag updated successfully' })
  @Roles(UserRole.admin)
  @UseGuards(RolesGuard)
  async updateFlag(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateFlagDto: UpdateFlagDto
  ): Promise<FlagEntity> {
    return await this.monitoringService.updateFlag(id, updateFlagDto);
  }

  @Delete('flags/:id')
  @ApiOperation({ summary: 'Delete flag (Admin only)' })
  @ApiResponse({ status: 200, description: 'Flag deleted successfully' })
  @Roles(UserRole.admin)
  @UseGuards(RolesGuard)
  async deleteFlag(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return await this.monitoringService.deleteFlag(id);
  }

  @Get('investor-agent/stats')
  @ApiOperation({ summary: 'Get investor-agent statistics' })
  @ApiResponse({ status: 200, description: 'Statistics retrieved successfully' })
  @Roles(UserRole.investor, UserRole.investor_agent)
  @UseGuards(RolesGuard)
  async getInvestorAgentStats(@Request() req: any): Promise<any> {
    return await this.monitoringService.getInvestorAgentStats(req.user.id);
  }

  @Get('flags/asset/:assetId')
  @ApiOperation({ summary: 'Get all flags for a specific asset' })
  @ApiResponse({ status: 200, description: 'Asset flags retrieved successfully' })
  async getAssetFlags(
    @Param('assetId', ParseIntPipe) assetId: number,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number
  ): Promise<{ flags: FlagEntity[], total: number }> {
    const filters: FlagFilters = {
      asset_id: assetId,
      limit: limit || 50,
      offset: offset || 0
    };
    return await this.monitoringService.getFlags(filters);
  }

  @Get('dashboard/pending-flags')
  @ApiOperation({ summary: 'Get pending flags for admin dashboard' })
  @ApiResponse({ status: 200, description: 'Pending flags retrieved successfully' })
  @Roles(UserRole.admin)
  @UseGuards(RolesGuard)
  async getPendingFlags(): Promise<{ flags: FlagEntity[], total: number }> {
    const filters: FlagFilters = {
      status: FlagStatus.PENDING,
      limit: 100
    };
    return await this.monitoringService.getFlags(filters);
  }

  @Get('dashboard/escalated-flags')
  @ApiOperation({ summary: 'Get escalated flags for admin dashboard' })
  @ApiResponse({ status: 200, description: 'Escalated flags retrieved successfully' })
  @Roles(UserRole.admin)
  @UseGuards(RolesGuard)
  async getEscalatedFlags(): Promise<{ flags: FlagEntity[], total: number }> {
    const filters: FlagFilters = {
      status: FlagStatus.ESCALATED,
      limit: 100
    };
    return await this.monitoringService.getFlags(filters);
  }

  @Get('leaderboard')
  @ApiOperation({ summary: 'Get investor-agent leaderboard' })
  @ApiResponse({ status: 200, description: 'Leaderboard retrieved successfully' })
  async getLeaderboard(
    @Query('limit') limit?: number
  ): Promise<any[]> {
    return []; // return await this.investorAgentService.getLeaderboard(limit || 10);
  }
}