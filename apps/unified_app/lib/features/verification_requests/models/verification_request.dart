import 'package:json_annotation/json_annotation.dart';

part 'verification_request.g.dart';

enum VerificationRequestType {
  @JsonValue('asset_inspection')
  assetInspection,
  @JsonValue('document_verification')
  documentVerification,
  @JsonValue('financial_audit')
  financialAudit,
  @JsonValue('compliance_check')
  complianceCheck,
  @JsonValue('site_visit')
  siteVisit,
  @JsonValue('condition_assessment')
  conditionAssessment,
  @JsonValue('ownership_verification')
  ownershipVerification,
  @JsonValue('valuation_check')
  valuationCheck,
}

enum VerificationRequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('assigned')
  assigned,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('submitted')
  submitted,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('disputed')
  disputed,
}

enum VerificationRequestUrgency {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

@JsonSerializable()
class VerificationRequest {
  final int id;
  final VerificationRequestType type;
  final VerificationRequestStatus status;
  final VerificationRequestUrgency urgency;
  final String title;
  final String description;
  final Map<String, dynamic>? requirements;
  final Map<String, dynamic>? location;
  final String budget;
  final String currency;
  final DateTime? deadline;
  final Map<String, dynamic>? deliverables;
  final String? notes;
  @JsonKey(name: 'asset_id')
  final int assetId;
  @JsonKey(name: 'requester_id')
  final int requesterId;
  @JsonKey(name: 'assigned_verifier_id')
  final int? assignedVerifierId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const VerificationRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.urgency,
    required this.title,
    required this.description,
    this.requirements,
    this.location,
    required this.budget,
    required this.currency,
    this.deadline,
    this.deliverables,
    this.notes,
    required this.assetId,
    required this.requesterId,
    this.assignedVerifierId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationRequest.fromJson(Map<String, dynamic> json) => _$VerificationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerificationRequestToJson(this);

  String get typeDisplayName {
    switch (type) {
      case VerificationRequestType.assetInspection:
        return 'Asset Inspection';
      case VerificationRequestType.documentVerification:
        return 'Document Verification';
      case VerificationRequestType.financialAudit:
        return 'Financial Audit';
      case VerificationRequestType.complianceCheck:
        return 'Compliance Check';
      case VerificationRequestType.siteVisit:
        return 'Site Visit';
      case VerificationRequestType.conditionAssessment:
        return 'Condition Assessment';
      case VerificationRequestType.ownershipVerification:
        return 'Ownership Verification';
      case VerificationRequestType.valuationCheck:
        return 'Valuation Check';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case VerificationRequestStatus.pending:
        return 'Pending Proposals';
      case VerificationRequestStatus.assigned:
        return 'Assigned';
      case VerificationRequestStatus.inProgress:
        return 'In Progress';
      case VerificationRequestStatus.submitted:
        return 'Report Submitted';
      case VerificationRequestStatus.approved:
        return 'Approved';
      case VerificationRequestStatus.rejected:
        return 'Rejected';
      case VerificationRequestStatus.cancelled:
        return 'Cancelled';
      case VerificationRequestStatus.disputed:
        return 'Disputed';
    }
  }

  String get urgencyDisplayName {
    switch (urgency) {
      case VerificationRequestUrgency.low:
        return 'Low Priority';
      case VerificationRequestUrgency.medium:
        return 'Medium Priority';
      case VerificationRequestUrgency.high:
        return 'High Priority';
      case VerificationRequestUrgency.urgent:
        return 'Urgent';
    }
  }

  double get budgetAmount => double.tryParse(budget) ?? 0.0;
}

@JsonSerializable()
class CreateVerificationRequestRequest {
  @JsonKey(name: 'asset_id')
  final int assetId;
  final VerificationRequestType type;
  final VerificationRequestUrgency urgency;
  final String title;
  final String description;
  final Map<String, dynamic>? requirements;
  final Map<String, dynamic>? location;
  final String budget;
  final String? currency;
  final DateTime? deadline;
  final Map<String, dynamic>? deliverables;
  final String? notes;

  const CreateVerificationRequestRequest({
    required this.assetId,
    required this.type,
    required this.urgency,
    required this.title,
    required this.description,
    this.requirements,
    this.location,
    required this.budget,
    this.currency,
    this.deadline,
    this.deliverables,
    this.notes,
  });

