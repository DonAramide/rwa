import 'package:flutter/foundation.dart';
import '../models/rofr_models.dart';
import '../models/asset.dart';
import '../core/api_client.dart';
import 'rofr_notification_service.dart';

/// Service for handling automatic market listing after ROFR expiry
class RofrMarketListingService {
  static const Duration _expiryCheckInterval = Duration(minutes: 15);
  static const Duration _expiryBuffer = Duration(minutes: 5);

  /// Process expired ROFR offers and list remaining shares on market
  static Future<List<MarketListing>> processExpiredOffers(List<RofrOffer> offers) async {
    final expiredOffers = offers.where((offer) =>
      offer.status == RofrStatus.pending &&
      offer.isExpired
    ).toList();

    if (expiredOffers.isEmpty) {
      return [];
    }

    final marketListings = <MarketListing>[];

    for (final offer in expiredOffers) {
      try {
        final listing = await _processExpiredOffer(offer);
        if (listing != null) {
          marketListings.add(listing);
        }
      } catch (e) {
        debugPrint('Error processing expired offer ${offer.id}: $e');
      }
    }

    return marketListings;
  }

  /// Process a single expired ROFR offer
  static Future<MarketListing?> _processExpiredOffer(RofrOffer offer) async {
    debugPrint('Processing expired ROFR offer: ${offer.id}');

    // Calculate remaining shares after ROFR responses
    final acceptedShares = offer.responses
        .where((r) => r.status == RofrStatus.accepted)
        .fold(0, (sum, r) => sum + r.sharesRequested);

    final remainingShares = offer.sharesOffered - acceptedShares;

    if (remainingShares <= 0) {
      debugPrint('No remaining shares to list for offer ${offer.id}');
      return null;
    }

    // Create market listing
    final marketListing = MarketListing(
      id: _generateListingId(),
      assetId: offer.assetId,
      assetTitle: offer.assetTitle,
      sellerId: offer.sellerId,
      sellerName: offer.sellerName,
      sharesAvailable: remainingShares,
      pricePerShare: offer.pricePerShare,
      totalValue: remainingShares * offer.pricePerShare,
      listingDate: DateTime.now(),
      source: MarketListingSource.rofrExpiry,
      rofrOfferId: offer.id,
      priority: _calculateListingPriority(offer, remainingShares),
      metadata: {
        'originalRofrShares': offer.sharesOffered,
        'acceptedShares': acceptedShares,
        'rofrExpiryDate': offer.expiryDate.toIso8601String(),
        'rofrDuration': offer.expiryDate.difference(offer.offerDate).inHours,
        'responseCount': offer.responses.length,
        'acceptanceRate': offer.responses.isEmpty ? 0 : (offer.responses.where((r) => r.status == RofrStatus.accepted).length / offer.responses.length),
      },
    );

    // Submit to marketplace API
    final listingResponse = await ApiClient.createMarketListing(marketListing.toJson());

    if (listingResponse['success'] == true) {
      final listingId = listingResponse['listingId'] as String;

      // Send notifications about the market listing
      await _sendMarketListingNotifications(offer, marketListing, acceptedShares);

      // Update the original ROFR offer status
      await _updateRofrOfferStatus(offer.id, RofrStatus.expired);

      debugPrint('Successfully listed ${remainingShares} shares on market with ID: $listingId');

      return marketListing.copyWith(id: listingId);
    } else {
      debugPrint('Failed to create market listing for offer ${offer.id}');
      return null;
    }
  }

