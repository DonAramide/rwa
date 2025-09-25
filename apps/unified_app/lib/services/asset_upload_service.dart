import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user_role.dart';
import '../models/asset.dart';
import '../models/asset_upload_models.dart';
import '../core/api_client.dart';
import '../features/asset_upload/super_admin_upload_screen.dart';
import '../features/asset_upload/individual_upload_screen.dart';
import '../features/merchant_admin/new_asset_proposal_screen.dart';

// Role-based upload requirements
class UploadRequirements {
  final bool requiresKYC;
  final bool requiresProfessionalVerification;
  final bool requiresMerchantVerification;
  final bool canBypassVerification;
  final List<String> requiredDocuments;
  final List<String> optionalDocuments;
  final int maxFileSize; // in MB
  final List<String> allowedFileTypes;
  final bool allowsBulkUpload;
  final bool requiresManualApproval;
  final int maxAssetsPerUpload;

  const UploadRequirements({
    this.requiresKYC = false,
    this.requiresProfessionalVerification = false,
    this.requiresMerchantVerification = false,
    this.canBypassVerification = false,
    this.requiredDocuments = const [],
    this.optionalDocuments = const [],
    this.maxFileSize = 50,
    this.allowedFileTypes = const ['pdf', 'jpg', 'png', 'doc', 'docx'],
    this.allowsBulkUpload = false,
    this.requiresManualApproval = true,
    this.maxAssetsPerUpload = 1,
  });
}

class AssetUploadService {
  // Get upload requirements based on user role
  static UploadRequirements getUploadRequirements(UserRole userRole) {
    switch (userRole) {
      case UserRole.superAdmin:
        return const UploadRequirements(
          requiresKYC: false,
          requiresProfessionalVerification: false,
          requiresMerchantVerification: false,
          canBypassVerification: true,
          requiredDocuments: [],
          optionalDocuments: [
            'Asset Documentation',
            'Valuation Report',
            'Legal Documents',
          ],
          maxFileSize: 500, // 500MB for super admin
          allowedFileTypes: ['pdf', 'jpg', 'png', 'doc', 'docx', 'csv', 'xlsx'],
          allowsBulkUpload: true,
          requiresManualApproval: false,
          maxAssetsPerUpload: 100,
        );

      case UserRole.merchantAdmin:
      case UserRole.merchantOperations:
      case UserRole.merchantWhiteLabel:
        return const UploadRequirements(
          requiresKYC: false,
          requiresProfessionalVerification: false,
          requiresMerchantVerification: true,
          canBypassVerification: false,
          requiredDocuments: [
            'Asset Title/Deed',
            'Merchant Authorization Document',
            'Asset Valuation Report',
            'Legal Compliance Certificate',
          ],
          optionalDocuments: [
            'Insurance Certificate',
            'Tax Assessment',
            'Property Management Agreement',
          ],
          maxFileSize: 200, // 200MB for merchants
          allowedFileTypes: ['pdf', 'jpg', 'png', 'doc', 'docx', 'csv'],
          allowsBulkUpload: true,
          requiresManualApproval: true,
          maxAssetsPerUpload: 50,
        );

      case UserRole.professionalAgent:
        return const UploadRequirements(
          requiresKYC: true,
          requiresProfessionalVerification: true,
          requiresMerchantVerification: false,
          canBypassVerification: false,
          requiredDocuments: [
            'Professional License',
            'Client Authorization',
            'Asset Ownership Proof',
            'Property Valuation Report',
            'Professional Insurance Certificate',
          ],
          optionalDocuments: [
            'Asset Inspection Report',
            'Market Analysis',
            'Due Diligence Report',
          ],
          maxFileSize: 100, // 100MB for professionals
          allowedFileTypes: ['pdf', 'jpg', 'png', 'doc', 'docx'],
          allowsBulkUpload: false,
          requiresManualApproval: true,
          maxAssetsPerUpload: 10,
        );

      case UserRole.investorAgent:
        return const UploadRequirements(
          requiresKYC: true,
          requiresProfessionalVerification: false,
          requiresMerchantVerification: false,
          canBypassVerification: false,
          requiredDocuments: [
            'Personal ID (BVN/NIN)',
            'Utility Bill',
            'Asset Ownership Proof',
            'Property Title/Deed',
            'Asset Valuation Report',
          ],
          optionalDocuments: [
            'Insurance Certificate',
            'Tax Receipt',
            'Property Survey',
          ],
          maxFileSize: 50, // 50MB for individuals
          allowedFileTypes: ['pdf', 'jpg', 'png'],
          allowsBulkUpload: false,
          requiresManualApproval: true,
          maxAssetsPerUpload: 3,
        );

      case UserRole.verifier:
        return const UploadRequirements(
          requiresKYC: true,
          requiresProfessionalVerification: false,
          requiresMerchantVerification: false,
          canBypassVerification: false,
          requiredDocuments: [
            'Verification Report',
            'Photo Evidence',
            'Location Verification',
          ],
          optionalDocuments: [
            'Additional Documentation',
            'Expert Opinion',
          ],
          maxFileSize: 25, // 25MB for verifiers
          allowedFileTypes: ['pdf', 'jpg', 'png'],
          allowsBulkUpload: false,
          requiresManualApproval: true,
          maxAssetsPerUpload: 1,
        );

      case UserRole.admin:
        return const UploadRequirements(
          requiresKYC: false,
          requiresProfessionalVerification: false,
          requiresMerchantVerification: false,
          canBypassVerification: true,
          requiredDocuments: [
            'Asset Documentation',
            'Administrative Authorization',
          ],
          optionalDocuments: [
            'Additional Legal Documents',
            'Compliance Reports',
          ],
          maxFileSize: 200, // 200MB for admins
          allowedFileTypes: ['pdf', 'jpg', 'png', 'doc', 'docx'],
          allowsBulkUpload: true,
          requiresManualApproval: false,
          maxAssetsPerUpload: 25,
        );
    }
  }

