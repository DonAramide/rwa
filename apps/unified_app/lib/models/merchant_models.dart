class MerchantCategories {
  static const List<String> allCategories = [
    'Real Estate',
    'Technology',
    'Energy',
    'Infrastructure',
    'Healthcare',
    'Finance',
    'Agriculture',
    'Manufacturing',
    'Retail',
    'Transportation',
    'Entertainment',
    'Education',
    'Hospitality',
    'Telecommunications',
    'Utilities',
  ];

  static const Map<String, String> categoryDescriptions = {
    'Real Estate': 'Property investments and development projects',
    'Technology': 'Tech startups, software and hardware companies',
    'Energy': 'Renewable energy, oil & gas, and utility projects',
    'Infrastructure': 'Transportation, bridges, ports, and public works',
    'Healthcare': 'Medical facilities, pharmaceutical, and health tech',
    'Finance': 'Financial services, fintech, and banking',
    'Agriculture': 'Farming, food production, and agribusiness',
    'Manufacturing': 'Industrial production and manufacturing facilities',
    'Retail': 'Shopping centers, e-commerce, and retail chains',
    'Transportation': 'Logistics, shipping, and transportation services',
    'Entertainment': 'Media, gaming, sports, and entertainment venues',
    'Education': 'Schools, universities, and educational technology',
    'Hospitality': 'Hotels, restaurants, and tourism',
    'Telecommunications': 'Telecom infrastructure and services',
    'Utilities': 'Water, gas, electricity, and waste management',
  };
}

