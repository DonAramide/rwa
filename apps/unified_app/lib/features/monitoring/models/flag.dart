// import 'package:json_annotation/json_annotation.dart';

// part 'flag.g.dart';

enum FlagType {
  
  suspiciousActivity,
  
  documentDiscrepancy,
  
  financialIrregularity,
  
  milestoneDelay,
  
  communicationIssue,
  
  legalConcern,
  
  other,
}

enum FlagStatus {
  
  pending,
  
  underReview,
  
  resolved,
  
  dismissed,
  
  escalated,
}

enum FlagSeverity {
  
  low,
  
  medium,
  
  high,
  
  critical,
}

enum VoteType {
  
  upvote,
  
  downvote,
}


class Flag {
  final int id;
  final FlagType type;
  final FlagStatus status;
  final FlagSeverity severity;
  final String title;
  final String description;
  final Map<String, dynamic>? evidence;
  
  final String? adminNotes;
  
  final String? resolutionNotes;
  
  final bool isAnonymous;
  final int upvotes;
  final int downvotes;
  
  final int assetId;
  
  final int flaggerId;
  
  final int? assignedAdminId;
  
  final DateTime createdAt;
  
  final DateTime updatedAt;

  const Flag({
    required this.id,
    required this.type,
    required this.status,
    required this.severity,
    required this.title,
    required this.description,
    this.evidence,
    this.adminNotes,
    this.resolutionNotes,
    required this.isAnonymous,
    required this.upvotes,
    required this.downvotes,
    required this.assetId,
    required this.flaggerId,
    this.assignedAdminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Flag.fromJson(Map<String, dynamic> json) => Flag(
    id: json['id'],
    type: FlagType.values.firstWhere((e) => e.name == json['type']),
    status: FlagStatus.values.firstWhere((e) => e.name == json['status']),
    severity: FlagSeverity.values.firstWhere((e) => e.name == json['severity']),
    title: json['title'],
    description: json['description'],
    evidence: json['evidence'],
    adminNotes: json['admin_notes'],
    resolutionNotes: json['resolution_notes'],
    isAnonymous: json['is_anonymous'],
    upvotes: json['upvotes'],
    downvotes: json['downvotes'],
    assetId: json['asset_id'],
    flaggerId: json['flagger_id'],
    assignedAdminId: json['assigned_admin_id'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'status': status.name,
    'severity': severity.name,
    'title': title,
    'description': description,
    'evidence': evidence,
    'admin_notes': adminNotes,
    'resolution_notes': resolutionNotes,
    'is_anonymous': isAnonymous,
    'upvotes': upvotes,
    'downvotes': downvotes,
    'asset_id': assetId,
    'flagger_id': flaggerId,
    'assigned_admin_id': assignedAdminId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  int get totalVotes => upvotes + downvotes;

  double get upvoteRatio => totalVotes > 0 ? upvotes / totalVotes : 0.0;

  String get typeDisplayName {
    switch (type) {
      case FlagType.suspiciousActivity:
        return 'Suspicious Activity';
      case FlagType.documentDiscrepancy:
        return 'Document Issue';
      case FlagType.financialIrregularity:
        return 'Financial Issue';
      case FlagType.milestoneDelay:
        return 'Milestone Delay';
      case FlagType.communicationIssue:
        return 'Communication Problem';
      case FlagType.legalConcern:
        return 'Legal Concern';
      case FlagType.other:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case FlagStatus.pending:
        return 'Pending Review';
      case FlagStatus.underReview:
        return 'Under Review';
      case FlagStatus.resolved:
        return 'Resolved';
      case FlagStatus.dismissed:
        return 'Dismissed';
      case FlagStatus.escalated:
        return 'Escalated';
    }
  }

  String get severityDisplayName {
    switch (severity) {
      case FlagSeverity.low:
        return 'Low';
      case FlagSeverity.medium:
        return 'Medium';
      case FlagSeverity.high:
        return 'High';
      case FlagSeverity.critical:
        return 'Critical';
    }
  }
}


class CreateFlagRequest {
  
  final int assetId;
  final FlagType type;
  final FlagSeverity severity;
  final String title;
  final String description;
  final Map<String, dynamic>? evidence;
  
  final bool isAnonymous;

  const CreateFlagRequest({
    required this.assetId,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    this.evidence,
    this.isAnonymous = false,
  });

  factory CreateFlagRequest.fromJson(Map<String, dynamic> json) => CreateFlagRequest(
    assetId: json['asset_id'],
    type: FlagType.values.firstWhere((e) => e.name == json['type']),
    severity: FlagSeverity.values.firstWhere((e) => e.name == json['severity']),
    title: json['title'],
    description: json['description'],
    evidence: json['evidence'],
    isAnonymous: json['is_anonymous'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'asset_id': assetId,
    'type': type.name,
    'severity': severity.name,
    'title': title,
    'description': description,
    'evidence': evidence,
    'is_anonymous': isAnonymous,
  };
}


class FlagResponse {
  final List<Flag> flags;
  final int total;

  const FlagResponse({
    required this.flags,
    required this.total,
  });

  factory FlagResponse.fromJson(Map<String, dynamic> json) => FlagResponse(
    flags: (json['flags'] as List).map((e) => Flag.fromJson(e)).toList(),
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'flags': flags.map((e) => e.toJson()).toList(),
    'total': total,
  };
}


class InvestorAgentStats {
  
  final int totalFlags;
  
  final int resolvedFlags;
  
  final double accuracyRate;
  
  final int reputationScore;
  
  final int totalUpvotes;
  
  final int totalDownvotes;

  const InvestorAgentStats({
    required this.totalFlags,
    required this.resolvedFlags,
    required this.accuracyRate,
    required this.reputationScore,
    required this.totalUpvotes,
    required this.totalDownvotes,
  });

  factory InvestorAgentStats.fromJson(Map<String, dynamic> json) => InvestorAgentStats(
    totalFlags: json['total_flags'],
    resolvedFlags: json['resolved_flags'],
    accuracyRate: json['accuracy_rate']?.toDouble() ?? 0.0,
    reputationScore: json['reputation_score'],
    totalUpvotes: json['total_upvotes'],
    totalDownvotes: json['total_downvotes'],
  );

  Map<String, dynamic> toJson() => {
    'total_flags': totalFlags,
    'resolved_flags': resolvedFlags,
    'accuracy_rate': accuracyRate,
    'reputation_score': reputationScore,
    'total_upvotes': totalUpvotes,
    'total_downvotes': totalDownvotes,
  };
}