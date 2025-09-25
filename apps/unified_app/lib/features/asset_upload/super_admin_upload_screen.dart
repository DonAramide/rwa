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

class SuperAdminUploadScreen extends ConsumerStatefulWidget {
  const SuperAdminUploadScreen({super.key});

  @override
  ConsumerState<SuperAdminUploadScreen> createState() => _SuperAdminUploadScreenState();
}

class _SuperAdminUploadScreenState extends ConsumerState<SuperAdminUploadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _bypassVerification = true;
  bool _isPlatformAsset = false;

  // Form controllers
  final _assetNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _navController = TextEditingController();
  final _spvIdController = TextEditingController();
  final _notesController = TextEditingController();

  // Asset details
  String _selectedAssetType = 'Real Estate';
  String _selectedStatus = 'active';

  // Media files
  List<XFile> _images = [];
  List<PlatformFile> _documents = [];
  XFile? _videoFile;

  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _assetTypes = [
    'Real Estate',
    'Commercial Property',
    'Residential Property',
    'Industrial Property',
    'Agricultural Land',
    'Transportation',
    'Precious Metals',
    'Financial Instruments',
    'Sustainable Assets',
    'Development Project'
  ];

  final List<String> _assetStatuses = [
    'active',
    'pending',
    'verified',
    'suspended',
    'draft'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _assetNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _navController.dispose();
    _spvIdController.dispose();
    _notesController.dispose();
    super.dispose();
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
                color: const Color(0xFFFF5722).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Color(0xFFFF5722),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Super Admin Upload'),
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
          tabs: const [
            Tab(text: 'Details', icon: Icon(Icons.info_outline)),
            Tab(text: 'Media', icon: Icon(Icons.photo_library)),
            Tab(text: 'Location', icon: Icon(Icons.location_on)),
            Tab(text: 'Admin', icon: Icon(Icons.admin_panel_settings)),
            Tab(text: 'Documents', icon: Icon(Icons.description)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(isDark),
            _buildMediaTab(isDark),
            _buildLocationTab(isDark),
            _buildAdminTab(isDark),
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
                onPressed: _isSubmitting ? null : _submitAsset,
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
                        _bypassVerification ? 'Upload Directly' : 'Submit for Review',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
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
              hintText: 'e.g., Premium Manhattan Apartment',
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

          // Asset Type and Status Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                  ),
                  items: _assetStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // NAV and SPV ID Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _navController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Net Asset Value (\$) *',
                    hintText: 'e.g., 2500000',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NAV is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _spvIdController,
                  decoration: InputDecoration(
                    labelText: 'SPV ID',
                    hintText: 'e.g., SPV-2024-001',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description *',
              hintText: 'Provide detailed description of the asset...',
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
            'Upload high-quality media files for the asset',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 24),

          // Images Section
          _buildMediaSection(
            title: 'Asset Images',
            subtitle: 'Upload up to 20 images (JPG, PNG, WebP)',
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
          const SizedBox(height: 24),

          // Video Section
          _buildMediaSection(
            title: 'Asset Video',
            subtitle: 'Upload walkthrough or promotional video (MP4, MOV)',
            icon: Icons.videocam,
            onTap: _pickVideo,
            isDark: isDark,
            children: [
              if (_videoFile != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.getSurface(isDark),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.getBorder(isDark)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.video_file,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _videoFile!.name,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _videoFile = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Location',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Address
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Property Address',
              hintText: 'Full address of the asset',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              prefixIcon: const Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 16),

          // TODO: Add map integration, coordinates input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: AppColors.getTextSecondary(isDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Map Integration',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coming Soon',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Controls',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Super Admin privileges and controls',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 24),

          // Bypass Verification Toggle
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
                    Icon(
                      Icons.security,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Verification Controls',
                      style: AppTextStyles.heading6.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Bypass Verification Process'),
                  subtitle: const Text('Skip standard verification and approve immediately'),
                  value: _bypassVerification,
                  onChanged: (value) {
                    setState(() {
                      _bypassVerification = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Platform Asset Toggle
          Container(
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
                      Icons.business,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Asset Ownership',
                      style: AppTextStyles.heading6.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Platform-Owned Asset'),
                  subtitle: const Text('Mark as platform demo/showcase asset'),
                  value: _isPlatformAsset,
                  onChanged: (value) {
                    setState(() {
                      _isPlatformAsset = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Admin Notes
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Admin Notes',
              hintText: 'Internal notes for this asset upload...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supporting Documents',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional: Upload supporting documentation',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 24),

          // Upload Documents Button
          Container(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickDocuments,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Documents'),
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
        _images.addAll(images.take(20 - _images.length));
      });
    } catch (e) {
      _showErrorSnackBar('Error picking images: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _videoFile = video;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking video: $e');
    }
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'csv', 'xlsx'],
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
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'csv':
      case 'xlsx':
        return Icons.table_chart;
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

  Future<void> _submitAsset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id ?? 'super_admin_001';

      // Create upload metadata
      final uploadMetadata = AssetUploadService.createUploadMetadata(
        userRole: UserRole.superAdmin,
        uploaderId: userId,
        uploaderName: authState.user?.name ?? 'Super Admin',
        uploaderEmail: authState.user?.email,
        originalSource: _isPlatformAsset ? 'platform' : 'super_admin',
        customMetadata: {
          'bypassVerification': _bypassVerification,
          'isPlatformAsset': _isPlatformAsset,
          'uploadTimestamp': DateTime.now().toIso8601String(),
        },
        verificationDocuments: _documents.map((doc) => doc.name).toList(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Create asset data
      final assetData = {
        'title': _assetNameController.text,
        'type': _selectedAssetType,
        'status': _bypassVerification ? 'active' : _selectedStatus,
        'nav': _navController.text,
        'spv_id': _spvIdController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'verification_required': !_bypassVerification,
        'uploadMetadata': uploadMetadata.toJson(),
        'imageCount': _images.length,
        'documentCount': _documents.length,
        'hasVideo': _videoFile != null,
        'createdBy': 'super_admin',
        'bypassVerification': _bypassVerification,
      };

      // TODO: Upload files and submit asset via API
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _bypassVerification
                  ? 'Asset uploaded and activated successfully!'
                  : 'Asset submitted for review successfully!',
            ),
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