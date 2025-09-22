import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/analytics_model.dart';
import 'auth_provider.dart';

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.read(apiClientProvider));
});

class AnalyticsState {
  final AnalyticsModel? dashboardStats;
  final RevenueAnalytics? revenueData;
  final UserGrowthMetrics? userGrowthData;
  final GeographicDistribution? geographicData;
  final Map<String, dynamic>? assetPerformance;
  final Map<String, dynamic>? transactionVolume;

  // Banking analytics data
  final BankingOverview? bankingOverview;
  final BankPerformanceComparison? bankPerformance;
  final ProposalPipelineAnalytics? proposalPipeline;
  final Map<String, dynamic>? bankingRevenue;

  final bool isLoading;
  final String? error;

  AnalyticsState({
    this.dashboardStats,
    this.revenueData,
    this.userGrowthData,
    this.geographicData,
    this.assetPerformance,
    this.transactionVolume,
    this.bankingOverview,
    this.bankPerformance,
    this.proposalPipeline,
    this.bankingRevenue,
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    AnalyticsModel? dashboardStats,
    RevenueAnalytics? revenueData,
    UserGrowthMetrics? userGrowthData,
    GeographicDistribution? geographicData,
    Map<String, dynamic>? assetPerformance,
    Map<String, dynamic>? transactionVolume,
    BankingOverview? bankingOverview,
    BankPerformanceComparison? bankPerformance,
    ProposalPipelineAnalytics? proposalPipeline,
    Map<String, dynamic>? bankingRevenue,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      dashboardStats: dashboardStats ?? this.dashboardStats,
      revenueData: revenueData ?? this.revenueData,
      userGrowthData: userGrowthData ?? this.userGrowthData,
      geographicData: geographicData ?? this.geographicData,
      assetPerformance: assetPerformance ?? this.assetPerformance,
      transactionVolume: transactionVolume ?? this.transactionVolume,
      bankingOverview: bankingOverview ?? this.bankingOverview,
      bankPerformance: bankPerformance ?? this.bankPerformance,
      proposalPipeline: proposalPipeline ?? this.proposalPipeline,
      bankingRevenue: bankingRevenue ?? this.bankingRevenue,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final ApiClient _apiClient;
  
  AnalyticsNotifier(this._apiClient) : super(AnalyticsState());

  Future<void> loadDashboardStats([String period = '30d']) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.getAnalyticsDashboard(period: period);
      state = state.copyWith(
        dashboardStats: AnalyticsModel.fromJson(response),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadRevenueAnalytics([String period = '12m', String granularity = 'monthly']) async {
    try {
      final response = await _apiClient.getRevenueAnalytics(
        period: period, 
        granularity: granularity,
      );
      state = state.copyWith(
        revenueData: RevenueAnalytics.fromJson(response),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadUserGrowthMetrics([String period = '12m', String granularity = 'monthly']) async {
    try {
      final response = await _apiClient.getUserGrowthMetrics(
        period: period,
        granularity: granularity,
      );
      state = state.copyWith(
        userGrowthData: UserGrowthMetrics.fromJson(response),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadAssetPerformance([String period = '12m', String? assetType]) async {
    try {
      final response = await _apiClient.getAssetPerformance(
        period: period,
        assetType: assetType,
      );
      state = state.copyWith(
        assetPerformance: response,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadTransactionVolume([String period = '12m', String granularity = 'monthly']) async {
    try {
      final response = await _apiClient.getTransactionVolume(
        period: period,
        granularity: granularity,
      );
      state = state.copyWith(
        transactionVolume: response,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadGeographicDistribution([String metric = 'users']) async {
    try {
      final response = await _apiClient.getGeographicDistribution(metric: metric);
      state = state.copyWith(
        geographicData: GeographicDistribution.fromJson(response),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadAllAnalytics() async {
    await Future.wait([
      loadDashboardStats(),
      loadRevenueAnalytics(),
      loadUserGrowthMetrics(),
      loadAssetPerformance(),
      loadTransactionVolume(),
      loadGeographicDistribution(),
    ]);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Banking analytics methods
  Future<void> loadBankingOverview([String? startDate, String? endDate]) async {
    try {
      final response = await _apiClient.getBankingOverview(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(
        bankingOverview: BankingOverview.fromJson(response),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadBankPerformanceComparison([String? startDate, String? endDate]) async {
    try {
      final response = await _apiClient.getBankPerformanceComparison(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(
        bankPerformance: BankPerformanceComparison.fromJson(response),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadProposalPipelineAnalytics([String? startDate, String? endDate]) async {
    try {
      final response = await _apiClient.getProposalPipelineAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(
        proposalPipeline: ProposalPipelineAnalytics.fromJson(response),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadBankingRevenueAnalytics([String? startDate, String? endDate]) async {
    try {
      final response = await _apiClient.getBankingRevenueAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(
        bankingRevenue: response,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadAllBankingAnalytics([String? startDate, String? endDate]) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.wait([
        loadBankingOverview(startDate, endDate),
        loadBankPerformanceComparison(startDate, endDate),
        loadProposalPipelineAnalytics(startDate, endDate),
        loadBankingRevenueAnalytics(startDate, endDate),
      ]);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}