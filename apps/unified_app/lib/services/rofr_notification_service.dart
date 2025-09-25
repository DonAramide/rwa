import 'package:flutter/foundation.dart';
import '../models/rofr_models.dart';
import '../core/api_client.dart';

/// Service for handling ROFR notifications and shareholder communications
class RofrNotificationService {
  static const Duration _reminderInterval = Duration(hours: 12);
  static const Duration _urgentThreshold = Duration(hours: 8);

  /// Send initial notifications to all eligible shareholders
  static Future<List<RofrNotification>> sendInitialNotifications({
    required RofrOffer offer,
    required List<ShareholderInfo> shareholders,
  }) async {
    final notifications = <RofrNotification>[];

    for (final shareholder in shareholders) {
      if (!shareholder.isEligibleForRofr) continue;

      final notification = RofrNotification(
        id: _generateNotificationId(),
        rofrOfferId: offer.id,
        recipientId: shareholder.userId,
        title: 'Right of First Refusal Opportunity - ${offer.assetTitle}',
        message: _buildInitialNotificationMessage(offer, shareholder),
        sentDate: DateTime.now(),
        status: RofrNotificationStatus.sent,
        metadata: {
          'notificationType': 'rofr_initial',
          'assetId': offer.assetId,
          'assetTitle': offer.assetTitle,
          'sellerId': offer.sellerId,
          'sellerName': offer.sellerName,
          'sharesOffered': offer.sharesOffered,
          'pricePerShare': offer.pricePerShare,
          'totalValue': offer.totalValue,
          'expiryDate': offer.expiryDate.toIso8601String(),
          'shareholderOwnership': shareholder.ownershipPercentage,
          'shareholderShares': shareholder.sharesOwned,
        },
      );

      try {
        await _sendNotificationToShareholder(notification, shareholder);
        notifications.add(notification);
        debugPrint('Sent initial ROFR notification to ${shareholder.email}');
      } catch (e) {
        debugPrint('Failed to send notification to ${shareholder.email}: $e');
      }
    }

    return notifications;
  }

  /// Send reminder notifications to shareholders who haven't responded
  static Future<List<RofrNotification>> sendReminderNotifications({
    required RofrOffer offer,
    required List<ShareholderInfo> unrespondedShareholders,
  }) async {
    final notifications = <RofrNotification>[];

    for (final shareholder in unrespondedShareholders) {
      final timeRemaining = offer.timeRemaining;
      final isUrgent = timeRemaining <= _urgentThreshold;

      final notification = RofrNotification(
        id: _generateNotificationId(),
        rofrOfferId: offer.id,
        recipientId: shareholder.userId,
        title: isUrgent
            ? 'URGENT: ROFR Expires Soon - ${offer.assetTitle}'
            : 'Reminder: ROFR Opportunity - ${offer.assetTitle}',
        message: _buildReminderNotificationMessage(offer, shareholder, timeRemaining),
        sentDate: DateTime.now(),
        status: RofrNotificationStatus.sent,
        metadata: {
          'notificationType': isUrgent ? 'rofr_urgent' : 'rofr_reminder',
          'assetId': offer.assetId,
          'assetTitle': offer.assetTitle,
          'timeRemainingHours': timeRemaining.inHours,
          'isUrgent': isUrgent,
          'shareholderOwnership': shareholder.ownershipPercentage,
        },
      );

      try {
        await _sendNotificationToShareholder(notification, shareholder);
        notifications.add(notification);
        debugPrint('Sent ${isUrgent ? 'urgent' : 'reminder'} notification to ${shareholder.email}');
      } catch (e) {
        debugPrint('Failed to send reminder to ${shareholder.email}: $e');
      }
    }

    return notifications;
  }

