import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/asset.dart';
import '../../models/asset_verification.dart';

class AssetVerificationScreen extends ConsumerStatefulWidget {
  final Asset asset;

  const AssetVerificationScreen({
    super.key,
    required this.asset,
  });

  @override
  ConsumerState<AssetVerificationScreen> createState() => _AssetVerificationScreenState();
}

class _AssetVerificationScreenState extends ConsumerState<AssetVerificationScreen> {
  AssetVerificationType? _selectedType;
  final TextEditingController _notesController = TextEditingController();
  List<String> _selectedPhotos = [];
  List<String> _selectedVideos = [];
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Verify Asset',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Info
            _buildAssetInfo(),
            const SizedBox(height: 24),

            // Verification Type Selection
            _buildVerificationTypeSelection(),
            const SizedBox(height: 24),

            // Conditional Content based on selected type
            if (_selectedType != null) ...[
              _buildVerificationContent(),
              const SizedBox(height: 24),
            ],

            // Submit Button
            if (_selectedType != null)
              _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getAssetIcon(widget.asset.type),
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.asset.title,
                  style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Asset ID: ${widget.asset.spvId}',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          if (widget.asset.location != null)
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.asset.location!.fullAddress,
                    style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Verification Method',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        ...AssetVerificationType.values.map((type) => _buildVerificationTypeCard(type)),
      ],
    );
  }

  Widget _buildVerificationTypeCard(AssetVerificationType type) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<AssetVerificationType>(
              value: type,
              groupValue: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.description,
                    style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationContent() {
    switch (_selectedType!) {
      case AssetVerificationType.selfVerification:
        return _buildSelfVerificationContent();
      case AssetVerificationType.professionalAgent:
        return _buildProfessionalAgentContent();
      case AssetVerificationType.verificationAgent:
        return _buildVerificationAgentContent();
    }
  }

  Widget _buildSelfVerificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Proof of Inspection',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),

        // Photo Upload
        _buildFileUploadSection(
          'Photos',
          'Upload photos of the asset showing different angles and key features',
          _selectedPhotos,
          () => _pickFiles(FileType.image, _selectedPhotos),
          Icons.photo_camera,
        ),
        const SizedBox(height: 16),

        // Video Upload
        _buildFileUploadSection(
          'Videos',
          'Upload videos showing a walkthrough of the asset',
          _selectedVideos,
          () => _pickFiles(FileType.video, _selectedVideos),
          Icons.videocam,
        ),
        const SizedBox(height: 16),

        // Notes
        _buildNotesSection(),
      ],
    );
  }

  Widget _buildProfessionalAgentContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Hire Professional Agent',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Connect with certified professional agents in your area who can inspect the asset on your behalf.',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _buildNotesSection(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAgentSelection(),
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text('Find Agents Near Asset', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationAgentContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Certified Verification Agent',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Our certified verification agents provide thorough asset inspections with detailed reports.',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Estimated Cost: \$150 - \$300',
                  style: AppTextStyles.body1.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildNotesSection(),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection(
    String title,
    String description,
    List<String> selectedFiles,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surface,
            ),
            child: Column(
              children: [
                Icon(icon, size: 32, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(
                  'Tap to select ${title.toLowerCase()}',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
                if (selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${selectedFiles.length} file(s) selected',
                    style: AppTextStyles.body2.copyWith(color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any specific observations or requirements...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _getSubmitButtonText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  String _getSubmitButtonText() {
    switch (_selectedType!) {
      case AssetVerificationType.selfVerification:
        return 'Submit Verification';
      case AssetVerificationType.professionalAgent:
        return 'Request Professional Agent';
      case AssetVerificationType.verificationAgent:
        return 'Book Verification Agent';
    }
  }

  IconData _getAssetIcon(String type) {
    switch (type) {
      case 'house':
        return Icons.home;
      case 'hotel':
        return Icons.hotel;
      case 'truck':
        return Icons.local_shipping;
      case 'land':
        return Icons.landscape;
      default:
        return Icons.business;
    }
  }

  Future<void> _pickFiles(FileType fileType, List<String> targetList) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          targetList.addAll(result.files.map((file) => file.path ?? ''));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _showAgentSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Professional Agents'),
        content: const Text('This feature will show available professional agents near the asset location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVerification() async {
    setState(() => _isSubmitting = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getSuccessMessage()),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting verification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getSuccessMessage() {
    switch (_selectedType!) {
      case AssetVerificationType.selfVerification:
        return 'Verification submitted successfully! It will be reviewed within 24-48 hours.';
      case AssetVerificationType.professionalAgent:
        return 'Professional agent request submitted! We\'ll connect you with available agents.';
      case AssetVerificationType.verificationAgent:
        return 'Verification agent booking submitted! You\'ll receive confirmation within 24 hours.';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}