import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/asset.dart';
import '../../models/user_role.dart';
import '../../services/asset_upload_service.dart';
import '../../providers/auth_provider.dart';

class IndividualUploadScreen extends ConsumerStatefulWidget {
  const IndividualUploadScreen({super.key});

  @override
  ConsumerState<IndividualUploadScreen> createState() => _IndividualUploadScreenState();
}

class _IndividualUploadScreenState extends ConsumerState<IndividualUploadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _kycCompleted = false;

  // Form controllers
  final _assetNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _expectedValueController = TextEditingController();
  final _ownershipDetailsController = TextEditingController();

  // KYC Controllers
  final _fullNameController = TextEditingController();
  final _bvnController = TextEditingController();
  final _ninController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Asset details
  String _selectedAssetType = 'Real Estate';
  String _selectedOwnershipType = 'full';
  double _ownershipPercentage = 100.0;

  // Media files
  List<XFile> _images = [];
  List<PlatformFile> _documents = [];
  List<PlatformFile> _kycDocuments = [];

  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _assetTypes = [
    'Real Estate',
    'Residential Property',
    'Commercial Property',
    'Land',
    'Vehicle',
    'Agricultural Land',
    'Equipment',
    'Other'
  ];

  final List<String> _ownershipTypes = [
    'full',
    'partial',
    'co-owned'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadUserKycData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _assetNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _purchasePriceController.dispose();
    _expectedValueController.dispose();
    _ownershipDetailsController.dispose();
    _fullNameController.dispose();
    _bvnController.dispose();
    _ninController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserKycData() {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      _fullNameController.text = authState.user?.name ?? '';
      _emailController.text = authState.user?.email ?? '';
      // TODO: Load other KYC data from user profile
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFFFF9800),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Individual Upload'),
          ],
        ),
        backgroundColor: AppColors.getSurface(isDark),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.getTextSecondary(isDark),
          isScrollable: true,
          tabs: [
            Tab(
              text: 'KYC',
              icon: Icon(
                _kycCompleted ? Icons.verified_user : Icons.person_outline,
                color: _kycCompleted ? Colors.green : null,
              ),
            ),
            const Tab(text: 'Details', icon: Icon(Icons.info_outline)),
            const Tab(text: 'Ownership', icon: Icon(Icons.account_balance)),
            const Tab(text: 'Media', icon: Icon(Icons.photo_library)),
            const Tab(text: 'Documents', icon: Icon(Icons.description)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildKycTab(isDark),
            _buildDetailsTab(isDark),
            _buildOwnershipTab(isDark),
            _buildMediaTab(isDark),
            _buildDocumentsTab(isDark),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          border: Border(
            top: BorderSide(color: AppColors.getBorder(isDark)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.getBorder(isDark)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting || !_kycCompleted ? null : _submitAsset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        !_kycCompleted ? 'Complete KYC First' : 'Submit for Review',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKycTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KYC Status Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kycCompleted
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _kycCompleted
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _kycCompleted ? Icons.verified_user : Icons.warning_amber,
                  color: _kycCompleted ? Colors.green : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _kycCompleted ? 'KYC Verification Complete' : 'KYC Verification Required',
                        style: AppTextStyles.heading6.copyWith(
                          color: _kycCompleted ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _kycCompleted
                            ? 'Your identity has been verified'
                            : 'Complete your identity verification to upload assets',
                        style: AppTextStyles.body2.copyWith(
                          color: _kycCompleted ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Personal Information',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Full Name
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name *',
              hintText: 'As per government ID',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // BVN and NIN Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bvnController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'BVN *',
                    hintText: '12345678901',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.credit_card),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'BVN is required';
                    }
                    if (value.length != 11) {
                      return 'BVN must be 11 digits';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _ninController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'NIN *',
                    hintText: '12345678901',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIN is required';
                    }
                    if (value.length != 11) {
                      return 'NIN must be 11 digits';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Phone and Email Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: '+234 xxx xxx xxxx',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'you@email.com',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KYC Documents Section
          Text(
            'Required KYC Documents',
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildKycDocumentSection('Government ID', 'Upload valid government-issued ID', isDark),
          const SizedBox(height: 12),
          _buildKycDocumentSection('Utility Bill', 'Recent utility bill (not older than 3 months)', isDark),
          const SizedBox(height: 24),

          // Verify KYC Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _kycCompleted ? null : _verifyKyc,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kycCompleted ? Colors.green : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _kycCompleted ? 'KYC Verified ✓' : 'Verify KYC Information',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycDocumentSection(String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.upload_file,
            color: AppColors.primary,
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
                    color: AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _pickKycDocument(title),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Information',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Asset Name
          TextFormField(
            controller: _assetNameController,
            decoration: InputDecoration(
              labelText: 'Asset Name *',
              hintText: 'e.g., My Family House in Lagos',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Asset name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Asset Type
          DropdownButtonFormField<String>(
            value: _selectedAssetType,
            decoration: InputDecoration(
              labelText: 'Asset Type *',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
            items: _assetTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAssetType = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Asset Description *',
              hintText: 'Describe your asset in detail...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Location
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Asset Location *',
              hintText: 'Full address of the asset',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              prefixIcon: const Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Asset location is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOwnershipTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ownership Information',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Ownership Type
          DropdownButtonFormField<String>(
            value: _selectedOwnershipType,
            decoration: InputDecoration(
              labelText: 'Ownership Type *',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
            items: _ownershipTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedOwnershipType = value!;
                if (value == 'full') {
                  _ownershipPercentage = 100.0;
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Ownership Percentage
          if (_selectedOwnershipType != 'full') ...[
            Text(
              'Ownership Percentage: ${_ownershipPercentage.toInt()}%',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            Slider(
              value: _ownershipPercentage,
              min: 1,
              max: 100,
              divisions: 99,
              label: '${_ownershipPercentage.toInt()}%',
              onChanged: (value) {
                setState(() {
                  _ownershipPercentage = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],

          // Purchase Price
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _purchasePriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Purchase Price (₦)',
                    hintText: 'e.g., 5000000',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _expectedValueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Current Value (₦)',
                    hintText: 'e.g., 6000000',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.trending_up),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ownership Details
          TextFormField(
            controller: _ownershipDetailsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Ownership Details',
              hintText: 'Additional ownership information, co-owners, etc.',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Media',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload photos of your asset (max 10 images)',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 24),

          // Images Section
          _buildMediaSection(
            title: 'Asset Photos',
            subtitle: 'Upload up to 10 images (JPG, PNG)',
            icon: Icons.photo_library,
            onTap: _pickImages,
            isDark: isDark,
            children: [
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_images[index].path),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(bool isDark) {
    final requirements = AssetUploadService.getUploadRequirements(UserRole.investorAgent);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Documents',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Required Documents List
          ...requirements.requiredDocuments.map((doc) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.getSurface(isDark),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      doc,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDocument(doc),
                    child: const Text('Upload'),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          // Upload Documents Button
          Container(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickDocuments,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Additional Documents'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Uploaded Documents List
          if (_documents.isNotEmpty) ...[
            Text(
              'Uploaded Documents',
              style: AppTextStyles.heading6.copyWith(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._documents.asMap().entries.map((entry) {
              final index = entry.key;
              final document = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.getBorder(isDark)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(document.extension ?? ''),
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.name,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.getTextPrimary(isDark),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatFileSize(document.size),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeDocument(index),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    List<Widget>? children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: AppTextStyles.heading6.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (children != null) ...children,
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      setState(() {
        _images.addAll(images.take(10 - _images.length));
      });
    } catch (e) {
      _showErrorSnackBar('Error picking images: $e');
    }
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _documents.addAll(result.files);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking documents: $e');
    }
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _documents.addAll(result.files);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking document: $e');
    }
  }

  Future<void> _pickKycDocument(String documentType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _kycDocuments.addAll(result.files);
        });
        _showSuccessSnackBar('$documentType uploaded successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Error picking KYC document: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _verifyKyc() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if required KYC documents are uploaded
    if (_kycDocuments.length < 2) {
      _showErrorSnackBar('Please upload all required KYC documents');
      return;
    }

    // TODO: Implement actual KYC verification via API
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    setState(() {
      _kycCompleted = true;
    });

    _showSuccessSnackBar('KYC verification completed successfully!');
  }

  Future<void> _submitAsset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      _showErrorSnackBar('Please upload at least one asset photo');
      return;
    }

    if (_documents.isEmpty) {
      _showErrorSnackBar('Please upload required documents');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id ?? 'individual_001';

      // Create upload metadata
      final uploadMetadata = AssetUploadService.createUploadMetadata(
        userRole: UserRole.investorAgent,
        uploaderId: userId,
        uploaderName: authState.user?.name ?? _fullNameController.text,
        uploaderEmail: authState.user?.email ?? _emailController.text,
        customMetadata: {
          'ownershipType': _selectedOwnershipType,
          'ownershipPercentage': _ownershipPercentage,
          'kycCompleted': _kycCompleted,
          'bvn': _bvnController.text,
          'nin': _ninController.text,
          'uploadTimestamp': DateTime.now().toIso8601String(),
        },
        verificationDocuments: _documents.map((doc) => doc.name).toList(),
        notes: 'Individual user upload - KYC completed',
      );

      // Create asset data
      final assetData = {
        'title': _assetNameController.text,
        'type': _selectedAssetType,
        'status': 'pending',
        'description': _descriptionController.text,
        'address': _addressController.text,
        'purchasePrice': _purchasePriceController.text,
        'currentValue': _expectedValueController.text,
        'ownershipType': _selectedOwnershipType,
        'ownershipPercentage': _ownershipPercentage,
        'verification_required': true,
        'uploadMetadata': uploadMetadata.toJson(),
        'imageCount': _images.length,
        'documentCount': _documents.length,
        'kycCompleted': _kycCompleted,
        'createdBy': 'individual',
      };

      // TODO: Upload files and submit asset via API
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asset submitted for review successfully! You will be notified once verified.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorSnackBar('Error submitting asset: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}