  /// Send notifications about the market listing
  static Future<void> _sendMarketListingNotifications(
    RofrOffer offer,
    MarketListing listing,
    int acceptedShares,
  ) async {
    // Notify the seller about the market listing
    final sellerNotification = RofrNotification(
      id: RofrNotificationService._generateNotificationId(),
      rofrOfferId: offer.id,
      recipientId: offer.sellerId,
      title: 'ROFR Completed - Shares Listed on Market',
      message: _buildSellerMarketListingMessage(offer, listing, acceptedShares),
      sentDate: DateTime.now(),
      status: RofrNotificationStatus.sent,
      metadata: {
        'notificationType': 'market_listing_seller',
        'marketListingId': listing.id,
        'sharesListed': listing.sharesAvailable,
        'acceptedShares': acceptedShares,
      },
    );

    try {
      await ApiClient.sendRofrNotification(sellerNotification.toJson());
    } catch (e) {
      debugPrint('Failed to send seller market listing notification: $e');
    }

    // Notify shareholders who didn't respond about the market opportunity
    final unrespondedShareholders = offer.eligibleShareholders.where((shareholder) =>
        !offer.responses.any((response) => response.shareholderId == shareholder.userId)
    ).toList();

    for (final shareholder in unrespondedShareholders) {
      final shareholderNotification = RofrNotification(
        id: RofrNotificationService._generateNotificationId(),
        rofrOfferId: offer.id,
        recipientId: shareholder.userId,
        title: 'ROFR Expired - Shares Now Available on Market',
        message: _buildShareholderMarketListingMessage(offer, listing, shareholder),
        sentDate: DateTime.now(),
        status: RofrNotificationStatus.sent,
        metadata: {
          'notificationType': 'market_listing_shareholder',
          'marketListingId': listing.id,
          'shareholderOwnership': shareholder.ownershipPercentage,
        },
      );

      try {
        await ApiClient.sendRofrNotification(shareholderNotification.toJson());
      } catch (e) {
        debugPrint('Failed to send shareholder market listing notification to ${shareholder.email}: $e');
      }
    }

    // Notify all shareholders about the successful ROFR completion
    final respondedShareholders = offer.eligibleShareholders.where((shareholder) =>
        offer.responses.any((response) => response.shareholderId == shareholder.userId)
    ).toList();

    for (final shareholder in respondedShareholders) {
      final completionNotification = RofrNotification(
        id: RofrNotificationService._generateNotificationId(),
        rofrOfferId: offer.id,
        recipientId: shareholder.userId,
        title: 'ROFR Process Completed - ${offer.assetTitle}',
        message: _buildCompletionMessage(offer, listing, shareholder, acceptedShares),
        sentDate: DateTime.now(),
        status: RofrNotificationStatus.sent,
        metadata: {
          'notificationType': 'rofr_completion',
          'participatedInRofr': true,
        },
      );

      try {
        await ApiClient.sendRofrNotification(completionNotification.toJson());
      } catch (e) {
        debugPrint('Failed to send completion notification to ${shareholder.email}: $e');
      }
    }
  }

  /// Update ROFR offer status
  static Future<void> _updateRofrOfferStatus(String offerId, RofrStatus status) async {
    try {
      await ApiClient.updateRofrOfferStatus(offerId, status.name);
    } catch (e) {
      debugPrint('Failed to update ROFR offer status: $e');
    }
  }

  /// Calculate listing priority based on various factors
  static MarketListingPriority _calculateListingPriority(RofrOffer offer, int remainingShares) {
    // High priority factors
    final isHighValue = offer.pricePerShare > 100.0;
    final isHighVolume = remainingShares > offer.sharesOffered * 0.5;
    final hadHighInterest = offer.responses.length > offer.eligibleShareholders.length * 0.5;
    final isPopularAsset = offer.assetTitle.toLowerCase().contains('premium') ||
                           offer.assetTitle.toLowerCase().contains('luxury');

    if ((isHighValue && isHighVolume) || (hadHighInterest && isPopularAsset)) {
      return MarketListingPriority.high;
    }

    // Medium priority factors
    final isModerateValue = offer.pricePerShare > 50.0;
    final hasModerateInterest = offer.responses.length > 1;

    if (isModerateValue || hasModerateInterest || isHighVolume) {
      return MarketListingPriority.medium;
    }

    return MarketListingPriority.normal;
  }

