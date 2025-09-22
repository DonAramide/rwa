class AnalyticsModel {
  final double totalRevenue;
  final int totalUsers;
  final int totalAssets;
  final int totalTransactions;
  final double revenueGrowth;
  final double userGrowth;
  final double assetGrowth;
  final double transactionGrowth;
  final String period;

  AnalyticsModel({
    required this.totalRevenue,
    required this.totalUsers,
    required this.totalAssets,
    required this.totalTransactions,
    required this.revenueGrowth,
    required this.userGrowth,
    required this.assetGrowth,
    required this.transactionGrowth,
    required this.period,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalUsers: json['totalUsers'] ?? 0,
      totalAssets: json['totalAssets'] ?? 0,
      totalTransactions: json['totalTransactions'] ?? 0,
      revenueGrowth: (json['revenueGrowth'] ?? 0).toDouble(),
      userGrowth: (json['userGrowth'] ?? 0).toDouble(),
      assetGrowth: (json['assetGrowth'] ?? 0).toDouble(),
      transactionGrowth: (json['transactionGrowth'] ?? 0).toDouble(),
      period: json['period'] ?? '30d',
    );
  }
}

class RevenueAnalytics {
  final String period;
  final String granularity;
  final List<RevenueDataPoint> data;
  final RevenueSummary summary;

  RevenueAnalytics({
    required this.period,
    required this.granularity,
    required this.data,
    required this.summary,
  });

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      period: json['period'] ?? '12m',
      granularity: json['granularity'] ?? 'monthly',
      data: (json['data'] as List)
          .map((item) => RevenueDataPoint.fromJson(item))
          .toList(),
      summary: RevenueSummary.fromJson(json['summary']),
    );
  }
}

class RevenueDataPoint {
  final String date;
  final double platformFees;
  final double managementFees;
  final double verificationFees;
  final double total;