  /// Send response confirmation notifications
  static Future<RofrNotification?> sendResponseConfirmation({
    required RofrResponse response,
    required RofrOffer offer,
  }) async {
    try {
      // Find the shareholder who responded
      final shareholder = offer.eligibleShareholders
          .firstWhere((s) => s.userId == response.shareholderId);

      final isAcceptance = response.status == RofrStatus.accepted;
      final notification = RofrNotification(
        id: _generateNotificationId(),
        rofrOfferId: offer.id,
        recipientId: response.shareholderId,
        title: isAcceptance
            ? 'ROFR Response Received - Purchase Confirmed'
            : 'ROFR Response Received - Thank You',
        message: _buildResponseConfirmationMessage(response, offer, isAcceptance),
        sentDate: DateTime.now(),
        status: RofrNotificationStatus.sent,
        metadata: {
          'notificationType': 'rofr_response_confirmation',
          'responseType': response.status.name,
          'sharesRequested': response.sharesRequested,
          'totalAmount': response.totalAmount,
        },
      );

      await _sendNotificationToShareholder(notification, shareholder);
      debugPrint('Sent response confirmation to ${shareholder.email}');
      return notification;
    } catch (e) {
      debugPrint('Failed to send response confirmation: $e');
      return null;
    }
  }

  /// Send notifications to seller about shareholder responses
  static Future<RofrNotification?> sendSellerUpdate({
    required RofrOffer offer,
    required RofrResponse response,
    required ShareholderInfo seller,
  }) async {
    try {
      final isAcceptance = response.status == RofrStatus.accepted;
      final notification = RofrNotification(
        id: _generateNotificationId(),
        rofrOfferId: offer.id,
        recipientId: offer.sellerId,
        title: isAcceptance
            ? 'ROFR Acceptance Received - ${offer.assetTitle}'
            : 'ROFR Response Update - ${offer.assetTitle}',
        message: _buildSellerUpdateMessage(offer, response, isAcceptance),
        sentDate: DateTime.now(),
        status: RofrNotificationStatus.sent,
        metadata: {
          'notificationType': 'rofr_seller_update',
          'responseType': response.status.name,
          'respondentName': response.shareholderName,
          'sharesRequested': response.sharesRequested,
          'totalAmount': response.totalAmount,
        },
      );

      await _sendNotificationToShareholder(notification, seller);
      debugPrint('Sent seller update notification');
      return notification;
    } catch (e) {
      debugPrint('Failed to send seller update: $e');
      return null;
    }
  }

  /// Send expiry notifications
  static Future<List<RofrNotification>> sendExpiryNotifications({
    required RofrOffer offer,
    required ShareholderInfo seller,
  }) async {
    final notifications = <RofrNotification>[];

    // Notify seller about expiry and next steps
    final sellerNotification = RofrNotification(
      id: _generateNotificationId(),
      rofrOfferId: offer.id,
      recipientId: offer.sellerId,
      title: 'ROFR Period Expired - Proceeding to Market',
      message: _buildExpirySellerMessage(offer),
      sentDate: DateTime.now(),
      status: RofrNotificationStatus.sent,
      metadata: {
        'notificationType': 'rofr_expired_seller',
        'sharesRemaining': offer.sharesRemaining,
        'totalAcceptedShares': offer.sharesOffered - offer.sharesRemaining,
        'proceedingToMarket': offer.sharesRemaining > 0,
      },
    );

    try {
      await _sendNotificationToShareholder(sellerNotification, seller);
      notifications.add(sellerNotification);
    } catch (e) {
      debugPrint('Failed to send expiry notification to seller: $e');
    }

    // Notify unresponded shareholders about missed opportunity
    final unrespondedShareholders = offer.eligibleShareholders.where((shareholder) =>
        !offer.responses.any((response) => response.shareholderId == shareholder.userId)
    ).toList();

    for (final shareholder in unrespondedShareholders) {
      final notification = RofrNotification(
        id: _generateNotificationId(),
        rofrOfferId: offer.id,
        recipientId: shareholder.userId,
        title: 'ROFR Opportunity Expired - ${offer.assetTitle}',
        message: _buildExpiryShareholderMessage(offer),
        sentDate: DateTime.now(),
        status: RofrNotificationStatus.sent,
        metadata: {
          'notificationType': 'rofr_expired_shareholder',
          'sharesRemaining': offer.sharesRemaining,
          'availableOnMarket': offer.sharesRemaining > 0,
        },
      );

      try {
        await _sendNotificationToShareholder(notification, shareholder);
        notifications.add(notification);
      } catch (e) {
        debugPrint('Failed to send expiry notification to ${shareholder.email}: $e');
      }
    }

    return notifications;
  }

