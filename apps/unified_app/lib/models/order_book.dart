class OrderBook {
  final String assetId;
  final List<OrderBookLevel> bids; // Buy orders (highest price first)
  final List<OrderBookLevel> asks; // Sell orders (lowest price first)
  final DateTime lastUpdated;

  const OrderBook({
    required this.assetId,
    required this.bids,
    required this.asks,
    required this.lastUpdated,
  });

  double? get bestBid => bids.isNotEmpty ? bids.first.price : null;
  double? get bestAsk => asks.isNotEmpty ? asks.first.price : null;
  double? get spread => bestBid != null && bestAsk != null ? bestAsk! - bestBid! : null;
  double? get spreadPercentage => bestBid != null && spread != null ? (spread! / bestBid!) * 100 : null;

  factory OrderBook.fromJson(Map<String, dynamic> json) {
    return OrderBook(
      assetId: json['assetId'],
      bids: (json['bids'] as List).map((e) => OrderBookLevel.fromJson(e)).toList(),
      asks: (json['asks'] as List).map((e) => OrderBookLevel.fromJson(e)).toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'bids': bids.map((e) => e.toJson()).toList(),
      'asks': asks.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class OrderBookLevel {
  final double price;
  final double quantity;
  final int orderCount;

  const OrderBookLevel({
    required this.price,
    required this.quantity,
    required this.orderCount,
  });

  double get total => price * quantity;

  factory OrderBookLevel.fromJson(Map<String, dynamic> json) {
    return OrderBookLevel(
      price: json['price'].toDouble(),
      quantity: json['quantity'].toDouble(),
      orderCount: json['orderCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'quantity': quantity,
      'orderCount': orderCount,
    };
  }
}

class MarketData {
  final String assetId;
  final double currentPrice;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double volume;
  final double change;
  final double changePercentage;
  final DateTime lastUpdated;

  const MarketData({
    required this.assetId,
    required this.currentPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.change,
    required this.changePercentage,
    required this.lastUpdated,
  });

  bool get isUp => change > 0;
  bool get isDown => change < 0;
  bool get isFlat => change == 0;

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      assetId: json['assetId'],
      currentPrice: json['currentPrice'].toDouble(),
      openPrice: json['openPrice'].toDouble(),
      highPrice: json['highPrice'].toDouble(),
      lowPrice: json['lowPrice'].toDouble(),
      volume: json['volume'].toDouble(),
      change: json['change'].toDouble(),
      changePercentage: json['changePercentage'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'currentPrice': currentPrice,
      'openPrice': openPrice,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'volume': volume,
      'change': change,
      'changePercentage': changePercentage,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}