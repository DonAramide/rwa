import 'user_role.dart';

/// Asset upload source types for role-based workflows
enum AssetUploadSource {
  superAdmin,
  bank,
  professional,
  individual,
  institutional,
}

/// Asset listing types
enum AssetListingType {
  fullSale,          // Complete ownership transfer
  fractionalSale,    // Tokenized fractional ownership
  rental,           // Rental income sharing
  development,      // Development projects
}

/// Verification status for uploads
enum VerificationStatus {
  pending,
  inProgress,
  approved,
  rejected,
  requiresDocuments,
  escalated,
}

/// Asset upload model for multi-role system
class AssetUpload {
  final String id;
  final String uploaderId;
  final String uploaderName;
  final String uploaderEmail;
  final AssetUploadSource source;
  final UserRole uploaderRole;
  final String title;
  final String description;
  final String location;
  final String assetType;
  final AssetListingType listingType;
  final double totalValue;
  final double? pricePerShare;
  final int? totalShares;
  final DateTime uploadDate;
  final VerificationStatus verificationStatus;
  final String? verificationNotes;
  final List<AssetDocument> documents;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final bool isPublished;
  final DateTime? publishedDate;
  final String? rejectionReason;

  const AssetUpload({
    required this.id,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploaderEmail,
    required this.source,
    required this.uploaderRole,
    required this.title,
    required this.description,
    required this.location,
    required this.assetType,
    required this.listingType,
    required this.totalValue,
    this.pricePerShare,
    this.totalShares,
    required this.uploadDate,
    this.verificationStatus = VerificationStatus.pending,
    this.verificationNotes,
    this.documents = const [],
    this.metadata = const {},
    this.tags = const [],
    this.isPublished = false,
    this.publishedDate,
    this.rejectionReason,
  });