  RevenueDataPoint({
    required this.date,
    required this.platformFees,
    required this.managementFees,
    required this.verificationFees,
    required this.total,
  });

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      date: json['date'],
      platformFees: (json['platformFees'] ?? 0).toDouble(),
      managementFees: (json['managementFees'] ?? 0).toDouble(),
      verificationFees: (json['verificationFees'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

class RevenueSummary {
  final double total;
  final double platformFees;
  final double managementFees;
  final double verificationFees;

  RevenueSummary({
    required this.total,
    required this.platformFees,
    required this.managementFees,
    required this.verificationFees,
  });

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    return RevenueSummary(
      total: (json['total'] ?? 0).toDouble(),
      platformFees: (json['platformFees'] ?? 0).toDouble(),
      managementFees: (json['managementFees'] ?? 0).toDouble(),
      verificationFees: (json['verificationFees'] ?? 0).toDouble(),
    );
  }
}

class UserGrowthMetrics {
  final String period;
  final String granularity;
  final List<UserGrowthDataPoint> data;
  final UserGrowthSummary summary;

  UserGrowthMetrics({
    required this.period,
    required this.granularity,
    required this.data,
    required this.summary,
  });

  factory UserGrowthMetrics.fromJson(Map<String, dynamic> json) {
    return UserGrowthMetrics(
      period: json['period'] ?? '12m',
      granularity: json['granularity'] ?? 'monthly',
      data: (json['data'] as List)
          .map((item) => UserGrowthDataPoint.fromJson(item))
          .toList(),
      summary: UserGrowthSummary.fromJson(json['summary']),
    );
  }
}

class UserGrowthDataPoint {
  final String date;
  final int newInvestors;
  final int newAgents;
  final int totalInvestors;
  final int totalAgents;
  final int activeUsers;

  UserGrowthDataPoint({
    required this.date,
    required this.newInvestors,
    required this.newAgents,
    required this.totalInvestors,
    required this.totalAgents,
    required this.activeUsers,
  });

  factory UserGrowthDataPoint.fromJson(Map<String, dynamic> json) {
    return UserGrowthDataPoint(
      date: json['date'],
      newInvestors: json['newInvestors'] ?? 0,
      newAgents: json['newAgents'] ?? 0,
      totalInvestors: json['totalInvestors'] ?? 0,
      totalAgents: json['totalAgents'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
    );
  }
}

class UserGrowthSummary {
  final int totalInvestors;
  final int totalAgents;
  final int totalActive;
  final double growthRate;

  UserGrowthSummary({
    required this.totalInvestors,
    required this.totalAgents,
    required this.totalActive,
    required this.growthRate,
  });

  factory UserGrowthSummary.fromJson(Map<String, dynamic> json) {
    return UserGrowthSummary(
      totalInvestors: json['totalInvestors'] ?? 0,
      totalAgents: json['totalAgents'] ?? 0,
      totalActive: json['totalActive'] ?? 0,
      growthRate: (json['growthRate'] ?? 0).toDouble(),
    );
  }
}

class GeographicDistribution {
  final String metric;
  final List<CountryData> countries;
  final GeographicSummary summary;

  GeographicDistribution({
    required this.metric,
    required this.countries,
    required this.summary,
  });

  factory GeographicDistribution.fromJson(Map<String, dynamic> json) {
    return GeographicDistribution(
      metric: json['metric'] ?? 'users',
      countries: (json['countries'] as List)
          .map((item) => CountryData.fromJson(item))
          .toList(),
      summary: GeographicSummary.fromJson(json['summary']),
    );
  }
}

class CountryData {
  final String country;
  final String code;
  final int users;
  final int assets;
  final double volume;
  final double lat;
  final double lng;

  CountryData({
    required this.country,
    required this.code,
    required this.users,
    required this.assets,
    required this.volume,
    required this.lat,
    required this.lng,
  });

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      country: json['country'],
      code: json['code'],
      users: json['users'] ?? 0,
      assets: json['assets'] ?? 0,
      volume: (json['volume'] ?? 0).toDouble(),
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

class GeographicSummary {
  final int totalCountries;
  final CountryData topCountry;
  final double totalMetricValue;

  GeographicSummary({
    required this.totalCountries,
    required this.topCountry,
    required this.totalMetricValue,
  });

  factory GeographicSummary.fromJson(Map<String, dynamic> json) {
    return GeographicSummary(
      totalCountries: json['totalCountries'] ?? 0,
      topCountry: CountryData.fromJson(json['topCountry']),
      totalMetricValue: (json['totalMetricValue'] ?? 0).toDouble(),
    );
  }
}

// Banking Analytics Models
class BankingOverview {
  final BankingPeriod period;
  final BankStats banks;
  final ProposalStats proposals;
  final SettlementStats settlements;
  final List<TopBank> topBanks;

  BankingOverview({
    required this.period,
    required this.banks,
    required this.proposals,
    required this.settlements,
    required this.topBanks,
  });

  factory BankingOverview.fromJson(Map<String, dynamic> json) {
    return BankingOverview(
      period: BankingPeriod.fromJson(json['period']),
      banks: BankStats.fromJson(json['banks']),
      proposals: ProposalStats.fromJson(json['proposals']),
      settlements: SettlementStats.fromJson(json['settlements']),
      topBanks: (json['topBanks'] as List)
          .map((item) => TopBank.fromJson(item))
          .toList(),
    );
  }
}

class BankingPeriod {
  final String startDate;
  final String endDate;

  BankingPeriod({required this.startDate, required this.endDate});

  factory BankingPeriod.fromJson(Map<String, dynamic> json) {
    return BankingPeriod(
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }
}

class BankStats {
  final int total;
  final List<StatusCount> byStatus;

  BankStats({required this.total, required this.byStatus});

  factory BankStats.fromJson(Map<String, dynamic> json) {
    return BankStats(
      total: json['total'] ?? 0,
      byStatus: (json['byStatus'] as List)
          .map((item) => StatusCount.fromJson(item))
          .toList(),
    );
  }
}

class ProposalStats {
  final int total;
  final List<StatusCount> byStatus;

  ProposalStats({required this.total, required this.byStatus});

  factory ProposalStats.fromJson(Map<String, dynamic> json) {
    return ProposalStats(
      total: json['total'] ?? 0,
      byStatus: (json['byStatus'] as List)
          .map((item) => StatusCount.fromJson(item))
          .toList(),
    );
  }
}

class SettlementStats {
  final double totalPayout;
  final double totalCommission;

  SettlementStats({required this.totalPayout, required this.totalCommission});

  factory SettlementStats.fromJson(Map<String, dynamic> json) {
    return SettlementStats(
      totalPayout: (json['totalPayout'] ?? 0).toDouble(),
      totalCommission: (json['totalCommission'] ?? 0).toDouble(),
    );
  }
}

class StatusCount {
  final String status;
  final int count;

  StatusCount({required this.status, required this.count});

  factory StatusCount.fromJson(Map<String, dynamic> json) {
    return StatusCount(
      status: json['status'],
      count: json['count'] ?? 0,
    );
  }
}

class TopBank {
  final String id;
  final String name;
  final double revenue;
  final int proposals;
  final int assets;

  TopBank({
    required this.id,
    required this.name,
    required this.revenue,
    required this.proposals,
    required this.assets,
  });

  factory TopBank.fromJson(Map<String, dynamic> json) {
    return TopBank(
      id: json['id'],
      name: json['name'],
      revenue: (json['revenue'] ?? 0).toDouble(),
      proposals: json['proposals'] ?? 0,
      assets: json['assets'] ?? 0,
    );
  }
}

class BankPerformanceComparison {
  final BankingPeriod period;
  final List<BankPerformance> banks;
  final BankPerformanceStats stats;

  BankPerformanceComparison({
    required this.period,
    required this.banks,
    required this.stats,
  });

  factory BankPerformanceComparison.fromJson(Map<String, dynamic> json) {
    return BankPerformanceComparison(
      period: BankingPeriod.fromJson(json['period']),
      banks: (json['banks'] as List)
          .map((item) => BankPerformance.fromJson(item))
          .toList(),
      stats: BankPerformanceStats.fromJson(json['stats']),
    );
  }
}

class BankPerformance {
  final String id;
  final String name;
  final double revenue;
  final int proposals;
  final int assetsCreated;
  final double commissionRate;
  final double avgProposalValue;

  BankPerformance({
    required this.id,
    required this.name,
    required this.revenue,
    required this.proposals,
    required this.assetsCreated,
    required this.commissionRate,
    required this.avgProposalValue,
  });

  factory BankPerformance.fromJson(Map<String, dynamic> json) {
    return BankPerformance(
      id: json['id'],
      name: json['name'],
      revenue: (json['revenue'] ?? 0).toDouble(),
      proposals: json['proposals'] ?? 0,
      assetsCreated: json['assetsCreated'] ?? 0,
      commissionRate: (json['commissionRate'] ?? 0).toDouble(),
      avgProposalValue: (json['avgProposalValue'] ?? 0).toDouble(),
    );
  }
}

class BankPerformanceStats {
  final double totalRevenue;
  final double avgCommissionRate;
  final BankPerformance topPerformer;

  BankPerformanceStats({
    required this.totalRevenue,
    required this.avgCommissionRate,
    required this.topPerformer,
  });

  factory BankPerformanceStats.fromJson(Map<String, dynamic> json) {
    return BankPerformanceStats(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      avgCommissionRate: (json['avgCommissionRate'] ?? 0).toDouble(),
      topPerformer: BankPerformance.fromJson(json['topPerformer']),
    );
  }
}

class ProposalPipelineAnalytics {
  final BankingPeriod period;
  final ProposalStats overview;
  final List<ProposalsByType> byType;
  final List<ProposalsByBank> byBank;
  final ProposalTimeline timeline;

  ProposalPipelineAnalytics({
    required this.period,
    required this.overview,
    required this.byType,
    required this.byBank,
    required this.timeline,
  });

  factory ProposalPipelineAnalytics.fromJson(Map<String, dynamic> json) {
    return ProposalPipelineAnalytics(
      period: BankingPeriod.fromJson(json['period']),
      overview: ProposalStats.fromJson(json['overview']),
      byType: (json['byType'] as List)
          .map((item) => ProposalsByType.fromJson(item))
          .toList(),
      byBank: (json['byBank'] as List)
          .map((item) => ProposalsByBank.fromJson(item))
          .toList(),
      timeline: ProposalTimeline.fromJson(json['timeline']),
    );
  }
}

class ProposalsByType {
  final String type;
  final int count;
  final double totalValue;

  ProposalsByType({
    required this.type,
    required this.count,
    required this.totalValue,
  });

  factory ProposalsByType.fromJson(Map<String, dynamic> json) {
    return ProposalsByType(
      type: json['type'],
      count: json['count'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
    );
  }
}

class ProposalsByBank {
  final String bankId;
  final String bankName;
  final int proposals;
  final double totalValue;
  final double approvalRate;

  ProposalsByBank({
    required this.bankId,
    required this.bankName,
    required this.proposals,
    required this.totalValue,
    required this.approvalRate,
  });

  factory ProposalsByBank.fromJson(Map<String, dynamic> json) {
    return ProposalsByBank(
      bankId: json['bankId'],
      bankName: json['bankName'],
      proposals: json['proposals'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      approvalRate: (json['approvalRate'] ?? 0).toDouble(),
    );
  }
}

class ProposalTimeline {
  final double avgApprovalTime;
  final List<TimelineDataPoint> data;

  ProposalTimeline({required this.avgApprovalTime, required this.data});

  factory ProposalTimeline.fromJson(Map<String, dynamic> json) {
    return ProposalTimeline(
      avgApprovalTime: (json['avgApprovalTime'] ?? 0).toDouble(),
      data: (json['data'] as List)
          .map((item) => TimelineDataPoint.fromJson(item))
          .toList(),
    );
  }
}

class TimelineDataPoint {
  final String date;
  final int submitted;
  final int approved;
  final int rejected;

  TimelineDataPoint({
    required this.date,
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory TimelineDataPoint.fromJson(Map<String, dynamic> json) {
    return TimelineDataPoint(
      date: json['date'],
      submitted: json['submitted'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}