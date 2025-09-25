import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

// Portfolio Analytics Models
class PerformanceDataPoint {
  final DateTime date;
  final double value;
  final double returnPercentage;

  const PerformanceDataPoint({
    required this.date,
    required this.value,
    required this.returnPercentage,
  });

  factory PerformanceDataPoint.fromJson(Map<String, dynamic> json) {
    return PerformanceDataPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      returnPercentage: (json['return'] as num).toDouble(),
    );
  }
}

class PerformanceMetrics {
  final double totalReturn;
  final double volatility;
  final double sharpeRatio;
  final double maxDrawdown;
  final double currentValue;
  final String bestPerformer;
  final double bestPerformerReturn;
  final String worstPerformer;
  final double worstPerformerReturn;

  const PerformanceMetrics({
    required this.totalReturn,
    required this.volatility,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.currentValue,
    required this.bestPerformer,
    required this.bestPerformerReturn,
    required this.worstPerformer,
    required this.worstPerformerReturn,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      totalReturn: (json['totalReturn'] as num).toDouble(),
      volatility: (json['volatility'] as num).toDouble(),
      sharpeRatio: (json['sharpeRatio'] as num).toDouble(),
      maxDrawdown: (json['maxDrawdown'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      bestPerformer: json['bestPerformer']['assetTitle'] as String,
      bestPerformerReturn: (json['bestPerformer']['return'] as num).toDouble(),
      worstPerformer: json['worstPerformer']['assetTitle'] as String,
      worstPerformerReturn: (json['worstPerformer']['return'] as num).toDouble(),
    );
  }
}

class BenchmarkData {
  final String name;
  final List<PerformanceDataPoint> dataPoints;
  final double totalReturn;
  final double volatility;

  const BenchmarkData({
    required this.name,
    required this.dataPoints,
    required this.totalReturn,
    required this.volatility,
  });

  factory BenchmarkData.fromJson(Map<String, dynamic> json) {
    return BenchmarkData(
      name: json['name'] as String,
      dataPoints: (json['dataPoints'] as List)
          .map((point) => PerformanceDataPoint.fromJson(point))
          .toList(),
      totalReturn: (json['totalReturn'] as num).toDouble(),
      volatility: (json['volatility'] as num).toDouble(),
    );
  }
}

class PortfolioPerformanceData {
  final String period;
  final List<PerformanceDataPoint> dataPoints;
  final PerformanceMetrics metrics;
  final BenchmarkData? benchmark;
  final double monthlyIncome;
  final double dividendYield;

  const PortfolioPerformanceData({
    required this.period,
    required this.dataPoints,
    required this.metrics,
    this.benchmark,
    required this.monthlyIncome,
    required this.dividendYield,
  });

  factory PortfolioPerformanceData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final portfolio = data['portfolio'] as Map<String, dynamic>;

    return PortfolioPerformanceData(
      period: data['period'] as String,
      dataPoints: (portfolio['dataPoints'] as List)
          .map((point) => PerformanceDataPoint.fromJson(point))
          .toList(),
      metrics: PerformanceMetrics.fromJson(portfolio),
      benchmark: data['benchmark'] != null
          ? BenchmarkData.fromJson(data['benchmark'])
          : null,
      monthlyIncome: (data['metrics']['monthlyIncome'] as num).toDouble(),
      dividendYield: (data['metrics']['dividendYield'] as num).toDouble(),
    );
  }
}

class AssetAllocation {
  final String sector;
  final double percentage;
  final double value;
  final int assetCount;

  const AssetAllocation({
    required this.sector,
    required this.percentage,
    required this.value,
    required this.assetCount,
  });

  factory AssetAllocation.fromJson(String sector, Map<String, dynamic> json) {
    return AssetAllocation(
      sector: sector,
      percentage: (json['percentage'] as num).toDouble(),
      value: (json['value'] as num).toDouble(),
      assetCount: json['assets'] as int,
    );
  }
}

class DiversificationData {
  final List<AssetAllocation> assetAllocation;
  final Map<String, double> geographicAllocation;
  final double herfindahlIndex;
  final double diversificationScore;
  final List<String> recommendations;

  const DiversificationData({
    required this.assetAllocation,
    required this.geographicAllocation,
    required this.herfindahlIndex,
    required this.diversificationScore,
    required this.recommendations,
  });

  factory DiversificationData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final assetAllocation = data['assetAllocation'] as Map<String, dynamic>;

    return DiversificationData(
      assetAllocation: assetAllocation.entries
          .map((entry) => AssetAllocation.fromJson(entry.key, entry.value))
          .toList(),
      geographicAllocation: Map<String, double>.from(
        data['geographicAllocation'] as Map<String, dynamic>
      ),
      herfindahlIndex: (data['concentrationMetrics']['herfindahlIndex'] as num).toDouble(),
      diversificationScore: (data['diversificationScore'] as num).toDouble(),
      recommendations: (data['recommendations'] as List)
          .map((rec) => rec['suggestion'] as String)
          .toList(),
    );
  }
}

class BenchmarkComparison {
  final String benchmarkName;
  final double portfolioReturn;
  final double benchmarkReturn;
  final double outperformance;
  final double trackingError;
  final double informationRatio;

