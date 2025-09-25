import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/merchant_models.dart';
import '../../providers/super_admin_provider.dart';

class NewMerchantSetupScreen extends ConsumerStatefulWidget {
  const NewMerchantSetupScreen({super.key});

  @override
  ConsumerState<NewMerchantSetupScreen> createState() => _NewMerchantSetupScreenState();
}

class _NewMerchantSetupScreenState extends ConsumerState<NewMerchantSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form controllers - Basic Information
  final _merchantNameController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form controllers - Domain & Branding
  final _primaryDomainController = TextEditingController();
  final _subdomainController = TextEditingController();
  final _brandingNotesController = TextEditingController();

  // Form controllers - Financial Terms
  final _commissionRateController = TextEditingController();
  final _revenueShareController = TextEditingController();
  final _minimumInvestmentController = TextEditingController();
  final _setupFeeController = TextEditingController();
  final _monthlyFeeController = TextEditingController();

  // Form controllers - Contact Information
  final _primaryContactNameController = TextEditingController();
  final _primaryContactEmailController = TextEditingController();
  final _primaryContactPhoneController = TextEditingController();
  final _technicalContactNameController = TextEditingController();
  final _technicalContactEmailController = TextEditingController();
  final _businessContactNameController = TextEditingController();
  final _businessContactEmailController = TextEditingController();

  // Form controllers - Compliance
  final _regulatoryLicenseController = TextEditingController();
  final _kycRequirementsController = TextEditingController();
  final _complianceNotesController = TextEditingController();

  // Dropdown selections
  String _selectedBankType = 'Commercial Bank';
  String _selectedStatus = 'pending';
  String _selectedTier = 'Standard';
  String _selectedRegion = 'North America';
  String _selectedCountry = 'United States';
  bool _hasApiAccess = true;
  bool _allowsBulkUpload = true;
  bool _requiresKYC = true;
  bool _requiresManualApproval = true;
  bool _isWhiteLabel = true;

  // Documents
  List<PlatformFile> _legalDocuments = [];
  List<PlatformFile> _complianceDocuments = [];

  final List<String> _bankTypes = [
    'Commercial Bank',
    'Investment Bank',
    'Credit Union',
    'Savings Bank',
    'Cooperative Bank',
    'Online Bank',
    'Merchant Bank',
    'Private Bank',
    'Development Bank',
    'Other Financial Institution'
  ];

  final List<String> _statusOptions = [
    'pending',
    'active',
    'suspended',
    'under_review'
  ];

  final List<String> _tierOptions = [
    'Basic',
    'Standard',
    'Premium',
    'Enterprise'
  ];

  final List<String> _regionOptions = [
    'North America',
    'Europe',
    'Asia Pacific',
    'Africa',
    'Middle East',
    'Latin America',
    'Global'
  ];

  final List<String> _countryOptions = [
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Australia',
    'Singapore',
    'Hong Kong',
    'Japan',
    'South Korea',
    'Brazil',
    'Mexico',
    'South Africa',
    'Nigeria',
    'Kenya',
    'United Arab Emirates',
    'India',
    'China',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadDefaultSettings();
  }

  void _loadDefaultSettings() {
    // Load default values from platform settings or leave empty for user input
    // These can be configured from platform settings
    final defaultCommissionRate = _getDefaultCommissionRate();
    final defaultRevenueShare = _getDefaultRevenueShare();
    final defaultCountry = _getDefaultCountry();

    if (defaultCommissionRate.isNotEmpty) {
      _commissionRateController.text = defaultCommissionRate;
    }
    if (defaultRevenueShare.isNotEmpty) {
      _revenueShareController.text = defaultRevenueShare;
    }
    if (defaultCountry.isNotEmpty) {
      _countryController.text = defaultCountry;
    }
  }

  String _getDefaultCommissionRate() {
    // TODO: Load from platform settings or return empty for user input
    return ''; // Let user enter their own rate
  }

  String _getDefaultRevenueShare() {
    // TODO: Load from platform settings or return empty for user input
    return ''; // Let user enter their own share
  }

  String _getDefaultCountry() {
    // TODO: Load from user's locale or platform settings
    return ''; // Let user select their country
  }

  @override
  void dispose() {
    _tabController.dispose();

    // Dispose all controllers
    _merchantNameController.dispose();
    _legalNameController.dispose();
    _registrationNumberController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _primaryDomainController.dispose();
    _subdomainController.dispose();
    _brandingNotesController.dispose();
    _commissionRateController.dispose();
    _revenueShareController.dispose();
    _minimumInvestmentController.dispose();
    _setupFeeController.dispose();
    _monthlyFeeController.dispose();
    _primaryContactNameController.dispose();
    _primaryContactEmailController.dispose();
    _primaryContactPhoneController.dispose();
    _technicalContactNameController.dispose();
    _technicalContactEmailController.dispose();
    _businessContactNameController.dispose();
    _businessContactEmailController.dispose();
    _regulatoryLicenseController.dispose();
    _kycRequirementsController.dispose();
    _complianceNotesController.dispose();

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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.account_balance,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text('New Bank/Merchant Setup'),
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
            Tab(text: 'Basic Info', icon: Icon(Icons.info_outline)),
            Tab(text: 'Domain & Branding', icon: Icon(Icons.branding_watermark)),
            Tab(text: 'Financial Terms', icon: Icon(Icons.monetization_on)),
            Tab(text: 'Contact Info', icon: Icon(Icons.contact_mail)),
            Tab(text: 'Compliance', icon: Icon(Icons.verified_user)),
            Tab(text: 'Configuration', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(isDark),
            _buildDomainBrandingTab(isDark),
            _buildFinancialTermsTab(isDark),
            _buildContactInfoTab(isDark),
            _buildComplianceTab(isDark),
            _buildConfigurationTab(isDark),
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
                onPressed: _isSubmitting ? null : _submitBankSetup,
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
                    : const Text(
                        'Create Bank/Merchant',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Bank Name
          TextFormField(
            controller: _merchantNameController,
            decoration: InputDecoration(
              labelText: 'Bank/Merchant Name *',
              hintText: 'e.g., Premier Investment Bank',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              prefixIcon: const Icon(Icons.account_balance),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bank name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Legal Name
          TextFormField(
            controller: _legalNameController,
            decoration: InputDecoration(
              labelText: 'Legal Entity Name *',
              hintText: 'e.g., Premier Investment Bank Limited',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              prefixIcon: const Icon(Icons.business),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Legal name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Bank Type and Registration Number Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedBankType,
                  decoration: InputDecoration(
                    labelText: 'Institution Type *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: _bankTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBankType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _registrationNumberController,
                  decoration: InputDecoration(
                    labelText: 'Registration Number *',
                    hintText: 'e.g., PIB2024001',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Registration number is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Country and Status Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: 'Country *',
                    hintText: 'e.g., United States',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.public),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Country is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Initial Status',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  items: _statusOptions.map((status) {
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

          // Region and Tier Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: InputDecoration(
                    labelText: 'Operating Region',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.map),
                  ),
                  items: _regionOptions.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTier,
                  decoration: InputDecoration(
                    labelText: 'Service Tier',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.stars),
                  ),
                  items: _tierOptions.map((tier) {
                    return DropdownMenuItem(
                      value: tier,
                      child: Text(tier),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTier = value!;
                    });
                  },
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
              labelText: 'Description',
              hintText: 'Brief description of the institution and services...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainBrandingTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Domain & Branding Setup',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure the bank\'s web presence and branding',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 24),

          // White Label Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: SwitchListTile(
              title: Text(
                'White Label Solution',
                style: AppTextStyles.heading6.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Enable custom branding and domain for this institution',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                ),
              ),
              value: _isWhiteLabel,
              onChanged: (value) {
                setState(() {
                  _isWhiteLabel = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          if (_isWhiteLabel) ...[
            // Primary Domain
            TextFormField(
              controller: _primaryDomainController,
              decoration: InputDecoration(
                labelText: 'Primary Domain',
                hintText: 'e.g., premier-bank.com',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                prefixIcon: const Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 16),

            // Subdomain
            TextFormField(
              controller: _subdomainController,
              decoration: InputDecoration(
                labelText: 'Subdomain Prefix',
                hintText: 'e.g., invest (creates invest.rwa-platform.com)',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                prefixIcon: const Icon(Icons.dns),
                suffix: Text(
                  '.rwa-platform.com',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Branding Notes
          TextFormField(
            controller: _brandingNotesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Branding Notes',
              hintText: 'Special branding requirements, color schemes, logo specifications...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Logo and Assets Section
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
                      Icons.image,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Branding Assets',
                      style: AppTextStyles.heading6.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload logo and branding assets after bank creation',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Asset upload will be available after bank creation'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Later'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTermsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Terms & Revenue Sharing',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Commission Rate
          TextFormField(
            controller: _commissionRateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Commission Rate (%) *',
              hintText: 'e.g., 2.50',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              prefixIcon: const Icon(Icons.percent),
              suffix: const Text('%'),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Commission rate is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Revenue Share
          TextFormField(
            controller: _revenueShareController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Revenue Share (%) *',
              hintText: 'e.g., 30.00',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              prefixIcon: const Icon(Icons.pie_chart),
              suffix: const Text('%'),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Revenue share is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Minimum Investment and Setup Fee Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minimumInvestmentController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Min. Investment (\$)',
                    hintText: 'e.g., 1000',
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
                  controller: _setupFeeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Setup Fee (\$)',
                    hintText: 'e.g., 5000',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    prefixIcon: const Icon(Icons.payment),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Monthly Fee
          TextFormField(
            controller: _monthlyFeeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monthly Subscription Fee (\$)',
              hintText: 'e.g., 500',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              prefixIcon: const Icon(Icons.subscriptions),
            ),
          ),
          const SizedBox(height: 24),

          // Financial Terms Summary
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
                Text(
                  'Revenue Structure Summary',
                  style: AppTextStyles.heading6.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Platform Commission',
                  '${_commissionRateController.text.isEmpty ? '0' : _commissionRateController.text}% per transaction',
                ),
                _buildSummaryRow(
                  'Bank Revenue Share',
                  '${_revenueShareController.text.isEmpty ? '0' : _revenueShareController.text}% of platform revenue',
                ),
                if (_setupFeeController.text.isNotEmpty)
                  _buildSummaryRow('One-time Setup Fee', '\$${_setupFeeController.text}'),
                if (_monthlyFeeController.text.isNotEmpty)
                  _buildSummaryRow('Monthly Subscription', '\$${_monthlyFeeController.text}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Primary Contact Section
          _buildContactSection(
            'Primary Contact',
            Icons.person,
            [
              TextFormField(
                controller: _primaryContactNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Primary contact name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _primaryContactEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address *',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Primary contact email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _primaryContactPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Primary contact phone is required';
                  }
                  return null;
                },
              ),
            ],
            isDark,
          ),
          const SizedBox(height: 24),

          // Technical Contact Section
          _buildContactSection(
            'Technical Contact',
            Icons.engineering,
            [
              TextFormField(
                controller: _technicalContactNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                  prefixIcon: const Icon(Icons.engineering),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _technicalContactEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
            ],
            isDark,
          ),
          const SizedBox(height: 24),

          // Business Contact Section
          _buildContactSection(
            'Business Contact',
            Icons.business_center,
            [
              TextFormField(
                controller: _businessContactNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                  prefixIcon: const Icon(Icons.business_center),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessContactEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
            ],
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compliance & Legal',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Regulatory License
          TextFormField(
            controller: _regulatoryLicenseController,
            decoration: InputDecoration(
              labelText: 'Regulatory License Number',
              hintText: 'e.g., FRB-2024-001',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              prefixIcon: const Icon(Icons.verified_user),
            ),
          ),
          const SizedBox(height: 16),

          // KYC Requirements
          TextFormField(
            controller: _kycRequirementsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'KYC/AML Requirements',
              hintText: 'Specific KYC and AML requirements for this institution...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Compliance Notes
          TextFormField(
            controller: _complianceNotesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Compliance Notes',
              hintText: 'Additional compliance requirements, restrictions, or notes...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Legal Documents Upload
          _buildDocumentUploadSection(
            'Legal Documents',
            'Upload incorporation documents, licenses, etc.',
            Icons.description,
            _legalDocuments,
            () => _pickDocuments('legal'),
            isDark,
          ),
          const SizedBox(height: 16),

          // Compliance Documents Upload
          _buildDocumentUploadSection(
            'Compliance Documents',
            'Upload compliance certifications, audit reports, etc.',
            Icons.security,
            _complianceDocuments,
            () => _pickDocuments('compliance'),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Configuration',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure platform features and access levels',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 24),

          // API Access
          _buildConfigToggle(
            'API Access',
            'Enable API access for programmatic interactions',
            Icons.api,
            _hasApiAccess,
            (value) => setState(() => _hasApiAccess = value),
            isDark,
          ),
          const SizedBox(height: 16),

          // Bulk Upload
          _buildConfigToggle(
            'Bulk Asset Upload',
            'Allow bulk asset upload via CSV or API',
            Icons.upload_file,
            _allowsBulkUpload,
            (value) => setState(() => _allowsBulkUpload = value),
            isDark,
          ),
          const SizedBox(height: 16),

          // KYC Requirements
          _buildConfigToggle(
            'KYC Requirements',
            'Require KYC verification for all users',
            Icons.verified_user,
            _requiresKYC,
            (value) => setState(() => _requiresKYC = value),
            isDark,
          ),
          const SizedBox(height: 16),

          // Manual Approval
          _buildConfigToggle(
            'Manual Approval Required',
            'All asset uploads require manual approval',
            Icons.approval,
            _requiresManualApproval,
            (value) => setState(() => _requiresManualApproval = value),
            isDark,
          ),
          const SizedBox(height: 24),

          // Configuration Summary
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
                      Icons.settings_applications,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Configuration Summary',
                      style: AppTextStyles.heading6.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Service Tier', _selectedTier),
                _buildSummaryRow('Institution Type', _selectedBankType),
                _buildSummaryRow('API Access', _hasApiAccess ? 'Enabled' : 'Disabled'),
                _buildSummaryRow('Bulk Upload', _allowsBulkUpload ? 'Enabled' : 'Disabled'),
                _buildSummaryRow('KYC Required', _requiresKYC ? 'Yes' : 'No'),
                _buildSummaryRow('Manual Approval', _requiresManualApproval ? 'Required' : 'Automatic'),
                _buildSummaryRow('White Label', _isWhiteLabel ? 'Yes' : 'No'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(String title, IconData icon, List<Widget> fields, bool isDark) {
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
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.heading6.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...fields,
        ],
      ),
    );
  }

  Widget _buildDocumentUploadSection(
    String title,
    String subtitle,
    IconData icon,
    List<PlatformFile> documents,
    VoidCallback onUpload,
    bool isDark,
  ) {
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
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.heading6.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Documents'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
          if (documents.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...documents.map((doc) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.getBackground(isDark),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Row(
                children: [
                  Icon(Icons.description, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doc.name,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                    onPressed: () {
                      setState(() {
                        documents.remove(doc);
                      });
                    },
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.primary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDocuments(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          if (type == 'legal') {
            _legalDocuments.addAll(result.files);
          } else {
            _complianceDocuments.addAll(result.files);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking documents: $e')),
      );
    }
  }

  Future<void> _submitBankSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create bank profile data
      final bankData = {
        'name': _merchantNameController.text,
        'legalName': _legalNameController.text,
        'registrationNumber': _registrationNumberController.text,
        'country': _countryController.text,
        'description': _descriptionController.text,
        'bankType': _selectedBankType,
        'status': _selectedStatus,
        'tier': _selectedTier,
        'region': _selectedRegion,
        'isWhiteLabel': _isWhiteLabel,
        'domain': _primaryDomainController.text.isEmpty ? null : _primaryDomainController.text,
        'subdomain': _subdomainController.text.isEmpty ? null : _subdomainController.text,
        'commissionRateBps': (double.tryParse(_commissionRateController.text) ?? 0) * 100,
        'revenueShareBps': (double.tryParse(_revenueShareController.text) ?? 0) * 100,
        'minimumInvestment': double.tryParse(_minimumInvestmentController.text),
        'setupFee': double.tryParse(_setupFeeController.text),
        'monthlyFee': double.tryParse(_monthlyFeeController.text),
        'primaryContact': {
          'name': _primaryContactNameController.text,
          'email': _primaryContactEmailController.text,
          'phone': _primaryContactPhoneController.text,
        },
        'technicalContact': {
          'name': _technicalContactNameController.text,
          'email': _technicalContactEmailController.text,
        },
        'businessContact': {
          'name': _businessContactNameController.text,
          'email': _businessContactEmailController.text,
        },
        'regulatoryLicense': _regulatoryLicenseController.text,
        'kycRequirements': _kycRequirementsController.text,
        'complianceNotes': _complianceNotesController.text,
        'configuration': {
          'hasApiAccess': _hasApiAccess,
          'allowsBulkUpload': _allowsBulkUpload,
          'requiresKYC': _requiresKYC,
          'requiresManualApproval': _requiresManualApproval,
        },
        'legalDocumentCount': _legalDocuments.length,
        'complianceDocumentCount': _complianceDocuments.length,
        'createdBy': 'super_admin',
        'contractStartDate': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // TODO: Submit to API and upload documents
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_merchantNameController.text} created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating bank: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}