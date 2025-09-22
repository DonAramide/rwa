class EarningModel {
  final String id;
  final String jobId;
  final String assetTitle;
  final double amount;
  final String currency;
  final String status;
  final String? transactionHash;
  final DateTime earnedAt;
  final DateTime? paidAt;

  EarningModel({
    required this.id,
    required this.jobId,
    required this.assetTitle,
    required this.amount,
    required this.currency,
    required this.status,
    this.transactionHash,
    required this.earnedAt,
    this.paidAt,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      id: json['id'].toString(),
      jobId: json['job_id'].toString(),
      assetTitle: json['asset_title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'pending',
      transactionHash: json['transaction_hash'],
      earnedAt: DateTime.parse(json['earned_at']),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'asset_title': assetTitle,
      'amount': amount,
      'currency': currency,
      'status': status,
      'transaction_hash': transactionHash,
      'earned_at': earnedAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
    };
  }

  EarningModel copyWith({
    String? id,
    String? jobId,
    String? assetTitle,
    double? amount,
    String? currency,
    String? status,
    String? transactionHash,
    DateTime? earnedAt,
    DateTime? paidAt,
  }) {
    return EarningModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      assetTitle: assetTitle ?? this.assetTitle,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      transactionHash: transactionHash ?? this.transactionHash,
      earnedAt: earnedAt ?? this.earnedAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isFailed => status == 'failed';
  
  String get formattedAmount => '\$$amount $currency';
}