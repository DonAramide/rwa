import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/wallet.dart';

class WalletService {
  static const _storage = FlutterSecureStorage();
  static const _walletKey = 'connected_wallet';

  // Check if MetaMask is available
  bool get isMetaMaskAvailable {
    if (kIsWeb) {
      return js.context.hasProperty('ethereum') &&
             js.context['ethereum'] != null &&
             js.context['ethereum']['isMetaMask'] == true;
    }
    return false;
  }

  // Check if any Ethereum provider is available
  bool get isEthereumAvailable {
    if (kIsWeb) {
      return js.context.hasProperty('ethereum') && js.context['ethereum'] != null;
    }
    return false;
  }

  Future<Wallet?> getPersistedWallet() async {
    try {
      final walletJson = await _storage.read(key: _walletKey);
      if (walletJson != null) {
        final walletData = json.decode(walletJson);
        final wallet = Wallet.fromJson(walletData);

        // Verify the wallet is still connected
        if (kIsWeb && isEthereumAvailable) {
          final accounts = await _getAccounts();
          if (accounts.isNotEmpty && accounts.first.toLowerCase() == wallet.address.toLowerCase()) {
            return wallet.copyWith(isConnected: true);
          }
        }
      }
    } catch (e) {
      print('Error loading persisted wallet: $e');
    }
    return null;
  }

  Future<Wallet> connectWallet(WalletType walletType) async {
    switch (walletType) {
      case WalletType.metamask:
        return await _connectMetaMask();
      case WalletType.walletConnect:
        return await _connectWalletConnect();
      case WalletType.browser:
        return await _connectBrowserWallet();
      default:
        throw Exception('Wallet type ${walletType.displayName} not supported yet');
    }
  }

  Future<Wallet> _connectMetaMask() async {
    if (!kIsWeb) {
      throw Exception('MetaMask is only available on web');
    }

    if (!isMetaMaskAvailable) {
      throw Exception('MetaMask is not installed. Please install MetaMask to continue.');
    }

    try {
      // Request account access
      final accounts = await _requestAccounts();
      if (accounts.isEmpty) {
        throw Exception('No accounts found. Please unlock MetaMask and try again.');
      }

      final address = accounts.first;
      final networkId = await _getNetworkId();
      final balance = await _getEthBalance(address);

      final wallet = Wallet(
        address: address,
        type: WalletType.metamask,
        name: 'MetaMask',
        isConnected: true,
        balance: balance,
        networkId: networkId,
      );

      await _persistWallet(wallet);
      return wallet;
    } catch (e) {
      throw Exception('Failed to connect to MetaMask: $e');
    }
  }

  Future<Wallet> _connectWalletConnect() async {
    // For demo purposes, we'll simulate WalletConnect
    // In a real implementation, you'd use the WalletConnect SDK
    throw Exception('WalletConnect integration coming soon!');
  }

  Future<Wallet> _connectBrowserWallet() async {
    if (!kIsWeb) {
      throw Exception('Browser wallet is only available on web');
    }

    if (!isEthereumAvailable) {
      throw Exception('No Ethereum provider found. Please install a web3 wallet.');
    }

    try {
      final accounts = await _requestAccounts();
      if (accounts.isEmpty) {
        throw Exception('No accounts found. Please unlock your wallet and try again.');
      }

      final address = accounts.first;
      final networkId = await _getNetworkId();
      final balance = await _getEthBalance(address);

      final wallet = Wallet(
        address: address,
        type: WalletType.browser,
        name: 'Browser Wallet',
        isConnected: true,
        balance: balance,
        networkId: networkId,
      );

      await _persistWallet(wallet);
      return wallet;
    } catch (e) {
      throw Exception('Failed to connect to browser wallet: $e');
    }
  }

  Future<void> disconnectWallet() async {
    await _storage.delete(key: _walletKey);
  }

  Future<double> getBalance(String address, CryptoCurrency currency) async {
    if (!kIsWeb || !isEthereumAvailable) {
      throw Exception('Web3 not available');
    }

    try {
      if (currency.symbol == 'ETH') {
        return await _getEthBalance(address);
      } else {
        return await _getTokenBalance(address, currency);
      }
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  Future<List<Transaction>> getTransactions(String address) async {
    // For demo purposes, return mock transactions
    // In a real implementation, you'd fetch from blockchain or API
    return _generateMockTransactions(address);
  }

  Future<Transaction> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required CryptoCurrency currency,
  }) async {
    if (!kIsWeb || !isEthereumAvailable) {
      throw Exception('Web3 not available');
    }

    try {
      String txHash;
      if (currency.symbol == 'ETH') {
        txHash = await _sendEthTransaction(fromAddress, toAddress, amount);
      } else {
        txHash = await _sendTokenTransaction(fromAddress, toAddress, amount, currency);
      }

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        from: fromAddress,
        to: toAddress,
        amount: amount,
        currency: currency,
        status: TransactionStatus.pending,
        hash: txHash,
        createdAt: DateTime.now(),
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to send transaction: $e');
    }
  }

