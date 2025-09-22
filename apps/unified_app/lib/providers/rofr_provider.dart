import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/rofr_models.dart';
import '../models/asset.dart';

class RofrState {
  final List<RofrOffer> offers;
  final List<RofrNotification> notifications;
  final Map<String, List<ShareholderInfo>> shareholdersByAsset;
  final bool isLoading;
  final String? error;

  const RofrState({
    this.offers = const [],
    this.notifications = const [],
    this.shareholdersByAsset = const {},
    this.isLoading = false,
    this.error,
  });

  RofrState copyWith({
    List<RofrOffer>? offers,
    List<RofrNotification>? notifications,
    Map<String, List<ShareholderInfo>>? shareholdersByAsset,
    bool? isLoading,
    String? error,
  }) {
    return RofrState(
      offers: offers ?? this.offers,
      notifications: notifications ?? this.notifications,
      shareholdersByAsset: shareholdersByAsset ?? this.shareholdersByAsset,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RofrNotifier extends StateNotifier<RofrState> {
  RofrNotifier() : super(const RofrState());

  // Create a new ROFR offer when someone wants to sell shares
  Future<String?> createRofrOffer({
    required String assetId,
    required String assetTitle,
    required int sharesOffered,
    required double pricePerShare,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get existing shareholders for this asset
      final shareholders = await _getAssetShareholders(assetId);

      if (shareholders.isEmpty) {
        // No existing shareholders, can proceed directly to market
        state = state.copyWith(isLoading: false);
        return null; // No ROFR needed
      }

      // Create ROFR offer
      final offer = RofrOffer(
        id: _generateId(),
        assetId: assetId,
        assetTitle: assetTitle,
        sellerId: 'current_user_id', // Would come from auth
        sellerName: 'Current User', // Would come from auth
        sharesOffered: sharesOffered,
        pricePerShare: pricePerShare,
        totalValue: sharesOffered * pricePerShare,
        offerDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(hours: 48)), // 48-hour window
        status: RofrStatus.pending,
        eligibleShareholders: shareholders,
        responses: [],
        notes: notes,
      );

      // Submit to API
      await ApiClient.createRofrOffer(offer.toJson());

      // Send notifications to all eligible shareholders
      await _sendNotificationsToShareholders(offer);

      // Update local state
      final updatedOffers = [...state.offers, offer];
      state = state.copyWith(
        offers: updatedOffers,
        isLoading: false,
      );

      return offer.id;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Respond to a ROFR offer (accept/reject)
  Future<bool> respondToRofrOffer({
    required String offerId,
    required RofrStatus response,
    required int sharesRequested,
    String? message,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rofrResponse = RofrResponse(
        id: _generateId(),
        rofrOfferId: offerId,
        shareholderId: 'current_user_id', // Would come from auth
        shareholderName: 'Current User', // Would come from auth
        status: response,
        sharesRequested: sharesRequested,
        totalAmount: sharesRequested * _getOfferPrice(offerId),
        responseDate: DateTime.now(),
        message: message,
        notificationStatus: RofrNotificationStatus.responded,
      );

      // Submit response to API
      await ApiClient.submitRofrResponse(rofrResponse.toJson());

      // Update local state
      final updatedOffers = state.offers.map((offer) {
        if (offer.id == offerId) {
          final updatedResponses = [...offer.responses, rofrResponse];
          return RofrOffer(
            id: offer.id,
            assetId: offer.assetId,
            assetTitle: offer.assetTitle,
            sellerId: offer.sellerId,
            sellerName: offer.sellerName,
            sharesOffered: offer.sharesOffered,
            pricePerShare: offer.pricePerShare,
            totalValue: offer.totalValue,
            offerDate: offer.offerDate,
            expiryDate: offer.expiryDate,
            status: _calculateOfferStatus(offer, updatedResponses),
            eligibleShareholders: offer.eligibleShareholders,
            responses: updatedResponses,
            notes: offer.notes,
          );
        }
        return offer;
      }).toList();

      state = state.copyWith(
        offers: updatedOffers,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Get ROFR offers for current user
  Future<void> loadUserRofrOffers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load offers where user is eligible shareholder
      final response = await ApiClient.getUserRofrOffers();
      final offers = (response['offers'] as List)
          .map((o) => RofrOffer.fromJson(o))
          .toList();

      // Load notifications
      final notificationResponse = await ApiClient.getRofrNotifications();
      final notifications = (notificationResponse['notifications'] as List)
          .map((n) => RofrNotification.fromJson(n))
          .toList();

      state = state.copyWith(
        offers: offers,
        notifications: notifications,
        isLoading: false,
      );
    } catch (e) {
      // For demo purposes, use mock data
      final mockOffers = _generateMockRofrOffers();
      final mockNotifications = _generateMockNotifications();

      state = state.copyWith(
        offers: mockOffers,
        notifications: mockNotifications,
        isLoading: false,
      );
    }
  }

  // Get shareholders for a specific asset
  Future<List<ShareholderInfo>> _getAssetShareholders(String assetId) async {
    try {
      final response = await ApiClient.getAssetShareholders(assetId);
      return (response['shareholders'] as List)
          .map((s) => ShareholderInfo.fromJson(s))
          .toList();
    } catch (e) {
      // Return mock shareholders for demo
      return _generateMockShareholders(assetId);
    }
  }

  // Send notifications to eligible shareholders
  Future<void> _sendNotificationsToShareholders(RofrOffer offer) async {
    final notifications = offer.eligibleShareholders.map((shareholder) {
      return RofrNotification(
        id: _generateId(),
        rofrOfferId: offer.id,
        recipientId: shareholder.userId,
        title: 'Right of First Refusal Opportunity',
        message: '${offer.sellerName} is offering ${offer.sharesOffered} shares of ${offer.assetTitle} at \$${offer.pricePerShare.toStringAsFixed(2)} per share. You have until ${_formatDate(offer.expiryDate)} to respond.',
        sentDate: DateTime.now(),
        status: RofrNotificationStatus.sent,
        metadata: {
          'assetId': offer.assetId,
          'assetTitle': offer.assetTitle,
          'sharesOffered': offer.sharesOffered,
          'pricePerShare': offer.pricePerShare,
        },
      );
    }).toList();

    // Send notifications via API
    for (final notification in notifications) {
      try {
        await ApiClient.sendRofrNotification(notification.toJson());
      } catch (e) {
        // Log error but continue
      }
    }

    // Update local notifications state
    final updatedNotifications = [...state.notifications, ...notifications];
    state = state.copyWith(notifications: updatedNotifications);
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await ApiClient.markRofrNotificationAsRead(notificationId);
    } catch (e) {
      // Handle error silently for demo
    }

    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return RofrNotification(
          id: notification.id,
          rofrOfferId: notification.rofrOfferId,
          recipientId: notification.recipientId,
          title: notification.title,
          message: notification.message,
          sentDate: notification.sentDate,
          readDate: DateTime.now(),
          status: RofrNotificationStatus.read,
          metadata: notification.metadata,
        );
      }
      return notification;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  // Process expired offers (called periodically)
  Future<void> processExpiredOffers() async {
    final now = DateTime.now();
    final updatedOffers = state.offers.map((offer) {
      if (offer.isExpired && offer.status == RofrStatus.pending) {
        // Move to market listing
        return RofrOffer(
          id: offer.id,
          assetId: offer.assetId,
          assetTitle: offer.assetTitle,
          sellerId: offer.sellerId,
          sellerName: offer.sellerName,
          sharesOffered: offer.sharesRemaining,
          pricePerShare: offer.pricePerShare,
          totalValue: offer.totalValue,
          offerDate: offer.offerDate,
          expiryDate: offer.expiryDate,
          status: RofrStatus.expired,
          eligibleShareholders: offer.eligibleShareholders,
          responses: offer.responses,
          notes: offer.notes,
        );
      }
      return offer;
    }).toList();

    if (updatedOffers != state.offers) {
      state = state.copyWith(offers: updatedOffers);

      // Notify about expired offers that should go to market
      final expiredOffers = updatedOffers
          .where((o) => o.status == RofrStatus.expired && o.sharesRemaining > 0)
          .toList();

      for (final offer in expiredOffers) {
        // List remaining shares on public market
        await _listOnPublicMarket(offer);
      }
    }
  }

  // Helper methods
  double _getOfferPrice(String offerId) {
    final offer = state.offers.firstWhere((o) => o.id == offerId);
    return offer.pricePerShare;
  }

  RofrStatus _calculateOfferStatus(RofrOffer offer, List<RofrResponse> responses) {
    final acceptedShares = responses
        .where((r) => r.status == RofrStatus.accepted)
        .fold(0, (sum, r) => sum + r.sharesRequested);

    if (acceptedShares >= offer.sharesOffered) {
      return RofrStatus.completed;
    } else if (offer.isExpired) {
      return RofrStatus.expired;
    } else {
      return RofrStatus.pending;
    }
  }

  Future<void> _listOnPublicMarket(RofrOffer offer) async {
    // Implementation to list remaining shares on public marketplace
    try {
      await ApiClient.listOnMarket({
        'assetId': offer.assetId,
        'sharesOffered': offer.sharesRemaining,
        'pricePerShare': offer.pricePerShare,
        'sellerId': offer.sellerId,
        'rofrOfferId': offer.id,
      });
    } catch (e) {
      // Handle error
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Mock data generators for demo purposes
  List<RofrOffer> _generateMockRofrOffers() {
    return [
      RofrOffer(
        id: '1',
        assetId: '1',
        assetTitle: 'Premium Office Complex Downtown',
        sellerId: 'seller_1',
        sellerName: 'John Smith',
        sharesOffered: 50,
        pricePerShare: 125.00,
        totalValue: 6250.00,
        offerDate: DateTime.now().subtract(const Duration(hours: 12)),
        expiryDate: DateTime.now().add(const Duration(hours: 36)),
        status: RofrStatus.pending,
        eligibleShareholders: _generateMockShareholders('1'),
        responses: [],
        notes: 'Urgent sale needed for personal reasons.',
      ),
      RofrOffer(
        id: '2',
        assetId: '2',
        assetTitle: 'Luxury Residential Apartments',
        sellerId: 'seller_2',
        sellerName: 'Sarah Johnson',
        sharesOffered: 25,
        pricePerShare: 200.00,
        totalValue: 5000.00,
        offerDate: DateTime.now().subtract(const Duration(hours: 6)),
        expiryDate: DateTime.now().add(const Duration(hours: 42)),
        status: RofrStatus.pending,
        eligibleShareholders: _generateMockShareholders('2'),
        responses: [],
      ),
    ];
  }

  List<ShareholderInfo> _generateMockShareholders(String assetId) {
    return [
      ShareholderInfo(
        userId: 'user_1',
        email: 'investor1@example.com',
        name: 'Alice Wilson',
        sharesOwned: 100,
        ownershipPercentage: 15.5,
        purchaseDate: DateTime.now().subtract(const Duration(days: 180)),
      ),
      ShareholderInfo(
        userId: 'user_2',
        email: 'investor2@example.com',
        name: 'Bob Chen',
        sharesOwned: 75,
        ownershipPercentage: 11.8,
        purchaseDate: DateTime.now().subtract(const Duration(days: 120)),
      ),
      ShareholderInfo(
        userId: 'user_3',
        email: 'investor3@example.com',
        name: 'Carol Davis',
        sharesOwned: 50,
        ownershipPercentage: 7.9,
        purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }

  List<RofrNotification> _generateMockNotifications() {
    return [
      RofrNotification(
        id: 'notif_1',
        rofrOfferId: '1',
        recipientId: 'current_user',
        title: 'New ROFR Opportunity',
        message: 'John Smith is offering 50 shares of Premium Office Complex Downtown at \$125.00 per share. You have 36 hours remaining to respond.',
        sentDate: DateTime.now().subtract(const Duration(hours: 12)),
        status: RofrNotificationStatus.delivered,
        metadata: {
          'assetId': '1',
          'assetTitle': 'Premium Office Complex Downtown',
          'sharesOffered': 50,
          'pricePerShare': 125.00,
        },
      ),
      RofrNotification(
        id: 'notif_2',
        rofrOfferId: '2',
        recipientId: 'current_user',
        title: 'ROFR Reminder',
        message: 'Don\'t miss your opportunity to purchase shares in Luxury Residential Apartments. 42 hours remaining.',
        sentDate: DateTime.now().subtract(const Duration(hours: 6)),
        status: RofrNotificationStatus.delivered,
        metadata: {
          'assetId': '2',
          'assetTitle': 'Luxury Residential Apartments',
          'sharesOffered': 25,
          'pricePerShare': 200.00,
        },
      ),
    ];
  }
}

// Providers
final rofrProvider = StateNotifierProvider<RofrNotifier, RofrState>((ref) {
  return RofrNotifier();
});

// Computed providers
final unreadRofrNotificationsProvider = Provider<int>((ref) {
  final notifications = ref.watch(rofrProvider).notifications;
  return notifications.where((n) => !n.isRead).length;
});

final activeRofrOffersProvider = Provider<List<RofrOffer>>((ref) {
  final offers = ref.watch(rofrProvider).offers;
  return offers.where((o) =>
    o.status == RofrStatus.pending && !o.isExpired
  ).toList();
});