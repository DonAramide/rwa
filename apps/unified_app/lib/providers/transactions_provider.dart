import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

/// Provider for managing user transactions
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  return TransactionsNotifier();
});

/// Provider for recent transactions (last 10)
final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  return transactionsState.transactions.take(10).toList();
});

/// Provider for transaction analytics
final transactionAnalyticsProvider = Provider<TransactionAnalytics>((ref) {
  final transactions = ref.watch(transactionsProvider).transactions;
  return TransactionAnalytics.fromTransactions(transactions);
});

class TransactionsNotifier extends StateNotifier<TransactionsState> {
  static const String _storageKey = 'user_transactions';

  TransactionsNotifier() : super(const TransactionsState()) {
    _loadTransactions();
  }

  /// Load transactions from local storage
  Future<void> _loadTransactions() async {
    try {
      state = state.copyWith(isLoading: true);

      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getStringList(_storageKey) ?? [];

      final List<Transaction> transactions = [];
      for (final jsonString in transactionsJson) {
        try {
          final transactionData = jsonDecode(jsonString) as Map<String, dynamic>;
          final transaction = Transaction.fromJson(transactionData);
          transactions.add(transaction);
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }

      // Sort by date (newest first)
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load transactions: $e',
      );
    }
  }

  /// Save transactions to local storage
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = state.transactions
          .map((transaction) => jsonEncode(transaction.toJson()))
          .toList();

      await prefs.setStringList(_storageKey, transactionsJson);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save transactions: $e');
    }
  }

  /// Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final updatedTransactions = [transaction, ...state.transactions];

      // Keep only the most recent 100 transactions to avoid storage bloat
      final limitedTransactions = updatedTransactions.take(100).toList();

      state = state.copyWith(
        transactions: limitedTransactions,
        error: null,
      );

      await _saveTransactions();
    } catch (e) {
      state = state.copyWith(error: 'Failed to add transaction: $e');
    }
  }

  /// Refresh transactions (reload from storage and simulate new data)
  Future<void> refreshTransactions() async {
    await _loadTransactions();

    // Simulate some new transactions for demo purposes
    await _simulateNewTransactions();
  }

  /// Simulate new transactions for demo
  Future<void> _simulateNewTransactions() async {
    final now = DateTime.now();
    final demoTransactions = [
      Transaction(
        id: 'tx_${now.millisecondsSinceEpoch}',
        type: TransactionType.dividendReceived,
        assetId: 'asset_1',
        assetTitle: 'Premium Office Complex Downtown',
        amount: 127.50,
        currency: 'USD',
        timestamp: now.subtract(Duration(minutes: 5)),
        status: TransactionStatus.completed,
        description: 'Monthly dividend payment',
      ),
      Transaction(
        id: 'tx_${now.millisecondsSinceEpoch + 1}',
        type: TransactionType.purchase,
        assetId: 'asset_2',
        assetTitle: 'Luxury Residential Apartments',
        amount: 2500.00,
        currency: 'USD',
        timestamp: now.subtract(Duration(hours: 2)),
        status: TransactionStatus.completed,
        description: 'Purchased 25 shares',
        metadata: {
          'shares': 25,
          'price_per_share': 100.0,
        },
      ),
    ];

    for (final transaction in demoTransactions) {
      // Only add if not already exists
      final exists = state.transactions.any((t) => t.id == transaction.id);
      if (!exists) {
        await addTransaction(transaction);
      }
    }
  }

  /// Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return state.transactions.where((t) => t.type == type).toList();
  }

  /// Get transactions by asset
  List<Transaction> getTransactionsByAsset(String assetId) {
    return state.transactions.where((t) => t.assetId == assetId).toList();
  }

  /// Get transactions in date range
  List<Transaction> getTransactionsInRange(DateTime start, DateTime end) {
    return state.transactions.where((t) =>
      t.timestamp.isAfter(start) && t.timestamp.isBefore(end)
    ).toList();
  }

  /// Clear all transactions
  Future<void> clearTransactions() async {
    try {
      state = state.copyWith(transactions: []);
      await _saveTransactions();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear transactions: $e');
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Transactions state class
class TransactionsState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;

  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionsState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Transaction analytics data class
class TransactionAnalytics {
  final double totalInvested;
  final double totalDividends;
  final double totalSales;
  final int transactionCount;
  final Map<TransactionType, int> typeBreakdown;
  final Map<String, double> monthlySpending;

  const TransactionAnalytics({
    required this.totalInvested,
    required this.totalDividends,
    required this.totalSales,
    required this.transactionCount,
    required this.typeBreakdown,
    required this.monthlySpending,
  });

  factory TransactionAnalytics.fromTransactions(List<Transaction> transactions) {
    double totalInvested = 0;
    double totalDividends = 0;
    double totalSales = 0;
    Map<TransactionType, int> typeBreakdown = {};
    Map<String, double> monthlySpending = {};

    for (final transaction in transactions) {
      // Count by type
      typeBreakdown[transaction.type] = (typeBreakdown[transaction.type] ?? 0) + 1;

      // Calculate totals
      switch (transaction.type) {
        case TransactionType.purchase:
          totalInvested += transaction.amount;
          break;
        case TransactionType.dividendReceived:
          totalDividends += transaction.amount;
          break;
        case TransactionType.sale:
          totalSales += transaction.amount;
          break;
        case TransactionType.withdrawal:
        case TransactionType.deposit:
        case TransactionType.fee:
          // These don't affect investment totals
          break;
      }

      // Monthly spending breakdown
      final monthKey = '${transaction.timestamp.year}-${transaction.timestamp.month.toString().padLeft(2, '0')}';
      if (transaction.type == TransactionType.purchase) {
        monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0) + transaction.amount;
      }
    }

    return TransactionAnalytics(
      totalInvested: totalInvested,
      totalDividends: totalDividends,
      totalSales: totalSales,
      transactionCount: transactions.length,
      typeBreakdown: typeBreakdown,
      monthlySpending: monthlySpending,
    );
  }
}