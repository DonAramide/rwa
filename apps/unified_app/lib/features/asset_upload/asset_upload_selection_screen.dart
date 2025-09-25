import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_role.dart';
import '../../models/asset.dart';
import '../../services/asset_upload_service.dart';
import '../../providers/auth_provider.dart';

class AssetUploadSelectionScreen extends ConsumerStatefulWidget {
  const AssetUploadSelectionScreen({super.key});

  @override
  ConsumerState<AssetUploadSelectionScreen> createState() => _AssetUploadSelectionScreenState();
}

class _AssetUploadSelectionScreenState extends ConsumerState<AssetUploadSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role ?? UserRole.investorAgent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!AssetUploadRouter.canUserUploadAssets(userRole)) {
      return _buildNotAllowedScreen(isDark);
    }

    final requirements = AssetUploadService.getUploadRequirements(userRole);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: const Text('Upload Asset'),
        backgroundColor: AppColors.getSurface(isDark),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(userRole, isDark),
            const SizedBox(height: 24),
            _buildRoleInfoCard(userRole, requirements, isDark),
            const SizedBox(height: 24),
            _buildRequirementsCard(requirements, isDark),
            const SizedBox(height: 24),
            _buildUploadOptions(userRole, requirements, isDark),
            const SizedBox(height: 32),
            _buildStartUploadButton(userRole, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAllowedScreen(bool isDark) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: const Text('Upload Asset'),
        backgroundColor: AppColors.getSurface(isDark),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Asset Upload Not Available',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your current role does not support asset uploads.',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(UserRole userRole, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.upload_file,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload New Asset',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'As a ${userRole.displayName}',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Follow the role-specific upload process to add your asset to the platform.',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleInfoCard(UserRole userRole, UploadRequirements requirements, bool isDark) {
    final sourceColor = Color(int.parse(_roleToAssetSource(userRole).colorCode.substring(1), radix: 16) + 0xFF000000);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sourceColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: sourceColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${userRole.displayName} Upload',
                style: AppTextStyles.heading6.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            userRole.description,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRoleFeature(
                'Max Assets',
                requirements.maxAssetsPerUpload.toString(),
                Icons.inventory,
                isDark,
              ),
              const SizedBox(width: 24),
              _buildRoleFeature(
                'File Size',
                '${requirements.maxFileSize}MB',
                Icons.storage,
                isDark,
              ),
              const SizedBox(width: 24),
              _buildRoleFeature(
                'Bulk Upload',
                requirements.allowsBulkUpload ? 'Yes' : 'No',
                Icons.upload_multiple,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFeature(String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.getTextPrimary(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.getTextSecondary(isDark),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsCard(UploadRequirements requirements, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Upload Requirements',
                style: AppTextStyles.heading6.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Required Documents
          if (requirements.requiredDocuments.isNotEmpty) ...[
            Text(
              'Required Documents:',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...requirements.requiredDocuments.map((doc) => _buildDocumentItem(doc, true, isDark)),
            const SizedBox(height: 16),
          ],

          // Optional Documents
          if (requirements.optionalDocuments.isNotEmpty) ...[
            Text(
              'Optional Documents:',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...requirements.optionalDocuments.map((doc) => _buildDocumentItem(doc, false, isDark)),
          ],

          // Verification Requirements
          if (requirements.requiresKYC || requirements.requiresProfessionalVerification) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Required',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (requirements.requiresKYC)
                    Text(
                      '• KYC/AML verification required',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  if (requirements.requiresProfessionalVerification)
                    Text(
                      '• Professional credentials verification required',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String document, bool isRequired, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isRequired ? Icons.check_circle : Icons.check_circle_outline,
            color: isRequired ? AppColors.success : AppColors.getTextSecondary(isDark),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              document,
              style: AppTextStyles.caption.copyWith(
                color: isRequired
                  ? AppColors.getTextPrimary(isDark)
                  : AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOptions(UserRole userRole, UploadRequirements requirements, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Upload Options',
                style: AppTextStyles.heading6.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Single Upload Option (always available)
          _buildUploadOption(
            'Single Asset Upload',
            'Upload one asset with complete documentation',
            Icons.upload_file,
            true,
            isDark,
          ),

          // Bulk Upload Option (if available)
          if (requirements.allowsBulkUpload) ...[
            const SizedBox(height: 12),
            _buildUploadOption(
              'Bulk Asset Upload',
              'Upload multiple assets via CSV or individual forms',
              Icons.upload_multiple,
              true,
              isDark,
            ),
          ],

          // Bypass Verification (if allowed)
          if (requirements.canBypassVerification) ...[
            const SizedBox(height: 12),
            _buildUploadOption(
              'Express Upload',
              'Skip standard verification process (Admin privileges)',
              Icons.flash_on,
              true,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadOption(String title, String description, IconData icon, bool isEnabled, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled
          ? AppColors.getBackground(isDark)
          : AppColors.getTextSecondary(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled
            ? AppColors.getBorder(isDark)
            : AppColors.getTextSecondary(isDark).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isEnabled
              ? AppColors.primary
              : AppColors.getTextSecondary(isDark),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    color: isEnabled
                      ? AppColors.getTextPrimary(isDark)
                      : AppColors.getTextSecondary(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: isEnabled
                      ? AppColors.getTextSecondary(isDark)
                      : AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          if (isEnabled)
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.getTextSecondary(isDark),
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildStartUploadButton(UserRole userRole, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _startUpload(userRole),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Start Upload Process',
          style: AppTextStyles.button.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _startUpload(UserRole userRole) {
    AssetUploadRouter.navigateToUpload(context, userRole);
  }

  // Convert user role to asset source
  AssetSource _roleToAssetSource(UserRole userRole) {
    switch (userRole) {
      case UserRole.superAdmin:
      case UserRole.admin:
        return AssetSource.superAdmin;
      case UserRole.bankAdmin:
      case UserRole.bankOperations:
      case UserRole.bankWhiteLabel:
        return AssetSource.bankAdmin;
      case UserRole.professionalAgent:
        return AssetSource.professionalAgent;
      case UserRole.investorAgent:
        return AssetSource.individual;
      case UserRole.verifier:
        return AssetSource.individual;
    }
  }
}