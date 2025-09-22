import { 
  Controller, 
  Get, 
  Post, 
  Patch, 
  Body, 
  Param, 
  Query, 
  UseGuards, 
  ParseIntPipe,
  BadRequestException
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery, ApiParam } from '@nestjs/swagger';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { JwtAuthGuard } from '../auth/jwt.guard';
import { RolesGuard, Roles } from '../auth/roles.guard';
import { UserRole } from '../users/user.entity';
import { AdminStatsDto, AdminActivityDto } from '../auth/dto';

// Import entities
import { UserEntity, UserStatus, KycStatus } from '../users/user.entity';
import { AssetEntity } from '../assets/asset.entity';
import { AgentEntity, AgentStatus } from '../agents/agent.entity';
import { DistributionEntity } from '../revenue/distribution.entity';

@ApiTags('Admin Dashboard')
@Controller('admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.admin)
export class AdminController {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(AssetEntity)
    private readonly assetRepository: Repository<AssetEntity>,
    @InjectRepository(AgentEntity)
    private readonly agentRepository: Repository<AgentEntity>,
    @InjectRepository(DistributionEntity)
    private readonly distributionRepository: Repository<DistributionEntity>,
  ) {}

  @Get('dashboard/stats')
  @ApiOperation({ summary: 'Get admin dashboard statistics' })
  @ApiResponse({ status: 200, type: AdminStatsDto })
  async getDashboardStats(): Promise<AdminStatsDto> {
    const [
      totalUsers,
      activeUsers,
      pendingKyc,
      totalAssets,
      activeAssets,
      pendingAssets,
      totalAgents,
      approvedAgents,
      pendingAgents,
      distributions
    ] = await Promise.all([
      this.userRepository.count(),
      this.userRepository.count({ where: { status: UserStatus.active } }),
      this.userRepository.count({ where: { kycStatus: KycStatus.pending } }),
      this.assetRepository.count(),
      this.assetRepository.count({ where: { status: 'active' } }),
      this.assetRepository.count({ where: { status: 'pending' } }),
      this.agentRepository.count(),
      this.agentRepository.count({ where: { status: AgentStatus.approved } }),
      this.agentRepository.count({ where: { status: AgentStatus.pending } }),
      this.distributionRepository.find({ order: { createdAt: 'DESC' }, take: 100 })
    ]);

    // Calculate portfolio value
    const assets = await this.assetRepository.find();
    const totalPortfolioValue = assets.reduce((sum, asset) => {
      const nav = parseFloat(asset.nav || '0');
      return sum + nav;
    }, 0);

    // Calculate monthly payouts
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const monthlyPayouts = distributions
      .filter(d => d.createdAt >= startOfMonth)
      .reduce((sum, d) => sum + parseFloat(d.net || '0'), 0);

    return {
      totalUsers,
      activeUsers,
      pendingKyc,
      totalAssets,
      activeAssets,
      pendingAssets,
      totalAgents,
      approvedAgents,
      pendingAgents,
      totalPortfolioValue,
      monthlyPayouts
    };
  }

  @Get('dashboard/activity')
  @ApiOperation({ summary: 'Get recent admin activity' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10 })
  @ApiResponse({ status: 200, type: [AdminActivityDto] })
  async getRecentActivity(
    @Query('limit') limit: number = 10
  ): Promise<AdminActivityDto[]> {
    // For now, return mock data. In production, you'd have an audit log table
    const activities: AdminActivityDto[] = [
      {
        id: '1',
        type: 'asset_created',
        title: 'New Asset Added',
        description: 'Historic Brownstone - Brooklyn, NY',
        userId: 'user-1',
        userName: 'Admin User',
        createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
        metadata: { assetId: 8, assetType: 'house' }
      },
      {
        id: '2',
        type: 'verification_completed',
        title: 'Verification Completed',
        description: 'Luxury Villa - Malibu, CA',
        userId: 'user-2',
        userName: 'Agent Smith',
        createdAt: new Date(Date.now() - 4 * 60 * 60 * 1000), // 4 hours ago
        metadata: { assetId: 4, verified: true }
      },
      {
        id: '3',
        type: 'agent_approved',
        title: 'Agent Approved',
        description: 'David Brown - Residential Specialist',
        userId: 'user-1',
        userName: 'Admin User',
        createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
        metadata: { agentId: 3, status: 'approved' }
      },
      {
        id: '4',
        type: 'payout_processed',
        title: 'Payout Processed',
        description: '$12,450 to 5 investors',
        userId: 'user-1',
        userName: 'System',
        createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
        metadata: { amount: 12450, investors: 5 }
      }
    ];

    return activities.slice(0, Math.min(limit, 50));
  }

  @Get('users')
  @ApiOperation({ summary: 'Get users list with filtering' })
  @ApiQuery({ name: 'kyc_status', required: false, enum: KycStatus })
  @ApiQuery({ name: 'status', required: false, enum: UserStatus })
  @ApiQuery({ name: 'role', required: false, enum: UserRole })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'offset', required: false, type: Number, example: 0 })
  async getUsers(
    @Query('kyc_status') kycStatus?: KycStatus,
    @Query('status') status?: UserStatus,
    @Query('role') role?: UserRole,
    @Query('limit') limit: number = 20,
    @Query('offset') offset: number = 0
  ) {
    const where: any = {};
    if (kycStatus) where.kycStatus = kycStatus;
    if (status) where.status = status;
    if (role) where.role = role;

    const [users, total] = await this.userRepository.findAndCount({
      where,
      take: Math.min(limit, 100),
      skip: offset,
      order: { createdAt: 'DESC' },
      select: [
        'id', 'email', 'firstName', 'lastName', 'role', 
        'status', 'kycStatus', 'residency', 'lastLoginAt', 'createdAt'
      ]
    });

    return {
      items: users,
      total,
      limit,
      offset,
      hasMore: offset + limit < total
    };
  }

  @Patch('users/:id/kyc')
  @ApiOperation({ summary: 'Update user KYC status' })
  @ApiParam({ name: 'id', type: 'string' })
  async updateUserKyc(
    @Param('id') userId: string,
    @Body() body: { status: KycStatus; notes?: string }
  ) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new BadRequestException('User not found');
    }

    user.kycStatus = body.status;
    if (body.notes) {
      user.kycNotes = body.notes;
    }

    await this.userRepository.save(user);
    return { success: true, user: { id: user.id, kycStatus: user.kycStatus } };
  }

  @Post('distributions/trigger')
  @ApiOperation({ summary: 'Trigger revenue distribution' })
  async triggerDistribution(
    @Body() body: { asset_id: number; amount: number; period: string }
  ) {
    // This would typically integrate with your revenue service
    // For now, return a mock response
    return {
      success: true,
      distribution: {
        id: Math.floor(Math.random() * 1000),
        assetId: body.asset_id,
        amount: body.amount,
        period: body.period,
        status: 'processing',
        createdAt: new Date()
      }
    };
  }

  @Get('assets/:id/verify')
  @ApiOperation({ summary: 'Get asset verification details' })
  @ApiParam({ name: 'id', type: 'number' })
  async getAssetVerification(@Param('id', ParseIntPipe) assetId: number) {
    const asset = await this.assetRepository.findOne({ where: { id: assetId } });
    if (!asset) {
      throw new BadRequestException('Asset not found');
    }

    // Return asset with verification details
    return {
      asset,
      verificationRequired: asset.verification_required,
      // In a real implementation, you'd fetch verification reports here
      reports: [],
      canApprove: asset.status === 'pending'
    };
  }

  @Post('assets/:id/verify')
  @ApiOperation({ summary: 'Approve or reject asset' })
  @ApiParam({ name: 'id', type: 'number' })
  async verifyAsset(
    @Param('id', ParseIntPipe) assetId: number,
    @Body() body: { approved: boolean; notes?: string }
  ) {
    const asset = await this.assetRepository.findOne({ where: { id: assetId } });
    if (!asset) {
      throw new BadRequestException('Asset not found');
    }

    asset.status = body.approved ? 'active' : 'rejected';
    await this.assetRepository.save(asset);

    return {
      success: true,
      asset: {
        id: asset.id,
        status: asset.status,
        approved: body.approved
      }
    };
  }
}