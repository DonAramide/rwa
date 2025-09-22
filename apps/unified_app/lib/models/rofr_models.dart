import 'user_role.dart';

enum RofrStatus {
  pending,
  accepted,
  rejected,
  expired,
  completed,
}

enum RofrNotificationStatus {
  sent,
  delivered,
  read,
  responded,
}

class ShareholderInfo {
  final String userId;
  final String email;
  final String name;
  final int sharesOwned;
  final double ownershipPercentage;
  final DateTime purchaseDate;
  final bool isEligibleForRofr;

  const ShareholderInfo({
    required this.userId,
    required this.email,
    required this.name,
    required this.sharesOwned,
    required this.ownershipPercentage,
    required this.purchaseDate,
    this.isEligibleForRofr = true,
  });

  factory ShareholderInfo.fromJson(Map<String, dynamic> json) {
    return ShareholderInfo(
      userId: json['userId'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      sharesOwned: json['sharesOwned'] as int,
      ownershipPercentage: (json['ownershipPercentage'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      isEligibleForRofr: json['isEligibleForRofr'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'sharesOwned': sharesOwned,
      'ownershipPercentage': ownershipPercentage,
      'purchaseDate': purchaseDate.toIso8601String(),
      'isEligibleForRofr': isEligibleForRofr,
    };
  }
}

class RofrOffer {
  final String id;
  final String assetId;
  final String assetTitle;
  final String sellerId;
  final String sellerName;
  final int sharesOffered;
  final double pricePerShare;
  final double totalValue;
  final DateTime offerDate;
  final DateTime expiryDate;
  final RofrStatus status;
  final List<ShareholderInfo> eligibleShareholders;
  final List<RofrResponse> responses;
  final String? notes;

  const RofrOffer({
    required this.id,
    required this.assetId,
    required this.assetTitle,
    required this.sellerId,
    required this.sellerName,
    required this.sharesOffered,
    required this.pricePerShare,
    required this.totalValue,
    required this.offerDate,
    required this.expiryDate,
    required this.status,
    required this.eligibleShareholders,
    required this.responses,
    this.notes,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  Duration get timeRemaining => isExpired
    ? Duration.zero
    : expiryDate.difference(DateTime.now());

  int get sharesRemaining {
    final acceptedShares = responses
        .where((r) => r.status == RofrStatus.accepted)
        .fold(0, (sum, r) => sum + r.sharesRequested);
    return sharesOffered - acceptedShares;
  }

  factory RofrOffer.fromJson(Map<String, dynamic> json) {
    return RofrOffer(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      assetTitle: json['assetTitle'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      sharesOffered: json['sharesOffered'] as int,
      pricePerShare: (json['pricePerShare'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      offerDate: DateTime.parse(json['offerDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      status: RofrStatus.values.byName(json['status'] as String),
      eligibleShareholders: (json['eligibleShareholders'] as List)
          .map((s) => ShareholderInfo.fromJson(s))
          .toList(),
      responses: (json['responses'] as List)
          .map((r) => RofrResponse.fromJson(r))
          .toList(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'assetTitle': assetTitle,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sharesOffered': sharesOffered,
      'pricePerShare': pricePerShare,
      'totalValue': totalValue,
      'offerDate': offerDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status.name,
      'eligibleShareholders': eligibleShareholders.map((s) => s.toJson()).toList(),
      'responses': responses.map((r) => r.toJson()).toList(),
      'notes': notes,
    };
  }
}

class RofrResponse {
  final String id;
  final String rofrOfferId;
  final String shareholderId;
  final String shareholderName;
  final RofrStatus status;
  final int sharesRequested;
  final double totalAmount;
  final DateTime responseDate;
  final String? message;
  final RofrNotificationStatus notificationStatus;

  const RofrResponse({
    required this.id,
    required this.rofrOfferId,
    required this.shareholderId,
    required this.shareholderName,
    required this.status,
    required this.sharesRequested,
    required this.totalAmount,
    required this.responseDate,
    this.message,
    this.notificationStatus = RofrNotificationStatus.sent,
  });

  factory RofrResponse.fromJson(Map<String, dynamic> json) {
    return RofrResponse(
      id: json['id'] as String,
      rofrOfferId: json['rofrOfferId'] as String,
      shareholderId: json['shareholderId'] as String,
      shareholderName: json['shareholderName'] as String,
      status: RofrStatus.values.byName(json['status'] as String),
      sharesRequested: json['sharesRequested'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      responseDate: DateTime.parse(json['responseDate'] as String),
      message: json['message'] as String?,
      notificationStatus: RofrNotificationStatus.values
          .byName(json['notificationStatus'] as String? ?? 'sent'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rofrOfferId': rofrOfferId,
      'shareholderId': shareholderId,
      'shareholderName': shareholderName,
      'status': status.name,
      'sharesRequested': sharesRequested,
      'totalAmount': totalAmount,
      'responseDate': responseDate.toIso8601String(),
      'message': message,
      'notificationStatus': notificationStatus.name,
    };
  }
}

class RofrNotification {
  final String id;
  final String rofrOfferId;
  final String recipientId;
  final String title;
  final String message;
  final DateTime sentDate;
  final DateTime? readDate;
  final RofrNotificationStatus status;
  final Map<String, dynamic> metadata;

  const RofrNotification({
    required this.id,
    required this.rofrOfferId,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.sentDate,
    this.readDate,
    this.status = RofrNotificationStatus.sent,
    this.metadata = const {},
  });

  bool get isRead => readDate != null;

  factory RofrNotification.fromJson(Map<String, dynamic> json) {
    return RofrNotification(
      id: json['id'] as String,
      rofrOfferId: json['rofrOfferId'] as String,
      recipientId: json['recipientId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      sentDate: DateTime.parse(json['sentDate'] as String),
      readDate: json['readDate'] != null
        ? DateTime.parse(json['readDate'] as String)
        : null,
      status: RofrNotificationStatus.values
          .byName(json['status'] as String? ?? 'sent'),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rofrOfferId': rofrOfferId,
      'recipientId': recipientId,
      'title': title,
      'message': message,
      'sentDate': sentDate.toIso8601String(),
      'readDate': readDate?.toIso8601String(),
      'status': status.name,
      'metadata': metadata,
    };
  }
}