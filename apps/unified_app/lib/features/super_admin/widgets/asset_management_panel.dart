import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AssetManagementPanel extends ConsumerStatefulWidget {
  const AssetManagementPanel({super.key});

  @override
  ConsumerState<AssetManagementPanel> createState() => _AssetManagementPanelState();
}

class _AssetManagementPanelState extends ConsumerState<AssetManagementPanel>
    with SingleTickerProviderStateMixin {
  late TabController _assetTabController;

  final List<Tab> _assetTabs = const [
    Tab(text: 'All Assets', height: 48),
    Tab(text: 'By Category', height: 48),
    Tab(text: 'Approvals', height: 48),
    Tab(text: 'Performance', height: 48),
    Tab(text: 'Settings', height: 48),
  ];

  @override
  void initState() {
    super.initState();
    _assetTabController = TabController(length: _assetTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _assetTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        Container(
          color: AppColors.getSurface(isDark),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asset Management',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage all assets across the platform including real estate, vehicles, commodities and more',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: 16),

              // Quick stats
              Row(
                children: [
                  Expanded(
                    child: _buildAssetMetricCard(
                      'Total Assets',
                      '2,847',
                      Icons.business_center,
                      Colors.blue,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAssetMetricCard(
                      'Pending Approval',
                      '23',
                      Icons.pending_actions,
                      Colors.orange,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAssetMetricCard(
                      'Total Value',
                      '\$847M',
                      Icons.monetization_on,
                      Colors.green,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAssetMetricCard(
                      'Active Listings',
                      '1,924',
                      Icons.trending_up,
                      Colors.purple,
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tab bar for asset categories
        Container(
          color: AppColors.getSurface(isDark),
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _assetTabController,
              tabs: _assetTabs,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.getTextSecondary(isDark),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _assetTabController,
            children: [
              _buildAllAssetsTab(isDark),
              _buildByCategoryTab(isDark),
              _buildApprovalsTab(isDark),
              _buildPerformanceTab(isDark),
              _buildSettingsTab(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetMetricCard(String title, String value, IconData icon, Color color, bool isDark) {
    return InkWell(
      onTap: () => _showAssetMetricDetails(title, value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.more_vert, color: AppColors.getTextSecondary(isDark), size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAssetsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and filters
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search assets...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Categories')),
                    DropdownMenuItem(value: 'real_estate', child: Text('Real Estate')),
                    DropdownMenuItem(value: 'vehicles', child: Text('Vehicles')),
                    DropdownMenuItem(value: 'commodities', child: Text('Commodities')),
                    DropdownMenuItem(value: 'equipment', child: Text('Equipment')),
                  ],
                  onChanged: (value) {},
                  value: 'all',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                    DropdownMenuItem(value: 'archived', child: Text('Archived')),
                  ],
                  onChanged: (value) {},
                  value: 'all',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Assets table
          _buildAssetsTable(isDark),
        ],
      ),
    );
  }

  Widget _buildByCategoryTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assets by Category',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Category cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildCategoryCard('Real Estate', '1,245', Icons.home, Colors.blue, isDark),
              _buildCategoryCard('Vehicles', '687', Icons.directions_car, Colors.green, isDark),
              _buildCategoryCard('Commodities', '423', Icons.grain, Colors.orange, isDark),
              _buildCategoryCard('Equipment', '492', Icons.precision_manufacturing, Colors.purple, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Asset Approvals',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _bulkApprovalActions(),
                icon: const Icon(Icons.checklist),
                label: const Text('Bulk Actions'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildApprovalsList(isDark),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Performance Analytics',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Performance metrics
          Row(
            children: [
              Expanded(
                child: _buildPerformanceCard('Best Performing', 'Tesla Model S', '+24.5%', Colors.green, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceCard('Most Traded', 'Manhattan Apartment', '847 trades', Colors.blue, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceCard('Highest Value', 'Commercial Building', '\$12.4M', Colors.purple, isDark),
              ),
            ],
          ),
          const SizedBox(height: 24),

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
                Text(
                  'Performance Charts',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  child: Center(
                    child: Text(
                      'Performance charts and analytics would be displayed here',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Management Settings',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Settings sections
          _buildSettingsSection('Asset Categories', isDark),
          const SizedBox(height: 24),
          _buildSettingsSection('Approval Workflows', isDark),
          const SizedBox(height: 24),
          _buildSettingsSection('Valuation Settings', isDark),
          const SizedBox(height: 24),
          _buildSettingsSection('Performance Metrics', isDark),
        ],
      ),
    );
  }

  Widget _buildAssetsTable(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Asset Name', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Category', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Value', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Status', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Owner', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Actions', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          // Mock asset data
          ..._getMockAssets().map((asset) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.getBorder(isDark))),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(asset['name'], style: AppTextStyles.body1)),
                Expanded(flex: 2, child: Text(asset['category'], style: AppTextStyles.body1)),
                Expanded(flex: 2, child: Text(asset['value'], style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: _buildStatusChip(asset['status'], isDark)),
                Expanded(flex: 2, child: Text(asset['owner'], style: AppTextStyles.body1)),
                Expanded(
                  flex: 1,
                  child: PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: AppColors.getTextSecondary(isDark)),
                    itemBuilder: (context) => [
                      const PopupMenuItem(child: Text('View Details')),
                      const PopupMenuItem(child: Text('Edit')),
                      const PopupMenuItem(child: Text('Suspend')),
                      const PopupMenuItem(child: Text('Archive')),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String count, IconData icon, Color color, bool isDark) {
    return InkWell(
      onTap: () => _viewCategoryDetails(title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
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

  Widget _buildApprovalsList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: _getMockPendingAssets().map((asset) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.getBorder(isDark))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset['name'], style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                    Text('${asset['category']} • ${asset['value']}', style: AppTextStyles.body2.copyWith(color: AppColors.getTextSecondary(isDark))),
                    Text('Submitted by: ${asset['submitter']}', style: AppTextStyles.caption.copyWith(color: AppColors.getTextSecondary(isDark))),
                  ],
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _approveAsset(asset['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approve'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _rejectAsset(asset['id']),
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPerformanceCard(String title, String assetName, String metric, Color color, bool isDark) {
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
          Text(title, style: AppTextStyles.body2.copyWith(color: AppColors.getTextSecondary(isDark))),
          const SizedBox(height: 8),
          Text(assetName, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            metric,
            style: AppTextStyles.heading4.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, bool isDark) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => _editSettings(title),
                child: const Text('Configure'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage $title configuration and rules',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Mock data methods
  List<Map<String, dynamic>> _getMockAssets() {
    return [
      {'name': 'Manhattan Penthouse', 'category': 'Real Estate', 'value': '\$2.4M', 'status': 'Active', 'owner': 'John Doe'},
      {'name': 'Tesla Model S', 'category': 'Vehicles', 'value': '\$89K', 'status': 'Active', 'owner': 'Jane Smith'},
      {'name': 'Gold Bars (100oz)', 'category': 'Commodities', 'value': '\$198K', 'status': 'Pending', 'owner': 'Bob Wilson'},
      {'name': 'Industrial Equipment', 'category': 'Equipment', 'value': '\$245K', 'status': 'Suspended', 'owner': 'Alice Brown'},
      {'name': 'Miami Beach House', 'category': 'Real Estate', 'value': '\$1.8M', 'status': 'Active', 'owner': 'Carlos Martinez'},
    ];
  }

  List<Map<String, dynamic>> _getMockPendingAssets() {
    return [
      {'id': '1', 'name': 'Luxury Yacht', 'category': 'Vehicles', 'value': '\$1.2M', 'submitter': 'Ocean Investments LLC'},
      {'id': '2', 'name': 'Commercial Building', 'category': 'Real Estate', 'value': '\$3.5M', 'submitter': 'Property Group Inc'},
      {'id': '3', 'name': 'Art Collection', 'category': 'Collectibles', 'value': '\$850K', 'submitter': 'Art Gallery Co'},
    ];
  }

  // Action methods
  void _showAssetMetricDetails(String title, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Value: $value'),
            const SizedBox(height: 16),
            const Text('Detailed asset metrics and analytics would appear here.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewCategoryDetails(String category) {
    // Navigate to detailed category view
  }

  void _bulkApprovalActions() {
    // Show bulk approval dialog
  }

  void _approveAsset(String assetId) {
    // Approve asset logic
  }

  void _rejectAsset(String assetId) {
    // Reject asset logic
  }

  void _editSettings(String settingType) {
    // Navigate to settings configuration
  }
}