  AssetUpload copyWith({
    String? id,
    String? uploaderId,
    String? uploaderName,
    String? uploaderEmail,
    AssetUploadSource? source,
    UserRole? uploaderRole,
    String? title,
    String? description,
    String? location,
    String? assetType,
    AssetListingType? listingType,
    double? totalValue,
    double? pricePerShare,
    int? totalShares,
    DateTime? uploadDate,
    VerificationStatus? verificationStatus,
    String? verificationNotes,
    List<AssetDocument>? documents,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    bool? isPublished,
    DateTime? publishedDate,
    String? rejectionReason,
  }) {
    return AssetUpload(
      id: id ?? this.id,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderEmail: uploaderEmail ?? this.uploaderEmail,
      source: source ?? this.source,
      uploaderRole: uploaderRole ?? this.uploaderRole,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      assetType: assetType ?? this.assetType,
      listingType: listingType ?? this.listingType,
      totalValue: totalValue ?? this.totalValue,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      totalShares: totalShares ?? this.totalShares,
      uploadDate: uploadDate ?? this.uploadDate,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      documents: documents ?? this.documents,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
      publishedDate: publishedDate ?? this.publishedDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  bool get requiresFractionalization => listingType == AssetListingType.fractionalSale && totalShares != null && totalShares! > 1;
  bool get isInstitutional => source == AssetUploadSource.superAdmin || source == AssetUploadSource.bank || source == AssetUploadSource.institutional;
  bool get isPendingVerification => verificationStatus == VerificationStatus.pending || verificationStatus == VerificationStatus.inProgress;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'uploaderEmail': uploaderEmail,
      'source': source.name,
      'uploaderRole': uploaderRole.name,
      'title': title,
      'description': description,
      'location': location,
      'assetType': assetType,
      'listingType': listingType.name,
      'totalValue': totalValue,
      'pricePerShare': pricePerShare,
      'totalShares': totalShares,
      'uploadDate': uploadDate.toIso8601String(),
      'verificationStatus': verificationStatus.name,
      'verificationNotes': verificationNotes,
      'documents': documents.map((d) => d.toJson()).toList(),
      'metadata': metadata,
      'tags': tags,
      'isPublished': isPublished,
      'publishedDate': publishedDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory AssetUpload.fromJson(Map<String, dynamic> json) {
    return AssetUpload(
      id: json['id'] as String,
      uploaderId: json['uploaderId'] as String,
      uploaderName: json['uploaderName'] as String,
      uploaderEmail: json['uploaderEmail'] as String,
      source: AssetUploadSource.values.byName(json['source'] as String),
      uploaderRole: UserRole.values.byName(json['uploaderRole'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      assetType: json['assetType'] as String,
      listingType: AssetListingType.values.byName(json['listingType'] as String),
      totalValue: (json['totalValue'] as num).toDouble(),
      pricePerShare: json['pricePerShare'] != null ? (json['pricePerShare'] as num).toDouble() : null,
      totalShares: json['totalShares'] as int?,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      verificationStatus: VerificationStatus.values.byName(json['verificationStatus'] as String? ?? 'pending'),
      verificationNotes: json['verificationNotes'] as String?,
      documents: (json['documents'] as List?)?.map((d) => AssetDocument.fromJson(d)).toList() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      isPublished: json['isPublished'] as bool? ?? false,
      publishedDate: json['publishedDate'] != null ? DateTime.parse(json['publishedDate'] as String) : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}

/// Asset document model for uploads
class AssetDocument {
  final String id;
  final String assetUploadId;
  final String fileName;
  final String fileType;
  final String filePath;
  final int fileSize;
  final AssetDocumentType documentType;
  final DateTime uploadDate;
  final bool isRequired;
  final bool isVerified;
  final String? verificationNotes;

  const AssetDocument({
    required this.id,
    required this.assetUploadId,
    required this.fileName,
    required this.fileType,
    required this.filePath,
    required this.fileSize,
    required this.documentType,
    required this.uploadDate,
    this.isRequired = false,
    this.isVerified = false,
    this.verificationNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetUploadId': assetUploadId,
      'fileName': fileName,
      'fileType': fileType,
      'filePath': filePath,
      'fileSize': fileSize,
      'documentType': documentType.name,
      'uploadDate': uploadDate.toIso8601String(),
      'isRequired': isRequired,
      'isVerified': isVerified,
      'verificationNotes': verificationNotes,
    };
  }

  factory AssetDocument.fromJson(Map<String, dynamic> json) {
    return AssetDocument(
      id: json['id'] as String,
      assetUploadId: json['assetUploadId'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      documentType: AssetDocumentType.values.byName(json['documentType'] as String),
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      isRequired: json['isRequired'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      verificationNotes: json['verificationNotes'] as String?,
    );
  }
}

/// Document types for asset uploads
enum AssetDocumentType {
  // Ownership documents
  titleDeed,
  certificateOfOccupancy,
  purchaseAgreement,
  ownershipCertificate,

  // Identification documents
  nationalId,
  passport,
  driversLicense,
  utilityBill,
  bankStatement,

  // Professional documents
  professionalLicense,
  businessRegistration,
  insuranceCertificate,

  // Asset documents
  valuationReport,
  surveyPlan,
  buildingPlan,
  engineeringReport,
  environmentalReport,

  // Financial documents
  taxReceipt,
  auditReport,
  incomeStatement,

  // Legal documents
  powerOfAttorney,
  courtOrder,
  legalOpinion,

  // Visual documentation
  assetPhotos,
  videoWalkthrough,
  droneFootage,

  // Other
  other,
}

/// Role-based upload requirements
class UploadRequirements {
  final AssetUploadSource source;
  final List<AssetDocumentType> requiredDocuments;
  final List<AssetDocumentType> optionalDocuments;
  final bool requiresProfessionalVerification;
  final bool requiresAdminApproval;
  final bool canBypassVerification;
  final int maxAssetValue;
  final List<AssetListingType> allowedListingTypes;

  const UploadRequirements({
    required this.source,
    required this.requiredDocuments,
    this.optionalDocuments = const [],
    this.requiresProfessionalVerification = true,
    this.requiresAdminApproval = true,
    this.canBypassVerification = false,
    this.maxAssetValue = 1000000000, // Default 1B limit
    this.allowedListingTypes = const [
      AssetListingType.fullSale,
      AssetListingType.fractionalSale,
      AssetListingType.rental,
    ],
  });

  static UploadRequirements forSource(AssetUploadSource source) {
    switch (source) {
      case AssetUploadSource.superAdmin:
        return const UploadRequirements(
          source: AssetUploadSource.superAdmin,
          requiredDocuments: [], // Super admin can upload anything
          optionalDocuments: [
            AssetDocumentType.titleDeed,
            AssetDocumentType.valuationReport,
            AssetDocumentType.assetPhotos,
          ],
          requiresProfessionalVerification: false,
          requiresAdminApproval: false,
          canBypassVerification: true,
          maxAssetValue: 999999999999, // Unlimited
          allowedListingTypes: [
            AssetListingType.fullSale,
            AssetListingType.fractionalSale,
            AssetListingType.rental,
            AssetListingType.development,
          ],
        );

      case AssetUploadSource.bank:
        return const UploadRequirements(
          source: AssetUploadSource.bank,
          requiredDocuments: [
            AssetDocumentType.businessRegistration,
            AssetDocumentType.titleDeed,
            AssetDocumentType.valuationReport,
          ],
          optionalDocuments: [
            AssetDocumentType.assetPhotos,
            AssetDocumentType.surveyPlan,
            AssetDocumentType.auditReport,
          ],
          requiresProfessionalVerification: false, // Banks are pre-verified
          requiresAdminApproval: true,
          canBypassVerification: false,
          maxAssetValue: 500000000, // 500M limit
        );

      case AssetUploadSource.professional:
        return const UploadRequirements(
          source: AssetUploadSource.professional,
          requiredDocuments: [
            AssetDocumentType.professionalLicense,
            AssetDocumentType.nationalId,
            AssetDocumentType.titleDeed,
            AssetDocumentType.valuationReport,
          ],
          optionalDocuments: [
            AssetDocumentType.insuranceCertificate,
            AssetDocumentType.assetPhotos,
            AssetDocumentType.engineeringReport,
          ],
          requiresProfessionalVerification: true,
          requiresAdminApproval: true,
          maxAssetValue: 100000000, // 100M limit
        );

      case AssetUploadSource.individual:
        return const UploadRequirements(
          source: AssetUploadSource.individual,
          requiredDocuments: [
            AssetDocumentType.nationalId,
            AssetDocumentType.titleDeed,
            AssetDocumentType.utilityBill,
            AssetDocumentType.assetPhotos,
          ],
          optionalDocuments: [
            AssetDocumentType.valuationReport,
            AssetDocumentType.surveyPlan,
            AssetDocumentType.bankStatement,
          ],
          requiresProfessionalVerification: true,
          requiresAdminApproval: true,
          maxAssetValue: 50000000, // 50M limit
          allowedListingTypes: [
            AssetListingType.fullSale,
            AssetListingType.fractionalSale,
          ],
        );

      case AssetUploadSource.institutional:
        return const UploadRequirements(
          source: AssetUploadSource.institutional,
          requiredDocuments: [
            AssetDocumentType.businessRegistration,
            AssetDocumentType.titleDeed,
            AssetDocumentType.valuationReport,
            AssetDocumentType.auditReport,
          ],
          optionalDocuments: [
            AssetDocumentType.assetPhotos,
            AssetDocumentType.legalOpinion,
            AssetDocumentType.environmentalReport,
          ],
          requiresProfessionalVerification: false,
          requiresAdminApproval: true,
          maxAssetValue: 1000000000, // 1B limit
        );
    }
  }
}

/// Tokenization configuration for fractional assets
class TokenizationConfig {
  final String assetUploadId;
  final String contractAddress;
  final String tokenName;
  final String tokenSymbol;
  final int totalSupply;
  final int decimals;
  final double pricePerToken;
  final DateTime deploymentDate;
  final bool isDeployed;
  final String? deploymentTxHash;
  final Map<String, dynamic> contractMetadata;

  const TokenizationConfig({
    required this.assetUploadId,
    required this.contractAddress,
    required this.tokenName,
    required this.tokenSymbol,
    required this.totalSupply,
    this.decimals = 18,
    required this.pricePerToken,
    required this.deploymentDate,
    this.isDeployed = false,
    this.deploymentTxHash,
    this.contractMetadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'assetUploadId': assetUploadId,
      'contractAddress': contractAddress,
      'tokenName': tokenName,
      'tokenSymbol': tokenSymbol,
      'totalSupply': totalSupply,
      'decimals': decimals,
      'pricePerToken': pricePerToken,
      'deploymentDate': deploymentDate.toIso8601String(),
      'isDeployed': isDeployed,
      'deploymentTxHash': deploymentTxHash,
      'contractMetadata': contractMetadata,
    };
  }

  factory TokenizationConfig.fromJson(Map<String, dynamic> json) {
    return TokenizationConfig(
      assetUploadId: json['assetUploadId'] as String,
      contractAddress: json['contractAddress'] as String,
      tokenName: json['tokenName'] as String,
      tokenSymbol: json['tokenSymbol'] as String,
      totalSupply: json['totalSupply'] as int,
      decimals: json['decimals'] as int? ?? 18,
      pricePerToken: (json['pricePerToken'] as num).toDouble(),
      deploymentDate: DateTime.parse(json['deploymentDate'] as String),
      isDeployed: json['isDeployed'] as bool? ?? false,
      deploymentTxHash: json['deploymentTxHash'] as String?,
      contractMetadata: json['contractMetadata'] as Map<String, dynamic>? ?? {},
    );
  }
}