  Future<BigInt> estimateGas({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required CryptoCurrency currency,
  }) async {
    if (!kIsWeb || !isEthereumAvailable) {
      throw Exception('Web3 not available');
    }

    try {
      if (currency.symbol == 'ETH') {
        return await _estimateEthGas(fromAddress, toAddress, amount);
      } else {
        return await _estimateTokenGas(fromAddress, toAddress, amount, currency);
      }
    } catch (e) {
      throw Exception('Failed to estimate gas: $e');
    }
  }

  Future<void> switchNetwork(String networkId) async {
    if (!kIsWeb || !isEthereumAvailable) {
      throw Exception('Web3 not available');
    }

    try {
      await _switchEthereumChain(networkId);
    } catch (e) {
      throw Exception('Failed to switch network: $e');
    }
  }

  // Private helper methods for Web3 interactions
  Future<List<String>> _requestAccounts() async {
    final result = await _callEthereumMethod('eth_requestAccounts', []);
    return List<String>.from(result);
  }

  Future<List<String>> _getAccounts() async {
    final result = await _callEthereumMethod('eth_accounts', []);
    return List<String>.from(result);
  }

  Future<String> _getNetworkId() async {
    final result = await _callEthereumMethod('net_version', []);
    return result.toString();
  }

  Future<double> _getEthBalance(String address) async {
    final result = await _callEthereumMethod('eth_getBalance', [address, 'latest']);
    final balanceHex = result.toString();
    final balanceWei = BigInt.parse(balanceHex.substring(2), radix: 16);
    return balanceWei.toDouble() / BigInt.from(10).pow(18).toDouble();
  }

  Future<double> _getTokenBalance(String address, CryptoCurrency currency) async {
    // For demo purposes, return a mock balance
    // In a real implementation, you'd call the token contract
    return 1000.0; // Mock balance
  }

  Future<String> _sendEthTransaction(String from, String to, BigInt amount) async {
    final amountHex = '0x${amount.toRadixString(16)}';
    final params = {
      'from': from,
      'to': to,
      'value': amountHex,
    };

    final result = await _callEthereumMethod('eth_sendTransaction', [params]);
    return result.toString();
  }

  Future<String> _sendTokenTransaction(String from, String to, BigInt amount, CryptoCurrency currency) async {
    // For demo purposes, simulate token transfer
    // In a real implementation, you'd encode the transfer function call
    throw Exception('Token transfers not implemented in demo');
  }

  Future<BigInt> _estimateEthGas(String from, String to, BigInt amount) async {
    final amountHex = '0x${amount.toRadixString(16)}';
    final params = {
      'from': from,
      'to': to,
      'value': amountHex,
    };

    final result = await _callEthereumMethod('eth_estimateGas', [params]);
    final gasHex = result.toString();
    return BigInt.parse(gasHex.substring(2), radix: 16);
  }

  Future<BigInt> _estimateTokenGas(String from, String to, BigInt amount, CryptoCurrency currency) async {
    // For demo purposes, return a mock gas estimate
    return BigInt.from(65000); // Mock gas estimate for token transfer
  }

  Future<void> _switchEthereumChain(String chainId) async {
    final params = [{'chainId': '0x${int.parse(chainId).toRadixString(16)}'}];
    await _callEthereumMethod('wallet_switchEthereumChain', params);
  }

  Future<dynamic> _callEthereumMethod(String method, List<dynamic> params) async {
    if (!kIsWeb || !isEthereumAvailable) {
      throw Exception('Ethereum provider not available');
    }

    final completer = Completer<dynamic>();

    try {
      js.context['ethereum'].callMethod('request', [
        js.JsObject.jsify({
          'method': method,
          'params': params,
        }),
      ]).then((result) {
        completer.complete(result);
      }).catchError((error) {
        completer.completeError(error);
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<void> _persistWallet(Wallet wallet) async {
    final walletJson = json.encode(wallet.toJson());
    await _storage.write(key: _walletKey, value: walletJson);
  }

  List<Transaction> _generateMockTransactions(String address) {
    return [
      Transaction(
        id: '1',
        from: address,
        to: '0x742637FC832A6bf4A91a5c91e3EDCB866F99A69c',
        amount: BigInt.from(500000000000000000), // 0.5 ETH
        currency: CryptoCurrency.eth,
        status: TransactionStatus.confirmed,
        hash: '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        confirmedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 58)),
        blockNumber: 18123456,
      ),
      Transaction(
        id: '2',
        from: '0x742637FC832A6bf4A91a5c91e3EDCB866F99A69c',
        to: address,
        amount: BigInt.from(1000000000), // 1000 USDC
        currency: CryptoCurrency.usdc,
        status: TransactionStatus.confirmed,
        hash: '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        confirmedAt: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(minutes: 2)),
        blockNumber: 18120123,
      ),
      Transaction(
        id: '3',
        from: address,
        to: '0x123456789abcdef123456789abcdef123456789ab',
        amount: BigInt.from(250000000000000000), // 0.25 ETH
        currency: CryptoCurrency.eth,
        status: TransactionStatus.pending,
        hash: '0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}