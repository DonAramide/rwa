import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

// Investment models
class Investment {
  final String id;
  final String assetId;
  final String assetTitle;
  final double amount;
  final double? shares;
  final double? pricePerShare;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionHash;
  final String? verificationMethod;
  final String? agentId;

  const Investment({
    required this.id,
    required this.assetId,
    required this.assetTitle,
    required this.amount,
    this.shares,
    this.pricePerShare,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionHash,
    this.verificationMethod,
    this.agentId,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'].toString(),
      assetId: json['assetId'].toString(),
      assetTitle: json['assetTitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      shares: json['shares'] != null ? (json['shares'] as num).toDouble() : null,
      pricePerShare: json['pricePerShare'] != null ? (json['pricePerShare'] as num).toDouble() : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      transactionHash: json['transactionHash'] as String?,
      verificationMethod: json['verificationMethod'] as String?,
      agentId: json['agentId'] as String?,
    );
  }
}

// Investment history state
class InvestmentHistoryState {
  final bool isLoading;
  final List<Investment> investments;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const InvestmentHistoryState({
    this.isLoading = false,
    this.investments = const [],
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  InvestmentHistoryState copyWith({
    bool? isLoading,
    List<Investment>? investments,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return InvestmentHistoryState(
      isLoading: isLoading ?? this.isLoading,
      investments: investments ?? this.investments,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Investment history notifier
class InvestmentHistoryNotifier extends StateNotifier<InvestmentHistoryState> {
  InvestmentHistoryNotifier() : super(const InvestmentHistoryState());

  Future<void> loadInvestmentHistory({bool refresh = false}) async {
    if (refresh) {
      state = const InvestmentHistoryState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await ApiClient.getInvestmentHistory(
        limit: 20,
        offset: 0,
      );

      final investmentsData = response['items'] as List? ?? [];
      final List<Investment> investments = investmentsData
          .map((json) => Investment.fromJson(json as Map<String, dynamic>))
          .toList();

      final total = response['total'] as int? ?? 0;
      final hasMore = investments.length < total;

      state = state.copyWith(
        isLoading: false,
        investments: investments,
        hasMore: hasMore,
        currentPage: 0,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreHistory() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await ApiClient.getInvestmentHistory(
        limit: 20,
        offset: nextPage * 20,
      );

      final investmentsData = response['items'] as List? ?? [];
      final List<Investment> newInvestments = investmentsData
          .map((json) => Investment.fromJson(json as Map<String, dynamic>))
          .toList();

      final total = response['total'] as int? ?? 0;
      final allInvestments = [...state.investments, ...newInvestments];
      final hasMore = allInvestments.length < total;

      state = state.copyWith(
        isLoading: false,
        investments: allInvestments,
        hasMore: hasMore,
        currentPage: nextPage,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshHistory() async {
    await loadInvestmentHistory(refresh: true);
  }
}

// Providers
final investmentHistoryProvider = StateNotifierProvider<InvestmentHistoryNotifier, InvestmentHistoryState>((ref) {
  return InvestmentHistoryNotifier();
});

// Computed providers
final totalInvestmentAmountProvider = Provider<double>((ref) {
  final investments = ref.watch(investmentHistoryProvider).investments;
  return investments
      .where((investment) => investment.status == 'completed')
      .fold(0.0, (sum, investment) => sum + investment.amount);
});

final pendingInvestmentsProvider = Provider<List<Investment>>((ref) {
  final investments = ref.watch(investmentHistoryProvider).investments;
  return investments.where((investment) => investment.status == 'pending').toList();
});

final completedInvestmentsProvider = Provider<List<Investment>>((ref) {
  final investments = ref.watch(investmentHistoryProvider).investments;
  return investments.where((investment) => investment.status == 'completed').toList();
});