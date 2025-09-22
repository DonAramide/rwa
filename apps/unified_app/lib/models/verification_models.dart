enum VerificationStatus {
  pending,
  underReview,
  approved,
  rejected,
  expired,
}

enum VerificationType {
  selfSubmitted,
  professionalAgent,
  validator,
}

enum DocumentType {
  photo,
  video,
  governmentId,
  proofOfAddress,
  selfieWithId,
}

class VerificationDocument {
  final String id;
  final DocumentType type;
  final String url;
  final String filename;
  final DateTime uploadDate;
  final Map<String, dynamic>? metadata;

  VerificationDocument({
    required this.id,
    required this.type,
    required this.url,
    required this.filename,
    required this.uploadDate,
    this.metadata,
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      id: json['id'],
      type: DocumentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      url: json['url'],
      filename: json['filename'],
      uploadDate: DateTime.parse(json['uploadDate']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'url': url,
      'filename': filename,
      'uploadDate': uploadDate.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class InvestorVerification {
  final String id;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final VerificationStatus status;
  final VerificationType type;
  final List<VerificationDocument> documents;
  final DateTime submissionDate;
  final DateTime? reviewDate;
  final DateTime? expiryDate;
  final String? reviewerId;
  final String? reviewerName;
  final String? reviewNotes;
  final Map<String, dynamic>? additionalData;

  InvestorVerification({
    required this.id,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.type,
    required this.documents,
    required this.submissionDate,
    this.reviewDate,
    this.expiryDate,
    this.reviewerId,
    this.reviewerName,
    this.reviewNotes,
    this.additionalData,
  });

  bool get isActive => status == VerificationStatus.approved &&
                      (expiryDate == null || DateTime.now().isBefore(expiryDate!));

  bool get canInvest => isActive;

  Duration? get timeUntilExpiry => expiryDate?.difference(DateTime.now());

  String get statusDisplayName {
    switch (status) {
      case VerificationStatus.pending:
        return 'Pending Review';
      case VerificationStatus.underReview:
        return 'Under Review';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.expired:
        return 'Expired';
    }
  }

  factory InvestorVerification.fromJson(Map<String, dynamic> json) {
    return InvestorVerification(
      id: json['id'],
      userId: json['userId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      status: VerificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      type: VerificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      documents: (json['documents'] as List)
          .map((d) => VerificationDocument.fromJson(d))
          .toList(),
      submissionDate: DateTime.parse(json['submissionDate']),
      reviewDate: json['reviewDate'] != null
          ? DateTime.parse(json['reviewDate'])
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      reviewerId: json['reviewerId'],
      reviewerName: json['reviewerName'],
      reviewNotes: json['reviewNotes'],
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'documents': documents.map((d) => d.toJson()).toList(),
      'submissionDate': submissionDate.toIso8601String(),
      'reviewDate': reviewDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewNotes': reviewNotes,
      'additionalData': additionalData,
    };
  }
}

class VerificationRequirement {
  final DocumentType documentType;
  final String title;
  final String description;
  final bool isRequired;
  final List<String> acceptedFormats;
  final int? maxFileSizeMB;

  VerificationRequirement({
    required this.documentType,
    required this.title,
    required this.description,
    required this.isRequired,
    required this.acceptedFormats,
    this.maxFileSizeMB,
  });

  static List<VerificationRequirement> getRequirements() {
    return [
      VerificationRequirement(
        documentType: DocumentType.governmentId,
        title: 'Government-issued ID',
        description: 'Clear photo of your passport, driver\'s license, or national ID card',
        isRequired: true,
        acceptedFormats: ['jpg', 'jpeg', 'png', 'pdf'],
        maxFileSizeMB: 10,
      ),
      VerificationRequirement(
        documentType: DocumentType.selfieWithId,
        title: 'Selfie with ID',
        description: 'Take a selfie holding your government ID next to your face',
        isRequired: true,
        acceptedFormats: ['jpg', 'jpeg', 'png'],
        maxFileSizeMB: 10,
      ),
      VerificationRequirement(
        documentType: DocumentType.proofOfAddress,
        title: 'Proof of Address',
        description: 'Recent utility bill, bank statement, or lease agreement (within 3 months)',
        isRequired: true,
        acceptedFormats: ['jpg', 'jpeg', 'png', 'pdf'],
        maxFileSizeMB: 10,
      ),
      VerificationRequirement(
        documentType: DocumentType.video,
        title: 'Verification Video (Optional)',
        description: 'Record a short video stating your full name and intention to invest',
        isRequired: false,
        acceptedFormats: ['mp4', 'mov', 'avi'],
        maxFileSizeMB: 50,
      ),
    ];
  }
}