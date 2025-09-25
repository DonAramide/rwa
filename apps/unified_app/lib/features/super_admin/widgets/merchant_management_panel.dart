import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/merchant_models.dart';
import '../../../providers/super_admin_provider.dart';
import '../new_merchant_setup_screen.dart';

class MerchantManagementPanel extends ConsumerStatefulWidget {
  const MerchantManagementPanel({super.key});

  @override
  ConsumerState<MerchantManagementPanel> createState() => _MerchantManagementPanelState();
}

class _MerchantManagementPanelState extends ConsumerState<MerchantManagementPanel>
    with SingleTickerProviderStateMixin {
  late TabController _merchantTabController;

  final List<Tab> _merchantTabs = const [
    Tab(text: 'Active Merchants'),
    Tab(text: 'Pending Approval'),
    Tab(text: 'All Merchants'),
    Tab(text: 'By Category'),
  ];

  @override
  void initState() {
    super.initState();
    _merchantTabController = TabController(length: _merchantTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _merchantTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final superAdminState = ref.watch(superAdminProvider);
    final activeMerchants = ref.watch(activeMerchantsProvider);
    final pendingMerchants = ref.watch(pendingMerchantsProvider);

    return Column(
      children: [
        // Header with merchant stats and add merchant button
        _buildMerchantStatsHeader(superAdminState.merchants),

        // Action bar with add merchant button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Merchant Management',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddMerchantDialog(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add New Merchant', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        // Tab bar for merchant categories
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _merchantTabController,
            tabs: _merchantTabs,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _merchantTabController,
            children: [
              _buildMerchantsList(activeMerchants, 'active'),
              _buildMerchantsList(pendingMerchants, 'pending'),
              _buildMerchantsList(superAdminState.merchants, 'all'),
              _buildMerchantsByCategoryTab(superAdminState.merchants),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMerchantStatsHeader(List<MerchantProfile> merchants) {
    final activeMerchants = merchants.where((m) => m.status == 'active').length;
    final pendingMerchants = merchants.where((m) => m.status == 'pending').length;
    final suspendedMerchants = merchants.where((m) => m.status == 'suspended').length;
    final totalRevenue = merchants.fold<double>(0.0, (sum, merchant) => sum + (merchant.totalRevenue ?? 0.0));

    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Active Merchants',
              activeMerchants.toString(),
              Icons.check_circle,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Pending Approval',
              pendingMerchants.toString(),
              Icons.pending,
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Suspended',
              suspendedMerchants.toString(),
              Icons.block,
              AppColors.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Total Revenue',
              '\$${_formatLargeNumber(totalRevenue)}',
              Icons.monetization_on,
              AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: AppColors.background,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantsList(List<MerchantProfile> merchants, String type) {
    if (merchants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type == 'all' ? '' : type} merchants found',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(superAdminProvider.notifier).refreshAllData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: merchants.length,
        itemBuilder: (context, index) {
          final merchant = merchants[index];
          return _buildMerchantCard(merchant);
        },
      ),
    );
  }

  Widget _buildMerchantCard(MerchantProfile merchant) {
    Color statusColor;
    IconData statusIcon;

    switch (merchant.status.toLowerCase()) {
      case 'active':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        break;
      case 'suspended':
        statusColor = AppColors.error;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with merchant logo, name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Merchant logo (if available)
                if (merchant.branding?.logoUrl != null) ...[
                  Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border.withOpacity(0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        merchant.branding!.logoUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(Icons.business, color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchant.name,
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        merchant.legalName ?? 'Legal name not provided',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (merchant.totalRevenue != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Revenue: \$${(merchant.totalRevenue! / 1000000).toStringAsFixed(1)}M',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        merchant.status.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Merchant details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Registration',
                    merchant.registrationNumber ?? 'N/A',
                    Icons.assignment_ind,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Country',
                    merchant.country,
                    Icons.public,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Domain',
                    merchant.domain ?? 'Not configured',
                    Icons.language,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Financial details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Commission Rate',
                    '${(merchant.commissionRateBps / 100).toStringAsFixed(2)}%',
                    Icons.percent,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Revenue Share',
                    '${(merchant.revenueShareBps / 100).toStringAsFixed(1)}%',
                    Icons.pie_chart,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Total Revenue',
                    '\$${_formatLargeNumber(merchant.totalRevenue ?? 0.0)}',
                    Icons.monetization_on,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // User and Contact details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Total Users',
                    merchant.totalUsers != null ? _formatLargeNumber(merchant.totalUsers!.toDouble()) : 'N/A',
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Contact Email',
                    merchant.contactInfo?.email ?? 'Not provided',
                    Icons.email,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Phone',
                    merchant.contactInfo?.phone ?? 'Not provided',
                    Icons.phone,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Portal and Category details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Portal URL',
                    merchant.portalInfo?.portalUrl ?? 'Not configured',
                    Icons.link,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Environment',
                    merchant.portalInfo?.environment?.toUpperCase() ?? 'N/A',
                    Icons.cloud,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Created',
                    _formatDate(merchant.createdAt),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),

            if (merchant.categories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Categories',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: merchant.categories.take(3).map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList()..addAll(merchant.categories.length > 3 ? [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${merchant.categories.length - 3}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ] : []),
              ),
            ],

            if (merchant.description?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                merchant.description!,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Text(
                  'Joined ${_formatTimeAgo(merchant.createdAt)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                ..._buildActionButtons(merchant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(MerchantProfile merchant) {
    final buttons = <Widget>[];

    if (merchant.status == 'pending') {
      buttons.addAll([
        OutlinedButton.icon(
          onPressed: () => _showApprovalDialog(merchant),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Approve'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.success,
            side: BorderSide(color: AppColors.success),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _showRejectDialog(merchant),
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Reject'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error),
          ),
        ),
      ]);
    } else if (merchant.status == 'active') {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () => _showSuspendDialog(merchant),
          icon: const Icon(Icons.block, size: 16),
          label: const Text('Suspend'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.warning,
            side: BorderSide(color: AppColors.warning),
          ),
        ),
      );
    } else if (merchant.status == 'suspended') {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () => _showReactivateDialog(merchant),
          icon: const Icon(Icons.play_arrow, size: 16),
          label: const Text('Reactivate'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.info,
            side: BorderSide(color: AppColors.info),
          ),
        ),
      );
    }

    buttons.addAll([
      const SizedBox(width: 8),
      IconButton(
        onPressed: () => _showSendNotificationDialog(merchant),
        icon: const Icon(Icons.notifications_outlined),
        tooltip: 'Send Notification',
        style: IconButton.styleFrom(
          foregroundColor: AppColors.info,
        ),
      ),
      IconButton(
        onPressed: () => _showChatDialog(merchant),
        icon: const Icon(Icons.chat_outlined),
        tooltip: 'Chat with Merchant',
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      IconButton(
        onPressed: () => _showMerchantDetails(merchant),
        icon: const Icon(Icons.info_outline),
        tooltip: 'View Details',
      ),
    ]);

    return buttons;
  }

  Widget _buildMerchantsByCategoryTab(List<MerchantProfile> merchants) {
    // Group merchants by category
    final Map<String, List<MerchantProfile>> merchantsByCategory = {};

    for (final merchant in merchants) {
      if (merchant.categories.isEmpty) {
        merchantsByCategory.putIfAbsent('Uncategorized', () => []).add(merchant);
      } else {
        for (final category in merchant.categories) {
          merchantsByCategory.putIfAbsent(category, () => []).add(merchant);
        }
      }
    }

    return merchants.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No merchants found',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: merchantsByCategory.keys.length,
            itemBuilder: (context, index) {
              final category = merchantsByCategory.keys.elementAt(index);
              final categoryMerchants = merchantsByCategory[category]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: AppColors.surface,
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category,
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${categoryMerchants.length}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: category != 'Uncategorized' && MerchantCategories.categoryDescriptions.containsKey(category)
                      ? Padding(
                          padding: const EdgeInsets.only(left: 32, top: 4),
                          child: Text(
                            MerchantCategories.categoryDescriptions[category]!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : null,
                  children: categoryMerchants.map((merchant) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildMerchantCard(merchant),
                    );
                  }).toList(),
                ),
              );
            },
          );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Real Estate':
        return Icons.home;
      case 'Technology':
        return Icons.computer;
      case 'Energy':
        return Icons.bolt;
      case 'Infrastructure':
        return Icons.foundation;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Finance':
        return Icons.account_balance;
      case 'Agriculture':
        return Icons.agriculture;
      case 'Manufacturing':
        return Icons.precision_manufacturing;
      case 'Retail':
        return Icons.store;
      case 'Transportation':
        return Icons.local_shipping;
      case 'Entertainment':
        return Icons.movie;
      case 'Education':
        return Icons.school;
      case 'Hospitality':
        return Icons.hotel;
      case 'Telecommunications':
        return Icons.cell_tower;
      case 'Utilities':
        return Icons.electrical_services;
      default:
        return Icons.business;
    }
  }

  void _showApprovalDialog(MerchantProfile merchant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Approve Merchant',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to approve ${merchant.name}? This will activate their account and allow them to start operations.',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(superAdminProvider.notifier).approveMerchant(merchant.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${merchant.name} has been approved')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(MerchantProfile merchant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Suspend Merchant',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to suspend ${merchant.name}? This will immediately stop all their operations.',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(superAdminProvider.notifier).suspendMerchant(merchant.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${merchant.name} has been suspended')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Suspend', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(MerchantProfile merchant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reject Merchant',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to reject ${merchant.name}\'s application? This action cannot be undone.',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${merchant.name}\'s application has been rejected')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReactivateDialog(MerchantProfile merchant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reactivate Merchant',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to reactivate ${merchant.name}? This will restore their full access.',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(superAdminProvider.notifier).approveMerchant(merchant.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${merchant.name} has been reactivated')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
            child: const Text('Reactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMerchantDetails(MerchantProfile merchant) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Merchant Details',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Merchant Name', merchant.name),
              _buildDetailRow('Legal Name', merchant.legalName ?? 'N/A'),
              _buildDetailRow('Registration Number', merchant.registrationNumber ?? 'N/A'),
              _buildDetailRow('Country', merchant.country),
              _buildDetailRow('Domain', merchant.domain ?? 'N/A'),
              _buildDetailRow('Subdomain', merchant.subdomain ?? 'N/A'),
              _buildDetailRow('Status', merchant.status.toUpperCase()),
              _buildDetailRow('Commission Rate', '${(merchant.commissionRateBps / 100).toStringAsFixed(2)}%'),
              _buildDetailRow('Revenue Share', '${(merchant.revenueShareBps / 100).toStringAsFixed(1)}%'),
              if (merchant.contractStartDate != null)
                _buildDetailRow('Contract Start', _formatDate(merchant.contractStartDate!)),
              _buildDetailRow('Created', _formatDate(merchant.createdAt)),
              _buildDetailRow('Last Updated', _formatDate(merchant.updatedAt)),
              if (merchant.description?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  'Description',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  merchant.description!,
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
              ],
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
            width: 140,
            child: Text(
              '$label:',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLargeNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toStringAsFixed(0);
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() != 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else {
      return 'Recently';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _showSendNotificationDialog(MerchantProfile merchant) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    String selectedType = 'info';
    String selectedPriority = 'medium';
    List<String> selectedAudience = ['merchants'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: AppColors.surface,
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Send Notification to ${merchant.name}',
                      style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Notification Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'info', child: Text('Info')),
                          DropdownMenuItem(value: 'warning', child: Text('Warning')),
                          DropdownMenuItem(value: 'alert', child: Text('Alert')),
                          DropdownMenuItem(value: 'announcement', child: Text('Announcement')),
                        ],
                        onChanged: (value) => setState(() => selectedType = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Low')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'high', child: Text('High')),
                          DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                        ],
                        onChanged: (value) => setState(() => selectedPriority = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement send notification logic
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Notification sent to ${merchant.name}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Send Notification', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChatDialog(MerchantProfile merchant) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat with ${merchant.name}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Chat history will appear here...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Implement send message logic
                          messageController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Message sent to ${merchant.name}')),
                          );
                        },
                        icon: const Icon(Icons.send),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMerchantDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewMerchantSetupScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}