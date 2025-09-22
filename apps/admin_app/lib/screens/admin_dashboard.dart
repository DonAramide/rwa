import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/assets_provider.dart';
import '../providers/agents_provider.dart';
import '../providers/payouts_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/banks_provider.dart';
import '../providers/brand_provider.dart';
import '../models/brand_model.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RWA Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                selectedIcon: Icon(Icons.business),
                label: Text('Assets'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people),
                label: Text('Agents'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.verified_user),
                selectedIcon: Icon(Icons.verified_user),
                label: Text('Verification'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.payments),
                selectedIcon: Icon(Icons.payments),
                label: Text('Payouts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_balance),
                selectedIcon: Icon(Icons.account_balance),
                label: Text('Banks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                selectedIcon: Icon(Icons.assignment),
                label: Text('Proposals'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.palette),
                selectedIcon: Icon(Icons.palette),
                label: Text('Brands'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const _OverviewTab();
      case 1:
        return const _AssetsTab();
      case 2:
        return const _AgentsTab();
      case 3:
        return const _VerificationTab();
      case 4:
        return const _PayoutsTab();
      case 5:
        return const _BanksTab();
      case 6:
        return const _ProposalsTab();
      case 7:
        return const _AnalyticsTab();
      case 8:
        return const _BrandsTab();
      default:
        return const _OverviewTab();
    }
  }
}

class _OverviewTab extends ConsumerStatefulWidget {
  const _OverviewTab();

  @override
  ConsumerState<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<_OverviewTab> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assetsProvider.notifier).loadAssets();
      ref.read(agentsProvider.notifier).loadAgents();
      ref.read(payoutsProvider.notifier).loadDistributions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsProvider);
    final agentsState = ref.watch(agentsProvider);
    final payoutsState = ref.watch(payoutsProvider);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Assets',
                  value: assetsState.assets.length.toString(),
                  subtitle: '${ref.read(assetsProvider.notifier).pendingAssets.length} pending approval',
                  icon: Icons.business,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Active Agents',
                  value: ref.read(agentsProvider.notifier).approvedAgents.length.toString(),
                  subtitle: '${ref.read(agentsProvider.notifier).pendingAgents.length} pending approval',
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Total Value',
                  value: '\$${(ref.read(assetsProvider.notifier).totalPortfolioValue / 1000000).toStringAsFixed(1)}M',
                  subtitle: 'Portfolio NAV',
                  icon: Icons.attach_money,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Monthly Payouts',
                  value: '\$${(ref.read(payoutsProvider.notifier).totalPayoutsThisMonth / 1000).toStringAsFixed(1)}K',
                  subtitle: 'This month',
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _RecentActivityCard(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickActionsCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ActivityItem(
              icon: Icons.business,
              title: 'New Asset Added',
              subtitle: 'Historic Brownstone - Brooklyn, NY',
              time: '2 hours ago',
              color: Colors.blue,
            ),
            _ActivityItem(
              icon: Icons.verified_user,
              title: 'Verification Completed',
              subtitle: 'Luxury Villa - Malibu, CA',
              time: '4 hours ago',
              color: Colors.green,
            ),
            _ActivityItem(
              icon: Icons.people,
              title: 'Agent Approved',
              subtitle: 'David Brown - Residential Specialist',
              time: '1 day ago',
              color: Colors.orange,
            ),
            _ActivityItem(
              icon: Icons.payments,
              title: 'Payout Processed',
              subtitle: '\$12,450 to 5 investors',
              time: '2 days ago',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ActionButton(
              icon: Icons.add_business,
              title: 'Add New Asset',
              subtitle: 'Create asset listing',
              onTap: () {
                // TODO: Navigate to add asset
              },
            ),
            _ActionButton(
              icon: Icons.people_alt,
              title: 'Manage Agents',
              subtitle: 'Review applications',
              onTap: () {
                // TODO: Navigate to agents
              },
            ),
            _ActionButton(
              icon: Icons.verified_user,
              title: 'Review Verifications',
              subtitle: 'Pending reports',
              onTap: () {
                // TODO: Navigate to verifications
              },
            ),
            _ActionButton(
              icon: Icons.payments,
              title: 'Process Payouts',
              subtitle: 'Monthly distributions',
              onTap: () {
                // TODO: Navigate to payouts
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetsTab extends ConsumerStatefulWidget {
  const _AssetsTab();

  @override
  ConsumerState<_AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends ConsumerState<_AssetsTab> {
  @override
  void initState() {
    super.initState();
    // Load assets when tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assetsProvider.notifier).loadAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsProvider);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asset Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add new asset
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Asset'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _AssetTableHeader(),
                    const Divider(),
                    Expanded(
                      child: assetsState.isLoading && assetsState.assets.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : assetsState.assets.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No assets found',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () => ref.read(assetsProvider.notifier).loadAssets(),
                                  child: ListView.builder(
                                    itemCount: assetsState.assets.length,
                                    itemBuilder: (context, index) {
                                      final asset = assetsState.assets[index];
                                      return _AssetTableRow(
                                        id: asset['id'] ?? 0,
                                        title: asset['title'] ?? 'Unknown Asset',
                                        type: asset['type'] ?? 'Unknown',
                                        status: asset['status'] ?? 'Unknown',
                                        nav: (asset['nav'] ?? 0.0).toDouble(),
                                        created: _formatDate(asset['created_at']),
                                        onEdit: () {
                                          // TODO: Navigate to edit asset
                                        },
                                        onView: () {
                                          ref.read(assetsProvider.notifier).loadAsset(asset['id']);
                                          _showAssetDetails(context, asset);
                                        },
                                      );
                                    },
                                  ),
                                ),
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inMinutes} minutes ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showAssetDetails(BuildContext context, Map<String, dynamic> asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset['title'] ?? 'Asset Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${asset['type']}'),
            Text('Status: ${asset['status']}'),
            Text('NAV: \$${(asset['nav'] ?? 0.0).toStringAsFixed(2)}'),
            Text('Created: ${_formatDate(asset['created_at'])}'),
            if (asset['description'] != null)
              Text('Description: ${asset['description']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (asset['status'] == 'pending')
            ElevatedButton(
              onPressed: () {
                ref.read(assetsProvider.notifier).verifyAsset(asset['id'], true, null);
                Navigator.of(context).pop();
              },
              child: const Text('Approve'),
            ),
        ],
      ),
    );
  }
}

class _AssetTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Asset', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Type', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Status', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(child: Text('NAV', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Created', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Actions', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _AssetTableRow extends StatelessWidget {
  final int id;
  final String title;
  final String type;
  final String status;
  final double nav;
  final String created;
  final VoidCallback? onEdit;
  final VoidCallback? onView;

  const _AssetTableRow({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.nav,
    required this.created,
    this.onEdit,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'suspended':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              type,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$${nav.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              created,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  tooltip: 'Edit asset',
                ),
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility, size: 16),
                  tooltip: 'View details',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetsTab extends ConsumerStatefulWidget {
  const _AssetsTab();

  @override
  ConsumerState<_AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends ConsumerState<_AssetsTab> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssets();
    });
  }

  void _loadAssets() {
    ref.read(assetsProvider.notifier).loadAssets(
      type: _selectedFilter == 'all' ? null : _selectedFilter,
    );
  }

  void _applyFilters() {
    _loadAssets();
  }

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Asset Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateAssetDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Asset'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters and Search
          Row(
            children: [
              // Asset Type Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                      _applyFilters();
                    },
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Types')),
                      DropdownMenuItem(value: 'real_estate', child: Text('Real Estate')),
                      DropdownMenuItem(value: 'vehicle', child: Text('Vehicle')),
                      DropdownMenuItem(value: 'commodity', child: Text('Commodity')),
                      DropdownMenuItem(value: 'art', child: Text('Art & Collectibles')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Search
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search assets...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Filter Button
              OutlinedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Assets Table
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
                              size: 48,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading assets',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              assetsState.error!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
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
                    : Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _AssetTableHeader(),
                              const Divider(),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: _filteredAssets(assetsState.assets).length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final asset = _filteredAssets(assetsState.assets)[index];
                                    return _AssetTableRow(
                                      id: asset['id'],
                                      title: asset['title'] ?? 'Untitled Asset',
                                      type: asset['type'] ?? 'Unknown',
                                      status: asset['status'] ?? 'pending',
                                      nav: (asset['nav'] ?? 0.0).toDouble(),
                                      created: _formatDate(asset['created_at']),
                                      onEdit: () => _showEditAssetDialog(context, asset),
                                      onView: () => _showAssetDetails(context, asset),
                                    );
                                  },
                                ),
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

  List<Map<String, dynamic>> _filteredAssets(List<Map<String, dynamic>> assets) {
    return assets.where((asset) {
      final matchesSearch = _searchQuery.isEmpty ||
          (asset['title'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (asset['type'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesSearch;
    }).toList();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inMinutes} minutes ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showCreateAssetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateAssetDialog(),
    );
  }

  void _showEditAssetDialog(BuildContext context, Map<String, dynamic> asset) {
    showDialog(
      context: context,
      builder: (context) => _EditAssetDialog(asset: asset),
    );
  }

  void _showAssetDetails(BuildContext context, Map<String, dynamic> asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset['title'] ?? 'Asset Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${asset['type']}'),
            Text('Status: ${asset['status']}'),
            Text('NAV: \$${(asset['nav'] ?? 0.0).toStringAsFixed(2)}'),
            Text('Created: ${_formatDate(asset['created_at'])}'),
            if (asset['description'] != null)
              Text('Description: ${asset['description']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (asset['status'] == 'pending')
            ElevatedButton(
              onPressed: () {
                ref.read(assetsProvider.notifier).verifyAsset(asset['id'], true, null);
                Navigator.of(context).pop();
              },
              child: const Text('Approve'),
            ),
        ],
      ),
    );
  }
}

