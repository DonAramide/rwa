import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_service.dart';
import '../../models/asset_upload_models.dart';
import '../../models/user_role.dart';
import '../../providers/asset_upload_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/asset_upload_service.dart';

class UnifiedAssetUploadScreen extends ConsumerStatefulWidget {
  const UnifiedAssetUploadScreen({super.key});

  @override
  ConsumerState<UnifiedAssetUploadScreen> createState() => _UnifiedAssetUploadScreenState();
}

class _UnifiedAssetUploadScreenState extends ConsumerState<UnifiedAssetUploadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _totalValueController = TextEditingController();
  final _pricePerShareController = TextEditingController();
  final _totalSharesController = TextEditingController();

  // State variables
  String _selectedAssetType = '';
  AssetListingType _selectedListingType = AssetListingType.fullSale;
  final List<File> _selectedDocuments = [];
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize upload when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        ref.read(assetUploadProvider.notifier).initializeUpload(
          userRole: authState.role,
          uploaderId: authState.userId ?? 'unknown',
          uploaderName: authState.email ?? 'Unknown User',
          uploaderEmail: authState.email ?? '',
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _totalValueController.dispose();
    _pricePerShareController.dispose();
    _totalSharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(assetUploadProvider);
    final authState = ref.read(authProvider);
    final requirements = ref.watch(uploadRequirementsProvider(authState.role));

    return Scaffold(
      backgroundColor: ThemeService.getScaffoldBackground(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Asset',
              style: AppTextStyles.heading3.copyWith(
                color: ThemeService.getTextPrimary(context),
              ),
            ),
            Text(
              AssetUploadService.getUploadSourceFromRole(authState.role).displayName,
              style: AppTextStyles.caption.copyWith(
                color: ThemeService.getTextSecondary(context),
              ),
            ),
          ],
        ),
        backgroundColor: ThemeService.getAppBarBackground(context),
        elevation: 0,
        actions: [
          // Progress indicator
          Consumer(
            builder: (context, ref, child) {
              final progress = ref.watch(currentUploadProgressProvider);
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: ThemeService.getTextSecondary(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: ThemeService.getBorder(context),
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: ThemeService.getTextSecondary(context),
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Pricing'),
            Tab(text: 'Documents'),
            Tab(text: 'Review'),
          ],
        ),
      ),
      body: uploadState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(context, requirements),
                _buildPricingTab(context, requirements),
                _buildDocumentsTab(context, requirements),
                _buildReviewTab(context, requirements),
              ],
            ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, UploadRequirements requirements) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              'Upload Requirements',
              'As a ${requirements.source.displayName}, you can upload up to ${_formatCurrency(requirements.maxAssetValue)} in asset value.',
              AppColors.info,
            ),

            const SizedBox(height: 24),

            // Asset Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Asset Title *',
                hintText: 'e.g., Premium Office Complex, Lagos',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.business),
              ),
              validator: (value) => value?.isEmpty == true ? 'Asset title is required' : null,
              onChanged: (value) => _updateUploadDetails(),
            ),

            const SizedBox(height: 16),

            // Asset Type
            DropdownButtonFormField<String>(
              value: _selectedAssetType.isEmpty ? null : _selectedAssetType,
              decoration: InputDecoration(
                labelText: 'Asset Type *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _getAssetTypes().map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAssetType = value ?? '';
                });
                _updateUploadDetails();
              },
              validator: (value) => value?.isEmpty == true ? 'Asset type is required' : null,
            ),

            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location *',
                hintText: 'e.g., Victoria Island, Lagos State',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.location_on),
              ),
              validator: (value) => value?.isEmpty == true ? 'Location is required' : null,
              onChanged: (value) => _updateUploadDetails(),
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Detailed description of the asset...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
              validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
              onChanged: (value) => _updateUploadDetails(),
            ),

            const SizedBox(height: 24),

            // Asset Value
            TextFormField(
              controller: _totalValueController,
              decoration: InputDecoration(
                labelText: 'Total Asset Value *',
                hintText: '0.00',
                prefixText: '₦ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Asset value is required';
                final amount = double.tryParse(value!.replaceAll(',', ''));
                if (amount == null || amount <= 0) return 'Enter a valid amount';
                if (amount > requirements.maxAssetValue) {
                  return 'Exceeds maximum allowed (${_formatCurrency(requirements.maxAssetValue)})';
                }
                return null;
              },
              onChanged: (value) => _updateUploadDetails(),
            ),

            const SizedBox(height: 24),

            // Tags
            _buildTagsSection(context),

            const SizedBox(height: 32),

            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    _tabController.animateTo(1);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Next: Pricing',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTab(BuildContext context, UploadRequirements requirements) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Listing Type',
            style: AppTextStyles.heading4.copyWith(
              color: ThemeService.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 16),

          // Listing type selection
          ...requirements.allowedListingTypes.map((type) =>
            RadioListTile<AssetListingType>(
              title: Text(type.displayName),
              subtitle: Text(_getListingTypeDescription(type)),
              value: type,
              groupValue: _selectedListingType,
              onChanged: (value) {
                setState(() {
                  _selectedListingType = value!;
                });
                _updateUploadDetails();
              },
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          // Fractional sale options
          if (_selectedListingType == AssetListingType.fractionalSale) ...[
            _buildInfoCard(
              context,
              'Fractional Sale Setup',
              'Configure how your asset will be divided into shares for investors.',
              AppColors.warning,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalSharesController,
                    decoration: InputDecoration(
                      labelText: 'Total Shares *',
                      hintText: '100',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.pie_chart),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateUploadDetails(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _pricePerShareController,
                    decoration: InputDecoration(
                      labelText: 'Price per Share *',
                      hintText: '0.00',
                      prefixText: '₦ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.money),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateUploadDetails(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tokenization info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.token, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tokenization Preview',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_totalSharesController.text.isNotEmpty && _pricePerShareController.text.isNotEmpty)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Token Symbol:'),
                            Text(_generateTokenSymbol(_titleController.text), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Supply:'),
                            Text('${_totalSharesController.text} tokens', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Market Cap:'),
                            Text('₦${_formatCurrency(_calculateMarketCap())}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _tabController.animateTo(0),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _tabController.animateTo(2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Next: Documents',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(BuildContext context, UploadRequirements requirements) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            'Required Documents',
            'Upload the following documents to verify your asset ownership and comply with regulations.',
            AppColors.success,
          ),

          const SizedBox(height: 24),

          // Required documents
          if (requirements.requiredDocuments.isNotEmpty) ...[
            Text(
              'Required Documents',
              style: AppTextStyles.heading4.copyWith(
                color: ThemeService.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            ...requirements.requiredDocuments.map((docType) =>
              _buildDocumentUploadCard(context, docType, true)
            ),
          ],

          const SizedBox(height: 24),

          // Optional documents
          if (requirements.optionalDocuments.isNotEmpty) ...[
            Text(
              'Optional Documents',
              style: AppTextStyles.heading4.copyWith(
                color: ThemeService.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            ...requirements.optionalDocuments.map((docType) =>
              _buildDocumentUploadCard(context, docType, false)
            ),
          ],

          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _tabController.animateTo(1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _tabController.animateTo(3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Next: Review',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab(BuildContext context, UploadRequirements requirements) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: AppTextStyles.heading3.copyWith(
              color: ThemeService.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review all information before submitting your asset upload.',
            style: AppTextStyles.body2.copyWith(
              color: ThemeService.getTextSecondary(context),
            ),
          ),

          const SizedBox(height: 24),

          // Asset summary
          _buildReviewCard(
            context,
            'Asset Details',
            [
              'Title: ${_titleController.text}',
              'Type: $_selectedAssetType',
              'Location: ${_locationController.text}',
              'Value: ₦${_formatCurrency(double.tryParse(_totalValueController.text.replaceAll(',', '')) ?? 0)}',
              'Listing: ${_selectedListingType.displayName}',
            ],
          ),

          const SizedBox(height: 16),

          // Pricing summary
          if (_selectedListingType == AssetListingType.fractionalSale)
            _buildReviewCard(
              context,
              'Tokenization Details',
              [
                'Total Shares: ${_totalSharesController.text}',
                'Price per Share: ₦${_pricePerShareController.text}',
                'Token Symbol: ${_generateTokenSymbol(_titleController.text)}',
                'Market Cap: ₦${_formatCurrency(_calculateMarketCap())}',
              ],
            ),

          const SizedBox(height: 16),

          // Documents summary
          _buildReviewCard(
            context,
            'Documents',
            [
              'Total Documents: ${_selectedDocuments.length}',
              'Required Docs: ${requirements.requiredDocuments.length}',
              'Status: ${_selectedDocuments.length >= requirements.requiredDocuments.length ? "Complete" : "Incomplete"}',
            ],
          ),

          const SizedBox(height: 24),

          // Validation results
          Consumer(
            builder: (context, ref, child) {
              final validation = ref.read(assetUploadProvider.notifier).validateCurrentUpload(_selectedDocuments);
              if (validation == null) return const SizedBox();

              return Column(
                children: [
                  if (validation.errors.isNotEmpty)
                    _buildValidationCard(context, 'Errors', validation.errors, AppColors.error),
                  if (validation.warnings.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildValidationCard(context, 'Warnings', validation.warnings, AppColors.warning),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit() ? _submitUpload : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Submit Asset Upload',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton(
            onPressed: () => _tabController.animateTo(2),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Previous: Documents'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.body2.copyWith(
              color: ThemeService.getTextPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (Optional)',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: ThemeService.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) => Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
                _updateUploadDetails();
              },
            )),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add Tag'),
              onPressed: _showAddTagDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard(BuildContext context, AssetDocumentType docType, bool isRequired) {
    final hasUploaded = _selectedDocuments.any((file) =>
      file.path.toLowerCase().contains(docType.name.toLowerCase()));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: ThemeService.getCardBackground(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hasUploaded ? AppColors.success.withOpacity(0.2) : AppColors.textSecondary.withOpacity(0.2),
          child: Icon(
            hasUploaded ? Icons.check : Icons.upload_file,
            color: hasUploaded ? AppColors.success : AppColors.textSecondary,
            size: 20,
          ),
        ),
        title: Text(docType.displayName),
        subtitle: Text(isRequired ? 'Required' : 'Optional'),
        trailing: hasUploaded
            ? Icon(Icons.check_circle, color: AppColors.success)
            : OutlinedButton(
                onPressed: () => _pickDocument(docType),
                child: const Text('Upload'),
              ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, String title, List<String> details) {
    return Card(
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.heading4.copyWith(
                color: ThemeService.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                detail,
                style: AppTextStyles.body2.copyWith(
                  color: ThemeService.getTextSecondary(context),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationCard(BuildContext context, String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body1.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color)),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.body2.copyWith(color: color),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Helper methods
  void _updateUploadDetails() {
    ref.read(assetUploadProvider.notifier).updateUploadDetails(
      title: _titleController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      assetType: _selectedAssetType,
      listingType: _selectedListingType,
      totalValue: double.tryParse(_totalValueController.text.replaceAll(',', '')) ?? 0,
      pricePerShare: double.tryParse(_pricePerShareController.text.replaceAll(',', '')),
      totalShares: int.tryParse(_totalSharesController.text),
      tags: _tags,
    );
  }

  List<String> _getAssetTypes() {
    return [
      'Real Estate - Residential',
      'Real Estate - Commercial',
      'Real Estate - Industrial',
      'Vehicle - Car',
      'Vehicle - Truck',
      'Vehicle - Bus',
      'Land - Agricultural',
      'Land - Residential',
      'Land - Commercial',
      'Equipment - Construction',
      'Equipment - Manufacturing',
      'Other',
    ];
  }

  String _getListingTypeDescription(AssetListingType type) {
    switch (type) {
      case AssetListingType.fullSale:
        return 'Sell the entire asset to one buyer';
      case AssetListingType.fractionalSale:
        return 'Divide asset into shares for multiple investors';
      case AssetListingType.rental:
        return 'Generate rental income for investors';
      case AssetListingType.development:
        return 'Fund development project with investor capital';
    }
  }

  String _generateTokenSymbol(String title) {
    if (title.isEmpty) return 'TOKEN';
    final words = title.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return '${words[0].substring(0, 3)}${words[1].substring(0, 2)}'.toUpperCase();
    } else {
      return title.substring(0, 5).toUpperCase();
    }
  }

  double _calculateMarketCap() {
    final shares = int.tryParse(_totalSharesController.text) ?? 0;
    final price = double.tryParse(_pricePerShareController.text.replaceAll(',', '')) ?? 0;
    return shares * price;
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty && !_tags.contains(controller.text)) {
                setState(() {
                  _tags.add(controller.text);
                });
                _updateUploadDetails();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _pickDocument(AssetDocumentType docType) {
    // TODO: Implement file picker
    // For now, add a mock file
    // final file = File('/mock/path/${docType.name}.pdf');
    // setState(() {
    //   _selectedDocuments.add(file);
    // });
  }

  bool _canSubmit() {
    return _titleController.text.isNotEmpty &&
           _descriptionController.text.isNotEmpty &&
           _locationController.text.isNotEmpty &&
           _selectedAssetType.isNotEmpty &&
           _totalValueController.text.isNotEmpty;
  }

  void _submitUpload() async {
    final success = await ref.read(assetUploadProvider.notifier).submitUpload(
      documentFiles: _selectedDocuments,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asset upload submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(assetUploadProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}