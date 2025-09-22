import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/order_book.dart';
import '../models/asset.dart';

enum TradingErrorType {
  network,
  validation,
  insufficientFunds,
  marketClosed,
  invalidOrder,
  orderNotFound,
  unauthorized,
  serverError,
  timeout,
  unknown,
}

class TradingError {
  final TradingErrorType type;
  final String message;
  final String? details;
  final DateTime timestamp;
  final bool isRetryable;

  const TradingError({
    required this.type,
    required this.message,
    this.details,
    required this.timestamp,
    this.isRetryable = false,
  });

  TradingError copyWith({
    TradingErrorType? type,
    String? message,
    String? details,
    DateTime? timestamp,
    bool? isRetryable,
  }) {
    return TradingError(
      type: type ?? this.type,
      message: message ?? this.message,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      isRetryable: isRetryable ?? this.isRetryable,
    );
  }
}

class TradingState {
  final Map<String, OrderBook> orderBooks;
  final Map<String, MarketData> marketData;
  final Map<String, List<Order>> userOrders;
  final bool isLoading;
  final Map<String, bool> loadingStates; // Track loading for different operations
  final TradingError? error;
  final bool isOnline;
  final DateTime? lastUpdated;
  final int retryCount;

  const TradingState({
    this.orderBooks = const {},
    this.marketData = const {},
    this.userOrders = const {},
    this.isLoading = false,
    this.loadingStates = const {},
    this.error,
    this.isOnline = true,
    this.lastUpdated,
    this.retryCount = 0,
  });

