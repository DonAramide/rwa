/// Transaction model for tracking user financial activities
class Transaction {
  final String id;
  final TransactionType type;
  final String assetId;
  final String assetTitle;
  final double amount;
  final String currency;
  final DateTime timestamp;
  final TransactionStatus status;
  final String description;
  final Map<String, dynamic>? metadata;

  const Transaction({
    required this.id,
    required this.type,
    required this.assetId,
    required this.assetTitle,
    required this.amount,
    required this.currency,
    required this.timestamp,
    required this.status,
    required this.description,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.purchase,
      ),
      assetId: json['assetId'] as String,
      assetTitle: json['assetTitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      description: json['description'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'assetId': assetId,
      'assetTitle': assetTitle,
      'amount': amount,
      'currency': currency,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'description': description,
      'metadata': metadata,
    };
  }

  Transaction copyWith({
    String? id,
    TransactionType? type,
    String? assetId,
    String? assetTitle,
    double? amount,
    String? currency,
    DateTime? timestamp,
    TransactionStatus? status,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      assetId: assetId ?? this.assetId,
      assetTitle: assetTitle ?? this.assetTitle,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Types of transactions
enum TransactionType {
  purchase,
  sale,
  dividendReceived,
  deposit,
  withdrawal,
  fee,
}

/// Transaction status
enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

/// Extensions for transaction types
extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.dividendReceived:
        return 'Dividend';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.fee:
        return 'Fee';
    }
  }

  String get description {
    switch (this) {
      case TransactionType.purchase:
        return 'Asset purchase';
      case TransactionType.sale:
        return 'Asset sale';
      case TransactionType.dividendReceived:
        return 'Dividend payment received';
      case TransactionType.deposit:
        return 'Funds deposited';
      case TransactionType.withdrawal:
        return 'Funds withdrawn';
      case TransactionType.fee:
        return 'Transaction fee';
    }
  }

  bool get isPositive {
    switch (this) {
      case TransactionType.dividendReceived:
      case TransactionType.deposit:
      case TransactionType.sale:
        return true;
      case TransactionType.purchase:
      case TransactionType.withdrawal:
      case TransactionType.fee:
        return false;
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }
}