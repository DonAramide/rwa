import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';

class WalletState {
  final Wallet? connectedWallet;
  final List<CryptoCurrency> supportedCurrencies;
  final List<Transaction> transactions;
  final bool isConnecting;
  final String? error;
  final Map<String, double> balances;

  const WalletState({
    this.connectedWallet,
    this.supportedCurrencies = const [],
    this.transactions = const [],
    this.isConnecting = false,
    this.error,
    this.balances = const {},
  });

  WalletState copyWith({
    Wallet? connectedWallet,
    List<CryptoCurrency>? supportedCurrencies,
    List<Transaction>? transactions,
    bool? isConnecting,
    String? error,
    Map<String, double>? balances,
  }) {
    return WalletState(
      connectedWallet: connectedWallet,
      supportedCurrencies: supportedCurrencies ?? this.supportedCurrencies,
      transactions: transactions ?? this.transactions,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error,
      balances: balances ?? this.balances,
    );
  }

  bool get isConnected => connectedWallet != null && connectedWallet!.isConnected;
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _walletService;

  WalletNotifier(this._walletService) : super(const WalletState()) {
    _initializeSupportedCurrencies();
    _loadPersistedWallet();
  }

  void _initializeSupportedCurrencies() {
    state = state.copyWith(
      supportedCurrencies: [
        CryptoCurrency.eth,
        CryptoCurrency.usdc,
        CryptoCurrency.usdt,
      ],
    );
  }

  Future<void> _loadPersistedWallet() async {
    try {
      final wallet = await _walletService.getPersistedWallet();
      if (wallet != null) {
        state = state.copyWith(connectedWallet: wallet);
        await _loadBalances();
        await _loadTransactions();
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load persisted wallet: $e');
    }
  }

  Future<void> connectWallet(WalletType walletType) async {
    state = state.copyWith(isConnecting: true, error: null);

    try {
      final wallet = await _walletService.connectWallet(walletType);
      state = state.copyWith(
        connectedWallet: wallet,
        isConnecting: false,
      );

      await _loadBalances();
      await _loadTransactions();
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: 'Failed to connect wallet: $e',
      );
    }
  }

  Future<void> disconnectWallet() async {
    try {
      await _walletService.disconnectWallet();
      state = state.copyWith(
        connectedWallet: null,
        balances: {},
        transactions: [],
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to disconnect wallet: $e');
    }
  }

  Future<void> _loadBalances() async {
    if (!state.isConnected) return;

    try {
      final balances = <String, double>{};
      for (final currency in state.supportedCurrencies) {
        final balance = await _walletService.getBalance(
          state.connectedWallet!.address,
          currency,
        );
        balances[currency.symbol] = balance;
      }
      state = state.copyWith(balances: balances);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load balances: $e');
    }
  }

  Future<void> _loadTransactions() async {
    if (!state.isConnected) return;

    try {
      final transactions = await _walletService.getTransactions(
        state.connectedWallet!.address,
      );
      state = state.copyWith(transactions: transactions);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load transactions: $e');
    }
  }

  Future<Transaction?> sendTransaction({
    required String toAddress,
    required BigInt amount,
    required CryptoCurrency currency,
  }) async {
    if (!state.isConnected) {
      state = state.copyWith(error: 'No wallet connected');
      return null;
    }

    try {
      final transaction = await _walletService.sendTransaction(
        fromAddress: state.connectedWallet!.address,
        toAddress: toAddress,
        amount: amount,
        currency: currency,
      );

      // Add transaction to local state
      final updatedTransactions = [transaction, ...state.transactions];
      state = state.copyWith(transactions: updatedTransactions);

      // Refresh balances after transaction
      await _loadBalances();

      return transaction;
    } catch (e) {
      state = state.copyWith(error: 'Failed to send transaction: $e');
      return null;
    }
  }

  Future<void> refreshBalances() async {
    await _loadBalances();
  }

  Future<void> refreshTransactions() async {
    await _loadTransactions();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  double getBalance(String currencySymbol) {
    return state.balances[currencySymbol] ?? 0.0;
  }

  List<Transaction> getTransactionsForCurrency(String currencySymbol) {
    return state.transactions
        .where((tx) => tx.currency.symbol == currencySymbol)
        .toList();
  }

  Future<BigInt> estimateGas({
    required String toAddress,
    required BigInt amount,
    required CryptoCurrency currency,
  }) async {
    if (!state.isConnected) {
      throw Exception('No wallet connected');
    }

    return await _walletService.estimateGas(
      fromAddress: state.connectedWallet!.address,
      toAddress: toAddress,
      amount: amount,
      currency: currency,
    );
  }

  Future<void> switchNetwork(String networkId) async {
    if (!state.isConnected) {
      state = state.copyWith(error: 'No wallet connected');
      return;
    }

    try {
      await _walletService.switchNetwork(networkId);
      final updatedWallet = state.connectedWallet!.copyWith(networkId: networkId);
      state = state.copyWith(connectedWallet: updatedWallet);
      await _loadBalances();
    } catch (e) {
      state = state.copyWith(error: 'Failed to switch network: $e');
    }
  }
}

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final walletService = ref.read(walletServiceProvider);
  return WalletNotifier(walletService);
});

// Convenient providers for common wallet data
final isWalletConnectedProvider = Provider<bool>((ref) {
  return ref.watch(walletProvider).isConnected;
});

final connectedWalletProvider = Provider<Wallet?>((ref) {
  return ref.watch(walletProvider).connectedWallet;
});

final walletBalancesProvider = Provider<Map<String, double>>((ref) {
  return ref.watch(walletProvider).balances;
});

final walletTransactionsProvider = Provider<List<Transaction>>((ref) {
  return ref.watch(walletProvider).transactions;
});