class _CreateAssetDialog extends StatefulWidget {
  @override
  State<_CreateAssetDialog> createState() => _CreateAssetDialogState();
}

class _CreateAssetDialogState extends State<_CreateAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _navController = TextEditingController();
  String _selectedType = 'real_estate';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Asset'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Asset Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter asset title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Asset Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'real_estate', child: Text('Real Estate')),
                  DropdownMenuItem(value: 'vehicle', child: Text('Vehicle')),
                  DropdownMenuItem(value: 'commodity', child: Text('Commodity')),
                  DropdownMenuItem(value: 'art', child: Text('Art & Collectibles')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _navController,
                decoration: const InputDecoration(
                  labelText: 'Net Asset Value (NAV)',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter NAV';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createAsset,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createAsset() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset created successfully')),
      );
    }
  }
}

class _EditAssetDialog extends StatefulWidget {
  final Map<String, dynamic> asset;

  const _EditAssetDialog({required this.asset});

  @override
  State<_EditAssetDialog> createState() => _EditAssetDialogState();
}

class _EditAssetDialogState extends State<_EditAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _navController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.asset['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.asset['description'] ?? '');
    _navController = TextEditingController(text: (widget.asset['nav'] ?? 0.0).toString());
    _selectedType = widget.asset['type'] ?? 'real_estate';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Asset'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Asset Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter asset title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Asset Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'real_estate', child: Text('Real Estate')),
                  DropdownMenuItem(value: 'vehicle', child: Text('Vehicle')),
                  DropdownMenuItem(value: 'commodity', child: Text('Commodity')),
                  DropdownMenuItem(value: 'art', child: Text('Art & Collectibles')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _navController,
                decoration: const InputDecoration(
                  labelText: 'Net Asset Value (NAV)',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter NAV';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateAsset,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _updateAsset() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset updated successfully')),
      );
    }
  }
}

class _VerificationTab extends ConsumerStatefulWidget {
  const _VerificationTab();

  @override
  ConsumerState<_VerificationTab> createState() => _VerificationTabState();
}

class _VerificationTabState extends ConsumerState<_VerificationTab> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVerificationJobs();
    });
  }

  void _loadVerificationJobs() {
    // TODO: Load verification jobs from provider
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Verification Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateVerificationDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Verification Job'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Filter
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                      _loadVerificationJobs();
                    },
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'disputed', child: Text('Disputed')),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _exportVerificationReport(context),
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Verification Jobs List
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('Asset', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Agent', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Progress', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 120, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Mock verification jobs
                    Expanded(
                      child: ListView.builder(
                        itemCount: _getMockVerificationJobs().length,
                        itemBuilder: (context, index) {
                          final job = _getMockVerificationJobs()[index];
                          return _VerificationJobRow(job: job);
                        },
                      ),
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

  List<Map<String, dynamic>> _getMockVerificationJobs() {
    return [
      {
        'id': 'VJ001',
        'assetTitle': 'Downtown Office Building',
        'agentName': 'John Smith',
        'status': 'in_progress',
        'progress': 0.75,
        'dueDate': '2024-01-15',
        'createdAt': '2024-01-01',
      },
      {
        'id': 'VJ002',
        'assetTitle': 'Fleet Truck #001',
        'agentName': 'Sarah Johnson',
        'status': 'pending',
        'progress': 0.0,
        'dueDate': '2024-01-20',
        'createdAt': '2024-01-05',
      },
      {
        'id': 'VJ003',
        'assetTitle': 'Agricultural Land - Iowa',
        'agentName': 'Mike Wilson',
        'status': 'completed',
        'progress': 1.0,
        'dueDate': '2024-01-10',
        'createdAt': '2023-12-15',
      },
    ];
  }

  void _showCreateVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateVerificationDialog(),
    );
  }

  void _exportVerificationReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting verification report...')),
    );
  }
}

class _VerificationJobRow extends StatelessWidget {
  final Map<String, dynamic> job;

  const _VerificationJobRow({required this.job});

  @override
  Widget build(BuildContext context) {
    final status = job['status'] ?? 'pending';
    final progress = job['progress'] ?? 0.0;

    Color statusColor = Colors.grey;
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'disputed':
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              job['assetTitle'] ?? 'Unknown Asset',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(job['agentName'] ?? 'Unassigned'),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${(progress * 100).toInt()}%'),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(job['dueDate'] ?? 'TBD'),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _viewDetails(context),
                  icon: const Icon(Icons.visibility, size: 16),
                  tooltip: 'View Details',
                ),
                IconButton(
                  onPressed: () => _editJob(context),
                  icon: const Icon(Icons.edit, size: 16),
                  tooltip: 'Edit Job',
                ),
                if (status == 'disputed')
                  IconButton(
                    onPressed: () => _resolveDispute(context),
                    icon: const Icon(Icons.gavel, size: 16),
                    tooltip: 'Resolve Dispute',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewDetails(BuildContext context) {
    // TODO: Implement view details
  }

  void _editJob(BuildContext context) {
    // TODO: Implement edit job
  }

  void _resolveDispute(BuildContext context) {
    // TODO: Implement resolve dispute
  }
}

class _CreateVerificationDialog extends StatefulWidget {
  @override
  State<_CreateVerificationDialog> createState() => _CreateVerificationDialogState();
}

class _CreateVerificationDialogState extends State<_CreateVerificationDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedAsset = '';
  String _selectedAgent = '';
  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Verification Job'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAsset.isEmpty ? null : _selectedAsset,
                decoration: const InputDecoration(
                  labelText: 'Asset',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'asset1', child: Text('Downtown Office Building')),
                  DropdownMenuItem(value: 'asset2', child: Text('Fleet Truck #001')),
                  DropdownMenuItem(value: 'asset3', child: Text('Agricultural Land - Iowa')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAsset = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an asset';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAgent.isEmpty ? null : _selectedAgent,
                decoration: const InputDecoration(
                  labelText: 'Agent',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'agent1', child: Text('John Smith')),
                  DropdownMenuItem(value: 'agent2', child: Text('Sarah Johnson')),
                  DropdownMenuItem(value: 'agent3', child: Text('Mike Wilson')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAgent = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an agent';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _dueDate = date;
                    });
                  }
                },
                validator: (value) {
                  if (_dueDate == null) {
                    return 'Please select a due date';
                  }
                  return null;
                },
                controller: TextEditingController(
                  text: _dueDate != null
                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                      : '',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createVerificationJob,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createVerificationJob() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification job created successfully')),
      );
    }
  }
}

class _AgentsTab extends ConsumerStatefulWidget {
  const _AgentsTab();

  @override
  ConsumerState<_AgentsTab> createState() => _AgentsTabState();
}

