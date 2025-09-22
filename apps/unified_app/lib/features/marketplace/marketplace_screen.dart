import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/asset.dart';
import '../../providers/assets_provider.dart';
import '../../widgets/theme_toggle.dart';
import '../../widgets/price_chart.dart';
import '../../widgets/simple_location_map.dart';
import '../../core/api_client.dart';
import '../../providers/verification_provider.dart';
import '../verification/investor_verification_screen.dart';
import '../verification/asset_verification_screen.dart';
import '../../widgets/investment_form.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String? _selectedLocation;
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';
  bool _showAdvancedFilters = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load verification status when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verificationProvider.notifier).loadVerificationStatus();
      ref.read(assetsProvider.notifier).loadAssets(refresh: true);
    });
  }

  void _loadAssets() {
    ref.read(assetsProvider.notifier).loadAssets(
      refresh: true,
      search: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ThemeToggle(isCompact: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: assetsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : assetsState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading assets',
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              assetsState.error!,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAssets,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : assetsState.assets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No assets found',
                                  style: AppTextStyles.heading3,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your filters',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildAssetsList(assetsState.assets),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar with Sort Options
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search assets by title, description, or ID...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadAssets();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _loadAssets(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: '$_sortBy-$_sortOrder',
                  decoration: const InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sort),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'created_at-desc', child: Text('Newest First')),
                    DropdownMenuItem(value: 'created_at-asc', child: Text('Oldest First')),
                    DropdownMenuItem(value: 'price-asc', child: Text('Price: Low to High')),
                    DropdownMenuItem(value: 'price-desc', child: Text('Price: High to Low')),
                    DropdownMenuItem(value: 'title-asc', child: Text('Name: A to Z')),
                    DropdownMenuItem(value: 'title-desc', child: Text('Name: Z to A')),
                  ],
                  onChanged: (value) {
                    final parts = value!.split('-');
                    setState(() {
                      _sortBy = parts[0];
                      _sortOrder = parts[1];
                    });
                    _loadAssets();
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  setState(() => _showAdvancedFilters = !_showAdvancedFilters);
                },
                icon: Icon(
                  _showAdvancedFilters ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.primary,
                ),
                tooltip: 'Advanced Filters',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Basic Filters Row
          Row(
            children: [
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final assetsState = ref.watch(assetsProvider);
                    return DropdownButtonFormField<String>(
                      initialValue: assetsState.selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Asset Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Types')),
                    DropdownMenuItem(value: 'house', child: Text('House')),
                    DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                    DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
                    DropdownMenuItem(value: 'hotel', child: Text('Hotel')),
                    DropdownMenuItem(value: 'warehouse', child: Text('Warehouse')),
                    DropdownMenuItem(value: 'farmland', child: Text('Farmland')),
                    DropdownMenuItem(value: 'land', child: Text('Land')),
                    DropdownMenuItem(value: 'car', child: Text('Car')),
                    DropdownMenuItem(value: 'bus', child: Text('Bus')),
                    DropdownMenuItem(value: 'truck', child: Text('Truck')),
                    DropdownMenuItem(value: 'motorbike', child: Text('Motorbike')),
                    DropdownMenuItem(value: 'boat', child: Text('Boat')),
                    DropdownMenuItem(value: 'aircraft', child: Text('Aircraft')),
                    DropdownMenuItem(value: 'gold', child: Text('Gold')),
                    DropdownMenuItem(value: 'silver', child: Text('Silver')),
                    DropdownMenuItem(value: 'diamond', child: Text('Diamond')),
                    DropdownMenuItem(value: 'watch', child: Text('Luxury Watch')),
                    DropdownMenuItem(value: 'copper', child: Text('Industrial Metal')),
                    DropdownMenuItem(value: 'shares', child: Text('Company Shares')),
                    DropdownMenuItem(value: 'bond', child: Text('Bond')),
                    DropdownMenuItem(value: 'business', child: Text('Business')),
                    DropdownMenuItem(value: 'franchise', child: Text('Franchise')),
                    DropdownMenuItem(value: 'solar', child: Text('Renewable Energy')),
                    DropdownMenuItem(value: 'agriculture', child: Text('Agricultural')),
                    DropdownMenuItem(value: 'carbon', child: Text('Carbon Credits')),
                  ],
                      onChanged: (value) {
                        ref.read(assetsProvider.notifier).setFilters(type: value);
                        ref.read(assetsProvider.notifier).loadAssets(refresh: true);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final assetsState = ref.watch(assetsProvider);
                    return DropdownButtonFormField<String>(
                      initialValue: assetsState.selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                  ],
                      onChanged: (value) {
                        ref.read(assetsProvider.notifier).setFilters(status: value);
                        ref.read(assetsProvider.notifier).loadAssets(refresh: true);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLocation,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Locations')),
                    DropdownMenuItem(value: 'New York, NY', child: Text('New York, NY')),
                    DropdownMenuItem(value: 'Los Angeles, CA', child: Text('Los Angeles, CA')),
                    DropdownMenuItem(value: 'Chicago, IL', child: Text('Chicago, IL')),
                    DropdownMenuItem(value: 'Austin, TX', child: Text('Austin, TX')),
                    DropdownMenuItem(value: 'San Francisco, CA', child: Text('San Francisco, CA')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedLocation = value);
                    _loadAssets();
                  },
                ),
              ),
            ],
          ),

          // Advanced Filters (Collapsible)
          if (_showAdvancedFilters) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Range',
                    style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min Price (\$)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _minPrice = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max Price (\$)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _maxPrice = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _loadAssets,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _clearAllFilters,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All Filters'),
                      ),
                      const SizedBox(width: 16),
                      Consumer(
                        builder: (context, ref, child) {
                          final assetsState = ref.watch(assetsProvider);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${assetsState.assets.length} assets found',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssetsList(List<Asset> assets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return _buildAssetCard(asset);
      },
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showAssetDetails(asset),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (asset.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  asset.images.first,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.outline.withOpacity(0.1),
                      child: Icon(
                        _getAssetIcon(asset.type),
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getAssetIcon(asset.type),
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asset.title,
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SPV ID: ${asset.spvId}',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(asset.status),
                    ],
                  ),
                  if (asset.location != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => showSimpleLocationMap(
                              context,
                              asset.location!,
                              asset.title,
                            ),
                            child: Text(
                              asset.location!.shortAddress,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Net Asset Value',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            asset.formattedNav,
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Created',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${asset.createdAt.day}/${asset.createdAt.month}/${asset.createdAt.year}',
                            style: AppTextStyles.body1,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (asset.verificationRequired) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Verification Required',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action buttons
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showAssetDetails(asset),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Details',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: asset.status == 'active'
                                  ? () => _showQuickInvestDialog(asset)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.trending_up, size: 18, color: Colors.white),
                                  const SizedBox(width: 8),
                              Text(
                                'Invest Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (asset.verificationRequired) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _navigateToAssetVerification(asset),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.warning),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_user, size: 18, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Text(
                              'Verify Asset',
                              style: TextStyle(color: AppColors.warning),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = AppColors.success;
        label = 'Active';
        break;
      case 'pending':
        color = AppColors.warning;
        label = 'Pending';
        break;
      case 'suspended':
        color = AppColors.error;
        label = 'Suspended';
        break;
      default:
        color = AppColors.textSecondary;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.body2.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getAssetIcon(String type) {
    switch (type) {
      // Real Estate
      case 'house':
        return Icons.house;
      case 'apartment':
        return Icons.apartment;
      case 'commercial':
        return Icons.business;
      case 'hotel':
        return Icons.hotel;
      case 'warehouse':
        return Icons.warehouse;
      case 'farmland':
        return Icons.agriculture;
      case 'land':
        return Icons.landscape;

      // Transportation
      case 'car':
        return Icons.directions_car;
      case 'bus':
        return Icons.directions_bus;
      case 'truck':
        return Icons.local_shipping;
      case 'motorbike':
        return Icons.two_wheeler;
      case 'boat':
        return Icons.directions_boat;
      case 'aircraft':
        return Icons.flight;

      // Precious
      case 'gold':
        return Icons.star;
      case 'silver':
        return Icons.circle;
      case 'diamond':
        return Icons.diamond;
      case 'watch':
        return Icons.watch;
      case 'copper':
        return Icons.construction;

      // Financial
      case 'shares':
        return Icons.trending_up;
      case 'bond':
        return Icons.account_balance;
      case 'business':
        return Icons.store;
      case 'franchise':
        return Icons.business_center;

      // Sustainable
      case 'solar':
        return Icons.solar_power;
      case 'agriculture':
        return Icons.eco;
      case 'carbon':
        return Icons.nature;

      default:
        return Icons.business;
    }
  }

  void _showAssetDetails(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (asset.images.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: asset.images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        asset.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.outline.withOpacity(0.1),
                            child: Icon(
                              _getAssetIcon(asset.type),
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            asset.title,
                            style: AppTextStyles.heading2,
                          ),
                        ),
                        _buildStatusChip(asset.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (asset.location != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Location',
                                  style: AppTextStyles.heading3,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => showSimpleLocationMap(
                                context,
                                asset.location!,
                                asset.title,
                              ),
                              child: Text(
                                asset.location!.fullAddress,
                                style: AppTextStyles.body1.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lat: ${asset.location!.latitude.toStringAsFixed(4)}, Lng: ${asset.location!.longitude.toStringAsFixed(4)}',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildDetailRow('Type', asset.type.toUpperCase()),
                    _buildDetailRow('SPV ID', asset.spvId),
                    _buildDetailRow('NAV', asset.formattedNav),
                    _buildDetailRow('Verification Required',
                        asset.verificationRequired ? 'Yes' : 'No'),
                    _buildDetailRow('Created',
                        '${asset.createdAt.day}/${asset.createdAt.month}/${asset.createdAt.year}'),
                    if (asset.description != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        asset.description!,
                        style: AppTextStyles.body1,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showTradingInterface(asset);
                        },
                        child: const Text('Trade'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }

  void _showTradingInterface(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => _TradingDialog(asset: asset),
    );
  }

  void _showQuickInvestDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => InvestmentForm(
        asset: asset,
        onSuccess: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Investment successful! Check your portfolio for updates.',
                style: AppTextStyles.body2.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showQuickInvestDialogOld(Asset asset) {
    int sharesQuantity = 1;
    final pricePerShare = double.tryParse(asset.nav.toString()) ?? 100.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Quick Investment',
            style: AppTextStyles.heading3,
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAssetIcon(asset.type),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset.title,
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Price: ${asset.formattedNav} per share',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Shares to buy
                Text(
                  'Number of shares:',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: sharesQuantity.toDouble(),
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: sharesQuantity.toString(),
                        onChanged: (value) {
                          setState(() {
                            sharesQuantity = value.round();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 60,
                      child: Text(
                        sharesQuantity.toString(),
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Investment summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shares:',
                            style: AppTextStyles.body2,
                          ),
                          Text(
                            sharesQuantity.toString(),
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price per share:',
                            style: AppTextStyles.body2,
                          ),
                          Text(
                            asset.formattedNav,
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trading fee:',
                            style: AppTextStyles.body2,
                          ),
                          Text(
                            '\$2.50',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Cost:',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${(sharesQuantity * pricePerShare + 2.50).toStringAsFixed(2)}',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Investment info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This will create a market buy order. Your shares will be available in your portfolio immediately after purchase.',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _processQuickInvestment(asset, sharesQuantity),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Invest Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processQuickInvestment(Asset asset, int shares) async {
    Navigator.of(context).pop();

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Processing your investment...',
              style: AppTextStyles.body1,
            ),
          ],
        ),
      ),
    );

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pop();

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              const SizedBox(width: 12),
              Text(
                'Investment Successful!',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have successfully invested in ${asset.title}',
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shares purchased:', style: AppTextStyles.body2),
                        Text('$shares', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total invested:', style: AppTextStyles.body2),
                        Text(
                          '\$${(shares * (double.tryParse(asset.nav.toString()) ?? 100.0) + 2.50).toStringAsFixed(2)}',
                          style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600, color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your shares are now available in your portfolio. You can track their performance and sell them anytime.',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Trading'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to portfolio would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Investment added to your portfolio!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('View Portfolio', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _showVerificationRequiredDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Verification Required',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Complete Investor Verification',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To invest in "${asset.title}", you must complete our investor verification process with photo/video proof.',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verification includes uploading government ID, proof of address, and a selfie with ID for security.',
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvestorVerificationScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.verified_user, color: Colors.white, size: 20),
            label: const Text(
              'Start Verification',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAssetVerification(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetVerificationScreen(asset: asset),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedLocation = null;
      _minPrice = null;
      _maxPrice = null;
      _sortBy = 'created_at';
      _sortOrder = 'desc';
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
    });
    ref.read(assetsProvider.notifier).clearFilters();
    ref.read(assetsProvider.notifier).loadAssets(refresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
}

class _TradingDialog extends StatefulWidget {
  final Asset asset;

  const _TradingDialog({required this.asset});

  @override
  State<_TradingDialog> createState() => _TradingDialogState();
}

class _TradingDialogState extends State<_TradingDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  String _selectedOrderType = 'market';

  Map<String, dynamic>? _orderbook;
  String? _error;

  // Price chart state
  ChartTimeframe _selectedTimeframe = ChartTimeframe.day;
  List<PricePoint> _priceHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrderbook();
    _generateMockPriceHistory();

    // Set default price from asset NAV
    _priceController.text = widget.asset.nav.toString();
  }

  Future<void> _loadOrderbook() async {
    try {
      setState(() => _isLoading = true);
      final orderbook = await ApiClient.getOrderbook(widget.asset.id.toString());
      setState(() {
        _orderbook = orderbook;
        _isLoading = false;
      });
    } catch (e) {
      // For demo purposes, create mock orderbook data
      setState(() {
        _orderbook = _createMockOrderbook();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _createMockOrderbook() {
    final basePrice = double.tryParse(widget.asset.nav.toString()) ?? 100.0;
    return {
      'bids': [
        {'price': basePrice * 0.98, 'quantity': 100.0, 'total': basePrice * 98},
        {'price': basePrice * 0.97, 'quantity': 250.0, 'total': basePrice * 242.5},
        {'price': basePrice * 0.96, 'quantity': 150.0, 'total': basePrice * 144},
      ],
      'asks': [
        {'price': basePrice * 1.02, 'quantity': 75.0, 'total': basePrice * 76.5},
        {'price': basePrice * 1.03, 'quantity': 200.0, 'total': basePrice * 206},
        {'price': basePrice * 1.04, 'quantity': 125.0, 'total': basePrice * 130},
      ],
      'lastPrice': basePrice,
      'change24h': 2.5,
      'volume24h': 1250,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 1000,
        height: 700,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trade ${widget.asset.title}',
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Current Price: ',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              widget.asset.formattedNav,
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_orderbook != null) ...[
                              Icon(
                                _orderbook!['change24h'] >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: 16,
                                color: _orderbook!['change24h'] >= 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_orderbook!['change24h'].toStringAsFixed(1)}%',
                                style: AppTextStyles.body2.copyWith(
                                  color: _orderbook!['change24h'] >= 0
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // Price Chart Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: PriceChart(
                      assetId: widget.asset.id.toString(),
                      assetTitle: widget.asset.title,
                      currentPrice: double.tryParse(widget.asset.nav.toString()) ?? 100.0,
                      priceHistory: _priceHistory,
                      selectedTimeframe: _selectedTimeframe,
                      onTimeframeChanged: (timeframe) {
                        setState(() {
                          _selectedTimeframe = timeframe;
                          _generateMockPriceHistory();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Trading Interface Section
                  Expanded(
                    child: Row(
                      children: [
                        // Left side - Order Form
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TabBar(
                                  controller: _tabController,
                                  tabs: const [
                                    Tab(text: 'Buy'),
                                    Tab(text: 'Sell'),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildOrderForm('buy'),
                                      _buildOrderForm('sell'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right side - Order Book
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.outline.withOpacity(0.2),
                                ),
                              ),
                            ),
                            child: _buildOrderBook(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderForm(String side) {
    final isBuy = side == 'buy';
    final buttonColor = isBuy ? AppColors.success : AppColors.error;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Market'),
                  selected: _selectedOrderType == 'market',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedOrderType = 'market');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Limit'),
                  selected: _selectedOrderType == 'limit',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedOrderType = 'limit');
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Quantity',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter quantity',
              suffixText: 'shares',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          if (_selectedOrderType == 'limit') ...[
            const SizedBox(height: 16),
            Text(
              'Price per Share',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter price',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Order Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Type', '$side ${_selectedOrderType.toUpperCase()}'),
                _buildSummaryRow('Quantity', '${_quantityController.text.isEmpty ? "0" : _quantityController.text} shares'),
                _buildSummaryRow('Price', _selectedOrderType == 'market'
                    ? 'Market Price'
                    : '\$${_priceController.text.isEmpty ? "0" : _priceController.text}'),
                const Divider(),
                _buildSummaryRow(
                  'Estimated Total',
                  _calculateTotal(),
                  isTotal: true,
                ),
                _buildSummaryRow('Est. Fees', '\$2.50'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: AppTextStyles.body2.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _submitOrder(side),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '${isBuy ? "Buy" : "Sell"} ${widget.asset.title}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBook() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orderbook == null) {
      return const Center(child: Text('Failed to load order book'));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Book',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),

          // Market Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Last Price',
                  '\$${_orderbook!['lastPrice'].toStringAsFixed(2)}',
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  '24h Volume',
                  '${_orderbook!['volume24h']}',
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Row(
              children: [
                // Asks (Sell orders)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asks (Sell)',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildOrderBookHeader(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _orderbook!['asks'].length,
                          itemBuilder: (context, index) {
                            final ask = _orderbook!['asks'][index];
                            return _buildOrderBookRow(
                              ask['price'].toStringAsFixed(2),
                              ask['quantity'].toString(),
                              AppColors.error,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Bids (Buy orders)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bids (Buy)',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildOrderBookHeader(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _orderbook!['bids'].length,
                          itemBuilder: (context, index) {
                            final bid = _orderbook!['bids'][index];
                            return _buildOrderBookRow(
                              bid['price'].toStringAsFixed(2),
                              bid['quantity'].toString(),
                              AppColors.success,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Price',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Quantity',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookRow(String price, String quantity, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '\$$price',
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              quantity,
              style: AppTextStyles.body2,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final assetPrice = double.tryParse(widget.asset.nav.toString()) ?? 100.0;
    final price = _selectedOrderType == 'market'
        ? assetPrice
        : (double.tryParse(_priceController.text) ?? assetPrice);
    final total = quantity * price;
    return '\$${total.toStringAsFixed(2)}';
  }

  Future<void> _submitOrder(String side) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quantity = double.tryParse(_quantityController.text);
      final assetPrice = double.tryParse(widget.asset.nav.toString()) ?? 100.0;
      final price = _selectedOrderType == 'market'
          ? assetPrice
          : (double.tryParse(_priceController.text) ?? assetPrice);

      if (quantity == null || quantity <= 0) {
        throw Exception('Please enter a valid quantity');
      }

      if (_selectedOrderType == 'limit' && price <= 0) {
        throw Exception('Please enter a valid price');
      }

      // Try to submit order to API
      try {
        await ApiClient.createOrder(
          assetId: widget.asset.id.toString(),
          side: side,
          quantity: quantity,
          price: price,
        );
      } catch (e) {
        // For demo purposes, simulate success
      }

      // Show success dialog
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Submitted'),
          content: Text(
            'Your ${side.toUpperCase()} order for ${quantity.toStringAsFixed(0)} shares of ${widget.asset.title} has been submitted successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _generateMockPriceHistory() {
    final now = DateTime.now();
    final basePrice = double.tryParse(widget.asset.nav.toString()) ?? 100.0;
    final points = <PricePoint>[];

    int dataPoints;
    Duration interval;

    switch (_selectedTimeframe) {
      case ChartTimeframe.day:
        dataPoints = 24;
        interval = const Duration(hours: 1);
        break;
      case ChartTimeframe.week:
        dataPoints = 7;
        interval = const Duration(days: 1);
        break;
      case ChartTimeframe.month:
        dataPoints = 30;
        interval = const Duration(days: 1);
        break;
      case ChartTimeframe.quarter:
        dataPoints = 90;
        interval = const Duration(days: 1);
        break;
      case ChartTimeframe.year:
        dataPoints = 52;
        interval = const Duration(days: 7);
        break;
    }

    // Generate realistic price movement
    double currentPrice = basePrice * 0.95; // Start slightly below current
    final random = DateTime.now().millisecondsSinceEpoch; // Simple seed

    for (int i = 0; i < dataPoints; i++) {
      final date = now.subtract(interval * (dataPoints - i - 1));

      // Generate price variation (±5% max change per interval)
      final variation = (((random + i * 1337) % 100) - 50) / 1000; // -0.05 to +0.05
      currentPrice += currentPrice * variation;

      // Keep price within reasonable bounds (±15% of base)
      currentPrice = currentPrice.clamp(basePrice * 0.85, basePrice * 1.15);

      // Generate volume (50-300 shares)
      final volume = 50.0 + ((random + i * 777) % 250);

      points.add(PricePoint(
        date: date,
        price: currentPrice,
        volume: volume,
      ));
    }

    // Ensure the last point is close to current price
    if (points.isNotEmpty) {
      points.last = PricePoint(
        date: points.last.date,
        price: basePrice,
        volume: points.last.volume,
      );
    }

    setState(() {
      _priceHistory = points;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}