  /// Schedule reminder notifications
  static void scheduleReminders(RofrOffer offer) {
    final timeToExpiry = offer.timeRemaining;

    // Schedule reminder at 24 hours remaining
    if (timeToExpiry > const Duration(hours: 24)) {
      final reminderTime = offer.expiryDate.subtract(const Duration(hours: 24));
      _scheduleNotification(reminderTime, 'reminder_24h', offer.id);
    }

    // Schedule urgent reminder at 8 hours remaining
    if (timeToExpiry > _urgentThreshold) {
      final urgentTime = offer.expiryDate.subtract(_urgentThreshold);
      _scheduleNotification(urgentTime, 'urgent_8h', offer.id);
    }

    // Schedule final warning at 2 hours remaining
    if (timeToExpiry > const Duration(hours: 2)) {
      final finalTime = offer.expiryDate.subtract(const Duration(hours: 2));
      _scheduleNotification(finalTime, 'final_2h', offer.id);
    }
  }

  // Private helper methods
  static Future<void> _sendNotificationToShareholder(
    RofrNotification notification,
    ShareholderInfo shareholder,
  ) async {
    final notificationData = {
      ...notification.toJson(),
      'recipientEmail': shareholder.email,
      'recipientName': shareholder.name,
      'deliveryMethods': ['email', 'in_app', 'push'],
    };

    await ApiClient.sendRofrNotification(notificationData);
  }

  static String _buildInitialNotificationMessage(RofrOffer offer, ShareholderInfo shareholder) {
    final timeRemaining = offer.timeRemaining;
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes % 60;

    return '''
Dear ${shareholder.name},

${offer.sellerName} is offering to sell ${offer.sharesOffered} shares of ${offer.assetTitle} for \$${offer.pricePerShare.toStringAsFixed(2)} per share (Total: \$${offer.totalValue.toStringAsFixed(2)}).

As an existing shareholder with ${shareholder.sharesOwned} shares (${shareholder.ownershipPercentage.toStringAsFixed(1)}% ownership), you have the right of first refusal on this offer.

Time remaining to respond: ${hours}h ${minutes}m
Offer expires: ${_formatDateTime(offer.expiryDate)}

${offer.notes != null ? '\nSeller\'s note: ${offer.notes}' : ''}

Please respond through the app to accept or decline this opportunity.

Best regards,
RWA Platform Team
    '''.trim();
  }

  static String _buildReminderNotificationMessage(
    RofrOffer offer,
    ShareholderInfo shareholder,
    Duration timeRemaining,
  ) {
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes % 60;
    final isUrgent = timeRemaining <= _urgentThreshold;

    return '''
${isUrgent ? 'URGENT REMINDER: ' : 'Reminder: '}Your right of first refusal opportunity for ${offer.assetTitle} expires in ${hours}h ${minutes}m.

Offer Details:
- Shares offered: ${offer.sharesOffered}
- Price per share: \$${offer.pricePerShare.toStringAsFixed(2)}
- Total value: \$${offer.totalValue.toStringAsFixed(2)}
- Your current ownership: ${shareholder.ownershipPercentage.toStringAsFixed(1)}%

${isUrgent ? 'This is your final reminder. ' : ''}Please respond soon to secure your investment opportunity.
    '''.trim();
  }