  /// Schedule periodic checks for expired offers
  static void scheduleExpiryChecks() {
    // In a real implementation, this would use a proper scheduling service
    // For now, this is a placeholder for the concept
    debugPrint('Scheduled ROFR expiry checks every ${_expiryCheckInterval.inMinutes} minutes');
  }

  /// Check if an offer is close to expiry (for warnings)
  static bool isNearExpiry(RofrOffer offer) {
    return offer.timeRemaining <= const Duration(hours: 2) && !offer.isExpired;
  }

  /// Get market listing preview for an offer
  static MarketListingPreview getListingPreview(RofrOffer offer) {
    final acceptedShares = offer.responses
        .where((r) => r.status == RofrStatus.accepted)
        .fold(0, (sum, r) => sum + r.sharesRequested);

    final remainingShares = offer.sharesOffered - acceptedShares;

    return MarketListingPreview(
      sharesRemaining: remainingShares,
      estimatedListingPrice: offer.pricePerShare,
      estimatedTotalValue: remainingShares * offer.pricePerShare,
      priority: _calculateListingPriority(offer, remainingShares),
      willBeListed: remainingShares > 0,
    );
  }

  // Helper methods for notification messages
  static String _buildSellerMarketListingMessage(
    RofrOffer offer,
    MarketListing listing,
    int acceptedShares,
  ) {
    if (acceptedShares == 0) {
      return '''
Your ROFR offer for ${offer.assetTitle} has expired without any acceptances from existing shareholders.

All ${listing.sharesAvailable} shares have been automatically listed on the public marketplace at \$${listing.pricePerShare.toStringAsFixed(2)} per share.

Market Listing Details:
• Listing ID: ${listing.id}
• Shares available: ${listing.sharesAvailable}
• Total value: \$${listing.totalValue.toStringAsFixed(2)}
• Listed on: ${_formatDateTime(listing.listingDate)}

Your shares are now available to all platform investors. You'll receive notifications when purchases are made.
      '''.trim();
    } else {
      return '''
Your ROFR offer for ${offer.assetTitle} has been completed!

ROFR Summary:
• Total shares offered: ${offer.sharesOffered}
• Purchased by shareholders: $acceptedShares
• Remaining shares: ${listing.sharesAvailable}

The remaining ${listing.sharesAvailable} shares have been automatically listed on the public marketplace at \$${listing.pricePerShare.toStringAsFixed(2)} per share.

You'll receive notifications for any additional sales through the marketplace.
      '''.trim();
    }
  }

  static String _buildShareholderMarketListingMessage(
    RofrOffer offer,
    MarketListing listing,
    ShareholderInfo shareholder,
  ) {
    return '''
The ROFR opportunity for ${offer.assetTitle} has expired.

Since you didn't respond to the ROFR offer, ${listing.sharesAvailable} shares are now available on the public marketplace at \$${listing.pricePerShare.toStringAsFixed(2)} per share.

You can still purchase these shares through the marketplace, but they're now available to all investors, not just existing shareholders.

Current ownership: ${shareholder.ownershipPercentage.toStringAsFixed(1)}%
Marketplace listing: ${listing.sharesAvailable} shares available

Visit the marketplace to view and purchase these shares if you're still interested.
    '''.trim();
  }

