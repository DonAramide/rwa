import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { PartnerBankEntity } from '../banking/partner-bank.entity';
import { AssetProposalEntity } from '../banking/asset-proposal.entity';
import { BankSettlementEntity } from '../banking/bank-settlement.entity';
import { AssetEntity } from '../assets/asset.entity';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(PartnerBankEntity)
    private bankRepository: Repository<PartnerBankEntity>,

    @InjectRepository(AssetProposalEntity)
    private proposalRepository: Repository<AssetProposalEntity>,

    @InjectRepository(BankSettlementEntity)
    private settlementRepository: Repository<BankSettlementEntity>,

    @InjectRepository(AssetEntity)
    private assetRepository: Repository<AssetEntity>,
  ) {}

  async getDashboardStats(period: string = '30d') {
    // Mock data for now - replace with actual database queries
    return {
      totalRevenue: 1250000,
      totalUsers: 8450,
      totalAssets: 156,
      totalTransactions: 3420,
      revenueGrowth: 15.8,
      userGrowth: 23.4,
      assetGrowth: 12.1,
      transactionGrowth: 18.7,
      period,
    };
  }

  async getRevenueAnalytics(period: string = '12m', granularity: string = 'monthly') {
    // Mock time series data
    const data = [];
    const months = granularity === 'daily' ? 30 : 12;
    const baseAmount = 50000;
    
    for (let i = 0; i < months; i++) {
      const date = new Date();
      if (granularity === 'daily') {
        date.setDate(date.getDate() - (months - 1 - i));
      } else {
        date.setMonth(date.getMonth() - (months - 1 - i));
      }
      
      data.push({
        date: date.toISOString().split('T')[0],
        platformFees: baseAmount + Math.random() * 20000,
        managementFees: baseAmount * 0.7 + Math.random() * 15000,
        verificationFees: baseAmount * 0.3 + Math.random() * 10000,
        total: baseAmount * 2 + Math.random() * 45000,
      });
    }

    return {
      period,
      granularity,
      data,
      summary: {
        total: data.reduce((sum, item) => sum + item.total, 0),
        platformFees: data.reduce((sum, item) => sum + item.platformFees, 0),
        managementFees: data.reduce((sum, item) => sum + item.managementFees, 0),
        verificationFees: data.reduce((sum, item) => sum + item.verificationFees, 0),
      },
    };
  }

  async getUserGrowthMetrics(period: string = '12m', granularity: string = 'monthly') {
    const data = [];
    const months = granularity === 'daily' ? 30 : 12;
    let cumulativeInvestors = 1000;
    let cumulativeAgents = 50;
    
    for (let i = 0; i < months; i++) {
      const date = new Date();
      if (granularity === 'daily') {
        date.setDate(date.getDate() - (months - 1 - i));
      } else {
        date.setMonth(date.getMonth() - (months - 1 - i));
      }
      
      const newInvestors = Math.floor(Math.random() * 100) + 20;
      const newAgents = Math.floor(Math.random() * 10) + 2;
      
      cumulativeInvestors += newInvestors;
      cumulativeAgents += newAgents;
      
      data.push({
        date: date.toISOString().split('T')[0],
        newInvestors,
        newAgents,
        totalInvestors: cumulativeInvestors,
        totalAgents: cumulativeAgents,
        activeUsers: Math.floor(cumulativeInvestors * 0.7),
      });
    }

    return {
      period,
      granularity,
      data,
      summary: {
        totalInvestors: cumulativeInvestors,
        totalAgents: cumulativeAgents,
        totalActive: Math.floor(cumulativeInvestors * 0.7),
        growthRate: ((cumulativeInvestors - 1000) / 1000) * 100,
      },
    };
  }

  async getAssetPerformance(period: string = '12m', assetType?: string) {
    const assets = [
      { id: 1, title: 'Downtown Office Building', type: 'real_estate', nav: 2500000, performance: 8.5 },
      { id: 2, title: 'Fleet Truck #001', type: 'vehicle', nav: 85000, performance: 12.3 },
      { id: 3, title: 'Agricultural Land - Iowa', type: 'land', nav: 1200000, performance: 6.8 },
      { id: 4, title: 'Manufacturing Equipment', type: 'equipment', nav: 450000, performance: 15.2 },
      { id: 5, title: 'Luxury Condo - Miami', type: 'real_estate', nav: 850000, performance: 9.7 },
    ];

    const filteredAssets = assetType 
      ? assets.filter(asset => asset.type === assetType)
      : assets;

    // Generate performance data over time
    const performanceData = filteredAssets.map(asset => {
      const monthlyData = [];
      let currentValue = asset.nav;
      
      for (let i = 0; i < 12; i++) {
        const date = new Date();
        date.setMonth(date.getMonth() - (11 - i));
        
        // Simulate monthly performance changes
        const monthlyReturn = (asset.performance / 12) + (Math.random() - 0.5) * 2;
        currentValue *= (1 + monthlyReturn / 100);
        
        monthlyData.push({
          date: date.toISOString().split('T')[0],
          value: Math.round(currentValue),
          return: monthlyReturn,
        });
      }
      
      return {
        ...asset,
        performanceData: monthlyData,
        totalReturn: ((currentValue - asset.nav) / asset.nav) * 100,
      };
    });

    return {
      period,
      assetType,
      assets: performanceData,
      summary: {
        totalAssets: filteredAssets.length,
        avgPerformance: filteredAssets.reduce((sum, asset) => sum + asset.performance, 0) / filteredAssets.length,
        totalValue: filteredAssets.reduce((sum, asset) => sum + asset.nav, 0),
        bestPerformer: filteredAssets.reduce((best, asset) => 
          asset.performance > best.performance ? asset : best
        ),
      },
    };
  }

  async getTransactionVolume(period: string = '12m', granularity: string = 'monthly') {
    const data = [];
    const months = granularity === 'daily' ? 30 : 12;
    
    for (let i = 0; i < months; i++) {
      const date = new Date();
      if (granularity === 'daily') {
        date.setDate(date.getDate() - (months - 1 - i));
      } else {
        date.setMonth(date.getMonth() - (months - 1 - i));
      }
      
      data.push({
        date: date.toISOString().split('T')[0],
        investments: Math.floor(Math.random() * 50) + 20,
        trades: Math.floor(Math.random() * 30) + 10,
        distributions: Math.floor(Math.random() * 100) + 50,
        investmentVolume: Math.floor(Math.random() * 500000) + 200000,
        tradeVolume: Math.floor(Math.random() * 300000) + 100000,
        distributionVolume: Math.floor(Math.random() * 200000) + 50000,
      });
    }

    return {
      period,
      granularity,
      data,
      summary: {
        totalTransactions: data.reduce((sum, item) => sum + item.investments + item.trades + item.distributions, 0),
        totalVolume: data.reduce((sum, item) => sum + item.investmentVolume + item.tradeVolume + item.distributionVolume, 0),
        avgDailyVolume: data.reduce((sum, item) => sum + item.investmentVolume + item.tradeVolume + item.distributionVolume, 0) / data.length,
      },
    };
  }

  async getGeographicDistribution(metric: string = 'users') {
    const countries = [
      { country: 'United States', code: 'US', users: 3420, assets: 45, volume: 8500000, lat: 39.8283, lng: -98.5795 },
      { country: 'Canada', code: 'CA', users: 890, assets: 12, volume: 2100000, lat: 56.1304, lng: -106.3468 },
      { country: 'United Kingdom', code: 'GB', users: 1250, assets: 18, volume: 3200000, lat: 55.3781, lng: -3.4360 },
      { country: 'Germany', code: 'DE', users: 760, assets: 8, volume: 1800000, lat: 51.1657, lng: 10.4515 },
      { country: 'Australia', code: 'AU', users: 540, assets: 15, volume: 2500000, lat: -25.2744, lng: 133.7751 },
      { country: 'Singapore', code: 'SG', users: 320, assets: 6, volume: 1200000, lat: 1.3521, lng: 103.8198 },
      { country: 'Japan', code: 'JP', users: 680, assets: 9, volume: 1900000, lat: 36.2048, lng: 138.2529 },
      { country: 'Switzerland', code: 'CH', users: 280, assets: 4, volume: 950000, lat: 46.8182, lng: 8.2275 },
      { country: 'Netherlands', code: 'NL', users: 420, assets: 7, volume: 1400000, lat: 52.1326, lng: 5.2913 },
      { country: 'France', code: 'FR', users: 590, assets: 11, volume: 1600000, lat: 46.2276, lng: 2.2137 },
    ];

    return {
      metric,
      countries,
      summary: {
        totalCountries: countries.length,
        topCountry: countries[0],
        totalMetricValue: countries.reduce((sum, country) => {
          switch (metric) {
            case 'assets': return sum + country.assets;
            case 'volume': return sum + country.volume;
            default: return sum + country.users;
          }
        }, 0),
      },
    };
  }

  async getPortfolioAnalytics() {
    return {
      assetTypes: [
        { type: 'real_estate', count: 89, value: 125000000, percentage: 68.5 },
        { type: 'vehicle', count: 34, value: 12500000, percentage: 6.8 },
        { type: 'equipment', count: 21, value: 28500000, percentage: 15.6 },
        { type: 'land', count: 12, value: 16800000, percentage: 9.1 },
      ],
      riskProfile: {
        low: { count: 45, percentage: 28.8 },
        medium: { count: 87, percentage: 55.8 },
        high: { count: 24, percentage: 15.4 },
      },
      diversificationScore: 8.2,
      totalPortfolioValue: 182800000,
      avgAssetValue: 1172436,
    };
  }

  async getMarketMetrics(period: string = '30d') {
    return {
      period,
      marketCap: 182800000,
      tradingVolume24h: 2400000,
      priceChange24h: 2.34,
      activeListings: 156,
      completedSales: 89,
      avgTimeToSale: 14.5, // days
      liquidityRatio: 0.13,
      marketTrends: {
        real_estate: { trend: 'up', change: 3.2 },
        vehicle: { trend: 'up', change: 8.1 },
        equipment: { trend: 'down', change: -1.8 },
        land: { trend: 'up', change: 5.4 },
      },
    };
  }

  // ===================
  // BANKING PARTNERSHIP ANALYTICS
  // ===================

  /**
   * Get comprehensive banking partnership overview
   */
  async getBankingOverview(period: { startDate: Date; endDate: Date }) {
    const { startDate, endDate } = period;

    // Get bank statistics
    const bankStats = await this.bankRepository
      .createQueryBuilder('bank')
      .select('bank.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .groupBy('bank.status')
      .getRawMany();

    // Get proposal statistics
    const proposalStats = await this.proposalRepository
      .createQueryBuilder('proposal')
      .select('proposal.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .where('proposal.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .groupBy('proposal.status')
      .getRawMany();

    // Get settlement statistics
    const settlementStats = await this.settlementRepository
      .createQueryBuilder('settlement')
      .select('SUM(settlement.netPayout)', 'totalPayout')
      .addSelect('SUM(settlement.commissionEarned)', 'totalCommission')
      .addSelect('COUNT(*)', 'settlementCount')
      .where('settlement.periodStart BETWEEN :startDate AND :endDate', { startDate, endDate })
      .getRawOne();

    // Get top performing banks
    const topBanks = await this.proposalRepository
      .createQueryBuilder('proposal')
      .select('bank.name', 'bankName')
      .addSelect('bank.id', 'bankId')
      .addSelect('COUNT(*)', 'proposalCount')
      .addSelect('SUM(CASE WHEN proposal.status = :approved THEN 1 ELSE 0 END)', 'approvedCount')
      .leftJoin('proposal.bank', 'bank')
      .where('proposal.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate, approved: 'approved' })
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
      settlements: {
        totalPayout: parseFloat(settlementStats?.totalPayout || '0'),
        totalCommission: parseFloat(settlementStats?.totalCommission || '0'),
        count: parseInt(settlementStats?.settlementCount || '0'),
      },
      topBanks,
    };
  }

  /**
   * Get bank performance metrics comparison
   */
  async getBankPerformanceComparison(period: { startDate: Date; endDate: Date }) {
    const { startDate, endDate } = period;

    const bankPerformance = await this.bankRepository
      .createQueryBuilder('bank')
      .select([
        'bank.id as bankId',
        'bank.name as bankName',
        'bank.status as status',
        'bank.commissionRateBps as commissionRate',
        'COUNT(proposals.id) as totalProposals',
        'SUM(CASE WHEN proposals.status = :approved THEN 1 ELSE 0 END) as approvedProposals',
        'SUM(CASE WHEN proposals.status = :rejected THEN 1 ELSE 0 END) as rejectedProposals',
        'AVG(EXTRACT(EPOCH FROM (proposals.reviewedAt - proposals.createdAt))) as avgReviewTime',
        'COALESCE(SUM(settlements.netPayout), 0) as totalRevenue',
        'COALESCE(SUM(settlements.commissionEarned), 0) as totalCommissions'
      ])
      .leftJoin('bank.proposals', 'proposals',
        'proposals.createdAt BETWEEN :startDate AND :endDate',
        { startDate, endDate }
      )
      .leftJoin(BankSettlementEntity, 'settlements',
        'settlements.bankId = bank.id AND settlements.periodStart BETWEEN :startDate AND :endDate',
        { startDate, endDate }
      )
      .where('bank.status IN (:...statuses)', { statuses: ['active', 'suspended'] })
      .setParameter('approved', 'approved')
      .setParameter('rejected', 'rejected')
      .groupBy('bank.id, bank.name, bank.status, bank.commissionRateBps')
      .orderBy('totalRevenue', 'DESC')
      .getRawMany();

    return {
      period: { startDate, endDate },
      bankPerformance: bankPerformance.map(bank => ({
        ...bank,
        approvalRate: bank.totalProposals > 0
          ? (parseFloat(bank.approvedProposals) / parseFloat(bank.totalProposals)) * 100
          : 0,
        avgReviewTimeHours: bank.avgReviewTime ? parseFloat(bank.avgReviewTime) / 3600 : null,
        totalRevenue: parseFloat(bank.totalRevenue),
        totalCommissions: parseFloat(bank.totalCommissions),
      })),
    };
  }

  /**
   * Get asset proposal pipeline analytics
   */
  async getProposalPipelineAnalytics(period: { startDate: Date; endDate: Date }) {
    const { startDate, endDate } = period;

    // Get proposal flow by status over time
    const proposalFlow = await this.proposalRepository
      .createQueryBuilder('proposal')
      .select([
        'DATE_TRUNC(:granularity, proposal.createdAt) as date',
        'proposal.status as status',
        'COUNT(*) as count',
        'AVG(proposal.assetDetails->>\'financials\'->\'estimatedValue\') as avgValue'
      ])
      .where('proposal.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .setParameter('granularity', 'day')
      .groupBy('DATE_TRUNC(:granularity, proposal.createdAt), proposal.status')
      .orderBy('date', 'ASC')
      .getRawMany();

    // Get proposal by asset type
    const proposalsByType = await this.proposalRepository
      .createQueryBuilder('proposal')
      .select([
        'proposal.assetDetails->>\'type\' as assetType',
        'COUNT(*) as count',
        'AVG(proposal.assetDetails->>\'financials\'->\'estimatedValue\') as avgValue',
        'SUM(CASE WHEN proposal.status = :approved THEN 1 ELSE 0 END) as approvedCount'
      ])
      .where('proposal.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .setParameter('approved', 'approved')
      .groupBy('proposal.assetDetails->>\'type\'')
      .getRawMany();

    // Review time analytics
    const reviewTimeStats = await this.proposalRepository
      .createQueryBuilder('proposal')
      .select([
        'AVG(EXTRACT(EPOCH FROM (proposal.reviewedAt - proposal.createdAt))) as avgReviewTime',
        'MIN(EXTRACT(EPOCH FROM (proposal.reviewedAt - proposal.createdAt))) as minReviewTime',
        'MAX(EXTRACT(EPOCH FROM (proposal.reviewedAt - proposal.createdAt))) as maxReviewTime',
        'PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (proposal.reviewedAt - proposal.createdAt))) as medianReviewTime'
      ])
      .where('proposal.reviewedAt IS NOT NULL')
      .andWhere('proposal.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .getRawOne();

    return {
      period: { startDate, endDate },
      proposalFlow,
      proposalsByType: proposalsByType.map(type => ({
        ...type,
        avgValue: parseFloat(type.avgValue || '0'),
        approvalRate: type.count > 0 ? (parseFloat(type.approvedCount) / parseFloat(type.count)) * 100 : 0,
      })),
      reviewTimeStats: {
        avgReviewTimeHours: reviewTimeStats?.avgReviewTime ? parseFloat(reviewTimeStats.avgReviewTime) / 3600 : null,
        minReviewTimeHours: reviewTimeStats?.minReviewTime ? parseFloat(reviewTimeStats.minReviewTime) / 3600 : null,
        maxReviewTimeHours: reviewTimeStats?.maxReviewTime ? parseFloat(reviewTimeStats.maxReviewTime) / 3600 : null,
        medianReviewTimeHours: reviewTimeStats?.medianReviewTime ? parseFloat(reviewTimeStats.medianReviewTime) / 3600 : null,
      },
    };
  }

  /**
   * Get revenue sharing and commission analytics
   */
  async getRevenueAnalytics(period: { startDate: Date; endDate: Date }) {
    const { startDate, endDate } = period;

    // Get commission trends over time
    const commissionTrends = await this.settlementRepository
      .createQueryBuilder('settlement')
      .select([
        'DATE_TRUNC(:granularity, settlement.periodStart) as date',
        'SUM(settlement.totalVolume) as totalVolume',
        'SUM(settlement.commissionEarned) as totalCommission',
        'SUM(settlement.revenueShare) as totalRevenueShare',
        'SUM(settlement.netPayout) as totalPayout',
        'AVG(settlement.commissionEarned / NULLIF(settlement.totalVolume, 0) * 100) as avgCommissionRate'
      ])
      .where('settlement.periodStart BETWEEN :startDate AND :endDate', { startDate, endDate })
      .setParameter('granularity', 'month')
      .groupBy('DATE_TRUNC(:granularity, settlement.periodStart)')
      .orderBy('date', 'ASC')
      .getRawMany();

    // Get bank revenue distribution
    const bankRevenue = await this.settlementRepository
      .createQueryBuilder('settlement')
      .select([
        'bank.name as bankName',
        'bank.id as bankId',
        'SUM(settlement.totalVolume) as totalVolume',
        'SUM(settlement.commissionEarned) as totalCommission',
        'SUM(settlement.netPayout) as totalPayout',
        'COUNT(settlement.id) as settlementCount'
      ])
      .leftJoin('settlement.bank', 'bank')
      .where('settlement.periodStart BETWEEN :startDate AND :endDate', { startDate, endDate })
      .groupBy('bank.id, bank.name')
      .orderBy('totalCommission', 'DESC')
      .getRawMany();

    return {
      period: { startDate, endDate },
      commissionTrends: commissionTrends.map(trend => ({
        ...trend,
        totalVolume: parseFloat(trend.totalVolume || '0'),
        totalCommission: parseFloat(trend.totalCommission || '0'),
        totalRevenueShare: parseFloat(trend.totalRevenueShare || '0'),
        totalPayout: parseFloat(trend.totalPayout || '0'),
        avgCommissionRate: parseFloat(trend.avgCommissionRate || '0'),
      })),
      bankRevenue: bankRevenue.map(bank => ({
        ...bank,
        totalVolume: parseFloat(bank.totalVolume || '0'),
        totalCommission: parseFloat(bank.totalCommission || '0'),
        totalPayout: parseFloat(bank.totalPayout || '0'),
        settlementCount: parseInt(bank.settlementCount),
      })),
      summary: {
        totalCommissions: bankRevenue.reduce((sum, bank) => sum + parseFloat(bank.totalCommission || '0'), 0),
        totalPayouts: bankRevenue.reduce((sum, bank) => sum + parseFloat(bank.totalPayout || '0'), 0),
        totalVolume: bankRevenue.reduce((sum, bank) => sum + parseFloat(bank.totalVolume || '0'), 0),
      },
    };
  }
}