  // Route user to appropriate upload flow
  static Widget getUploadScreen(UserRole userRole, {Map<String, dynamic>? context}) {
    switch (userRole) {
      case UserRole.superAdmin:
        return _getSuperAdminUploadScreen(context);
      case UserRole.merchantAdmin:
      case UserRole.merchantOperations:
      case UserRole.merchantWhiteLabel:
        return _getMerchantUploadScreen(userRole, context);
      case UserRole.professionalAgent:
        return _getProfessionalUploadScreen(context);
      case UserRole.investorAgent:
        return _getIndividualUploadScreen(context);
      case UserRole.verifier:
        return _getVerifierUploadScreen(context);
      case UserRole.admin:
        return _getAdminUploadScreen(context);
    }
  }

  // Create asset upload metadata based on role
  static AssetUploadMetadata createUploadMetadata({
    required UserRole userRole,
    required String uploaderId,
    String? uploaderName,
    String? uploaderEmail,
    String? merchantId,
    String? professionalLicenseNumber,
    String? originalSource,
    Map<String, dynamic>? customMetadata,
    List<String>? verificationDocuments,
    String? notes,
  }) {
    final source = _roleToAssetSource(userRole);
    final requirements = getUploadRequirements(userRole);

    return AssetUploadMetadata(
      source: source,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      uploaderEmail: uploaderEmail,
      merchantId: merchantId,
      professionalLicenseNumber: professionalLicenseNumber,
      uploadedAt: DateTime.now(),
      originalSource: originalSource,
      customMetadata: customMetadata,
      verificationDocuments: verificationDocuments ?? [],
      requiresKYC: requirements.requiresKYC,
      requiresProfessionalVerification: requirements.requiresProfessionalVerification,
      notes: notes,
    );
  }

  // Validate upload based on role requirements
  static List<String> validateUpload({
    required UserRole userRole,
    required Map<String, dynamic> assetData,
    required List<String> uploadedDocuments,
    required int fileSizeInMB,
  }) {
    final requirements = getUploadRequirements(userRole);
    final errors = <String>[];

    // Check file size
    if (fileSizeInMB > requirements.maxFileSize) {
      errors.add('File size exceeds ${requirements.maxFileSize}MB limit for ${userRole.displayName}');
    }

    // Check required documents
    for (final requiredDoc in requirements.requiredDocuments) {
      if (!uploadedDocuments.any((doc) => doc.toLowerCase().contains(requiredDoc.toLowerCase()))) {
        errors.add('Missing required document: $requiredDoc');
      }
    }

    // Role-specific validations
    switch (userRole) {
      case UserRole.professionalAgent:
        if (assetData['professionalLicenseNumber'] == null ||
            assetData['professionalLicenseNumber'].toString().isEmpty) {
          errors.add('Professional license number is required');
        }
        break;
      case UserRole.merchantAdmin:
      case UserRole.merchantOperations:
      case UserRole.merchantWhiteLabel:
        if (assetData['merchantId'] == null || assetData['merchantId'].toString().isEmpty) {
          errors.add('Merchant ID is required');
        }
        break;
      case UserRole.investorAgent:
        if (assetData['ownershipProof'] == null) {
          errors.add('Ownership proof is required for individual uploads');
        }
        break;
      default:
        break;
    }

    return errors;
  }

  // Convert user role to asset source
  static AssetSource _roleToAssetSource(UserRole userRole) {
    switch (userRole) {
      case UserRole.superAdmin:
      case UserRole.admin:
        return AssetSource.superAdmin;
      case UserRole.merchantAdmin:
      case UserRole.merchantOperations:
      case UserRole.merchantWhiteLabel:
        return AssetSource.merchantAdmin;
      case UserRole.professionalAgent:
        return AssetSource.professionalAgent;
      case UserRole.investorAgent:
        return AssetSource.individual;
      case UserRole.verifier:
        return AssetSource.individual; // Verifiers typically upload on behalf of individuals
    }
  }

  // Upload screens for different roles
  static Widget _getSuperAdminUploadScreen(Map<String, dynamic>? context) {
    return const SuperAdminUploadScreen();
  }

  static Widget _getMerchantUploadScreen(UserRole merchantRole, Map<String, dynamic>? context) {
    return const NewAssetProposalScreen();
  }

  static Widget _getProfessionalUploadScreen(Map<String, dynamic>? context) {
    // TODO: Implement professional upload screen
    return const IndividualUploadScreen(); // Temporary placeholder
  }

  static Widget _getIndividualUploadScreen(Map<String, dynamic>? context) {
    return const IndividualUploadScreen();
  }

  static Widget _getVerifierUploadScreen(Map<String, dynamic>? context) {
    // Verifiers typically don't upload assets, they verify them
    return const Center(
      child: Text('Verifiers cannot upload assets'),
    );
  }

  static Widget _getAdminUploadScreen(Map<String, dynamic>? context) {
    return const SuperAdminUploadScreen(); // Admins use same flow as super admin
  }
}

// Upload flow router
class AssetUploadRouter {
  static void navigateToUpload(BuildContext context, UserRole userRole) {
    final uploadScreen = AssetUploadService.getUploadScreen(userRole);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => uploadScreen,
        settings: RouteSettings(
          name: '/asset-upload/${userRole.name}',
          arguments: {'userRole': userRole},
        ),
      ),
    );
  }

  static bool canUserUploadAssets(UserRole userRole) {
    switch (userRole) {
      case UserRole.verifier:
        return false; // Verifiers don't upload assets, they verify them
      default:
        return true;
    }
  }
}