  const BenchmarkComparison({
    required this.benchmarkName,
    required this.portfolioReturn,
    required this.benchmarkReturn,
    required this.outperformance,
    required this.trackingError,
    required this.informationRatio,
  });

  factory BenchmarkComparison.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final comparison = data['comparison'] as Map<String, dynamic>;

    return BenchmarkComparison(
      benchmarkName: data['benchmark']['name'] as String,
      portfolioReturn: (comparison['portfolioReturn'] as num).toDouble(),
      benchmarkReturn: (comparison['benchmarkReturn'] as num).toDouble(),
      outperformance: (comparison['outperformance'] as num).toDouble(),
      trackingError: (comparison['trackingError'] as num).toDouble(),
      informationRatio: (comparison['informationRatio'] as num).toDouble(),
    );
  }
}

// Portfolio Analytics State
class PortfolioAnalyticsState {
  final bool isLoading;
  final PortfolioPerformanceData? performanceData;
  final DiversificationData? diversificationData;
  final BenchmarkComparison? benchmarkComparison;
  final String? error;
  final String selectedPeriod;
  final String selectedBenchmark;

  const PortfolioAnalyticsState({
    this.isLoading = false,
    this.performanceData,
    this.diversificationData,
    this.benchmarkComparison,
    this.error,
    this.selectedPeriod = '6M',
    this.selectedBenchmark = 'SP500',
  });

  PortfolioAnalyticsState copyWith({
    bool? isLoading,
    PortfolioPerformanceData? performanceData,
    DiversificationData? diversificationData,
    BenchmarkComparison? benchmarkComparison,
    String? error,
    String? selectedPeriod,
    String? selectedBenchmark,
  }) {
    return PortfolioAnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      performanceData: performanceData ?? this.performanceData,
      diversificationData: diversificationData ?? this.diversificationData,
      benchmarkComparison: benchmarkComparison ?? this.benchmarkComparison,
      error: error ?? this.error,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedBenchmark: selectedBenchmark ?? this.selectedBenchmark,
    );
  }
}

// Portfolio Analytics Notifier
class PortfolioAnalyticsNotifier extends StateNotifier<PortfolioAnalyticsState> {
  PortfolioAnalyticsNotifier() : super(const PortfolioAnalyticsState());

  Future<void> loadPerformanceData({String? period}) async {
    final targetPeriod = period ?? state.selectedPeriod;
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedPeriod: targetPeriod,
    );

    try {
      final response = await ApiClient.getPortfolioPerformance(
        period: targetPeriod,
        includeBenchmark: true,
      );

      final performanceData = PortfolioPerformanceData.fromJson(response);

      state = state.copyWith(
        isLoading: false,
        performanceData: performanceData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadDiversificationData() async {
    try {
      final response = await ApiClient.getPortfolioDiversification();
      final diversificationData = DiversificationData.fromJson(response);

      state = state.copyWith(
        diversificationData: diversificationData,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadBenchmarkComparison({String? benchmark}) async {
    final targetBenchmark = benchmark ?? state.selectedBenchmark;

    try {
      final response = await ApiClient.getBenchmarkComparison(
        benchmark: targetBenchmark,
        period: state.selectedPeriod,
      );

      final benchmarkComparison = BenchmarkComparison.fromJson(response);

      state = state.copyWith(
        benchmarkComparison: benchmarkComparison,
        selectedBenchmark: targetBenchmark,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadAllAnalytics({String? period, String? benchmark}) async {
    await Future.wait([
      loadPerformanceData(period: period),
      loadDiversificationData(),
      loadBenchmarkComparison(benchmark: benchmark),
    ]);
  }

  void updatePeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
    loadPerformanceData(period: period);
  }

  void updateBenchmark(String benchmark) {
    state = state.copyWith(selectedBenchmark: benchmark);
    loadBenchmarkComparison(benchmark: benchmark);
  }
}

// Providers
final portfolioAnalyticsProvider = StateNotifierProvider<PortfolioAnalyticsNotifier, PortfolioAnalyticsState>((ref) {
  return PortfolioAnalyticsNotifier();
});

// Computed providers
final performanceChartDataProvider = Provider<List<double>>((ref) {
  final analytics = ref.watch(portfolioAnalyticsProvider);
  return analytics.performanceData?.dataPoints.map((point) => point.value).toList() ?? [];
});

final performanceChartLabelsProvider = Provider<List<String>>((ref) {
  final analytics = ref.watch(portfolioAnalyticsProvider);
  return analytics.performanceData?.dataPoints.map((point) {
    final month = point.date.month;
    final year = point.date.year.toString().substring(2);
    return '$month/$year';
  }).toList() ?? [];
});

final currentMetricsProvider = Provider<PerformanceMetrics?>((ref) {
  final analytics = ref.watch(portfolioAnalyticsProvider);
  return analytics.performanceData?.metrics;
});

final diversificationProvider = Provider<DiversificationData?>((ref) {
  final analytics = ref.watch(portfolioAnalyticsProvider);
  return analytics.diversificationData;
});

final benchmarkProvider = Provider<BenchmarkComparison?>((ref) {
  final analytics = ref.watch(portfolioAnalyticsProvider);
  return analytics.benchmarkComparison;
});