  static String _buildCompletionMessage(
    RofrOffer offer,
    MarketListing listing,
    ShareholderInfo shareholder,
    int totalAcceptedShares,
  ) {
    final userResponse = offer.responses.firstWhere(
      (r) => r.shareholderId == shareholder.userId,
      orElse: () => RofrResponse(
        id: '',
        rofrOfferId: '',
        shareholderId: '',
        shareholderName: '',
        status: RofrStatus.pending,
        sharesRequested: 0,
        totalAmount: 0,
        responseDate: DateTime.now(),
      ),
    );

    if (userResponse.status == RofrStatus.accepted) {
      return '''
The ROFR process for ${offer.assetTitle} has been completed successfully!

Your purchase: ${userResponse.sharesRequested} shares for \$${userResponse.totalAmount.toStringAsFixed(2)}
Total ROFR purchases: $totalAcceptedShares shares

${listing.sharesAvailable > 0
  ? 'Remaining ${listing.sharesAvailable} shares are now available on the public marketplace.'
  : 'All shares have been purchased through the ROFR process.'}

Thank you for participating in the Right of First Refusal process.
      '''.trim();
    } else {
      return '''
The ROFR process for ${offer.assetTitle} has been completed.

You declined this opportunity, and other shareholders purchased $totalAcceptedShares shares.

${listing.sharesAvailable > 0
  ? '${listing.sharesAvailable} shares are now available on the public marketplace at \$${listing.pricePerShare.toStringAsFixed(2)} per share.'
  : 'All remaining shares have been allocated.'}

Keep an eye out for future ROFR opportunities in your portfolio.
      '''.trim();
    }
  }

  static String _generateListingId() {
    return 'mkt_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Market listing model for ROFR-to-market transitions
class MarketListing {
  final String id;
  final String assetId;
  final String assetTitle;
  final String sellerId;
  final String sellerName;
  final int sharesAvailable;
  final double pricePerShare;
  final double totalValue;
  final DateTime listingDate;
  final MarketListingSource source;
  final String? rofrOfferId;
  final MarketListingPriority priority;
  final Map<String, dynamic> metadata;

  const MarketListing({
    required this.id,
    required this.assetId,
    required this.assetTitle,
    required this.sellerId,
    required this.sellerName,
    required this.sharesAvailable,
    required this.pricePerShare,
    required this.totalValue,
    required this.listingDate,
    required this.source,
    this.rofrOfferId,
    this.priority = MarketListingPriority.normal,
    this.metadata = const {},
  });

  MarketListing copyWith({
    String? id,
    String? assetId,
    String? assetTitle,
    String? sellerId,
    String? sellerName,
    int? sharesAvailable,
    double? pricePerShare,
    double? totalValue,
    DateTime? listingDate,
    MarketListingSource? source,
    String? rofrOfferId,
    MarketListingPriority? priority,
    Map<String, dynamic>? metadata,
  }) {
    return MarketListing(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      assetTitle: assetTitle ?? this.assetTitle,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sharesAvailable: sharesAvailable ?? this.sharesAvailable,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      totalValue: totalValue ?? this.totalValue,
      listingDate: listingDate ?? this.listingDate,
      source: source ?? this.source,
      rofrOfferId: rofrOfferId ?? this.rofrOfferId,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'assetTitle': assetTitle,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sharesAvailable': sharesAvailable,
      'pricePerShare': pricePerShare,
      'totalValue': totalValue,
      'listingDate': listingDate.toIso8601String(),
      'source': source.name,
      'rofrOfferId': rofrOfferId,
      'priority': priority.name,
      'metadata': metadata,
    };
  }

  factory MarketListing.fromJson(Map<String, dynamic> json) {
    return MarketListing(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      assetTitle: json['assetTitle'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      sharesAvailable: json['sharesAvailable'] as int,
      pricePerShare: (json['pricePerShare'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      listingDate: DateTime.parse(json['listingDate'] as String),
      source: MarketListingSource.values.byName(json['source'] as String),
      rofrOfferId: json['rofrOfferId'] as String?,
      priority: MarketListingPriority.values.byName(json['priority'] as String? ?? 'normal'),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Market listing preview for UI
class MarketListingPreview {
  final int sharesRemaining;
  final double estimatedListingPrice;
  final double estimatedTotalValue;
  final MarketListingPriority priority;
  final bool willBeListed;

  const MarketListingPreview({
    required this.sharesRemaining,
    required this.estimatedListingPrice,
    required this.estimatedTotalValue,
    required this.priority,
    required this.willBeListed,
  });
}

enum MarketListingSource {
  rofrExpiry,
  directListing,
  secondaryMarket,
}

enum MarketListingPriority {
  high,
  medium,
  normal,
  low,
}