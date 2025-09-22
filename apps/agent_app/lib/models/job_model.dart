class JobModel {
  final String id;
  final String assetId;
  final String assetTitle;
  final String assetType;
  final String? assetDescription;
  final String investorId;
  final String? agentId;
  final String status;
  final double price;
  final String currency;
  final String? requirements;
  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final List<String> mediaUrls;
  final Map<String, dynamic>? reportData;

  JobModel({
    required this.id,
    required this.assetId,
    required this.assetTitle,
    required this.assetType,
    this.assetDescription,
    required this.investorId,
    this.agentId,
    required this.status,
    required this.price,
    required this.currency,
    this.requirements,
    this.latitude,
    this.longitude,
    this.address,
    required this.deadline,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    required this.mediaUrls,
    this.reportData,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'].toString(),
      assetId: json['asset_id'].toString(),
      assetTitle: json['asset_title'] ?? '',
      assetType: json['asset_type'] ?? '',
      assetDescription: json['asset_description'],
      investorId: json['investor_id'].toString(),
      agentId: json['agent_id']?.toString(),
      status: json['status'] ?? 'open',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      requirements: json['requirements'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      deadline: DateTime.parse(json['deadline']),
      createdAt: DateTime.parse(json['created_at']),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      reportData: json['report_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'asset_title': assetTitle,
      'asset_type': assetType,
      'asset_description': assetDescription,
      'investor_id': investorId,
      'agent_id': agentId,
      'status': status,
      'price': price,
      'currency': currency,
      'requirements': requirements,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'deadline': deadline.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'media_urls': mediaUrls,
      'report_data': reportData,
    };
  }

  JobModel copyWith({
    String? id,
    String? assetId,
    String? assetTitle,
    String? assetType,
    String? assetDescription,
    String? investorId,
    String? agentId,
    String? status,
    double? price,
    String? currency,
    String? requirements,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    List<String>? mediaUrls,
    Map<String, dynamic>? reportData,
  }) {
    return JobModel(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      assetTitle: assetTitle ?? this.assetTitle,
      assetType: assetType ?? this.assetType,
      assetDescription: assetDescription ?? this.assetDescription,
      investorId: investorId ?? this.investorId,
      agentId: agentId ?? this.agentId,
      status: status ?? this.status,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      requirements: requirements ?? this.requirements,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      reportData: reportData ?? this.reportData,
    );
  }

  bool get isOpen => status == 'open';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  bool get hasLocation => latitude != null && longitude != null;
  
  Duration get timeUntilDeadline => deadline.difference(DateTime.now());
  bool get isOverdue => DateTime.now().isAfter(deadline);
  
  String get formattedPrice => '\$$price $currency';
}