  TradingState copyWith({
    Map<String, OrderBook>? orderBooks,
    Map<String, MarketData>? marketData,
    Map<String, List<Order>>? userOrders,
    bool? isLoading,
    Map<String, bool>? loadingStates,
    TradingError? error,
    bool? isOnline,
    DateTime? lastUpdated,
    int? retryCount,
  }) {
    return TradingState(
      orderBooks: orderBooks ?? this.orderBooks,
      marketData: marketData ?? this.marketData,
      userOrders: userOrders ?? this.userOrders,
      isLoading: isLoading ?? this.isLoading,
      loadingStates: loadingStates ?? this.loadingStates,
      error: error,
      isOnline: isOnline ?? this.isOnline,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  bool isLoadingOperation(String operation) {
    return loadingStates[operation] ?? false;
  }
}

class TradingNotifier extends StateNotifier<TradingState> {
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  TradingNotifier() : super(const TradingState());

  void clearError() {
    state = state.copyWith(error: null, retryCount: 0);
  }

  void _setLoadingState(String operation, bool loading) {
    final updatedLoadingStates = Map<String, bool>.from(state.loadingStates);
    updatedLoadingStates[operation] = loading;
    state = state.copyWith(loadingStates: updatedLoadingStates);
  }

  TradingError _createError(Exception exception, TradingErrorType defaultType, String defaultMessage) {
    TradingErrorType errorType = defaultType;
    String message = defaultMessage;
    String? details = exception.toString();
    bool isRetryable = false;

    if (exception.toString().contains('SocketException') ||
        exception.toString().contains('network') ||
        exception.toString().contains('connection')) {
      errorType = TradingErrorType.network;
      message = 'Network connection failed. Please check your internet connection.';
      isRetryable = true;
    } else if (exception.toString().contains('TimeoutException') ||
               exception.toString().contains('timeout')) {
      errorType = TradingErrorType.timeout;
      message = 'Request timed out. Please try again.';
      isRetryable = true;
    } else if (exception.toString().contains('insufficient')) {
      errorType = TradingErrorType.insufficientFunds;
      message = 'Insufficient funds to complete this transaction.';
      isRetryable = false;
    } else if (exception.toString().contains('market closed')) {
      errorType = TradingErrorType.marketClosed;
      message = 'Market is currently closed. Trading hours: 9:30 AM - 4:00 PM EST.';
      isRetryable = false;
    } else if (exception.toString().contains('invalid order')) {
      errorType = TradingErrorType.invalidOrder;
      message = 'Order parameters are invalid. Please check your input.';
      isRetryable = false;
    }

    return TradingError(
      type: errorType,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      isRetryable: isRetryable,
    );
  }

  Future<void> loadOrderBook(String assetId) async {
    _setLoadingState('orderBook_$assetId', true);
    state = state.copyWith(error: null);

    try {
      // Simulate network conditions and potential failures
      await Future.delayed(const Duration(seconds: 1));

      // Simulate random network failures for demonstration
      if (DateTime.now().millisecond % 5 == 0) {
        throw Exception('network_error: Connection timeout');
      }

      final orderBook = _generateMockOrderBook(assetId);
      final updatedOrderBooks = Map<String, OrderBook>.from(state.orderBooks);
      updatedOrderBooks[assetId] = orderBook;

      state = state.copyWith(
        orderBooks: updatedOrderBooks,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      final error = _createError(
        e is Exception ? e : Exception(e.toString()),
        TradingErrorType.network,
        'Failed to load order book',
      );
      state = state.copyWith(error: error);
    } finally {
      _setLoadingState('orderBook_$assetId', false);
    }
  }

  Future<void> loadMarketData(String assetId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final marketData = _generateMockMarketData(assetId);

      final updatedMarketData = Map<String, MarketData>.from(state.marketData);
      updatedMarketData[assetId] = marketData;

      state = state.copyWith(marketData: updatedMarketData);
    } catch (e) {
      final error = _createError(
        e is Exception ? e : Exception(e.toString()),
        TradingErrorType.network,
        'Failed to load market data',
      );
      state = state.copyWith(error: error);
    }
  }

  Future<void> loadUserOrders(String assetId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      final orders = _generateMockUserOrders(assetId);

      final updatedUserOrders = Map<String, List<Order>>.from(state.userOrders);
      updatedUserOrders[assetId] = orders;

      state = state.copyWith(userOrders: updatedUserOrders);
    } catch (e) {
      final error = _createError(
        e is Exception ? e : Exception(e.toString()),
        TradingErrorType.network,
        'Failed to load user orders',
      );
      state = state.copyWith(error: error);
    }
  }

  Future<void> placeOrder({
    required String assetId,
    required OrderType type,
    required OrderSide side,
    required double quantity,
    required double price,
    DateTime? expiresAt,
  }) async {
    _setLoadingState('placeOrder', true);
    state = state.copyWith(error: null);

    try {
      // Pre-flight validation
      await _validateOrder(assetId, type, side, quantity, price);

      // Simulate API call with potential failures
      await Future.delayed(const Duration(seconds: 2));

      // Simulate various trading errors
      final random = DateTime.now().millisecond % 10;
      if (random == 0) {
        throw Exception('insufficient_funds: Not enough balance to place this order');
      } else if (random == 1) {
        throw Exception('market_closed: Trading is not allowed outside market hours');
      } else if (random == 2) {
        throw Exception('invalid_order: Order quantity exceeds daily limit');
      } else if (random == 3) {
        throw Exception('network_error: Connection timeout during order placement');
      }

      // Create new order
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        assetId: assetId,
        userId: 'current_user',
        type: type,
        side: side,
        quantity: quantity,
        price: price,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
      );

      // Add to user orders
      final currentOrders = state.userOrders[assetId] ?? [];
      final updatedOrders = [order, ...currentOrders];

      final updatedUserOrders = Map<String, List<Order>>.from(state.userOrders);
      updatedUserOrders[assetId] = updatedOrders;

      state = state.copyWith(
        userOrders: updatedUserOrders,
        lastUpdated: DateTime.now(),
      );

      // Simulate order processing
      _simulateOrderProcessing(order);
    } catch (e) {
      final error = _createError(
        e is Exception ? e : Exception(e.toString()),
        TradingErrorType.unknown,
        'Failed to place order',
      );
      state = state.copyWith(error: error);
      rethrow;
    } finally {
      _setLoadingState('placeOrder', false);
    }
  }

  Future<void> _validateOrder(
    String assetId,
    OrderType type,
    OrderSide side,
    double quantity,
    double price,
  ) async {
    // Validate quantity
    if (quantity <= 0) {
      throw Exception('validation_error: Quantity must be greater than 0');
    }

    if (quantity > 10000) {
      throw Exception('validation_error: Quantity cannot exceed 10,000 shares');
    }

    // Validate price for limit orders
    if ((type == OrderType.limit || type == OrderType.stopLimit) && price <= 0) {
      throw Exception('validation_error: Price must be greater than 0 for limit orders');
    }

    // Check market hours (simplified)
    final now = DateTime.now();
    final hour = now.hour;
    final isWeekend = now.weekday > 5;

    if (isWeekend || hour < 9 || hour >= 16) {
      throw Exception('market_closed: Market is closed. Trading hours: 9:30 AM - 4:00 PM EST, Monday-Friday');
    }

    // Simulate balance check for buy orders
    if (side == OrderSide.buy) {
      final requiredAmount = quantity * price;
      const mockBalance = 5000.0; // Mock user balance

      if (requiredAmount > mockBalance) {
        throw Exception('insufficient_funds: Required: \$${requiredAmount.toStringAsFixed(2)}, Available: \$${mockBalance.toStringAsFixed(2)}');
      }
    }
  }