class _AgentsTabState extends ConsumerState<_AgentsTab> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgents();
    });
  }

  void _loadAgents() {
    ref.read(agentsProvider.notifier).loadAgents(
      status: _selectedFilter == 'all' ? null : _selectedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final agentsState = ref.watch(agentsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Agents Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddAgentDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Agent'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters and Search
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search agents...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    // TODO: Implement search functionality
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Agents')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  _loadAgents();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Agents List
          Expanded(
            child: agentsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : agentsState.error != null
                    ? Center(child: Text('Error: ${agentsState.error}'))
                    : agentsState.agents.isEmpty
                        ? const Center(child: Text('No agents found'))
                        : ListView.builder(
                            itemCount: agentsState.agents.length,
                            itemBuilder: (context, index) {
                              final agent = agentsState.agents[index];
                              return _AgentCard(
                                agent: agent,
                                onApprove: () => _approveAgent(agent['id']),
                                onReject: () => _rejectAgent(agent['id']),
                                onView: () => _viewAgentDetails(agent),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showAddAgentDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddAgentDialog(),
    );
  }

  void _approveAgent(String agentId) {
    // TODO: Implement agent approval
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agent approved successfully')),
    );
  }

  void _rejectAgent(String agentId) {
    // TODO: Implement agent rejection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agent rejected')),
    );
  }

  void _viewAgentDetails(dynamic agent) {
    showDialog(
      context: context,
      builder: (context) => _AgentDetailsDialog(agent: agent),
    );
  }
}

class _VerificationTab extends ConsumerStatefulWidget {
  const _VerificationTab();

  @override
  ConsumerState<_VerificationTab> createState() => _VerificationTabState();
}

class _VerificationTabState extends ConsumerState<_VerificationTab> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Verification Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showCreateJobDialog,
                icon: const Icon(Icons.add_task),
                label: const Text('Create Verification Job'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Pending Verifications',
                  value: '12',
                  subtitle: 'Awaiting review',
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'In Progress',
                  value: '8',
                  subtitle: 'Active jobs',
                  color: Colors.blue,
                  icon: Icons.work,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Completed This Month',
                  value: '45',
                  subtitle: 'Successfully verified',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Average Rating',
                  value: '4.7',
                  subtitle: 'Agent performance',
                  color: Colors.purple,
                  icon: Icons.star,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters and Search
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search verification jobs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Jobs')),
                  DropdownMenuItem(value: 'open', child: Text('Open')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Verification Jobs List
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Mock data count
              itemBuilder: (context, index) {
                return _VerificationJobCard(
                  jobId: 'VJ-${(index + 1).toString().padLeft(3, '0')}',
                  assetTitle: 'Downtown Office Building - Austin, TX',
                  investorName: 'investor@example.com',
                  agentName: 'agent@example.com',
                  status: _getRandomStatus(index),
                  createdAt: DateTime.now().subtract(Duration(days: index)),
                  onView: () => _viewJobDetails('VJ-${(index + 1).toString().padLeft(3, '0')}'),
                  onAssign: () => _assignAgent('VJ-${(index + 1).toString().padLeft(3, '0')}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getRandomStatus(int index) {
    final statuses = ['open', 'in_progress', 'completed', 'cancelled'];
    return statuses[index % statuses.length];
  }

  void _showCreateJobDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Verification Job'),
        content: const Text('This feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewJobDetails(String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Job Details: $jobId'),
        content: const Text('Detailed job information will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _assignAgent(String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Agent to $jobId'),
        content: const Text('Agent assignment interface will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agent assigned successfully')),
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}


class _VerificationJobCard extends StatelessWidget {
  final String jobId;
  final String assetTitle;
  final String investorName;
  final String agentName;
  final String status;
  final DateTime createdAt;
  final VoidCallback onView;
  final VoidCallback onAssign;

  const _VerificationJobCard({
    required this.jobId,
    required this.assetTitle,
    required this.investorName,
    required this.agentName,
    required this.status,
    required this.createdAt,
    required this.onView,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  jobId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assetTitle,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Investor: $investorName',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.support_agent, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Agent: $agentName',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Created: ${_formatDate(createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                if (status == 'open')
                  ElevatedButton.icon(
                    onPressed: onAssign,
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Assign Agent'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PayoutsTab extends ConsumerStatefulWidget {
  const _PayoutsTab();

  @override
  ConsumerState<_PayoutsTab> createState() => _PayoutsTabState();
}

class _PayoutsTabState extends ConsumerState<_PayoutsTab> {
  String _selectedFilter = 'all';
  String _selectedPeriod = 'monthly';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(payoutsProvider.notifier).loadDistributions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final payoutsState = ref.watch(payoutsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Payouts Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showCreateDistributionDialog,
                icon: const Icon(Icons.payment),
                label: const Text('Create Distribution'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Distributions',
                  value: '\$2.4M',
                  subtitle: 'This quarter',
                  color: Colors.green,
                  icon: Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Pending Payouts',
                  value: '\$180K',
                  subtitle: 'Awaiting approval',
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Avg Distribution',
                  value: '\$45K',
                  subtitle: 'Per investor',
                  color: Colors.blue,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Platform Fee',
                  value: '\$24K',
                  subtitle: '2% of distributions',
                  color: Colors.purple,
                  icon: Icons.percent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              DropdownButton<String>(
                value: _selectedPeriod,
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Distributions')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'failed', child: Text('Failed')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _exportDistributions,
                icon: const Icon(Icons.download),
                label: const Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Distributions List
          Expanded(
            child: payoutsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : payoutsState.error != null
                    ? Center(child: Text('Error: ${payoutsState.error}'))
                    : payoutsState.distributions.isEmpty
                        ? const Center(child: Text('No distributions found'))
                        : ListView.builder(
                            itemCount: payoutsState.distributions.length,
                            itemBuilder: (context, index) {
                              final distribution = payoutsState.distributions[index];
                              return _DistributionCard(
                                distribution: distribution,
                                onView: () => _viewDistributionDetails(distribution),
                                onApprove: () => _approveDistribution(distribution['id']),
                                onReject: () => _rejectDistribution(distribution['id']),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showCreateDistributionDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateDistributionDialog(),
    );
  }

  void _viewDistributionDetails(Map<String, dynamic> distribution) {
    showDialog(
      context: context,
      builder: (context) => _DistributionDetailsDialog(distribution: distribution),
    );
  }

  void _approveDistribution(String distributionId) {
    // TODO: Implement approval
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Distribution approved')),
    );
  }

  void _rejectDistribution(String distributionId) {
    // TODO: Implement rejection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Distribution rejected')),
    );
  }

  void _exportDistributions() {
    // TODO: Implement CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting distributions to CSV...')),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final dynamic agent;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onView;

  const _AgentCard({
    required this.agent,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getStatusColor(),
              child: Text(
                (agent['id'] ?? 'A').toString().substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agent #${agent['id'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatusChip(status: agent['status'] ?? 'unknown'),
                      const SizedBox(width: 8),
                      if ((agent['ratingAvg'] ?? 0) > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(' ${(agent['ratingAvg'] ?? 0).toStringAsFixed(1)}'),
                          ],
                        ),
                    ],
                  ),
                  if (agent['regions'] != null && (agent['regions'] as List).isNotEmpty)
                    Text(
                      'Regions: ${(agent['regions'] as List).join(', ')}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility),
                  tooltip: 'View Details',
                ),
                if (agent['status'] == 'pending') ...[
                  IconButton(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: 'Approve',
                  ),
                  IconButton(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Reject',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (agent.status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
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
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AddAgentDialog extends StatefulWidget {
  const _AddAgentDialog();

  @override
  State<_AddAgentDialog> createState() => _AddAgentDialogState();
}

class _AddAgentDialogState extends State<_AddAgentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  String _selectedStatus = 'pending';
  final List<String> _selectedRegions = [];
  final List<String> _selectedSkills = [];

  final List<String> _availableRegions = [
    'US', 'CA', 'EU', 'UK', 'AU', 'SG', 'JP'
  ];

  final List<String> _availableSkills = [
    'real_estate', 'vehicle', 'land', 'equipment', 'infrastructure'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Agent'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Regions:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Wrap(
                spacing: 8,
                children: _availableRegions.map((region) {
                  return FilterChip(
                    label: Text(region),
                    selected: _selectedRegions.contains(region),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRegions.add(region);
                        } else {
                          _selectedRegions.remove(region);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Skills:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Wrap(
                spacing: 8,
                children: _availableSkills.map((skill) {
                  return FilterChip(
                    label: Text(skill),
                    selected: _selectedSkills.contains(skill),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addAgent,
          child: const Text('Add Agent'),
        ),
      ],
    );
  }

  void _addAgent() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement add agent functionality
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agent added successfully')),
      );
    }
  }
}

class _AgentDetailsDialog extends StatelessWidget {
  final dynamic agent;

  const _AgentDetailsDialog({required this.agent});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agent Details: #${agent['id'] ?? 'Unknown'}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Status', value: agent['status'] ?? 'unknown'),
            _DetailRow(label: 'Regions', value: (agent['regions'] as List?)?.join(', ') ?? 'None'),
            _DetailRow(label: 'Skills', value: (agent['skills'] as List?)?.join(', ') ?? 'None'),
            _DetailRow(label: 'Rating', value: (agent['ratingAvg'] ?? 0) > 0 ? '${agent['ratingAvg']}/5.0' : 'No ratings'),
            _DetailRow(label: 'Reviews', value: '${agent['ratingCount'] ?? 0} reviews'),
            if (agent['bio'] != null) ...[
              const SizedBox(height: 16),
              Text(
                'Bio:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(agent['bio']),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  final Map<String, dynamic> distribution;
  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _DistributionCard({
    required this.distribution,
    required this.onView,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getStatusColor(),
              child: Icon(
                Icons.payment,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribution #${distribution['id'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatusChip(status: distribution['status'] ?? 'unknown'),
                      const SizedBox(width: 8),
                      Text(
                        'Amount: \$${_formatAmount(distribution['amount'] ?? 0)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Asset: ${distribution['asset_title'] ?? 'Unknown Asset'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Period: ${distribution['period'] ?? 'Unknown'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility),
                  tooltip: 'View Details',
                ),
                if (distribution['status'] == 'pending') ...[
                  IconButton(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: 'Approve',
                  ),
                  IconButton(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Reject',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch ((distribution['status'] ?? '').toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount is num) {
      return amount.toStringAsFixed(0);
    }
    return '0';
  }
}

class _CreateDistributionDialog extends StatefulWidget {
  const _CreateDistributionDialog();

  @override
  State<_CreateDistributionDialog> createState() => _CreateDistributionDialogState();
}

class _CreateDistributionDialogState extends State<_CreateDistributionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedAsset = '';
  String _selectedPeriod = 'monthly';

  final List<Map<String, dynamic>> _mockAssets = [
    {'id': '1', 'title': 'Downtown Office Building'},
    {'id': '2', 'title': 'Fleet Truck #001'},
    {'id': '3', 'title': 'Agricultural Land - Iowa'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Distribution'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAsset.isEmpty ? null : _selectedAsset,
                decoration: const InputDecoration(
                  labelText: 'Asset',
                  border: OutlineInputBorder(),
                ),
                items: _mockAssets.map((asset) {
                  return DropdownMenuItem<String>(
                    value: asset['id'],
                    child: Text(asset['title']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAsset = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an asset';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                decoration: const InputDecoration(
                  labelText: 'Period',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Distribution Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter distribution amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createDistribution,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createDistribution() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Distribution created successfully')),
      );
    }
  }
}

class _DistributionDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> distribution;

  const _DistributionDetailsDialog({required this.distribution});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Distribution #${distribution['id'] ?? 'Unknown'}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Status', value: distribution['status'] ?? 'unknown'),
            _DetailRow(label: 'Amount', value: '\$${distribution['amount'] ?? '0'}'),
            _DetailRow(label: 'Asset', value: distribution['asset_title'] ?? 'Unknown'),
            _DetailRow(label: 'Period', value: distribution['period'] ?? 'Unknown'),
            _DetailRow(label: 'Investors', value: '${distribution['investor_count'] ?? 0} investors'),
            _DetailRow(label: 'Created', value: distribution['created_at'] ?? 'Unknown'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _PayoutsTab extends ConsumerStatefulWidget {
  const _PayoutsTab();

  @override
  ConsumerState<_PayoutsTab> createState() => _PayoutsTabState();
}

class _PayoutsTabState extends ConsumerState<_PayoutsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '30d';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeDates() {
    final now = DateTime.now();
    _endDate = now;
    switch (_selectedPeriod) {
      case '7d':
        _startDate = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        _startDate = now.subtract(const Duration(days: 30));
        break;
      case '90d':
        _startDate = now.subtract(const Duration(days: 90));
        break;
      case '1y':
        _startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        _startDate = now.subtract(const Duration(days: 30));
    }
  }

  void _loadData() {
    final startDateString = _startDate?.toIso8601String().split('T')[0];
    final endDateString = _endDate?.toIso8601String().split('T')[0];

    ref.read(analyticsProvider.notifier).loadBankingRevenueAnalytics(
      startDateString,
      endDateString,
    );
    ref.read(payoutsProvider.notifier).loadDistributions();
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _initializeDates();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Revenue Sharing & Commission Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _PeriodSelector(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: _onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Revenue Overview'),
                Tab(text: 'Commission Tracking'),
                Tab(text: 'Payout History'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _RevenueOverviewTab(),
                _CommissionTrackingTab(),
                _PayoutHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueOverviewTab extends ConsumerWidget {
  const _RevenueOverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);
    final revenueData = analyticsState.bankingRevenue;

    if (analyticsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (analyticsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading revenue data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              analyticsState.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final totalRevenue = revenueData?['totalRevenue'] ?? 0.0;
    final platformFees = revenueData?['platformFees'] ?? 0.0;
    final commissionFees = revenueData?['commissionFees'] ?? 0.0;
    final revenueGrowth = revenueData?['revenueGrowth'] ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Summary Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Revenue',
                  value: '\$${_formatCurrency(totalRevenue)}',
                  subtitle: '${revenueGrowth > 0 ? '+' : ''}${revenueGrowth.toStringAsFixed(1)}% vs last period',
                  icon: Icons.monetization_on,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Platform Fees',
                  value: '\$${_formatCurrency(platformFees)}',
                  subtitle: '${((platformFees / totalRevenue) * 100).toStringAsFixed(1)}% of total',
                  icon: Icons.account_balance,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Commission Fees',
                  value: '\$${_formatCurrency(commissionFees)}',
                  subtitle: '${((commissionFees / totalRevenue) * 100).toStringAsFixed(1)}% of total',
                  icon: Icons.handshake,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Avg. Commission Rate',
                  value: '${(revenueData?['avgCommissionRate'] ?? 0.0).toStringAsFixed(2)}%',
                  subtitle: 'Across all partnerships',
                  icon: Icons.percent,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Revenue Breakdown Chart
          if (revenueData?['breakdown'] != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Breakdown by Source',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _RevenueBreakdownChart(
                        data: List<Map<String, dynamic>>.from(revenueData!['breakdown']),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _CommissionTrackingTab extends ConsumerWidget {
  const _CommissionTrackingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banksState = ref.watch(banksProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Commission Overview
          Row(
            children: [
              Text(
                'Bank Commission Tracking',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCommissionSettingsDialog(context, ref),
                icon: const Icon(Icons.settings),
                label: const Text('Commission Settings'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Banks Commission Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: Text('Bank Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Commission Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Total Earned', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('This Month', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(width: 100, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bank Commission Rows
                  ...banksState.banks.map((bank) => _BankCommissionRow(bank: bank)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommissionSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CommissionSettingsDialog(),
    );
  }
}

class _PayoutHistoryTab extends ConsumerWidget {
  const _PayoutHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsState = ref.watch(payoutsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Actions
        Row(
          children: [
            Text(
              'Payout History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => _exportPayoutHistory(context),
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showCreatePayoutDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create Payout'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Payout List
        Expanded(
          child: payoutsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : payoutsState.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading payouts',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            payoutsState.error!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: payoutsState.distributions.length,
                      itemBuilder: (context, index) {
                        final distribution = payoutsState.distributions[index];
                        return _DistributionCard(
                          distribution: distribution,
                          onView: () => _showDistributionDetails(context, distribution),
                          onApprove: () => _approveDistribution(ref, distribution['id']),
                          onReject: () => _rejectDistribution(ref, distribution['id']),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _exportPayoutHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting payout history...')),
    );
  }

  void _showCreatePayoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _CreateDistributionDialog(),
    );
  }

  void _showDistributionDetails(BuildContext context, Map<String, dynamic> distribution) {
    showDialog(
      context: context,
      builder: (context) => _DistributionDetailsDialog(distribution: distribution),
    );
  }

  void _approveDistribution(WidgetRef ref, String distributionId) {
    // TODO: Implement approve distribution
  }

  void _rejectDistribution(WidgetRef ref, String distributionId) {
    // TODO: Implement reject distribution
  }
}

class _BankCommissionRow extends StatelessWidget {
  final Map<String, dynamic> bank;

  const _BankCommissionRow({required this.bank});

  @override
  Widget build(BuildContext context) {
    final commissionRate = bank['commissionRate'] ?? 2.5;
    final totalEarned = bank['totalCommissionEarned'] ?? 15420.0;
    final monthlyEarned = bank['monthlyCommissionEarned'] ?? 2380.0;
    final status = bank['status'] ?? 'active';

    Color statusColor = Colors.grey;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'suspended':
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              bank['name'] ?? 'Unknown Bank',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text('${commissionRate.toStringAsFixed(2)}%'),
          ),
          Expanded(
            child: Text('\$${_formatCurrency(totalEarned)}'),
          ),
          Expanded(
            child: Text('\$${_formatCurrency(monthlyEarned)}'),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _editCommission(context),
                  icon: const Icon(Icons.edit, size: 16),
                  tooltip: 'Edit Commission',
                ),
                IconButton(
                  onPressed: () => _viewDetails(context),
                  icon: const Icon(Icons.visibility, size: 16),
                  tooltip: 'View Details',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editCommission(BuildContext context) {
    // TODO: Implement edit commission
  }

  void _viewDetails(BuildContext context) {
    // TODO: Implement view details
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _RevenueBreakdownChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _RevenueBreakdownChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Simple bar chart representation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.map((item) {
                final percentage = (item['value'] / data.fold(0.0, (sum, item) => sum + item['value'])) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['source'] ?? 'Unknown'),
                          Text('\$${_formatCurrency(item['value'])} (${percentage.toStringAsFixed(1)}%)'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(_getColorForIndex(data.indexOf(item))),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    return colors[index % colors.length];
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _CommissionSettingsDialog extends StatefulWidget {
  @override
  State<_CommissionSettingsDialog> createState() => _CommissionSettingsDialogState();
}

class _CommissionSettingsDialogState extends State<_CommissionSettingsDialog> {
  final _defaultRateController = TextEditingController(text: '2.5');
  final _minimumRateController = TextEditingController(text: '1.0');
  final _maximumRateController = TextEditingController(text: '5.0');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Commission Settings'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _defaultRateController,
              decoration: const InputDecoration(
                labelText: 'Default Commission Rate (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minimumRateController,
              decoration: const InputDecoration(
                labelText: 'Minimum Commission Rate (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maximumRateController,
              decoration: const InputDecoration(
                labelText: 'Maximum Commission Rate (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Commission settings updated')),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends ConsumerStatefulWidget {
  const _AnalyticsTab();

  @override
  ConsumerState<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<_AnalyticsTab> {
  String _selectedPeriod = '30d';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  void _initializeDates() {
    final now = DateTime.now();
    _endDate = now;
    switch (_selectedPeriod) {
      case '7d':
        _startDate = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        _startDate = now.subtract(const Duration(days: 30));
        break;
      case '90d':
        _startDate = now.subtract(const Duration(days: 90));
        break;
      case '1y':
        _startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        _startDate = now.subtract(const Duration(days: 30));
    }
  }

  void _loadAnalytics() {
    final startDateString = _startDate?.toIso8601String().split('T')[0];
    final endDateString = _endDate?.toIso8601String().split('T')[0];

    ref.read(analyticsProvider.notifier).loadAllBankingAnalytics(
      startDateString,
      endDateString,
    );
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _initializeDates();
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Banking Partnership Analytics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _PeriodSelector(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: _onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (analyticsState.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (analyticsState.error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading analytics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      analyticsState.error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAnalytics,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Overview Cards
                    if (analyticsState.bankingOverview != null)
                      _BankingOverviewSection(
                        overview: analyticsState.bankingOverview!,
                      ),
                    const SizedBox(height: 24),

                    // Performance and Pipeline Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bank Performance
                        if (analyticsState.bankPerformance != null)
                          Expanded(
                            child: _BankPerformanceSection(
                              performance: analyticsState.bankPerformance!,
                            ),
                          ),
                        const SizedBox(width: 16),

                        // Proposal Pipeline
                        if (analyticsState.proposalPipeline != null)
                          Expanded(
                            child: _ProposalPipelineSection(
                              pipeline: analyticsState.proposalPipeline!,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Revenue Analytics
                    if (analyticsState.bankingRevenue != null)
                      _RevenueAnalyticsSection(
                        revenueData: analyticsState.bankingRevenue!,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodButton('7d', '7 Days'),
          _PeriodButton('30d', '30 Days'),
          _PeriodButton('90d', '90 Days'),
          _PeriodButton('1y', '1 Year'),
        ],
      ),
    );
  }

  Widget _PeriodButton(String value, String label) {
    final isSelected = selectedPeriod == value;

    return InkWell(
      onTap: () => onPeriodChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _BankingOverviewSection extends StatelessWidget {
  final BankingOverview overview;

  const _BankingOverviewSection({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partnership Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Banks',
                value: overview.banks.total.toString(),
                subtitle: _buildBankStatusBreakdown(overview.banks.byStatus),
                icon: Icons.account_balance,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Total Proposals',
                value: overview.proposals.total.toString(),
                subtitle: _buildProposalStatusBreakdown(overview.proposals.byStatus),
                icon: Icons.description,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Settlement Payouts',
                value: '\$${_formatCurrency(overview.settlements.totalPayout)}',
                subtitle: 'Commission: \$${_formatCurrency(overview.settlements.totalCommission)}',
                icon: Icons.payments,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Top Performer',
                value: overview.topBanks.isNotEmpty ? overview.topBanks.first.name : 'N/A',
                subtitle: overview.topBanks.isNotEmpty
                    ? '\$${_formatCurrency(overview.topBanks.first.revenue)} revenue'
                    : 'No data',
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _buildBankStatusBreakdown(List<StatusCount> statuses) {
    final active = statuses.where((s) => s.status == 'active').firstOrNull?.count ?? 0;
    final pending = statuses.where((s) => s.status == 'pending').firstOrNull?.count ?? 0;
    return '$active active, $pending pending';
  }

  String _buildProposalStatusBreakdown(List<StatusCount> statuses) {
    final approved = statuses.where((s) => s.status == 'approved').firstOrNull?.count ?? 0;
    final pending = statuses.where((s) => s.status == 'pending').firstOrNull?.count ?? 0;
    return '$approved approved, $pending pending';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _BankPerformanceSection extends StatelessWidget {
  final BankPerformanceComparison performance;

  const _BankPerformanceSection({required this.performance});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...performance.banks.take(5).map((bank) => _BankPerformanceRow(bank)),
          ],
        ),
      ),
    );
  }
}

class _BankPerformanceRow extends StatelessWidget {
  final BankPerformance bank;

  const _BankPerformanceRow(this.bank);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              bank.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text('\$${_formatCurrency(bank.revenue)}'),
          ),
          Expanded(
            child: Text('${bank.proposals} proposals'),
          ),
          Expanded(
            child: Text('${bank.commissionRate.toStringAsFixed(1)}%'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _ProposalPipelineSection extends StatelessWidget {
  final ProposalPipelineAnalytics pipeline;

  const _ProposalPipelineSection({required this.pipeline});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proposal Pipeline',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'By Asset Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...pipeline.byType.map((type) => _ProposalTypeRow(type)),
            const SizedBox(height: 16),
            Text(
              'Avg Approval Time: ${pipeline.timeline.avgApprovalTime.toStringAsFixed(1)} days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposalTypeRow extends StatelessWidget {
  final ProposalsByType type;

  const _ProposalTypeRow(this.type);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              type.type.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text('${type.count} proposals'),
          const SizedBox(width: 16),
          Text('\$${_formatCurrency(type.totalValue)}'),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _RevenueAnalyticsSection extends StatelessWidget {
  final Map<String, dynamic> revenueData;

  const _RevenueAnalyticsSection({required this.revenueData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _RevenueMetricCard(
                    title: 'Total Revenue',
                    value: '\$${_formatCurrency((revenueData['totalRevenue'] ?? 0).toDouble())}',
                    change: '${(revenueData['revenueGrowth'] ?? 0).toStringAsFixed(1)}%',
                    isPositive: (revenueData['revenueGrowth'] ?? 0) >= 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RevenueMetricCard(
                    title: 'Commission Rate',
                    value: '${(revenueData['avgCommissionRate'] ?? 0).toStringAsFixed(1)}%',
                    change: '${(revenueData['commissionRateChange'] ?? 0).toStringAsFixed(1)}%',
                    isPositive: (revenueData['commissionRateChange'] ?? 0) >= 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RevenueMetricCard(
                    title: 'Monthly ARR',
                    value: '\$${_formatCurrency((revenueData['monthlyARR'] ?? 0).toDouble())}',
                    change: '${(revenueData['arrGrowth'] ?? 0).toStringAsFixed(1)}%',
                    isPositive: (revenueData['arrGrowth'] ?? 0) >= 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _RevenueMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;

  const _RevenueMetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BanksTab extends ConsumerStatefulWidget {
  const _BanksTab();

  @override
  ConsumerState<_BanksTab> createState() => _BanksTabState();
}

class _BanksTabState extends ConsumerState<_BanksTab> {
  final _searchController = TextEditingController();
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(banksProvider.notifier).loadBanks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banksState = ref.watch(banksProvider);
    final banksNotifier = ref.read(banksProvider.notifier);

    List<Map<String, dynamic>> filteredBanks = banksState.banks;

    if (_statusFilter != 'all') {
      filteredBanks = filteredBanks.where((bank) => bank['status'] == _statusFilter).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredBanks = filteredBanks.where((bank) {
        final name = (bank['name'] ?? '').toLowerCase();
        final email = (bank['email'] ?? '').toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bank Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBankDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Bank'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search and Filter Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search banks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _statusFilter,
                  decoration: InputDecoration(
                    labelText: 'Status Filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Banks')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                  ],
                  onChanged: (value) => setState(() => _statusFilter = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Banks',
                  value: '${banksState.banks.length}',
                  subtitle: 'Registered',
                  color: Colors.blue,
                  icon: Icons.account_balance,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Active Banks',
                  value: '${banksNotifier.activeBanks.length}',
                  subtitle: 'Operating',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Pending Banks',
                  value: '${banksNotifier.pendingBanks.length}',
                  subtitle: 'Awaiting approval',
                  color: Colors.orange,
                  icon: Icons.pending,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Suspended Banks',
                  value: '${banksNotifier.suspendedBanks.length}',
                  subtitle: 'Temporarily disabled',
                  color: Colors.red,
                  icon: Icons.block,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Banks Table
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const _BanksTableHeader(),
                  const Divider(height: 1),
                  if (banksState.isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (banksState.error != null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${banksState.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => banksNotifier.loadBanks(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filteredBanks.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No banks found'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredBanks.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final bank = filteredBanks[index];
                          return _BankTableRow(
                            bank: bank,
                            onEdit: () => _showEditBankDialog(context, bank),
                            onView: () => _showBankDetailsDialog(context, bank),
                            onDelete: () => _showDeleteConfirmation(context, bank),
                            onStatusChange: (status) => banksNotifier.updateBankStatus(
                              bank['id'],
                              status,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBankDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddBankDialog(),
    );
  }

  void _showEditBankDialog(BuildContext context, Map<String, dynamic> bank) {
    showDialog(
      context: context,
      builder: (context) => _EditBankDialog(bank: bank),
    );
  }

  void _showBankDetailsDialog(BuildContext context, Map<String, dynamic> bank) {
    showDialog(
      context: context,
      builder: (context) => _BankDetailsDialog(bank: bank),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> bank) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bank'),
        content: Text('Are you sure you want to delete ${bank['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(banksProvider.notifier).deleteBank(bank['id']);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BanksTableHeader extends StatelessWidget {
  const _BanksTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Bank Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Commission', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Created', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 120, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _BankTableRow extends StatelessWidget {
  final Map<String, dynamic> bank;
  final VoidCallback onEdit;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final Function(String) onStatusChange;

  const _BankTableRow({
    required this.bank,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final status = bank['status'] ?? 'pending';
    final commission = bank['commissionRate'] ?? 0.0;
    final createdAt = DateTime.tryParse(bank['createdAt'] ?? '') ?? DateTime.now();

    Color statusColor = Colors.grey;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'suspended':
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank['name'] ?? 'Unknown Bank',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  bank['address'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(bank['email'] ?? ''),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text('${(commission * 100).toStringAsFixed(1)}%'),
          ),
          Expanded(
            child: Text(
              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility, size: 18),
                  tooltip: 'View Details',
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'Edit Bank',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    } else {
                      onStatusChange(value);
                    }
                  },
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'active',
                      child: Text('Set Active'),
                    ),
                    const PopupMenuItem(
                      value: 'suspended',
                      child: Text('Suspend'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBankDialog extends ConsumerStatefulWidget {
  const _AddBankDialog();

  @override
  ConsumerState<_AddBankDialog> createState() => _AddBankDialogState();
}

class _AddBankDialogState extends ConsumerState<_AddBankDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form keys for each step
  final _basicInfoKey = GlobalKey<FormState>();
  final _documentsKey = GlobalKey<FormState>();
  final _complianceKey = GlobalKey<FormState>();
  final _settingsKey = GlobalKey<FormState>();

  // Basic Information Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  // Document Controllers
  final _licenseNumberController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _swiftCodeController = TextEditingController();

  // Compliance Controllers
  final _kycPolicyController = TextEditingController();
  final _amlPolicyController = TextEditingController();
  final _riskAssessmentController = TextEditingController();

  // Settings Controllers
  final _commissionController = TextEditingController(text: '2.5');
  final _minimumAssetValueController = TextEditingController(text: '100000');
  final _maximumAssetValueController = TextEditingController(text: '10000000');

  // Document upload states
  bool _bankingLicenseUploaded = false;
  bool _incorporationCertUploaded = false;
  bool _auditReportUploaded = false;
  bool _complianceCertUploaded = false;

  // Compliance checkboxes
  bool _kycCompliant = false;
  bool _amlCompliant = false;
  bool _gdprCompliant = false;
  bool _riskAssessmentComplete = false;

  final List<String> _steps = [
    'Basic Information',
    'Documents',
    'Compliance',
    'Settings',
    'Review & Submit'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _registrationNumberController.dispose();
    _licenseNumberController.dispose();
    _taxIdController.dispose();
    _swiftCodeController.dispose();
    _kycPolicyController.dispose();
    _amlPolicyController.dispose();
    _riskAssessmentController.dispose();
    _commissionController.dispose();
    _minimumAssetValueController.dispose();
    _maximumAssetValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bank Onboarding Workflow',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Stepper
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final isActive = index == _currentStep;
                  final isCompleted = index < _currentStep;

                  return Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green
                                  : isActive
                                      ? Colors.blue
                                      : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : Icons.circle,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 120,
                            child: Text(
                              _steps[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive ? Colors.blue : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (index < _steps.length - 1)
                        Container(
                          width: 50,
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 32),
                          color: index < _currentStep ? Colors.green : Colors.grey[300],
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoStep(),
                  _buildDocumentsStep(),
                  _buildComplianceStep(),
                  _buildSettingsStep(),
                  _buildReviewStep(),
                ],
              ),
            ),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _previousStep,
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox(),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _currentStep == _steps.length - 1 ? _submitOnboarding : _nextStep,
                      child: Text(_currentStep == _steps.length - 1 ? 'Complete Onboarding' : 'Next'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _basicInfoKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Bank Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter bank name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _registrationNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Registration Number *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter registration number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Official Email *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Business Address *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter business address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Documents',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDocumentUpload(
            'Banking License',
            'Valid banking license issued by regulatory authority',
            _bankingLicenseUploaded,
            (uploaded) => setState(() => _bankingLicenseUploaded = uploaded),
          ),
          const SizedBox(height: 16),
          _buildDocumentUpload(
            'Certificate of Incorporation',
            'Official incorporation certificate',
            _incorporationCertUploaded,
            (uploaded) => setState(() => _incorporationCertUploaded = uploaded),
          ),
          const SizedBox(height: 16),
          _buildDocumentUpload(
            'Latest Audit Report',
            'Most recent annual audit report',
            _auditReportUploaded,
            (uploaded) => setState(() => _auditReportUploaded = uploaded),
          ),
          const SizedBox(height: 16),
          _buildDocumentUpload(
            'Compliance Certificates',
            'KYC/AML and other regulatory compliance certificates',
            _complianceCertUploaded,
            (uploaded) => setState(() => _complianceCertUploaded = uploaded),
          ),
          const SizedBox(height: 24),
          Form(
            key: _documentsKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _licenseNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Banking License Number *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter license number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _taxIdController,
                        decoration: const InputDecoration(
                          labelText: 'Tax ID Number *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter tax ID';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _swiftCodeController,
                  decoration: const InputDecoration(
                    labelText: 'SWIFT Code (if applicable)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload(String title, String description, bool uploaded, Function(bool) onUpload) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              uploaded ? Icons.check_circle : Icons.upload_file,
              color: uploaded ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => onUpload(!uploaded),
              style: ElevatedButton.styleFrom(
                backgroundColor: uploaded ? Colors.green : null,
              ),
              child: Text(uploaded ? 'Uploaded' : 'Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceStep() {
    return Form(
      key: _complianceKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compliance Requirements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('KYC (Know Your Customer) Compliance'),
                      subtitle: const Text('Bank has implemented KYC procedures'),
                      value: _kycCompliant,
                      onChanged: (value) => setState(() => _kycCompliant = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('AML (Anti-Money Laundering) Compliance'),
                      subtitle: const Text('Bank follows AML regulations'),
                      value: _amlCompliant,
                      onChanged: (value) => setState(() => _amlCompliant = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('GDPR Compliance'),
                      subtitle: const Text('Data protection compliance confirmed'),
                      value: _gdprCompliant,
                      onChanged: (value) => setState(() => _gdprCompliant = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Risk Assessment Completed'),
                      subtitle: const Text('Comprehensive risk assessment conducted'),
                      value: _riskAssessmentComplete,
                      onChanged: (value) => setState(() => _riskAssessmentComplete = value ?? false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kycPolicyController,
              decoration: const InputDecoration(
                labelText: 'KYC Policy Document Reference',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amlPolicyController,
              decoration: const InputDecoration(
                labelText: 'AML Policy Document Reference',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _riskAssessmentController,
              decoration: const InputDecoration(
                labelText: 'Risk Assessment Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsStep() {
    return Form(
      key: _settingsKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _commissionController,
                    decoration: const InputDecoration(
                      labelText: 'Commission Rate (%)',
                      border: OutlineInputBorder(),
                      helperText: 'Platform commission on asset transactions',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter commission rate';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate < 0 || rate > 100) {
                        return 'Please enter valid rate (0-100)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minimumAssetValueController,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Asset Value (\$)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter minimum value';
                      }
                      final val = double.tryParse(value);
                      if (val == null || val < 0) {
                        return 'Please enter valid amount';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maximumAssetValueController,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Asset Value (\$)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter maximum value';
                      }
                      final val = double.tryParse(value);
                      if (val == null || val < 0) {
                        return 'Please enter valid amount';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Initial Access Permissions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text('✓ Asset Proposal Submission'),
                    const Text('✓ Transaction History Access'),
                    const Text('✓ Performance Analytics'),
                    const Text('✓ Commission Tracking'),
                    const SizedBox(height: 12),
                    const Text(
                      'Note: Additional permissions can be granted after successful onboarding.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Basic Information', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _DetailRow('Bank Name', _nameController.text),
                  _DetailRow('Registration Number', _registrationNumberController.text),
                  _DetailRow('Email', _emailController.text),
                  _DetailRow('Phone', _phoneController.text),
                  _DetailRow('Address', _addressController.text),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Documents Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildStatusRow('Banking License', _bankingLicenseUploaded),
                  _buildStatusRow('Certificate of Incorporation', _incorporationCertUploaded),
                  _buildStatusRow('Audit Report', _auditReportUploaded),
                  _buildStatusRow('Compliance Certificates', _complianceCertUploaded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Compliance Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildStatusRow('KYC Compliance', _kycCompliant),
                  _buildStatusRow('AML Compliance', _amlCompliant),
                  _buildStatusRow('GDPR Compliance', _gdprCompliant),
                  _buildStatusRow('Risk Assessment', _riskAssessmentComplete),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Platform Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _DetailRow('Commission Rate', '${_commissionController.text}%'),
                  _DetailRow('Min Asset Value', '\$${_minimumAssetValueController.text}'),
                  _DetailRow('Max Asset Value', '\$${_maximumAssetValueController.text}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _basicInfoKey.currentState?.validate() ?? false;
      case 1:
        if (!_bankingLicenseUploaded || !_incorporationCertUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload required documents')),
          );
          return false;
        }
        return _documentsKey.currentState?.validate() ?? false;
      case 2:
        if (!_kycCompliant || !_amlCompliant) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please confirm compliance requirements')),
          );
          return false;
        }
        return true;
      case 3:
        return _settingsKey.currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  void _submitOnboarding() async {
    try {
      final bankData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'website': _websiteController.text,
        'registrationNumber': _registrationNumberController.text,
        'licenseNumber': _licenseNumberController.text,
        'taxId': _taxIdController.text,
        'swiftCode': _swiftCodeController.text,
        'commissionRate': double.parse(_commissionController.text) / 100,
        'minimumAssetValue': double.parse(_minimumAssetValueController.text),
        'maximumAssetValue': double.parse(_maximumAssetValueController.text),
        'status': 'pending',
        'onboardingCompleted': true,
        'kycCompliant': _kycCompliant,
        'amlCompliant': _amlCompliant,
        'gdprCompliant': _gdprCompliant,
        'riskAssessmentComplete': _riskAssessmentComplete,
        'documentsUploaded': {
          'bankingLicense': _bankingLicenseUploaded,
          'incorporationCert': _incorporationCertUploaded,
          'auditReport': _auditReportUploaded,
          'complianceCert': _complianceCertUploaded,
        },
      };

      await ref.read(banksProvider.notifier).createBank(bankData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank onboarding completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _EditBankDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> bank;

  const _EditBankDialog({required this.bank});

  @override
  ConsumerState<_EditBankDialog> createState() => _EditBankDialogState();
}

class _EditBankDialogState extends ConsumerState<_EditBankDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _commissionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bank['name']);
    _emailController = TextEditingController(text: widget.bank['email']);
    _addressController = TextEditingController(text: widget.bank['address']);
    _phoneController = TextEditingController(text: widget.bank['phone']);
    _commissionController = TextEditingController(
      text: ((widget.bank['commissionRate'] ?? 0.0) * 100).toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Bank'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commissionController,
                decoration: const InputDecoration(
                  labelText: 'Commission Rate (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter commission rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0 || rate > 100) {
                    return 'Please enter valid rate (0-100)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Update Bank'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'commissionRate': double.parse(_commissionController.text) / 100,
      };

      await ref.read(banksProvider.notifier).updateBank(
        widget.bank['id'],
        updateData,
      );
      if (mounted) Navigator.pop(context);
    }
  }
}

class _BankDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> bank;

  const _BankDetailsDialog({required this.bank});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(bank['createdAt'] ?? '') ?? DateTime.now();
    final status = bank['status'] ?? 'pending';
    final commission = bank['commissionRate'] ?? 0.0;

    Color statusColor = Colors.grey;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'suspended':
        statusColor = Colors.red;
        break;
    }

    return AlertDialog(
      title: Text(bank['name'] ?? 'Bank Details'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Bank ID', bank['id'] ?? 'N/A'),
            _DetailRow('Email', bank['email'] ?? 'N/A'),
            _DetailRow('Address', bank['address'] ?? 'N/A'),
            _DetailRow('Phone', bank['phone'] ?? 'N/A'),
            _DetailRow('Commission Rate', '${(commission * 100).toStringAsFixed(2)}%'),
            Row(
              children: [
                const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _DetailRow('Created At', '${createdAt.day}/${createdAt.month}/${createdAt.year}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ProposalsTab extends ConsumerStatefulWidget {
  const _ProposalsTab();

  @override
  ConsumerState<_ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends ConsumerState<_ProposalsTab> {
  final _searchController = TextEditingController();
  String _statusFilter = 'all';
  String _bankFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(banksProvider.notifier).loadBankProposals();
      ref.read(banksProvider.notifier).loadBanks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banksState = ref.watch(banksProvider);
    final banksNotifier = ref.read(banksProvider.notifier);

    List<Map<String, dynamic>> filteredProposals = banksState.bankProposals;

    if (_statusFilter != 'all') {
      filteredProposals = filteredProposals.where((proposal) => proposal['status'] == _statusFilter).toList();
    }

    if (_bankFilter != 'all') {
      filteredProposals = filteredProposals.where((proposal) => proposal['bankId'] == _bankFilter).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredProposals = filteredProposals.where((proposal) {
        final assetName = (proposal['assetName'] ?? '').toLowerCase();
        final description = (proposal['description'] ?? '').toLowerCase();
        return assetName.contains(query) || description.contains(query);
      }).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asset Proposals Review',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => banksNotifier.loadBankProposals(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search and Filter Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search proposals...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _statusFilter,
                  decoration: InputDecoration(
                    labelText: 'Status Filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending Review')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) => setState(() => _statusFilter = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _bankFilter,
                  decoration: InputDecoration(
                    labelText: 'Bank Filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Banks')),
                    ...banksState.banks.map((bank) => DropdownMenuItem(
                      value: bank['id'],
                      child: Text(bank['name'] ?? 'Unknown Bank'),
                    )),
                  ],
                  onChanged: (value) => setState(() => _bankFilter = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Proposals',
                  value: '${banksState.bankProposals.length}',
                  subtitle: 'Submitted',
                  color: Colors.blue,
                  icon: Icons.assignment,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Pending Review',
                  value: '${banksNotifier.pendingProposals.length}',
                  subtitle: 'Awaiting decision',
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Approved',
                  value: '${banksState.bankProposals.where((p) => p['status'] == 'approved').length}',
                  subtitle: 'Ready for tokenization',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Rejected',
                  value: '${banksState.bankProposals.where((p) => p['status'] == 'rejected').length}',
                  subtitle: 'Declined',
                  color: Colors.red,
                  icon: Icons.cancel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Proposals Table
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const _ProposalsTableHeader(),
                  const Divider(height: 1),
                  if (banksState.isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (banksState.error != null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${banksState.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => banksNotifier.loadBankProposals(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filteredProposals.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No proposals found'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredProposals.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final proposal = filteredProposals[index];
                          return _ProposalTableRow(
                            proposal: proposal,
                            banks: banksState.banks,
                            onView: () => _showProposalDetailsDialog(context, proposal),
                            onApprove: () => _showApprovalDialog(context, proposal),
                            onReject: () => _showRejectionDialog(context, proposal),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProposalDetailsDialog(BuildContext context, Map<String, dynamic> proposal) {
    final bank = ref.read(banksProvider).banks.firstWhere(
      (b) => b['id'] == proposal['bankId'],
      orElse: () => {'name': 'Unknown Bank'},
    );

    showDialog(
      context: context,
      builder: (context) => _ProposalDetailsDialog(
        proposal: proposal,
        bank: bank,
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, Map<String, dynamic> proposal) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Proposal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to approve "${proposal['assetName']}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Approval Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(banksProvider.notifier).approveProposal(
                proposal['id'],
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, Map<String, dynamic> proposal) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Proposal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${proposal['assetName']}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                ref.read(banksProvider.notifier).rejectProposal(
                  proposal['id'],
                  reason: reasonController.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _ProposalsTableHeader extends StatelessWidget {
  const _ProposalsTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Asset Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Bank', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Submitted', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 140, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _ProposalTableRow extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final List<Map<String, dynamic>> banks;
  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ProposalTableRow({
    required this.proposal,
    required this.banks,
    required this.onView,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = proposal['status'] ?? 'pending';
    final value = proposal['value'] ?? 0.0;
    final submittedAt = DateTime.tryParse(proposal['submittedAt'] ?? '') ?? DateTime.now();

    final bank = banks.firstWhere(
      (b) => b['id'] == proposal['bankId'],
      orElse: () => {'name': 'Unknown Bank'},
    );

    Color statusColor = Colors.grey;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proposal['assetName'] ?? 'Unknown Asset',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  proposal['description'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(bank['name'] ?? 'Unknown Bank'),
          ),
          Expanded(
            child: Text(proposal['assetType'] ?? 'N/A'),
          ),
          Expanded(
            child: Text('\$${value.toStringAsFixed(0)}'),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${submittedAt.day}/${submittedAt.month}/${submittedAt.year}',
            ),
          ),
          SizedBox(
            width: 140,
            child: Row(
              children: [
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility, size: 18),
                  tooltip: 'View Details',
                ),
                if (status == 'pending') ...[
                  IconButton(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18, color: Colors.green),
                    tooltip: 'Approve',
                  ),
                  IconButton(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    tooltip: 'Reject',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProposalDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final Map<String, dynamic> bank;

  const _ProposalDetailsDialog({
    required this.proposal,
    required this.bank,
  });

  @override
  Widget build(BuildContext context) {
    final submittedAt = DateTime.tryParse(proposal['submittedAt'] ?? '') ?? DateTime.now();
    final status = proposal['status'] ?? 'pending';
    final value = proposal['value'] ?? 0.0;

    Color statusColor = Colors.grey;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
    }

    return AlertDialog(
      title: Text(proposal['assetName'] ?? 'Proposal Details'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('Proposal ID', proposal['id'] ?? 'N/A'),
              _DetailRow('Asset Name', proposal['assetName'] ?? 'N/A'),
              _DetailRow('Asset Type', proposal['assetType'] ?? 'N/A'),
              _DetailRow('Value', '\$${value.toStringAsFixed(2)}'),
              _DetailRow('Bank', bank['name'] ?? 'Unknown Bank'),
              Row(
                children: [
                  const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _DetailRow('Submitted Date', '${submittedAt.day}/${submittedAt.month}/${submittedAt.year}'),
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  proposal['description'] ?? 'No description provided',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (proposal['notes'] != null) ...[
                const SizedBox(height: 16),
                const Text('Admin Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Text(
                    proposal['notes'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
              if (proposal['rejectionReason'] != null) ...[
                const SizedBox(height: 16),
                const Text('Rejection Reason:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Text(
                    proposal['rejectionReason'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _BrandsTab extends ConsumerStatefulWidget {
  const _BrandsTab();

  @override
  ConsumerState<_BrandsTab> createState() => _BrandsTabState();
}

class _BrandsTabState extends ConsumerState<_BrandsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedBankId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(brandProvider.notifier).loadBrands();
      ref.read(banksProvider.notifier).loadBanks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.palette, size: 32),
              const SizedBox(width: 16),
              const Text(
                'Brand Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateBrandDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Create Brand'),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Brands'),
            Tab(text: 'Bank-Specific Brands'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllBrandsTab(),
              _buildBankSpecificBrandsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllBrandsTab() {
    final brandState = ref.watch(brandProvider);

    if (brandState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (brandState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${brandState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(brandProvider.notifier).loadBrands(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Brand Name')),
                  DataColumn(label: Text('Bank')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Created')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: brandState.brands.map((brand) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _parseColor(brand.colors.primary),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(brand.brandName),
                          ],
                        ),
                      ),
                      DataCell(Text(brand.bankId)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: brand.isActive ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            brand.isActive ? 'Active' : 'Inactive',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(
                        '${brand.createdAt.day}/${brand.createdAt.month}/${brand.createdAt.year}',
                      )),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showBrandDetails(brand),
                              icon: const Icon(Icons.visibility),
                              tooltip: 'View Details',
                            ),
                            IconButton(
                              onPressed: () => _showEditBrandDialog(brand),
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit Brand',
                            ),
                            if (!brand.isActive)
                              IconButton(
                                onPressed: () => _activateBrand(brand),
                                icon: const Icon(Icons.play_arrow),
                                tooltip: 'Activate',
                                color: Colors.green,
                              ),
                            IconButton(
                              onPressed: () => _deleteBrand(brand.id),
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSpecificBrandsTab() {
    final banksState = ref.watch(banksProvider);
    final brandState = ref.watch(brandProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Bank',
              border: OutlineInputBorder(),
            ),
            value: _selectedBankId,
            items: banksState.banks.map((bank) {
              return DropdownMenuItem(
                value: bank['id'],
                child: Text(bank['name'] ?? 'Unknown'),
              );
            }).toList(),
            onChanged: (bankId) {
              setState(() {
                _selectedBankId = bankId;
              });
              if (bankId != null) {
                ref.read(brandProvider.notifier).loadBrands(bankId: bankId);
              }
            },
          ),
        ),
        if (_selectedBankId != null) ...[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: brandState.getBrandsForBank(_selectedBankId!).length,
              itemBuilder: (context, index) {
                final brand = brandState.getBrandsForBank(_selectedBankId!)[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(brand.colors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: brand.assets.logoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                brand.assets.logoUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text(brand.brandName),
                    subtitle: Text(
                      brand.isActive ? 'Active Brand' : 'Inactive Brand',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showBrandPreview(brand),
                          icon: const Icon(Icons.preview),
                          tooltip: 'Preview',
                        ),
                        IconButton(
                          onPressed: () => _showEditBrandDialog(brand),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  void _showCreateBrandDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateBrandDialog(),
    );
  }

  void _showEditBrandDialog(BrandConfig brand) {
    showDialog(
      context: context,
      builder: (context) => _EditBrandDialog(brand: brand),
    );
  }

  void _showBrandDetails(BrandConfig brand) {
    showDialog(
      context: context,
      builder: (context) => _BrandDetailsDialog(brand: brand),
    );
  }

  void _showBrandPreview(BrandConfig brand) {
    showDialog(
      context: context,
      builder: (context) => _BrandPreviewDialog(brand: brand),
    );
  }

  void _activateBrand(BrandConfig brand) {
    ref.read(brandProvider.notifier).activateBrand(brand.id, brand.bankId);
  }

  void _deleteBrand(String brandId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brand'),
        content: const Text('Are you sure you want to delete this brand? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(brandProvider.notifier).deleteBrand(brandId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CreateBrandDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateBrandDialog> createState() => _CreateBrandDialogState();
}

class _CreateBrandDialogState extends ConsumerState<_CreateBrandDialog> {
  final _formKey = GlobalKey<FormState>();
  final _brandNameController = TextEditingController();
  final _primaryColorController = TextEditingController(text: '2196F3');
  final _secondaryColorController = TextEditingController(text: '03DAC6');
  String? _selectedBankId;

  @override
  Widget build(BuildContext context) {
    final banksState = ref.watch(banksProvider);

    return AlertDialog(
      title: const Text('Create New Brand'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Bank',
                  border: OutlineInputBorder(),
                ),
                value: _selectedBankId,
                items: banksState.banks.map((bank) {
                  return DropdownMenuItem(
                    value: bank['id'],
                    child: Text(bank['name'] ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedBankId = value),
                validator: (value) => value == null ? 'Please select a bank' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandNameController,
                decoration: const InputDecoration(
                  labelText: 'Brand Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Brand name is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _primaryColorController,
                      decoration: const InputDecoration(
                        labelText: 'Primary Color',
                        border: OutlineInputBorder(),
                        prefixText: '#',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _secondaryColorController,
                      decoration: const InputDecoration(
                        labelText: 'Secondary Color',
                        border: OutlineInputBorder(),
                        prefixText: '#',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createBrand,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createBrand() {
    if (_formKey.currentState?.validate() == true) {
      final brandConfig = BrandConfig(
        id: '',
        bankId: _selectedBankId!,
        brandName: _brandNameController.text,
        colors: BrandColors(
          primary: '#${_primaryColorController.text}',
          secondary: '#${_secondaryColorController.text}',
          accent: '#FFC107',
          background: '#FFFFFF',
          surface: '#FFFFFF',
          error: '#B00020',
          onPrimary: '#FFFFFF',
          onSecondary: '#000000',
          onBackground: '#000000',
          onSurface: '#000000',
          onError: '#FFFFFF',
        ),
        assets: BrandAssets.defaultAssets(),
        typography: BrandTypography.defaultTypography(),
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      ref.read(brandProvider.notifier).createBrand(brandConfig);
      Navigator.pop(context);
    }
  }
}

class _EditBrandDialog extends ConsumerStatefulWidget {
  final BrandConfig brand;

  const _EditBrandDialog({required this.brand});

  @override
  ConsumerState<_EditBrandDialog> createState() => _EditBrandDialogState();
}

class _EditBrandDialogState extends ConsumerState<_EditBrandDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandNameController;
  late TextEditingController _primaryColorController;
  late TextEditingController _secondaryColorController;

  @override
  void initState() {
    super.initState();
    _brandNameController = TextEditingController(text: widget.brand.brandName);
    _primaryColorController = TextEditingController(
      text: widget.brand.colors.primary.replaceFirst('#', ''),
    );
    _secondaryColorController = TextEditingController(
      text: widget.brand.colors.secondary.replaceFirst('#', ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Brand'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _brandNameController,
                decoration: const InputDecoration(
                  labelText: 'Brand Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Brand name is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _primaryColorController,
                      decoration: const InputDecoration(
                        labelText: 'Primary Color',
                        border: OutlineInputBorder(),
                        prefixText: '#',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _secondaryColorController,
                      decoration: const InputDecoration(
                        labelText: 'Secondary Color',
                        border: OutlineInputBorder(),
                        prefixText: '#',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateBrand,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _updateBrand() {
    if (_formKey.currentState?.validate() == true) {
      final updatedBrand = widget.brand.copyWith(
        brandName: _brandNameController.text,
        colors: BrandColors(
          primary: '#${_primaryColorController.text}',
          secondary: '#${_secondaryColorController.text}',
          accent: widget.brand.colors.accent,
          background: widget.brand.colors.background,
          surface: widget.brand.colors.surface,
          error: widget.brand.colors.error,
          onPrimary: widget.brand.colors.onPrimary,
          onSecondary: widget.brand.colors.onSecondary,
          onBackground: widget.brand.colors.onBackground,
          onSurface: widget.brand.colors.onSurface,
          onError: widget.brand.colors.onError,
        ),
        updatedAt: DateTime.now(),
      );

      ref.read(brandProvider.notifier).updateBrand(widget.brand.id, updatedBrand);
      Navigator.pop(context);
    }
  }
}

class _BrandDetailsDialog extends StatelessWidget {
  final BrandConfig brand;

  const _BrandDetailsDialog({required this.brand});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(brand.brandName),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection('Basic Information', [
                _buildInfoRow('Brand Name', brand.brandName),
                _buildInfoRow('Bank ID', brand.bankId),
                _buildInfoRow('Status', brand.isActive ? 'Active' : 'Inactive'),
                _buildInfoRow('Created', _formatDate(brand.createdAt)),
                _buildInfoRow('Updated', _formatDate(brand.updatedAt)),
              ]),
              const SizedBox(height: 16),
              _buildInfoSection('Colors', [
                _buildColorRow('Primary', brand.colors.primary),
                _buildColorRow('Secondary', brand.colors.secondary),
                _buildColorRow('Accent', brand.colors.accent),
                _buildColorRow('Background', brand.colors.background),
                _buildColorRow('Surface', brand.colors.surface),
              ]),
              const SizedBox(height: 16),
              _buildInfoSection('Typography', [
                _buildInfoRow('Font Family', brand.typography.fontFamily),
                _buildInfoRow('Heading Font', brand.typography.headingFontFamily),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildColorRow(String label, String color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _parseColor(color),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(color),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class _BrandPreviewDialog extends StatelessWidget {
  final BrandConfig brand;

  const _BrandPreviewDialog({required this.brand});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Preview: ${brand.brandName}'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Container(
          decoration: BoxDecoration(
            color: _parseColor(brand.colors.background),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: _parseColor(brand.colors.primary),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    brand.brandName,
                    style: TextStyle(
                      color: _parseColor(brand.colors.onPrimary),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Content',
                        style: TextStyle(
                          color: _parseColor(brand.colors.onBackground),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is how your brand colors will look in the application interface.',
                        style: TextStyle(
                          color: _parseColor(brand.colors.onBackground),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _parseColor(brand.colors.secondary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Secondary Color Example',
                          style: TextStyle(
                            color: _parseColor(brand.colors.onSecondary),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}


