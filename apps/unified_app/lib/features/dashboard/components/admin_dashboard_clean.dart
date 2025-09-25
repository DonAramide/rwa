import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/admin_users_provider.dart';
import '../../../providers/admin_stats_provider.dart';
import '../../../providers/assets_provider.dart';
import '../../../models/admin_stats.dart';
import '../../../models/asset.dart';

class AdminDashboardClean extends ConsumerStatefulWidget {
  const AdminDashboardClean({super.key});

  @override
  ConsumerState<AdminDashboardClean> createState() => _AdminDashboardCleanState();
}

class _AdminDashboardCleanState extends ConsumerState<AdminDashboardClean>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Asset management state
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Status';
  String _selectedVerification = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Load data using providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminStatsProvider.notifier).loadDashboardData();
      ref.read(adminUsersProvider.notifier).loadUsers();
      ref.read(assetsProvider.notifier).loadAssets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsState = ref.watch(adminStatsProvider);
    final usersState = ref.watch(adminUsersProvider);
    final assetsState = ref.watch(assetsProvider);

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
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.security), text: 'Security'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(isDark, statsState),

          // Users Tab
          _buildUsersTab(isDark, usersState),

          // Assets Tab
          _buildAssetsTab(isDark, assetsState),

          // Analytics Tab
          _buildAnalyticsTab(isDark, statsState),

          // Security Tab
          _buildSecurityTab(isDark),

          // Settings Tab
          _buildSettingsTab(isDark),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark, AdminStatsState statsState) {
    if (statsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (statsState.error != null) {
      return Center(
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
              'Error loading dashboard data',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              statsState.error!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(adminStatsProvider.notifier).loadDashboardData(forceRefresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = statsState.stats;
    if (stats == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsCards(isDark, stats),

          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivity(isDark, statsState.activities),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDark, AdminStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          isDark,
          'Total Users',
          stats.totalUsers.toString(),
          Icons.people,
          AppColors.primary,
        ),
        _buildStatCard(
          isDark,
          'Total Assets',
          stats.totalAssets.toString(),
          Icons.business,
          AppColors.success,
        ),
        _buildStatCard(
          isDark,
          'Active Assets',
          stats.activeAssets.toString(),
          Icons.check_circle,
          AppColors.info,
        ),
        _buildStatCard(
          isDark,
          'Total NAV',
          '\$${(stats.totalNAV / 1000000).toStringAsFixed(1)}M',
          Icons.attach_money,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(bool isDark, String title, String value, IconData icon, Color color) {
    return Card(
      color: AppColors.getSurface(isDark),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildRecentActivity(bool isDark, List<AdminActivity> activities) {
    return Card(
      color: AppColors.getSurface(isDark),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              Center(
                child: Text(
                  'No recent activity',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => Divider(
                  color: AppColors.getDivider(isDark),
                ),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _getActivityColor(activity.type).withOpacity(0.1),
                      child: Icon(
                        _getActivityIcon(activity.type),
                        color: _getActivityColor(activity.type),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      activity.description,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    subtitle: Text(
                      _formatTimestamp(activity.timestamp),
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    trailing: Text(
                      activity.user,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(bool isDark, AdminUsersState usersState) {
    if (usersState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (usersState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error loading users', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              usersState.error!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(adminUsersProvider.notifier).loadUsers();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final users = usersState.users;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Users filters and search would go here
          Text(
            'Users (${users.length})',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 16),

          // Users list
          Card(
            color: AppColors.getSurface(isDark),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.getDivider(isDark),
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                    child: Text(
                      user.email[0].toUpperCase(),
                      style: TextStyle(
                        color: _getRoleColor(user.role),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user.email,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  subtitle: Text(
                    '${user.role} • ${user.status}',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user.kycVerified)
                        Icon(Icons.verified, color: AppColors.success, size: 20)
                      else
                        Icon(Icons.pending, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('View Details'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit User'),
                          ),
                          if (!user.kycVerified)
                            const PopupMenuItem(
                              value: 'approve_kyc',
                              child: Text('Approve KYC'),
                            ),
                          const PopupMenuItem(
                            value: 'suspend',
                            child: Text('Suspend'),
                          ),
                        ],
                        onSelected: (value) {
                          _handleUserAction(user.id, value.toString());
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsTab(bool isDark, AssetsState assetsState) {
    if (assetsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assetsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error loading assets', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              assetsState.error!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(assetsProvider.notifier).loadAssets();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final assets = assetsState.assets;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assets (${assets.length})',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 16),

          // Assets grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 :
                             MediaQuery.of(context).size.width > 800 ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return _buildAssetCard(isDark, asset);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(bool isDark, Asset asset) {
    return Card(
      color: AppColors.getSurface(isDark),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    asset.title,
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View Details')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit Asset')),
                    const PopupMenuItem(value: 'verify', child: Text('Verify')),
                    const PopupMenuItem(value: 'archive', child: Text('Archive')),
                  ],
                  onSelected: (value) {
                    _handleAssetAction(asset.id, value.toString());
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              asset.type,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              asset.status,
              style: AppTextStyles.body2.copyWith(
                color: _getStatusColor(asset.status),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (asset.nav != null)
              Text(
                '\$${asset.nav}',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(bool isDark, AdminStatsState statsState) {
    return const Center(
      child: Text('Analytics coming soon...'),
    );
  }

  Widget _buildSecurityTab(bool isDark) {
    return const Center(
      child: Text('Security settings coming soon...'),
    );
  }

  Widget _buildSettingsTab(bool isDark) {
    return const Center(
      child: Text('Settings coming soon...'),
    );
  }

  // Helper methods
  Color _getActivityColor(String type) {
    switch (type) {
      case 'user_registration':
        return AppColors.primary;
      case 'asset_creation':
        return AppColors.success;
      case 'verification':
        return AppColors.info;
      case 'transaction':
        return AppColors.warning;
      default:
        return AppColors.secondary;
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'investor':
        return AppColors.primary;
      case 'agent':
        return AppColors.success;
      case 'verifier':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'inactive':
      case 'suspended':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  void _handleUserAction(int userId, String action) {
    switch (action) {
      case 'approve_kyc':
        ref.read(adminUsersProvider.notifier).approveKyc(userId);
        break;
      case 'suspend':
        ref.read(adminUsersProvider.notifier).updateUserStatus(userId, 'suspended');
        break;
      // Add other actions as needed
    }
  }

  void _handleAssetAction(int assetId, String action) {
    // Implement asset actions
    print('Asset $assetId action: $action');
  }
}