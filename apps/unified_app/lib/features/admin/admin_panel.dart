import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/admin_stats.dart';
import '../../models/asset.dart';
import '../../models/asset_categories.dart';
import '../../services/admin_service.dart';
import '../../providers/assets_provider.dart';
import '../../data/comprehensive_asset_data.dart';
import '../../widgets/theme_toggle.dart';

class AdminPanel extends ConsumerStatefulWidget {
  const AdminPanel({super.key});

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  AdminStats? _stats;
  List<AdminUser> _users = [];
  List<AdminUser> _filteredUsers = [];
  List<AdminActivity> _activities = [];
  List<Asset> _assets = [];
  String? _error;
  String? _selectedRole;
  String? _selectedStatus;
  bool? _kycFilter;
  final TextEditingController _userSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final results = await Future.wait([
        AdminService.getDashboardStats(),
        AdminService.getUsers(),
        AdminService.getRecentActivity(),
        _loadComprehensiveAssets(),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as AdminStats;
          _users = results[1] as List<AdminUser>;
          _filteredUsers = _users;
          _activities = results[2] as List<AdminActivity>;
          _assets = results[3] as List<Asset>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<List<Asset>> _loadComprehensiveAssets() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final allAssetData = ComprehensiveAssetData.getAllAssets();
    return allAssetData.map((json) => Asset.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: AppColors.getTextPrimary(isDark))
        ),
        backgroundColor: AppColors.getSurface(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.getTextPrimary(isDark)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ThemeToggle(isCompact: true),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.getTextPrimary(isDark),
          unselectedLabelColor: AppColors.getTextSecondary(isDark),
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.business), text: 'Assets'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.verified_user), text: 'Compliance'),
            Tab(icon: Icon(Icons.message), text: 'Messages'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
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
                        'Error loading dashboard',
                        style: AppTextStyles.heading3.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildUsersTab(),
                    _buildAssetsTab(),
                    _buildCategoriesTab(),
                    _buildActivityTab(),
                    _buildAnalyticsTab(),
                    _buildComplianceTab(),
                    _buildMessagesTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    if (_stats == null) return const Center(child: Text('No data available'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Statistics',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 200,
                height: 120,
                child: InkWell(
                  onTap: () => _tabController.animateTo(1),
                  child: _buildStatCard(
                    'Total Users',
                    _stats!.totalUsers.toString(),
                    Icons.people,
                    AppColors.primary,
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 120,
                child: InkWell(
                  onTap: () => _tabController.animateTo(2),
                  child: _buildStatCard(
                    'Total Assets',
                    _assets.length.toString(),
                    Icons.business,
                    AppColors.success,
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 120,
                child: InkWell(
                  onTap: () => _tabController.animateTo(2),
                  child: _buildStatCard(
                    'Active Assets',
                    _assets.where((a) => a.status == 'active').length.toString(),
                    Icons.verified,
                    AppColors.investment,
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 120,
                child: InkWell(
                  onTap: () => _tabController.animateTo(5),
                  child: _buildStatCard(
                    'Total NAV',
                    _formatTotalNAV(_assets),
                    Icons.attach_money,
                    AppColors.portfolio,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Asset Categories Overview',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildCategoryStatsGrid(),
          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ...(_activities.take(5).map((activity) => InkWell(
            onTap: () => _showActivityDetails(activity),
            child: _buildActivityCard(activity),
          ))),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                color: color,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                color: Colors.grey[400],
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildUserFilters(),
          const SizedBox(height: 16),
          ..._filteredUsers.map((user) => _buildUserCard(user)),
        ],
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.email,
                      style: AppTextStyles.heading4.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(user.role.toUpperCase()),
                        const SizedBox(width: 8),
                        _buildStatusChip(user.status.toUpperCase()),
                        const SizedBox(width: 8),
                        if (user.kycVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'KYC VERIFIED',
                              style: AppTextStyles.caption.copyWith(color: Colors.white).copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (user.role != 'admin')
                PopupMenuButton<String>(
                  onSelected: (value) => _handleUserAction(user, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view_details',
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('View Details'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view_transactions',
                      child: ListTile(
                        leading: Icon(Icons.receipt),
                        title: Text('View Transactions'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view_assets',
                      child: ListTile(
                        leading: Icon(Icons.business),
                        title: Text('View Assets'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'suspend',
                      child: ListTile(
                        leading: Icon(Icons.block),
                        title: Text('Suspend User'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'activate',
                      child: ListTile(
                        leading: Icon(Icons.check_circle),
                        title: Text('Activate User'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (!user.kycVerified)
                      const PopupMenuItem(
                        value: 'approve_kyc',
                        child: ListTile(
                          leading: Icon(Icons.verified),
                          title: Text('Approve KYC'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Joined: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                  color: Colors.grey[400],
                ),
              ),
              const Spacer(),
              if (user.lastLogin != null)
                Text(
                  'Last login: ${_formatLastLogin(user.lastLogin!)}',
                  style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                    color: Colors.grey[400],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Asset Management',
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add new asset - Coming soon')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Asset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAssetFilters(),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Total: ${_assets.length} assets',
                style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bulk operations - Coming soon')),
                  );
                },
                icon: const Icon(Icons.checklist),
                label: const Text('Bulk Operations'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._assets.map((asset) => _buildAssetManagementCard(asset)),
        ],
      ),
    );
  }

  Widget _buildAssetFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Assets',
            style: AppTextStyles.heading4.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<AssetCategory?>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                    ...AssetCategory.values.map((category) =>
                      DropdownMenuItem(
                        value: category,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(category.icon, color: category.color, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category.displayName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    // Filter logic would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Filtering by ${value?.displayName ?? 'All Categories'}')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                  ],
                  onChanged: (value) {
                    // Filter logic would go here
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<bool>(
                  decoration: const InputDecoration(
                    labelText: 'Verification',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: true, child: Text('Verified')),
                    DropdownMenuItem(value: false, child: Text('Needs Verification')),
                  ],
                  onChanged: (value) {
                    // Filter logic would go here
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetManagementCard(Asset asset) {
    final category = _getAssetCategory(asset.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: category.color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAssetIcon(asset.type),
                  color: category.color,
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
                      style: AppTextStyles.heading4.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category.displayName,
                            style: AppTextStyles.caption.copyWith(color: Colors.white).copyWith(
                              color: category.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SPV ID: ${asset.spvId}',
                          style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Asset Image
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildAssetImage(asset),
                ),
              ),
              _buildStatusChip(asset.status.toUpperCase()),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) => _handleAssetAction(asset, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'verify',
                    child: ListTile(
                      leading: Icon(Icons.verified),
                      title: Text('Verify Asset'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'view_details',
                    child: ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('View Full Details'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'view_media',
                    child: ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('View Media & Docs'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'view_location',
                    child: ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('View on Map'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'view_trading',
                    child: ListTile(
                      leading: Icon(Icons.trending_up),
                      title: Text('View Trading Data'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit Details'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'suspend',
                    child: ListTile(
                      leading: Icon(Icons.block),
                      title: Text('Suspend Asset'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NAV: ${asset.formattedNav}',
                    style: AppTextStyles.heading4.copyWith(color: Colors.white).copyWith(
                      color: category.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Location: ${asset.location?.shortAddress ?? 'Not specified'}',
                    style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (asset.verificationRequired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'VERIFICATION REQUIRED',
                        style: AppTextStyles.caption.copyWith(color: Colors.white).copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Updated: ${_formatAssetDate(asset.createdAt)}',
                    style: AppTextStyles.caption.copyWith(color: Colors.white).copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ..._activities.map((activity) => InkWell(
            onTap: () => _showActivityDetails(activity),
            child: _buildActivityCard(activity),
          )),
        ],
      ),
    );
  }

  Widget _buildActivityCard(AdminActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: AppTextStyles.body1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.user} • ${_formatTimestamp(activity.timestamp)}',
                  style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
      case 'admin':
        color = AppColors.success;
        break;
      case 'pending':
      case 'investor':
        color = AppColors.warning;
        break;
      case 'suspended':
        color = AppColors.error;
        break;
      case 'agent':
      case 'verifier':
        color = AppColors.primary;
        break;
      default:
        color = Colors.grey[400]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTextStyles.caption.copyWith(color: Colors.white).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTotalNAV(List<Asset> assets) {
    final totalNAV = assets.fold(0.0, (sum, asset) => sum + _parseNavValue(asset.nav));
    if (totalNAV >= 1000000000) {
      return '\$${(totalNAV / 1000000000).toStringAsFixed(1)}B';
    } else if (totalNAV >= 1000000) {
      return '\$${(totalNAV / 1000000).toStringAsFixed(1)}M';
    } else if (totalNAV >= 1000) {
      return '\$${(totalNAV / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${totalNAV.toStringAsFixed(0)}';
    }
  }

  Widget _buildCategoryStatsGrid() {
    final categoryStats = _calculateCategoryStats();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: AssetCategory.values.map((category) {
        final stats = categoryStats[category] ?? {'count': 0, 'nav': 0.0};
        final count = stats['count'] as int;
        final nav = stats['nav'] as double;

        return SizedBox(
          width: 220,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: category.color.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: category.color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        count.toString(),
                        style: AppTextStyles.heading3.copyWith(
                          color: category.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  category.displayName,
                  style: AppTextStyles.heading4.copyWith(color: Colors.white).copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'NAV: ${_formatCurrencyShort(nav)}',
                  style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<AssetCategory, Map<String, dynamic>> _calculateCategoryStats() {
    final stats = <AssetCategory, Map<String, dynamic>>{};

    for (final category in AssetCategory.values) {
      final categoryAssets = _assets.where((asset) {
        return _getAssetCategory(asset.type) == category;
      }).toList();

      final totalNAV = categoryAssets.fold(0.0, (sum, asset) => sum + _parseNavValue(asset.nav));

      stats[category] = {
        'count': categoryAssets.length,
        'nav': totalNAV,
      };
    }

    return stats;
  }

  AssetCategory _getAssetCategory(String type) {
    switch (type) {
      case 'house':
      case 'apartment':
      case 'commercial':
      case 'hotel':
      case 'warehouse':
      case 'farmland':
      case 'land':
        return AssetCategory.realEstate;
      case 'car':
      case 'bus':
      case 'truck':
      case 'motorbike':
      case 'boat':
      case 'aircraft':
        return AssetCategory.transportation;
      case 'gold':
      case 'silver':
      case 'diamond':
      case 'watch':
      case 'copper':
        return AssetCategory.precious;
      case 'shares':
      case 'bond':
      case 'business':
      case 'franchise':
        return AssetCategory.financial;
      case 'solar':
      case 'agriculture':
      case 'carbon':
        return AssetCategory.sustainable;
      default:
        return AssetCategory.financial;
    }
  }

  String _formatCurrencyShort(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${value.toStringAsFixed(0)}';
    }
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Categories Management',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildCategoryManagementGrid(),
          const SizedBox(height: 32),
          Text(
            'Category Distribution',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildCategoryDistributionCards(),
        ],
      ),
    );
  }

  Widget _buildCategoryManagementGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: AssetCategory.values.length,
      itemBuilder: (context, index) {
        final category = AssetCategory.values[index];
        final categoryAssets = _assets.where((asset) =>
          _getAssetCategory(asset.type) == category).toList();

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: category.color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 32,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCategoryAction(category, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add_asset',
                        child: Text('Add New Asset'),
                      ),
                      const PopupMenuItem(
                        value: 'view_all',
                        child: Text('View All Assets'),
                      ),
                      const PopupMenuItem(
                        value: 'bulk_update',
                        child: Text('Bulk Update'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                category.displayName,
                style: AppTextStyles.heading4.copyWith(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                category.description,
                style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                  color: Colors.grey[400],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    '${categoryAssets.length} assets',
                    style: AppTextStyles.heading4.copyWith(color: Colors.white).copyWith(
                      color: category.color,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category.subCategories.length} types',
                      style: AppTextStyles.caption.copyWith(color: Colors.white).copyWith(
                        color: category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDistributionCards() {
    final totalAssets = _assets.length;

    return Column(
      children: AssetCategory.values.map((category) {
        final categoryAssets = _assets.where((asset) =>
          _getAssetCategory(asset.type) == category).toList();
        final percentage = totalAssets > 0 ? (categoryAssets.length / totalAssets * 100) : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: AppTextStyles.heading4.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: category.color.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation(category.color),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                            color: category.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${categoryAssets.length}',
                style: AppTextStyles.heading3.copyWith(
                  color: category.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _handleCategoryAction(AssetCategory category, String action) {
    switch (action) {
      case 'add_asset':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add ${category.displayName} asset - Coming soon')),
        );
        break;
      case 'view_all':
        _tabController.animateTo(2); // Switch to Assets tab
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viewing all ${category.displayName} assets')),
        );
        break;
      case 'bulk_update':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bulk update for ${category.displayName} - Coming soon')),
        );
        break;
    }
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

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'user_registration':
        return Icons.person_add;
      case 'asset_creation':
        return Icons.add_business;
      case 'verification':
        return Icons.verified;
      case 'transaction':
        return Icons.attach_money;
      default:
        return Icons.info;
    }
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _handleUserAction(AdminUser user, String action) async {
    try {
      switch (action) {
        case 'view_details':
          _showUserDetails(user);
          break;
        case 'view_transactions':
          _showUserTransactions(user);
          break;
        case 'view_assets':
          _showUserAssets(user);
          break;
        case 'suspend':
          await AdminService.updateUserStatus(user.id, 'suspended');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${user.email} suspended successfully'),
              backgroundColor: AppColors.warning,
            ),
          );
          _loadDashboardData();
          break;
        case 'activate':
          await AdminService.updateUserStatus(user.id, 'active');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${user.email} activated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadDashboardData();
          break;
        case 'approve_kyc':
          await AdminService.approveKyc(user.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('KYC approved for ${user.email}'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadDashboardData();
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleAssetAction(Asset asset, String action) async {
    try {
      switch (action) {
        case 'verify':
          await AdminService.verifyAsset(asset.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Asset "${asset.title}" verified successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          break;
        case 'view_details':
          _showAssetDetailsDialog(asset);
          break;
        case 'view_media':
          _showAssetMediaDialog(asset);
          break;
        case 'view_location':
          _showAssetLocationDialog(asset);
          break;
        case 'view_trading':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Trading data for "${asset.title}" - Feature coming soon'),
              backgroundColor: AppColors.primary,
            ),
          );
          break;
        case 'suspend':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Asset suspension functionality coming soon'),
              backgroundColor: AppColors.warning,
            ),
          );
          break;
        case 'edit':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Asset editing functionality coming soon'),
              backgroundColor: AppColors.primary,
            ),
          );
          break;
      }

      if (action == 'verify') {
        _loadDashboardData(); // Refresh data only for actions that change state
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final searchText = _userSearchController.text.toLowerCase();
        final matchesSearch = searchText.isEmpty ||
                             user.email.toLowerCase().contains(searchText);

        final matchesRole = _selectedRole == null || user.role == _selectedRole;
        final matchesStatus = _selectedStatus == null || user.status == _selectedStatus;
        final matchesKyc = _kycFilter == null || user.kycVerified == _kycFilter;

        return matchesSearch && matchesRole && matchesStatus && matchesKyc;
      }).toList();
    });
  }

  Widget _buildUserFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Users',
            style: AppTextStyles.heading4.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _userSearchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by email',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _filterUsers(),
                ),
              ),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Roles')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'investor', child: Text('Investor')),
                    DropdownMenuItem(value: 'agent', child: Text('Agent')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                    _filterUsers();
                  },
                ),
              ),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _filterUsers();
                  },
                ),
              ),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<bool>(
                  value: _kycFilter,
                  decoration: const InputDecoration(
                    labelText: 'KYC Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All KYC')),
                    DropdownMenuItem(value: true, child: Text('Verified')),
                    DropdownMenuItem(value: false, child: Text('Not Verified')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _kycFilter = value;
                    });
                    _filterUsers();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _userSearchController.clear();
                    _selectedRole = null;
                    _selectedStatus = null;
                    _kycFilter = null;
                  });
                  _filterUsers();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
              ),
              const Spacer(),
              Text(
                'Showing ${_filteredUsers.length} of ${_users.length} users',
                style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAssetDetailsDialog(Asset asset) {
    final category = _getAssetCategory(asset.type);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getAssetIcon(asset.type),
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                asset.title,
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('SPV ID', asset.spvId),
              _buildDetailRow('Category', category.displayName),
              _buildDetailRow('Type', asset.type.toUpperCase()),
              _buildDetailRow('Status', asset.status.toUpperCase()),
              _buildDetailRow('NAV', asset.formattedNav),
              _buildDetailRow('Location', asset.location?.fullAddress ?? 'Not specified'),
              _buildDetailRow('Created', _formatAssetDate(asset.createdAt)),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: AppTextStyles.heading4.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                asset.description ?? 'No description available',
                style: AppTextStyles.body2.copyWith(color: Colors.white),
              ),
              if (asset.verificationRequired) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This asset requires verification before trading',
                          style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (asset.verificationRequired)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleAssetAction(asset, 'verify');
              },
              child: const Text('Verify Asset'),
            ),
        ],
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
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAssetDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  double _parseNavValue(String navString) {
    // Remove currency symbols and parse the numeric value
    final cleanedString = navString.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanedString) ?? 0.0;
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Analytics',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Analytics Metrics Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 220,
                child: _buildAnalyticsMetricCard(
                  'Total Revenue',
                  '\$2.8M',
                  '↗ 12.5%',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              SizedBox(
                width: 220,
                child: _buildAnalyticsMetricCard(
                  'Active Investments',
                  '1,247',
                  '↗ 8.2%',
                  Colors.blue,
                  Icons.account_balance,
                ),
              ),
              SizedBox(
                width: 220,
                child: _buildAnalyticsMetricCard(
                  'Platform Fees',
                  '\$142K',
                  '↗ 15.3%',
                  Colors.purple,
                  Icons.account_balance_wallet,
                ),
              ),
              SizedBox(
                width: 220,
                child: _buildAnalyticsMetricCard(
                  'User Growth',
                  '+89',
                  '↗ 22.1%',
                  Colors.orange,
                  Icons.people,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Performance Charts Section
          Text(
            'Performance Overview',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  children: [
                    Expanded(child: _buildAnalyticsChartCard('Asset Performance', 'View detailed asset performance metrics and trends')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAnalyticsChartCard('Revenue Trends', 'Monitor revenue growth and forecasting')),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildAnalyticsChartCard('Asset Performance', 'View detailed asset performance metrics and trends'),
                    const SizedBox(height: 16),
                    _buildAnalyticsChartCard('Revenue Trends', 'Monitor revenue growth and forecasting'),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 32),

          // Top Assets Table
          Text(
            'Top Performing Assets',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildTopAssetsTable(),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compliance Management',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Compliance Status Overview - Clickable
          Row(
            children: [
              Expanded(child: _buildClickableComplianceCard('KYC Status', '142 / 156', '91%', AppColors.success, () => _showKYCApprovalList())),
              const SizedBox(width: 16),
              Expanded(child: _buildClickableComplianceCard('AML Checks', '156 / 156', '100%', AppColors.success, () => _showAMLList())),
              const SizedBox(width: 16),
              Expanded(child: _buildClickableComplianceCard('Doc Verification', '28 / 30', '93%', AppColors.warning, () => _showDocVerificationList())),
              const SizedBox(width: 16),
              Expanded(child: _buildClickableComplianceCard('Risk Assessment', '30 / 30', '100%', AppColors.success, () => _showRiskAssessmentList())),
            ],
          ),

          const SizedBox(height: 32),

          // Pending Approvals Section
          Text(
            'Pending Approvals',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),

          _buildPendingApprovalsList(),

          const SizedBox(height: 32),

          // Recent Compliance Activity
          Text(
            'Recent Compliance Activity',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),

          _buildComplianceActivityList(),
        ],
      ),
    );
  }

  void _showActivityDetails(AdminActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActivityIcon(activity.type),
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Activity Details',
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', activity.type.toUpperCase()),
              _buildDetailRow('User', activity.user),
              _buildDetailRow('Timestamp', _formatTimestamp(activity.timestamp)),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: AppTextStyles.heading4.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                activity.description,
                style: AppTextStyles.body2.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity investigation features coming soon')),
              );
            },
            child: const Text('Investigate'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'User Details',
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Role', user.role.toUpperCase()),
              _buildDetailRow('Status', user.status.toUpperCase()),
              _buildDetailRow('KYC Status', user.kycVerified ? 'VERIFIED' : 'NOT VERIFIED'),
              _buildDetailRow('Joined', _formatAssetDate(user.createdAt)),
              if (user.lastLogin != null)
                _buildDetailRow('Last Login', _formatLastLogin(user.lastLogin!)),
              const SizedBox(height: 16),
              Text(
                'Account Summary',
                style: AppTextStyles.heading4.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Balance:', style: AppTextStyles.body2.copyWith(color: Colors.white)),
                        Text('\$${(user.id * 1234.56).toStringAsFixed(2)}',
                             style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Assets Owned:', style: AppTextStyles.body2.copyWith(color: Colors.white)),
                        Text('${user.id % 5 + 1}',
                             style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transactions:', style: AppTextStyles.body2.copyWith(color: Colors.white)),
                        Text('${user.id * 3 + 7}',
                             style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                      ],
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
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showUserTransactions(user);
            },
            child: const Text('View Transactions'),
          ),
        ],
      ),
    );
  }

  void _showUserTransactions(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.email} - Transactions'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text('Transaction history for ${user.email}'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: user.id * 2 + 3,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.receipt),
                      title: Text('Transaction #${1000 + index}'),
                      subtitle: Text('Amount: \$${(index + 1) * 125.50}'),
                      trailing: Text('${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().month}'),
                    );
                  },
                ),
              ),
            ],
          ),
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

  void _showUserAssets(AdminUser user) {
    final userAssets = _assets.where((asset) => asset.id % 10 == user.id % 10).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.email} - Assets'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text('Assets owned by ${user.email}'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: userAssets.length,
                  itemBuilder: (context, index) {
                    final asset = userAssets[index];
                    return ListTile(
                      leading: Icon(_getAssetIcon(asset.type)),
                      title: Text(asset.title),
                      subtitle: Text(asset.type.toUpperCase()),
                      trailing: Text(asset.nav),
                    );
                  },
                ),
              ),
            ],
          ),
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

  void _showAssetMediaDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${asset.title} - Media & Documents'),
        content: Container(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Images & Videos', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline.withOpacity(0.2)),
                  ),
                  child: asset.images.isNotEmpty
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: asset.images.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(Icons.image, color: AppColors.primary),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('No media files', style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400])),
                          ],
                        ),
                      ),
                ),
                const SizedBox(height: 24),
                Text('Documents', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                _buildDocumentItem('Property Deed', 'deed.pdf', Icons.description),
                _buildDocumentItem('Valuation Report', 'valuation.pdf', Icons.assessment),
                _buildDocumentItem('Insurance Certificate', 'insurance.pdf', Icons.security),
                _buildDocumentItem('Tax Records', 'tax_records.pdf', Icons.receipt_long),
                const SizedBox(height: 24),
                Text('Verifiers', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                _buildVerifierItem('John Smith', 'Property Appraiser', Icons.verified_user),
                _buildVerifierItem('Sarah Johnson', 'Legal Counsel', Icons.gavel),
                _buildVerifierItem('Mike Brown', 'Insurance Agent', Icons.security),
              ],
            ),
          ),
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

  Widget _buildDocumentItem(String name, String filename, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
                Text(filename, style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400])),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening $filename...')),
              );
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifierItem(String name, String role, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
                Text(role, style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'VERIFIED',
              style: AppTextStyles.caption.copyWith(color: Colors.white).copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssetLocationDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${asset.title} - Location'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (asset.location != null) ...[
                _buildDetailRow('Address', asset.location!.fullAddress),
                _buildDetailRow('City', asset.location!.city),
                _buildDetailRow('State', asset.location!.state),
                _buildDetailRow('Country', asset.location!.country),
                _buildDetailRow('Coordinates', '${asset.location!.latitude.toStringAsFixed(6)}, ${asset.location!.longitude.toStringAsFixed(6)}'),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 64, color: AppColors.primary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('Interactive Map View', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(
                            'Map integration coming soon.\nThis will show the exact location of the asset.',
                            style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No location data available', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (asset.location != null)
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening in external map app...')),
                );
              },
              child: const Text('Open in Maps'),
            ),
        ],
      ),
    );
  }

  // Compliance helper methods
  Widget _buildClickableComplianceCard(String title, String value, String percentage, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              percentage,
              style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovalsList() {
    final pendingItems = [
      {'type': 'KYC', 'user': 'john.doe@example.com', 'submitted': '2 hours ago', 'priority': 'High'},
      {'type': 'Document', 'user': 'jane.smith@example.com', 'submitted': '4 hours ago', 'priority': 'Medium'},
      {'type': 'Asset Verification', 'user': 'mike.brown@example.com', 'submitted': '1 day ago', 'priority': 'Low'},
      {'type': 'AML Review', 'user': 'sarah.wilson@example.com', 'submitted': '3 hours ago', 'priority': 'High'},
    ];

    return Column(
      children: pendingItems.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withOpacity(0.2)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getPriorityColor(item['priority']!).withOpacity(0.1),
            child: Icon(
              _getApprovalIcon(item['type']!),
              color: _getPriorityColor(item['priority']!),
              size: 20,
            ),
          ),
          title: Text('${item['type']} Approval'),
          subtitle: Text('${item['user']} • ${item['submitted']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(item['priority']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['priority']!,
                  style: AppTextStyles.caption.copyWith(color: Colors.white).copyWith(
                    color: _getPriorityColor(item['priority']!),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) => _handleApprovalAction(item, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'approve', child: Text('Approve')),
                  const PopupMenuItem(value: 'reject', child: Text('Reject')),
                  const PopupMenuItem(value: 'review', child: Text('Review Details')),
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildComplianceActivityList() {
    final activities = [
      {'action': 'KYC Approved', 'user': 'admin@company.com', 'target': 'investor1@example.com', 'time': '10 min ago'},
      {'action': 'Document Rejected', 'user': 'admin@company.com', 'target': 'user2@example.com', 'time': '25 min ago'},
      {'action': 'AML Check Completed', 'user': 'system', 'target': 'investor3@example.com', 'time': '1 hour ago'},
      {'action': 'Risk Assessment Updated', 'user': 'admin@company.com', 'target': 'Asset RE-001', 'time': '2 hours ago'},
    ];

    return Column(
      children: activities.map((activity) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.security,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['action']!,
                    style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${activity['user']} → ${activity['target']}',
                    style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Text(
              activity['time']!,
              style: AppTextStyles.caption.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
        return AppColors.success;
      default:
        return Colors.grey[400]!;
    }
  }

  IconData _getApprovalIcon(String type) {
    switch (type) {
      case 'KYC':
        return Icons.person_outline;
      case 'Document':
        return Icons.description;
      case 'Asset Verification':
        return Icons.business;
      case 'AML Review':
        return Icons.security;
      default:
        return Icons.approval;
    }
  }

  void _handleApprovalAction(Map<String, String> item, String action) {
    switch (action) {
      case 'approve':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['type']} approved for ${item['user']}'),
            backgroundColor: AppColors.success,
          ),
        );
        break;
      case 'reject':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['type']} rejected for ${item['user']}'),
            backgroundColor: AppColors.error,
          ),
        );
        break;
      case 'review':
        _showApprovalDetails(item);
        break;
    }
  }

  void _showApprovalDetails(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item['type']} Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', item['type']!),
            _buildDetailRow('User', item['user']!),
            _buildDetailRow('Submitted', item['submitted']!),
            _buildDetailRow('Priority', item['priority']!),
            const SizedBox(height: 16),
            const Text('Additional review details would be shown here...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleApprovalAction(item, 'approve');
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showKYCApprovalList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('KYC Approvals')),
          body: const Center(child: Text('KYC approval list would be implemented here')),
        ),
      ),
    );
  }

  void _showAMLList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('AML Monitoring')),
          body: const Center(child: Text('AML monitoring list would be implemented here')),
        ),
      ),
    );
  }

  void _showDocVerificationList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Document Verification')),
          body: const Center(child: Text('Document verification list would be implemented here')),
        ),
      ),
    );
  }

  void _showRiskAssessmentList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Risk Assessment')),
          body: const Center(child: Text('Risk assessment list would be implemented here')),
        ),
      ),
    );
  }

  // Analytics helper methods
  Widget _buildAnalyticsMetricCard(String title, String value, String change, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                change,
                style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsChartCard(String title, String description) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading4.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSimpleChartBar('Q1', 0.6, AppColors.primary),
                          _buildSimpleChartBar('Q2', 0.8, AppColors.primary),
                          _buildSimpleChartBar('Q3', 0.4, AppColors.primary),
                          _buildSimpleChartBar('Q4', 0.9, AppColors.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Interactive chart view',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAssetsTable() {
    final topAssets = _assets.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asset Performance',
                style: AppTextStyles.heading4.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${topAssets.length} assets',
                style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topAssets.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.business_center_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No assets available',
                      style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add assets to see performance metrics',
                      style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...topAssets.map((asset) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business_center,
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
                        style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'NAV: ${asset.nav}',
                        style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Text(
                  '↗ ${(5 + (asset.id % 20)).toStringAsFixed(1)}%',
                  style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content Management & Messaging',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Send targeted messages to users based on categories and segments',
            style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),

          // Quick Actions Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMessageActionCard(
                'Broadcast Message',
                'Send to all users',
                Icons.campaign,
                Colors.blue,
                () => _showMessageComposer('broadcast'),
              ),
              _buildMessageActionCard(
                'Category Message',
                'Target by asset category',
                Icons.category,
                Colors.green,
                () => _showMessageComposer('category'),
              ),
              _buildMessageActionCard(
                'User Segment',
                'Send to specific user groups',
                Icons.people,
                Colors.orange,
                () => _showMessageComposer('segment'),
              ),
              _buildMessageActionCard(
                'Announcement',
                'Platform updates & news',
                Icons.announcement,
                Colors.purple,
                () => _showMessageComposer('announcement'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Messages Section
          Text(
            'Recent Messages',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildRecentMessagesList(),

          const SizedBox(height: 32),

          // Message Templates Section
          Text(
            'Message Templates',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildMessageTemplates(),
        ],
      ),
    );
  }

  Widget _buildMessageActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
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
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.heading4.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMessagesList() {
    final recentMessages = [
      {
        'title': 'Platform Maintenance Notice',
        'type': 'Announcement',
        'category': 'All Users',
        'sent': '2 hours ago',
        'recipients': '1,247',
        'status': 'Delivered',
        'color': Colors.blue,
      },
      {
        'title': 'New Real Estate Opportunities',
        'type': 'Category Message',
        'category': 'Real Estate Investors',
        'sent': '1 day ago',
        'recipients': '453',
        'status': 'Delivered',
        'color': Colors.green,
      },
      {
        'title': 'KYC Document Update Required',
        'type': 'User Segment',
        'category': 'Pending Verification',
        'sent': '2 days ago',
        'recipients': '89',
        'status': 'Delivered',
        'color': Colors.orange,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: recentMessages.map((message) => _buildMessageListItem(message)).toList(),
      ),
    );
  }

  Widget _buildMessageListItem(Map<String, dynamic> message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outline.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (message['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.message,
              color: message['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['title'],
                  style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${message['type']} • ${message['category']}',
                  style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message['sent'],
                style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
              ),
              Text(
                '${message['recipients']} recipients',
                style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTemplates() {
    final templates = [
      {
        'title': 'Welcome Message',
        'description': 'New user onboarding message',
        'category': 'Onboarding',
        'icon': Icons.waving_hand,
        'color': Colors.blue,
      },
      {
        'title': 'Investment Opportunity',
        'description': 'Notify about new assets',
        'category': 'Marketing',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'title': 'Document Reminder',
        'description': 'KYC/AML compliance reminder',
        'category': 'Compliance',
        'icon': Icons.description,
        'color': Colors.orange,
      },
      {
        'title': 'Market Update',
        'description': 'Weekly market insights',
        'category': 'Newsletter',
        'icon': Icons.insights,
        'color': Colors.purple,
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: templates.map((template) => _buildTemplateCard(template)).toList(),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return SizedBox(
      width: 200,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (template['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                template['icon'],
                color: template['color'],
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              template['title'],
              style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              template['description'],
              style: AppTextStyles.body2.copyWith(color: Colors.white).copyWith(color: Colors.grey[400]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (template['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                template['category'],
                style: TextStyle(
                  fontSize: 10,
                  color: template['color'],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageComposer(String messageType) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compose ${messageType.substring(0, 1).toUpperCase()}${messageType.substring(1)} Message',
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Target Selection
              if (messageType == 'category') ...[
                Text('Select Category:', style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Choose asset category',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'real_estate', child: Text('Real Estate Investors')),
                    DropdownMenuItem(value: 'transportation', child: Text('Transportation Assets')),
                    DropdownMenuItem(value: 'financial', child: Text('Financial Instruments')),
                    DropdownMenuItem(value: 'precious', child: Text('Precious Metals')),
                    DropdownMenuItem(value: 'sustainable', child: Text('Sustainable Investments')),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
              ],

              if (messageType == 'segment') ...[
                Text('Select User Segment:', style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Choose user segment',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'kyc_pending', child: Text('KYC Pending')),
                    DropdownMenuItem(value: 'verified', child: Text('Verified Users')),
                    DropdownMenuItem(value: 'active_investors', child: Text('Active Investors')),
                    DropdownMenuItem(value: 'new_users', child: Text('New Users (Last 30 days)')),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
              ],

              // Message Content
              Text('Subject:', style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter message subject',
                ),
              ),
              const SizedBox(height: 16),

              Text('Message:', style: AppTextStyles.body1.copyWith(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your message content...',
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${messageType.substring(0, 1).toUpperCase()}${messageType.substring(1)} message sent successfully')),
                        );
                      },
                      child: const Text('Send Message'),
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

  Widget _buildSimpleChartBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: height * 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 8)),
      ],
    );
  }

  Widget _buildAssetImage(Asset asset) {
    // Mock asset images based on asset type
    String imagePath = _getAssetImagePath(asset.type);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAssetCategory(asset.type).color.withOpacity(0.3),
            _getAssetCategory(asset.type).color.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            _getAssetIcon(asset.type),
            color: _getAssetCategory(asset.type).color,
            size: 32,
          ),
          // Overlay with asset type text
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getAssetTypeShort(asset.type),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAssetImagePath(String assetType) {
    // In a real app, these would be actual image paths/URLs
    switch (assetType.toLowerCase()) {
      case 'house':
      case 'apartment':
        return 'assets/images/house.jpg';
      case 'commercial':
        return 'assets/images/commercial.jpg';
      case 'hotel':
        return 'assets/images/hotel.jpg';
      case 'warehouse':
        return 'assets/images/warehouse.jpg';
      case 'car':
        return 'assets/images/car.jpg';
      case 'truck':
        return 'assets/images/truck.jpg';
      case 'boat':
        return 'assets/images/boat.jpg';
      default:
        return 'assets/images/default_asset.jpg';
    }
  }

  String _getAssetTypeShort(String assetType) {
    switch (assetType.toLowerCase()) {
      case 'house':
        return 'HSE';
      case 'apartment':
        return 'APT';
      case 'commercial':
        return 'COM';
      case 'hotel':
        return 'HTL';
      case 'warehouse':
        return 'WHR';
      case 'farmland':
        return 'FRM';
      case 'land':
        return 'LND';
      case 'car':
        return 'CAR';
      case 'bus':
        return 'BUS';
      case 'truck':
        return 'TRK';
      case 'motorbike':
        return 'MTB';
      case 'boat':
        return 'BOT';
      case 'aircraft':
        return 'AIR';
      default:
        return 'AST';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }
}