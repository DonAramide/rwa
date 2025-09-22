class Order {
  final String id;
  final String assetId;
  final String userId;
  final OrderType type;
  final OrderSide side;
  final double quantity;
  final double price;
  final double? filledQuantity;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;

  const Order({
    required this.id,
    required this.assetId,
    required this.userId,
    required this.type,
    required this.side,
    required this.quantity,
    required this.price,
    this.filledQuantity,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  double get remainingQuantity => quantity - (filledQuantity ?? 0);
  bool get isPartiallyFilled => (filledQuantity ?? 0) > 0 && (filledQuantity ?? 0) < quantity;
  bool get isFullyFilled => (filledQuantity ?? 0) >= quantity;
  double get totalValue => quantity * price;
  double get filledValue => (filledQuantity ?? 0) * price;

  Order copyWith({
    String? id,
    String? assetId,
    String? userId,
    OrderType? type,
    OrderSide? side,
    double? quantity,
    double? price,
    double? filledQuantity,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return Order(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      side: side ?? this.side,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      filledQuantity: filledQuantity ?? this.filledQuantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'userId': userId,
      'type': type.name,
      'side': side.name,
      'quantity': quantity,
      'price': price,
      'filledQuantity': filledQuantity,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      assetId: json['assetId'],
      userId: json['userId'],
      type: OrderType.values.firstWhere((e) => e.name == json['type']),
      side: OrderSide.values.firstWhere((e) => e.name == json['side']),
      quantity: json['quantity'].toDouble(),
      price: json['price'].toDouble(),
      filledQuantity: json['filledQuantity']?.toDouble(),
      status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}

enum OrderType {
  market,
  limit,
  stopLoss,
  stopLimit,
}

enum OrderSide {
  buy,
  sell,
}

enum OrderStatus {
  pending,
  partiallyFilled,
  filled,
  cancelled,
  expired,
  rejected,
}

extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.market:
        return 'Market';
      case OrderType.limit:
        return 'Limit';
      case OrderType.stopLoss:
        return 'Stop Loss';
      case OrderType.stopLimit:
        return 'Stop Limit';
    }
  }

  String get description {
    switch (this) {
      case OrderType.market:
        return 'Execute immediately at current market price';
      case OrderType.limit:
        return 'Execute only at specified price or better';
      case OrderType.stopLoss:
        return 'Market order triggered when price reaches stop level';
      case OrderType.stopLimit:
        return 'Limit order triggered when price reaches stop level';
    }
  }
}

extension OrderSideExtension on OrderSide {
  String get displayName {
    switch (this) {
      case OrderSide.buy:
        return 'Buy';
      case OrderSide.sell:
        return 'Sell';
    }
  }
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.partiallyFilled:
        return 'Partially Filled';
      case OrderStatus.filled:
        return 'Filled';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.expired:
        return 'Expired';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }
}