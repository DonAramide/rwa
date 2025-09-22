import 'package:json_annotation/json_annotation.dart';

part 'flag.g.dart';

enum FlagType {
  @JsonValue('suspicious_activity')
  suspiciousActivity,
  @JsonValue('document_discrepancy')
  documentDiscrepancy,
  @JsonValue('financial_irregularity')
  financialIrregularity,
  @JsonValue('milestone_delay')
  milestoneDelay,
  @JsonValue('communication_issue')
  communicationIssue,
  @JsonValue('legal_concern')
  legalConcern,
  @JsonValue('other')
  other,
}

enum FlagStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('under_review')
  underReview,
  @JsonValue('resolved')
  resolved,
  @JsonValue('dismissed')
  dismissed,
  @JsonValue('escalated')
  escalated,
}

enum FlagSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum VoteType {
  @JsonValue('upvote')
  upvote,
  @JsonValue('downvote')
  downvote,
}

@JsonSerializable()
class Flag {
  final int id;
  final FlagType type;
  final FlagStatus status;
  final FlagSeverity severity;
  final String title;
  final String description;
  final Map<String, dynamic>? evidence;
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  @JsonKey(name: 'resolution_notes')
  final String? resolutionNotes;
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;
  final int upvotes;
  final int downvotes;
  @JsonKey(name: 'asset_id')
  final int assetId;
  @JsonKey(name: 'flagger_id')
  final int flaggerId;
  @JsonKey(name: 'assigned_admin_id')
  final int? assignedAdminId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
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

  factory Flag.fromJson(Map<String, dynamic> json) => _$FlagFromJson(json);
  Map<String, dynamic> toJson() => _$FlagToJson(this);

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

@JsonSerializable()
class CreateFlagRequest {
  @JsonKey(name: 'asset_id')
  final int assetId;
  final FlagType type;
  final FlagSeverity severity;
  final String title;
  final String description;
  final Map<String, dynamic>? evidence;
  @JsonKey(name: 'is_anonymous')
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

  factory CreateFlagRequest.fromJson(Map<String, dynamic> json) => _$CreateFlagRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateFlagRequestToJson(this);
}

@JsonSerializable()
class FlagResponse {
  final List<Flag> flags;
  final int total;

  const FlagResponse({
    required this.flags,
    required this.total,
  });

  factory FlagResponse.fromJson(Map<String, dynamic> json) => _$FlagResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FlagResponseToJson(this);
}

@JsonSerializable()
class InvestorAgentStats {
  @JsonKey(name: 'total_flags')
  final int totalFlags;
  @JsonKey(name: 'resolved_flags')
  final int resolvedFlags;
  @JsonKey(name: 'accuracy_rate')
  final double accuracyRate;
  @JsonKey(name: 'reputation_score')
  final int reputationScore;
  @JsonKey(name: 'total_upvotes')
  final int totalUpvotes;
  @JsonKey(name: 'total_downvotes')
  final int totalDownvotes;

  const InvestorAgentStats({
    required this.totalFlags,
    required this.resolvedFlags,
    required this.accuracyRate,
    required this.reputationScore,
    required this.totalUpvotes,
    required this.totalDownvotes,
  });

  factory InvestorAgentStats.fromJson(Map<String, dynamic> json) => _$InvestorAgentStatsFromJson(json);
  Map<String, dynamic> toJson() => _$InvestorAgentStatsToJson(this);
}