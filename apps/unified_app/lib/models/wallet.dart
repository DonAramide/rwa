class Wallet {
  final String address;
  final WalletType type;
  final String name;
  final bool isConnected;
  final double? balance;
  final String? networkId;

  const Wallet({
    required this.address,
    required this.type,
    required this.name,
    required this.isConnected,
    this.balance,
    this.networkId,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      address: json['address'],
      type: WalletType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      name: json['name'],
      isConnected: json['isConnected'],
      balance: json['balance']?.toDouble(),
      networkId: json['networkId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'type': type.toString().split('.').last,
      'name': name,
      'isConnected': isConnected,
      'balance': balance,
      'networkId': networkId,
    };
  }

  Wallet copyWith({
    String? address,
    WalletType? type,
    String? name,
    bool? isConnected,
    double? balance,
    String? networkId,
  }) {
    return Wallet(
      address: address ?? this.address,
      type: type ?? this.type,
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      balance: balance ?? this.balance,
      networkId: networkId ?? this.networkId,
    );
  }

  String get shortAddress {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}

enum WalletType {
  metamask,
  walletConnect,
  coinbaseWallet,
  trustWallet,
  browser,
}

extension WalletTypeExtension on WalletType {
  String get displayName {
    switch (this) {
      case WalletType.metamask:
        return 'MetaMask';
      case WalletType.walletConnect:
        return 'WalletConnect';
      case WalletType.coinbaseWallet:
        return 'Coinbase Wallet';
      case WalletType.trustWallet:
        return 'Trust Wallet';
      case WalletType.browser:
        return 'Browser Wallet';
    }
  }

  String get iconPath {
    switch (this) {
      case WalletType.metamask:
        return 'assets/images/metamask-icon.png';
      case WalletType.walletConnect:
        return 'assets/images/walletconnect-icon.png';
      case WalletType.coinbaseWallet:
        return 'assets/images/coinbase-icon.png';
      case WalletType.trustWallet:
        return 'assets/images/trust-icon.png';
      case WalletType.browser:
        return 'assets/images/browser-icon.png';
    }
  }
}

class CryptoCurrency {
  final String symbol;
  final String name;
  final String contractAddress;
  final int decimals;
  final String? iconUrl;
  final double? priceUsd;

  const CryptoCurrency({
    required this.symbol,
    required this.name,
    required this.contractAddress,
    required this.decimals,
    this.iconUrl,
    this.priceUsd,
  });

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    return CryptoCurrency(
      symbol: json['symbol'],
      name: json['name'],
      contractAddress: json['contractAddress'],
      decimals: json['decimals'],
      iconUrl: json['iconUrl'],
      priceUsd: json['priceUsd']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'contractAddress': contractAddress,
      'decimals': decimals,
      'iconUrl': iconUrl,
      'priceUsd': priceUsd,
    };
  }

  static const eth = CryptoCurrency(
    symbol: 'ETH',
    name: 'Ethereum',
    contractAddress: '0x0000000000000000000000000000000000000000',
    decimals: 18,
  );

  static const usdc = CryptoCurrency(
    symbol: 'USDC',
    name: 'USD Coin',
    contractAddress: '0xA0b86a33E6e3e9b4BF1234567890123456789012',
    decimals: 6,
  );

  static const usdt = CryptoCurrency(
    symbol: 'USDT',
    name: 'Tether USD',
    contractAddress: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
    decimals: 6,
  );
}

class Transaction {
  final String id;
  final String from;
  final String to;
  final BigInt amount;
  final CryptoCurrency currency;
  final TransactionStatus status;
  final String? hash;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? error;
  final int? blockNumber;
  final BigInt? gasUsed;
  final BigInt? gasPrice;

  const Transaction({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
    required this.status,
    this.hash,
    required this.createdAt,
    this.confirmedAt,
    this.error,
    this.blockNumber,
    this.gasUsed,
    this.gasPrice,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      from: json['from'],
      to: json['to'],
      amount: BigInt.parse(json['amount']),
      currency: CryptoCurrency.fromJson(json['currency']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      hash: json['hash'],
      createdAt: DateTime.parse(json['createdAt']),
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      error: json['error'],
      blockNumber: json['blockNumber'],
      gasUsed: json['gasUsed'] != null ? BigInt.parse(json['gasUsed']) : null,
      gasPrice: json['gasPrice'] != null ? BigInt.parse(json['gasPrice']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'amount': amount.toString(),
      'currency': currency.toJson(),
      'status': status.toString().split('.').last,
      'hash': hash,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'error': error,
      'blockNumber': blockNumber,
      'gasUsed': gasUsed?.toString(),
      'gasPrice': gasPrice?.toString(),
    };
  }

  double get amountInUnits {
    return amount.toDouble() / BigInt.from(10).pow(currency.decimals).toDouble();
  }

  String get formattedAmount {
    return '${amountInUnits.toStringAsFixed(currency.decimals == 18 ? 6 : currency.decimals)} ${currency.symbol}';
  }
}

enum TransactionStatus {
  pending,
  confirming,
  confirmed,
  failed,
  cancelled,
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.confirming:
        return 'Confirming';
      case TransactionStatus.confirmed:
        return 'Confirmed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get color {
    switch (this) {
      case TransactionStatus.pending:
        return 'warning';
      case TransactionStatus.confirming:
        return 'info';
      case TransactionStatus.confirmed:
        return 'success';
      case TransactionStatus.failed:
        return 'error';
      case TransactionStatus.cancelled:
        return 'secondary';
    }
  }
}