  factory CreateVerificationRequestRequest.fromJson(Map<String, dynamic> json) => _$CreateVerificationRequestRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateVerificationRequestRequestToJson(this);
}

@JsonSerializable()
class VerificationProposal {
  final int id;
  @JsonKey(name: 'proposed_price')
  final String proposedPrice;
  final String currency;
  @JsonKey(name: 'proposal_message')
  final String proposalMessage;
  @JsonKey(name: 'estimated_completion')
  final DateTime estimatedCompletion;
  final Map<String, dynamic>? methodology;
  @JsonKey(name: 'is_accepted')
  final bool isAccepted;
  @JsonKey(name: 'request_id')
  final int requestId;
  @JsonKey(name: 'verifier_id')
  final int verifierId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const VerificationProposal({
    required this.id,
    required this.proposedPrice,
    required this.currency,
    required this.proposalMessage,
    required this.estimatedCompletion,
    this.methodology,
    required this.isAccepted,
    required this.requestId,
    required this.verifierId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationProposal.fromJson(Map<String, dynamic> json) => _$VerificationProposalFromJson(json);
  Map<String, dynamic> toJson() => _$VerificationProposalToJson(this);

  double get proposedPriceAmount => double.tryParse(proposedPrice) ?? 0.0;
}

@JsonSerializable()
class CreateProposalRequest {
  @JsonKey(name: 'proposed_price')
  final String proposedPrice;
  final String? currency;
  @JsonKey(name: 'proposal_message')
  final String proposalMessage;
  @JsonKey(name: 'estimated_completion')
  final DateTime estimatedCompletion;
  final Map<String, dynamic>? methodology;

  const CreateProposalRequest({
    required this.proposedPrice,
    this.currency,
    required this.proposalMessage,
    required this.estimatedCompletion,
    this.methodology,
  });

  factory CreateProposalRequest.fromJson(Map<String, dynamic> json) => _$CreateProposalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateProposalRequestToJson(this);
}

@JsonSerializable()
class VerificationReport {
  final int id;
  final String title;
  final String summary;
  final Map<String, dynamic> findings;
  final Map<String, dynamic>? photos;
  final Map<String, dynamic>? documents;
  @JsonKey(name: 'gps_data')
  final Map<String, dynamic>? gpsData;
  @JsonKey(name: 'is_approved')
  final bool isApproved;
  @JsonKey(name: 'reviewer_notes')
  final String? reviewerNotes;
  @JsonKey(name: 'reviewed_at')
  final DateTime? reviewedAt;
  @JsonKey(name: 'request_id')
  final int requestId;
  @JsonKey(name: 'verifier_id')
  final int verifierId;
  @JsonKey(name: 'reviewer_id')
  final int? reviewerId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const VerificationReport({
    required this.id,
    required this.title,
    required this.summary,
    required this.findings,
    this.photos,
    this.documents,
    this.gpsData,
    required this.isApproved,
    this.reviewerNotes,
    this.reviewedAt,
    required this.requestId,
    required this.verifierId,
    this.reviewerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationReport.fromJson(Map<String, dynamic> json) => _$VerificationReportFromJson(json);
  Map<String, dynamic> toJson() => _$VerificationReportToJson(this);
}

@JsonSerializable()
class CreateReportRequest {
  final String title;
  final String summary;
  final Map<String, dynamic> findings;
  final Map<String, dynamic>? photos;
  final Map<String, dynamic>? documents;
  @JsonKey(name: 'gps_data')
  final Map<String, dynamic>? gpsData;

  const CreateReportRequest({
    required this.title,
    required this.summary,
    required this.findings,
    this.photos,
    this.documents,
    this.gpsData,
  });

  factory CreateReportRequest.fromJson(Map<String, dynamic> json) => _$CreateReportRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReportRequestToJson(this);
}

@JsonSerializable()
class VerificationRequestResponse {
  final List<VerificationRequest> requests;
  final int total;

  const VerificationRequestResponse({
    required this.requests,
    required this.total,
  });

  factory VerificationRequestResponse.fromJson(Map<String, dynamic> json) => _$VerificationRequestResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VerificationRequestResponseToJson(this);
}