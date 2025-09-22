class AssetVerification {
  final String id;
  final String assetId;
  final String investorId;
  final AssetVerificationType type;
  final AssetVerificationStatus status;
  final List<String> proofPhotos;
  final List<String> proofVideos;
  final String? notes;
  final String? agentId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? rejectionReason;

  AssetVerification({
    required this.id,
    required this.assetId,
    required this.investorId,
    required this.type,
    required this.status,
    this.proofPhotos = const [],
    this.proofVideos = const [],
    this.notes,
    this.agentId,
    required this.createdAt,
    this.completedAt,
    this.rejectionReason,
  });

  factory AssetVerification.fromJson(Map<String, dynamic> json) {
    return AssetVerification(
      id: json['id'],
      assetId: json['assetId'],
      investorId: json['investorId'],
      type: AssetVerificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: AssetVerificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      proofPhotos: List<String>.from(json['proofPhotos'] ?? []),
      proofVideos: List<String>.from(json['proofVideos'] ?? []),
      notes: json['notes'],
      agentId: json['agentId'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'investorId': investorId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'proofPhotos': proofPhotos,
      'proofVideos': proofVideos,
      'notes': notes,
      'agentId': agentId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }
}

enum AssetVerificationType {
  selfVerification,
  professionalAgent,
  verificationAgent,
}

enum AssetVerificationStatus {
  pending,
  inProgress,
  completed,
  rejected,
}

extension AssetVerificationTypeExtension on AssetVerificationType {
  String get displayName {
    switch (this) {
      case AssetVerificationType.selfVerification:
        return 'Self Verification';
      case AssetVerificationType.professionalAgent:
        return 'Professional Agent';
      case AssetVerificationType.verificationAgent:
        return 'Verification Agent';
    }
  }

  String get description {
    switch (this) {
      case AssetVerificationType.selfVerification:
        return 'Upload photos/videos yourself as proof of asset inspection';
      case AssetVerificationType.professionalAgent:
        return 'Hire a professional agent to inspect and verify the asset';
      case AssetVerificationType.verificationAgent:
        return 'Use our certified verification agent for inspection';
    }
  }
}

extension AssetVerificationStatusExtension on AssetVerificationStatus {
  String get displayName {
    switch (this) {
      case AssetVerificationStatus.pending:
        return 'Pending';
      case AssetVerificationStatus.inProgress:
        return 'In Progress';
      case AssetVerificationStatus.completed:
        return 'Completed';
      case AssetVerificationStatus.rejected:
        return 'Rejected';
    }
  }

  String get color {
    switch (this) {
      case AssetVerificationStatus.pending:
        return 'warning';
      case AssetVerificationStatus.inProgress:
        return 'info';
      case AssetVerificationStatus.completed:
        return 'success';
      case AssetVerificationStatus.rejected:
        return 'error';
    }
  }
}