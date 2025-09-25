import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NewAssetProposalScreen extends StatefulWidget {
  const NewAssetProposalScreen({super.key});

  @override
  State<NewAssetProposalScreen> createState() => _NewAssetProposalScreenState();
}

class _NewAssetProposalScreenState extends State<NewAssetProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assetNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void dispose() {
    _assetNameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'New Asset Proposal',
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
        ),
        backgroundColor: AppColors.getSurface(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.getTextPrimary(isDark)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Asset Proposal',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit a new asset proposal for review',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: 32),

              _buildFormField(
                'Asset Name',
                _assetNameController,
                'Enter the name of the asset',
                isDark,
              ),
              const SizedBox(height: 20),

              _buildFormField(
                'Asset Value',
                _valueController,
                'Enter the estimated value',
                isDark,
                keyboardType: TextInputType.number,
                prefix: '\$',
              ),
              const SizedBox(height: 20),

              _buildFormField(
                'Description',
                _descriptionController,
                'Provide a detailed description of the asset',
                isDark,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.getBorder(isDark)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitProposal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Submit Proposal',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint,
    bool isDark, {
    TextInputType? keyboardType,
    String? prefix,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.getTextPrimary(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.getTextSecondary(isDark)),
            prefixText: prefix,
            prefixStyle: TextStyle(color: AppColors.getTextPrimary(isDark)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.getSurface(isDark),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _submitProposal() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement proposal submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asset proposal submitted successfully!'),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}