  static String _buildResponseConfirmationMessage(RofrResponse response, RofrOffer offer, bool isAcceptance) {
    if (isAcceptance) {
      return '''
Thank you for your response! Your request to purchase ${response.sharesRequested} shares of ${offer.assetTitle} has been received.

Purchase Summary:
- Shares requested: ${response.sharesRequested}
- Price per share: \$${offer.pricePerShare.toStringAsFixed(2)}
- Total amount: \$${response.totalAmount.toStringAsFixed(2)}

${response.message != null ? 'Your message: "${response.message}"' : ''}

We will process your purchase and send you the transaction details shortly.
      '''.trim();
    } else {
      return '''
Thank you for your response. We have recorded that you are declining the ROFR offer for ${offer.assetTitle}.

${response.message != null ? 'Your message: "${response.message}"' : ''}

You will continue to receive notifications about future opportunities for this and other assets in your portfolio.
      '''.trim();
    }
  }

  static String _buildSellerUpdateMessage(RofrOffer offer, RofrResponse response, bool isAcceptance) {
    if (isAcceptance) {
      return '''
Great news! ${response.shareholderName} has accepted your ROFR offer for ${offer.assetTitle}.

Acceptance Details:
- Shares requested: ${response.sharesRequested}
- Total amount: \$${response.totalAmount.toStringAsFixed(2)}
- Remaining shares: ${offer.sharesOffered - response.sharesRequested}

${response.message != null ? 'Buyer\'s message: "${response.message}"' : ''}

We will initiate the transfer process and send you further instructions.
      '''.trim();
    } else {
      return '''
${response.shareholderName} has declined your ROFR offer for ${offer.assetTitle}.

${response.message != null ? 'Their message: "${response.message}"' : ''}

Your offer remains active for other eligible shareholders until ${_formatDateTime(offer.expiryDate)}.
      '''.trim();
    }
  }

  static String _buildExpirySellerMessage(RofrOffer offer) {
    final acceptedShares = offer.sharesOffered - offer.sharesRemaining;

    if (offer.sharesRemaining == 0) {
      return '''
Your ROFR offer for ${offer.assetTitle} has been fully accepted by existing shareholders.

Final Summary:
- Total shares sold: ${offer.sharesOffered}
- Total value: \$${offer.totalValue.toStringAsFixed(2)}

All shares have been allocated and we will process the transfers shortly.
      '''.trim();
    } else {
      return '''
Your ROFR period for ${offer.assetTitle} has expired.

Summary:
- Shares accepted by shareholders: $acceptedShares
- Remaining shares: ${offer.sharesRemaining}
- Value of remaining shares: \$${(offer.sharesRemaining * offer.pricePerShare).toStringAsFixed(2)}

The remaining ${offer.sharesRemaining} shares will now be listed on the public marketplace at your specified price of \$${offer.pricePerShare.toStringAsFixed(2)} per share.
      '''.trim();
    }
  }

  static String _buildExpiryShareholderMessage(RofrOffer offer) {
    if (offer.sharesRemaining > 0) {
      return '''
The ROFR period for ${offer.assetTitle} has expired.

${offer.sharesRemaining} shares are now available on the public marketplace at \$${offer.pricePerShare.toStringAsFixed(2)} per share.

You can still purchase these shares through the marketplace, but they will be available to all investors, not just existing shareholders.
      '''.trim();
    } else {
      return '''
The ROFR period for ${offer.assetTitle} has expired and all shares have been purchased by existing shareholders.

Keep an eye out for future opportunities in your portfolio assets.
      '''.trim();
    }
  }

  static String _generateNotificationId() {
    return 'rofr_notif_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static void _scheduleNotification(DateTime when, String type, String offerId) {
    // In a real implementation, this would use a proper scheduling service
    // For now, this is a placeholder that would integrate with:
    // - Firebase Cloud Messaging for push notifications
    // - A backend job queue for email notifications
    // - Local notifications for in-app reminders
    debugPrint('Scheduled $type notification for offer $offerId at $when');
  }
}