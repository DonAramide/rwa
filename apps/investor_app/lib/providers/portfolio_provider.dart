import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

// Portfolio models
class Holding {
  final String assetId;
  final String assetTitle;
  final String assetType;
  final double balance;
  final double lockedBalance;
  final double value;
  final double returnPercent;
  final double monthlyIncome;
  final DateTime updatedAt;

  const Holding({
    required this.assetId,
    required this.assetTitle,
    required this.assetType,
    required this.balance,
    required this.lockedBalance,
    required this.value,
    required this.returnPercent,
    required this.monthlyIncome,
    required this.updatedAt,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      assetId: json['assetId'].toString(),
      assetTitle: json['assetTitle'] as String,
      assetType: json['assetType'] as String,
      balance: (json['balance'] as num).toDouble(),
      lockedBalance: (json['lockedBalance'] as num).toDouble(),
      value: (json['value'] as num).toDouble(),
      returnPercent: (json['returnPercent'] as num).toDouble(),
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class Distribution {
  final String id;
  final String assetId;
  final String assetTitle;
  final double amount;
  final DateTime date;
  final String status;
  final String period;
  final String? transactionHash;

  const Distribution({
    required this.id,
    required this.assetId,
    required this.assetTitle,
    required this.amount,
    required this.date,
    required this.status,
    required this.period,
    this.transactionHash,
  });

  factory Distribution.fromJson(Map<String, dynamic> json) {
    return Distribution(
      id: json['id'].toString(),
      assetId: json['assetId'].toString(),
      assetTitle: json['assetTitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      period: json['period'] as String,
      transactionHash: json['transactionHash'] as String?,
    );
  }
}

class PortfolioSummary {
  final double totalValue;
  final double totalReturn;
  final double monthlyIncome;
  final int totalHoldings;
  final double totalInvested;

  const PortfolioSummary({
    required this.totalValue,
    required this.totalReturn,
    required this.monthlyIncome,
    required this.totalHoldings,
    required this.totalInvested,
  });

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      totalValue: (json['totalValue'] as num).toDouble(),
      totalReturn: (json['totalReturn'] as num).toDouble(),
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      totalHoldings: json['totalHoldings'] as int,
      totalInvested: (json['totalInvested'] as num).toDouble(),
    );
  }
}

// Portfolio state
class PortfolioState {
  final bool isLoading;
  final PortfolioSummary? summary;
  final List<Holding> holdings;
  final List<Distribution> distributions;
  final String? error;
  final bool hasMoreDistributions;

  const PortfolioState({
    this.isLoading = false,
    this.summary,
    this.holdings = const [],
    this.distributions = const [],
    this.error,
    this.hasMoreDistributions = false,
  });

  PortfolioState copyWith({
    bool? isLoading,
    PortfolioSummary? summary,
    List<Holding>? holdings,
    List<Distribution>? distributions,
    String? error,
    bool? hasMoreDistributions,
  }) {
    return PortfolioState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      holdings: holdings ?? this.holdings,
      distributions: distributions ?? this.distributions,
      error: error ?? this.error,
      hasMoreDistributions: hasMoreDistributions ?? this.hasMoreDistributions,
    );
  }
}

// Portfolio notifier
class PortfolioNotifier extends StateNotifier<PortfolioState> {
  PortfolioNotifier() : super(const PortfolioState());

  Future<void> loadPortfolio({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        summary: null,
        holdings: [],
        distributions: [],
        error: null,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // Load holdings and summary in parallel
      final holdingsResponse = await ApiClient.getHoldings();
      final summaryData = holdingsResponse['summary'] as Map<String, dynamic>?;
      final holdingsData = holdingsResponse['holdings'] as List;

      final List<Holding> holdings = holdingsData
          .map((json) => Holding.fromJson(json as Map<String, dynamic>))
          .toList();

      PortfolioSummary? summary;
      if (summaryData != null) {
        summary = PortfolioSummary.fromJson(summaryData);
      }

      // Load recent distributions
      await _loadDistributions(refresh: true);

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        holdings: holdings,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadDistributions({bool refresh = false}) async {
    try {
      // Get distributions from all assets in portfolio
      final allDistributions = <Distribution>[];
      
      for (final holding in state.holdings) {
        try {
          final response = await ApiClient.getDistributions(holding.assetId);
          final distributionsData = response['items'] as List? ?? [];
          
          final distributions = distributionsData
              .take(5) // Get latest 5 per asset
              .map((json) => Distribution.fromJson(json as Map<String, dynamic>))
              .toList();
          
          allDistributions.addAll(distributions);
        } catch (e) {
          // Continue with other assets if one fails
          continue;
        }
      }

      // Sort by date (newest first) and take top 20
      allDistributions.sort((a, b) => b.date.compareTo(a.date));
      final recentDistributions = allDistributions.take(20).toList();

      state = state.copyWith(
        distributions: recentDistributions,
        hasMoreDistributions: allDistributions.length > 20,
      );
    } catch (e) {
      // Don't fail the entire portfolio load if distributions fail
      print('Failed to load distributions: $e');
    }
  }

  Future<void> refreshPortfolio() async {
    await loadPortfolio(refresh: true);
  }

  Future<void> loadMoreDistributions() async {
    if (state.hasMoreDistributions) {
      await _loadDistributions(refresh: false);
    }
  }
}

// Providers
final portfolioProvider = StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  return PortfolioNotifier();
});

// Computed providers
final portfolioSummaryProvider = Provider<PortfolioSummary?>((ref) {
  return ref.watch(portfolioProvider).summary;
});

final holdingsProvider = Provider<List<Holding>>((ref) {
  return ref.watch(portfolioProvider).holdings;
});

final distributionsProvider = Provider<List<Distribution>>((ref) {
  return ref.watch(portfolioProvider).distributions;
});

final totalPortfolioValueProvider = Provider<double>((ref) {
  final summary = ref.watch(portfolioSummaryProvider);
  return summary?.totalValue ?? 0.0;
});

final totalMonthlyIncomeProvider = Provider<double>((ref) {
  final summary = ref.watch(portfolioSummaryProvider);
  return summary?.monthlyIncome ?? 0.0;
});