class MerchantProfile {
  final String id;
  final String name;
  final String legalName;
  final String registrationNumber;
  final String country;
  final String domain;
  final String? subdomain;
  final String status;
  final int commissionRateBps;
  final int revenueShareBps;
  final DateTime contractStartDate;
  final DateTime? contractEndDate;
  final String? description;
  final MerchantContactInfo? contactInfo;
  final MerchantBranding? branding;
  final MerchantPortalInfo? portalInfo;
  final List<String> categories;
  final double? totalRevenue;
  final int? totalUsers;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantProfile({
    required this.id,
    required this.name,
    required this.legalName,
    required this.registrationNumber,
    required this.country,
    required this.domain,
    this.subdomain,
    required this.status,
    required this.commissionRateBps,
    required this.revenueShareBps,
    required this.contractStartDate,
    this.contractEndDate,
    this.description,
    this.contactInfo,
    this.branding,
    this.portalInfo,
    this.categories = const [],
    this.totalRevenue,
    this.totalUsers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantProfile.fromJson(Map<String, dynamic> json) {
    return MerchantProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      legalName: json['legalName'] as String,
      registrationNumber: json['registrationNumber'] as String,
      country: json['country'] as String,
      domain: json['domain'] as String,
      subdomain: json['subdomain'] as String?,
      status: json['status'] as String,
      commissionRateBps: json['commissionRateBps'] as int,
      revenueShareBps: json['revenueShareBps'] as int,
      contractStartDate: DateTime.parse(json['contractStartDate'] as String),
      contractEndDate: json['contractEndDate'] != null
          ? DateTime.parse(json['contractEndDate'] as String)
          : null,
      description: json['description'] as String?,
      contactInfo: json['contactInfo'] != null
          ? MerchantContactInfo.fromJson(json['contactInfo'] as Map<String, dynamic>)
          : null,
      branding: json['branding'] != null
          ? MerchantBranding.fromJson(json['branding'] as Map<String, dynamic>)
          : null,
      portalInfo: json['portalInfo'] != null
          ? MerchantPortalInfo.fromJson(json['portalInfo'] as Map<String, dynamic>)
          : null,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'] as List<dynamic>)
          : [],
      totalRevenue: json['totalRevenue'] != null
          ? (json['totalRevenue'] as num).toDouble()
          : null,
      totalUsers: json['totalUsers'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'legalName': legalName,
      'registrationNumber': registrationNumber,
      'country': country,
      'domain': domain,
      'subdomain': subdomain,
      'status': status,
      'commissionRateBps': commissionRateBps,
      'revenueShareBps': revenueShareBps,
      'contractStartDate': contractStartDate.toIso8601String(),
      'contractEndDate': contractEndDate?.toIso8601String(),
      'description': description,
      'contactInfo': contactInfo?.toJson(),
      'branding': branding?.toJson(),
      'portalInfo': portalInfo?.toJson(),
      'categories': categories,
      'totalRevenue': totalRevenue,
      'totalUsers': totalUsers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class MerchantContactInfo {
  final String primaryContact;
  final String email;
  final String phone;
  final String address;

  const MerchantContactInfo({
    required this.primaryContact,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory MerchantContactInfo.fromJson(Map<String, dynamic> json) {
    return MerchantContactInfo(
      primaryContact: json['primaryContact'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryContact': primaryContact,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}

class MerchantBranding {
  final String? logoUrl;
  final String? faviconUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final Map<String, dynamic>? themeConfig;
  final String? customDomain;
  final Map<String, dynamic>? customCss;
  final Map<String, dynamic>? emailTemplates;

  const MerchantBranding({
    this.logoUrl,
    this.faviconUrl,
    this.primaryColor,
    this.secondaryColor,
    this.themeConfig,
    this.customDomain,
    this.customCss,
    this.emailTemplates,
  });

  factory MerchantBranding.fromJson(Map<String, dynamic> json) {
    return MerchantBranding(
      logoUrl: json['logoUrl'] as String?,
      faviconUrl: json['faviconUrl'] as String?,
      primaryColor: json['primaryColor'] as String?,
      secondaryColor: json['secondaryColor'] as String?,
      themeConfig: json['themeConfig'] as Map<String, dynamic>?,
      customDomain: json['customDomain'] as String?,
      customCss: json['customCss'] as Map<String, dynamic>?,
      emailTemplates: json['emailTemplates'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logoUrl': logoUrl,
      'faviconUrl': faviconUrl,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'themeConfig': themeConfig,
      'customDomain': customDomain,
      'customCss': customCss,
      'emailTemplates': emailTemplates,
    };
  }
}

class MerchantPortalInfo {
  final String? portalUrl;
  final String? ipAddress;
  final int? port;
  final String? environment; // 'production', 'staging', 'development'
  final bool isActive;
  final DateTime? lastHealthCheck;
  final Map<String, dynamic>? healthStatus;

  const MerchantPortalInfo({
    this.portalUrl,
    this.ipAddress,
    this.port,
    this.environment,
    this.isActive = true,
    this.lastHealthCheck,
    this.healthStatus,
  });

  factory MerchantPortalInfo.fromJson(Map<String, dynamic> json) {
    return MerchantPortalInfo(
      portalUrl: json['portalUrl'] as String?,
      ipAddress: json['ipAddress'] as String?,
      port: json['port'] as int?,
      environment: json['environment'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastHealthCheck: json['lastHealthCheck'] != null
          ? DateTime.parse(json['lastHealthCheck'] as String)
          : null,
      healthStatus: json['healthStatus'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portalUrl': portalUrl,
      'ipAddress': ipAddress,
      'port': port,
      'environment': environment,
      'isActive': isActive,
      'lastHealthCheck': lastHealthCheck?.toIso8601String(),
      'healthStatus': healthStatus,
    };
  }
}

class MerchantDashboardAnalytics {
  final double totalAum;
  final int activeInvestors;
  final int pendingApprovals;
  final double revenueEarned;
  final int totalAssets;
  final double totalInvestments;
  final int completedTransactions;
  final Map<String, double> revenueBreakdown;
  final List<MerchantMetric> metrics;

  MerchantDashboardAnalytics({
    required this.totalAum,
    required this.activeInvestors,
    required this.pendingApprovals,
    required this.revenueEarned,
    required this.totalAssets,
    required this.totalInvestments,
    required this.completedTransactions,
    required this.revenueBreakdown,
    required this.metrics,
  });

  factory MerchantDashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return MerchantDashboardAnalytics(
      totalAum: (json['totalAum'] as num).toDouble(),
      activeInvestors: json['activeInvestors'] as int,
      pendingApprovals: json['pendingApprovals'] as int,
      revenueEarned: (json['revenueEarned'] as num).toDouble(),
      totalAssets: json['totalAssets'] as int,
      totalInvestments: (json['totalInvestments'] as num).toDouble(),
      completedTransactions: json['completedTransactions'] as int,
      revenueBreakdown: Map<String, double>.from(
        (json['revenueBreakdown'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      metrics: (json['metrics'] as List<dynamic>)
          .map((item) => MerchantMetric.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MerchantMetric {
  final String label;
  final double value;
  final String unit;
  final double? changePercent;
  final String? trend;

  MerchantMetric({
    required this.label,
    required this.value,
    required this.unit,
    this.changePercent,
    this.trend,
  });

  factory MerchantMetric.fromJson(Map<String, dynamic> json) {
    return MerchantMetric(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      changePercent: json['changePercent'] != null
          ? (json['changePercent'] as num).toDouble()
          : null,
      trend: json['trend'] as String?,
    );
  }
}

class MerchantCustomer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String kycStatus;
  final double totalInvestments;
  final int activeAssets;
  final DateTime joinedDate;
  final DateTime? lastActivity;
  final String riskLevel;

  MerchantCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.kycStatus,
    required this.totalInvestments,
    required this.activeAssets,
    required this.joinedDate,
    this.lastActivity,
    required this.riskLevel,
  });

  factory MerchantCustomer.fromJson(Map<String, dynamic> json) {
    return MerchantCustomer(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      kycStatus: json['kycStatus'] as String,
      totalInvestments: (json['totalInvestments'] as num).toDouble(),
      activeAssets: json['activeAssets'] as int,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : null,
      riskLevel: json['riskLevel'] as String,
    );
  }

  String get fullName => '$firstName $lastName';
}

class MerchantTransaction {
  final String id;
  final String customerId;
  final String assetId;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? txHash;
  final double? commission;

  MerchantTransaction({
    required this.id,
    required this.customerId,
    required this.assetId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.txHash,
    this.commission,
  });

  factory MerchantTransaction.fromJson(Map<String, dynamic> json) {
    return MerchantTransaction(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      assetId: json['assetId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      txHash: json['txHash'] as String?,
      commission: json['commission'] != null
          ? (json['commission'] as num).toDouble()
          : null,
    );
  }
}

class MerchantAssetProposal {
  final String id;
  final String proposerType;
  final String proposerId;
  final String merchantId;
  final Map<String, dynamic> assetDetails;
  final List<String> documents;
  final String status;
  final String? masterAdminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantAssetProposal({
    required this.id,
    required this.proposerType,
    required this.proposerId,
    required this.merchantId,
    required this.assetDetails,
    required this.documents,
    required this.status,
    this.masterAdminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantAssetProposal.fromJson(Map<String, dynamic> json) {
    return MerchantAssetProposal(
      id: json['id'] as String,
      proposerType: json['proposerType'] as String,
      proposerId: json['proposerId'] as String,
      merchantId: json['merchantId'] as String,
      assetDetails: json['assetDetails'] as Map<String, dynamic>,
      documents: List<String>.from(json['documents'] as List<dynamic>),
      status: json['status'] as String,
      masterAdminNotes: json['masterAdminNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class MerchantSettlement {
  final String id;
  final String merchantId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalVolume;
  final double commissionEarned;
  final double revenueShare;
  final double netPayout;
  final String status;
  final DateTime? settlementDate;
  final String? txHash;
  final DateTime createdAt;

  MerchantSettlement({
    required this.id,
    required this.merchantId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalVolume,
    required this.commissionEarned,
    required this.revenueShare,
    required this.netPayout,
    required this.status,
    this.settlementDate,
    this.txHash,
    required this.createdAt,
  });

  factory MerchantSettlement.fromJson(Map<String, dynamic> json) {
    return MerchantSettlement(
      id: json['id'] as String,
      merchantId: json['merchantId'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalVolume: (json['totalVolume'] as num).toDouble(),
      commissionEarned: (json['commissionEarned'] as num).toDouble(),
      revenueShare: (json['revenueShare'] as num).toDouble(),
      netPayout: (json['netPayout'] as num).toDouble(),
      status: json['status'] as String,
      settlementDate: json['settlementDate'] != null
          ? DateTime.parse(json['settlementDate'] as String)
          : null,
      txHash: json['txHash'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AdminNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'alert', 'announcement'
  final List<String> targetAudience; // 'merchants', 'investors', 'agents', 'all'
  final String? specificMerchantId; // For merchant-specific notifications
  final String? linkUrl;
  final String? imageUrl;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final bool isRead;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String createdBy; // Admin ID who created the notification

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.targetAudience,
    this.specificMerchantId,
    this.linkUrl,
    this.imageUrl,
    this.priority = 'medium',
    this.isRead = false,
    required this.createdAt,
    this.expiresAt,
    required this.createdBy,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      targetAudience: List<String>.from(json['targetAudience'] as List<dynamic>),
      specificMerchantId: json['specificMerchantId'] as String?,
      linkUrl: json['linkUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'targetAudience': targetAudience,
      'specificMerchantId': specificMerchantId,
      'linkUrl': linkUrl,
      'imageUrl': imageUrl,
      'priority': priority,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}

class MerchantMessage {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserRole; // 'super_admin', 'merchant_admin', 'agent'
  final String? toMerchantId;
  final String? toUserId;
  final String subject;
  final String message;
  final List<String> attachments;
  final String status; // 'sent', 'delivered', 'read'
  final DateTime createdAt;
  final DateTime? readAt;
  final String? parentMessageId; // For reply threads

  MerchantMessage({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserRole,
    this.toMerchantId,
    this.toUserId,
    required this.subject,
    required this.message,
    this.attachments = const [],
    this.status = 'sent',
    required this.createdAt,
    this.readAt,
    this.parentMessageId,
  });

  factory MerchantMessage.fromJson(Map<String, dynamic> json) {
    return MerchantMessage(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromUserRole: json['fromUserRole'] as String,
      toMerchantId: json['toMerchantId'] as String?,
      toUserId: json['toUserId'] as String?,
      subject: json['subject'] as String,
      message: json['message'] as String,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List<dynamic>)
          : [],
      status: json['status'] as String? ?? 'sent',
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      parentMessageId: json['parentMessageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserRole': fromUserRole,
      'toMerchantId': toMerchantId,
      'toUserId': toUserId,
      'subject': subject,
      'message': message,
      'attachments': attachments,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'parentMessageId': parentMessageId,
    };
  }
}