  Future<void> cancelOrder(String orderId, String assetId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final currentOrders = state.userOrders[assetId] ?? [];
      final updatedOrders = currentOrders.map((order) {
        if (order.id == orderId && order.status == OrderStatus.pending) {
          return order.copyWith(
            status: OrderStatus.cancelled,
            updatedAt: DateTime.now(),
          );
        }
        return order;
      }).toList();

      final updatedUserOrders = Map<String, List<Order>>.from(state.userOrders);
      updatedUserOrders[assetId] = updatedOrders;

      state = state.copyWith(userOrders: updatedUserOrders);
    } catch (e) {
      final error = _createError(
        e is Exception ? e : Exception(e.toString()),
        TradingErrorType.network,
        'Failed to cancel order',
      );
      state = state.copyWith(error: error);
      rethrow;
    }
  }

  void _simulateOrderProcessing(Order order) {
    // Simulate order getting filled after some time
    Future.delayed(const Duration(seconds: 5), () {
      final currentOrders = state.userOrders[order.assetId] ?? [];
      final updatedOrders = currentOrders.map((o) {
        if (o.id == order.id && o.status == OrderStatus.pending) {
          // Simulate partial or full fill
          final fillPercentage = 0.7 + (DateTime.now().millisecond % 30) / 100; // 70-100%
          final filledQuantity = o.quantity * fillPercentage;

          return o.copyWith(
            filledQuantity: filledQuantity,
            status: filledQuantity >= o.quantity ? OrderStatus.filled : OrderStatus.partiallyFilled,
            updatedAt: DateTime.now(),
          );
        }
        return o;
      }).toList();

      final updatedUserOrders = Map<String, List<Order>>.from(state.userOrders);
      updatedUserOrders[order.assetId] = updatedOrders;

      state = state.copyWith(userOrders: updatedUserOrders);
    });
  }

  OrderBook _generateMockOrderBook(String assetId) {
    // Generate realistic bid/ask data
    const basePrice = 100.0;
    final random = DateTime.now().millisecond;

    final bids = List.generate(10, (index) {
      final price = basePrice - (index * 0.5) - (random % 5);
      final quantity = 10.0 + (index * 2) + (random % 20);
      return OrderBookLevel(
        price: price,
        quantity: quantity,
        orderCount: 1 + (index % 3),
      );
    });

    final asks = List.generate(10, (index) {
      final price = basePrice + (index * 0.5) + (random % 5);
      final quantity = 8.0 + (index * 1.5) + (random % 15);
      return OrderBookLevel(
        price: price,
        quantity: quantity,
        orderCount: 1 + (index % 3),
      );
    });

    return OrderBook(
      assetId: assetId,
      bids: bids,
      asks: asks,
      lastUpdated: DateTime.now(),
    );
  }

  MarketData _generateMockMarketData(String assetId) {
    const basePrice = 100.0;
    final random = DateTime.now().millisecond;

    final currentPrice = basePrice + (random % 20) - 10;
    final openPrice = basePrice + (random % 15) - 7.5;
    final change = currentPrice - openPrice;
    final changePercentage = (change / openPrice) * 100;

    return MarketData(
      assetId: assetId,
      currentPrice: currentPrice,
      openPrice: openPrice,
      highPrice: currentPrice + (random % 5),
      lowPrice: currentPrice - (random % 5),
      volume: 1000.0 + (random % 5000),
      change: change,
      changePercentage: changePercentage,
      lastUpdated: DateTime.now(),
    );
  }

  List<Order> _generateMockUserOrders(String assetId) {
    // Generate some sample user orders
    final now = DateTime.now();
    return [
      Order(
        id: '1',
        assetId: assetId,
        userId: 'current_user',
        type: OrderType.limit,
        side: OrderSide.buy,
        quantity: 10.0,
        price: 95.0,
        status: OrderStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Order(
        id: '2',
        assetId: assetId,
        userId: 'current_user',
        type: OrderType.limit,
        side: OrderSide.sell,
        quantity: 5.0,
        price: 105.0,
        filledQuantity: 2.0,
        status: OrderStatus.partiallyFilled,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}

final tradingProvider = StateNotifierProvider<TradingNotifier, TradingState>((ref) {
  return TradingNotifier();
});