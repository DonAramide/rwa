import 'package:flutter/foundation.dart';

enum VerificationStage {
  application,
  documents,
  background,
  skills,
  interview,
  completed;

  String get displayName {
    switch (this) {
      case VerificationStage.application:
        return 'Application';
      case VerificationStage.documents:
        return 'Document Verification';
      case VerificationStage.background:
        return 'Background Check';
      case VerificationStage.skills:
        return 'Skills Assessment';
      case VerificationStage.interview:
        return 'Interview';
      case VerificationStage.completed:
        return 'Completed';
    }
  }

  String get description {
    switch (this) {
      case VerificationStage.application:
        return 'Submit basic information and qualifications';
      case VerificationStage.documents:
        return 'Upload and verify identity documents';
      case VerificationStage.background:
        return 'Professional background verification';
      case VerificationStage.skills:
        return 'Complete skills assessment test';
      case VerificationStage.interview:
        return 'Video interview with verification team';
      case VerificationStage.completed:
        return 'Verification process completed';
    }
  }
}

enum VerificationStatus {
  pending,
  inProgress,
  approved,
  rejected,
  needsRevision;

  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.inProgress:
        return 'In Progress';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.needsRevision:
        return 'Needs Revision';
    }
  }
}

enum DocumentType {
  passport,
  drivingLicense,
  nationalId,
  professionalCertificate,
  degreesCertificate,
  workReference,
  addressProof;

  String get displayName {
    switch (this) {
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.drivingLicense:
        return 'Driving License';
      case DocumentType.nationalId:
        return 'National ID';
      case DocumentType.professionalCertificate:
        return 'Professional Certificate';
      case DocumentType.degreesCertificate:
        return 'Degree Certificate';
      case DocumentType.workReference:
        return 'Work Reference';
      case DocumentType.addressProof:
        return 'Address Proof';
    }
  }
}

@immutable
class VerificationDocument {
  final String id;
  final DocumentType type;
  final String fileName;
  final String url;
  final VerificationStatus status;
  final String? rejectionReason;
  final DateTime uploadedAt;
  final DateTime? reviewedAt;

  const VerificationDocument({
    required this.id,
    required this.type,
    required this.fileName,
    required this.url,
    required this.status,
    this.rejectionReason,
    required this.uploadedAt,
    this.reviewedAt,
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      id: json['id'].toString(),
      type: DocumentType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => DocumentType.passport,
      ),
      fileName: json['fileName'] as String,
      url: json['url'] as String,
      status: VerificationStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => VerificationStatus.pending,
      ),
      rejectionReason: json['rejectionReason'] as String?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
    );
  }
}

@immutable
class SkillsAssessment {
  final String id;
  final String title;
  final int totalQuestions;
  final int answeredQuestions;
  final double? score;
  final VerificationStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> questions;
  final Map<String, dynamic> answers;

  const SkillsAssessment({
    required this.id,
    required this.title,
    required this.totalQuestions,
    required this.answeredQuestions,
    this.score,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.questions,
    required this.answers,
  });

  factory SkillsAssessment.fromJson(Map<String, dynamic> json) {
    return SkillsAssessment(
      id: json['id'].toString(),
      title: json['title'] as String,
      totalQuestions: json['totalQuestions'] as int,
      answeredQuestions: json['answeredQuestions'] as int,
      score: (json['score'] as num?)?.toDouble(),
      status: VerificationStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => VerificationStatus.pending,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      questions: json['questions'] as Map<String, dynamic>? ?? {},
      answers: json['answers'] as Map<String, dynamic>? ?? {},
    );
  }

  double get progress => answeredQuestions / totalQuestions;
  bool get isCompleted => answeredQuestions >= totalQuestions;
}

@immutable
class InterviewSlot {
  final String id;
  final DateTime scheduledAt;
  final String interviewerName;
  final String meetingLink;
  final VerificationStatus status;
  final String? notes;
  final DateTime? completedAt;

  const InterviewSlot({
    required this.id,
    required this.scheduledAt,
    required this.interviewerName,
    required this.meetingLink,
    required this.status,
    this.notes,
    this.completedAt,
  });

  factory InterviewSlot.fromJson(Map<String, dynamic> json) {
    return InterviewSlot(
      id: json['id'].toString(),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      interviewerName: json['interviewerName'] as String,
      meetingLink: json['meetingLink'] as String,
      status: VerificationStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => VerificationStatus.pending,
      ),
      notes: json['notes'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

@immutable
class AgentVerificationApplication {
  final String id;
  final String userId;
  final VerificationStage currentStage;
  final VerificationStatus overallStatus;
  final Map<VerificationStage, VerificationStatus> stageStatuses;
  final List<VerificationDocument> documents;
  final List<SkillsAssessment> assessments;
  final InterviewSlot? interview;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final List<String> specializations;
  final List<String> regions;
  final int yearsOfExperience;
  final String? bio;
  final DateTime submittedAt;
  final DateTime? completedAt;
  final String? rejectionReason;

  const AgentVerificationApplication({
    required this.id,
    required this.userId,
    required this.currentStage,
    required this.overallStatus,
    required this.stageStatuses,
    required this.documents,
    required this.assessments,
    this.interview,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.specializations,
    required this.regions,
    required this.yearsOfExperience,
    this.bio,
    required this.submittedAt,
    this.completedAt,
    this.rejectionReason,
  });

  factory AgentVerificationApplication.fromJson(Map<String, dynamic> json) {
    return AgentVerificationApplication(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      currentStage: VerificationStage.values.firstWhere(
        (stage) => stage.name == json['currentStage'],
        orElse: () => VerificationStage.application,
      ),
      overallStatus: VerificationStatus.values.firstWhere(
        (status) => status.name == json['overallStatus'],
        orElse: () => VerificationStatus.pending,
      ),
      stageStatuses: Map<VerificationStage, VerificationStatus>.fromEntries(
        (json['stageStatuses'] as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(
            VerificationStage.values.firstWhere(
              (stage) => stage.name == entry.key,
              orElse: () => VerificationStage.application,
            ),
            VerificationStatus.values.firstWhere(
              (status) => status.name == entry.value,
              orElse: () => VerificationStatus.pending,
            ),
          ),
        ),
      ),
      documents: (json['documents'] as List? ?? [])
          .map((doc) => VerificationDocument.fromJson(doc as Map<String, dynamic>))
          .toList(),
      assessments: (json['assessments'] as List? ?? [])
          .map((assessment) => SkillsAssessment.fromJson(assessment as Map<String, dynamic>))
          .toList(),
      interview: json['interview'] != null
          ? InterviewSlot.fromJson(json['interview'] as Map<String, dynamic>)
          : null,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      specializations: List<String>.from(json['specializations'] ?? []),
      regions: List<String>.from(json['regions'] ?? []),
      yearsOfExperience: json['yearsOfExperience'] as int,
      bio: json['bio'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';

  double get overallProgress {
    final completedStages = stageStatuses.values
        .where((status) => status == VerificationStatus.approved)
        .length;
    return completedStages / VerificationStage.values.length;
  }

  bool get canProceedToNextStage {
    final currentIndex = VerificationStage.values.indexOf(currentStage);
    if (currentIndex == 0) return true;

    final previousStage = VerificationStage.values[currentIndex - 1];
    return stageStatuses[previousStage] == VerificationStatus.approved;
  }

  VerificationStage? get nextStage {
    final currentIndex = VerificationStage.values.indexOf(currentStage);
    if (currentIndex < VerificationStage.values.length - 1) {
      return VerificationStage.values[currentIndex + 1];
    }
    return null;
  }
}