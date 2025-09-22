import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/asset.dart';
import '../../../data/comprehensive_asset_data.dart';

class ProfessionalAgentDashboard extends ConsumerStatefulWidget {
  const ProfessionalAgentDashboard({super.key});

  @override
  ConsumerState<ProfessionalAgentDashboard> createState() => _ProfessionalAgentDashboardState();
}

class _ProfessionalAgentDashboardState extends ConsumerState<ProfessionalAgentDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Asset> _assets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allAssetData = ComprehensiveAssetData.getAllAssets();
    setState(() {
      _assets = allAssetData.map((json) => Asset.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Agent Dashboard'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.assignment), text: 'Assignments'),
            Tab(icon: Icon(Icons.verified), text: 'Verifications'),
            Tab(icon: Icon(Icons.analytics), text: 'Performance'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Earnings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAssignmentsTab(),
                _buildVerificationsTab(),
                _buildPerformanceTab(),
                _buildEarningsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildRecentAssignments(),
          const SizedBox(height: 24),
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Professional Agent Dashboard',
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Expert verification and professional oversight of RWA assets.',
            style: AppTextStyles.body1.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'PROFESSIONAL CERTIFIED',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active Cases',
                '12',
                Icons.assignment,
                AppColors.primary,
                '+3 this week',
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completed',
                '89',
                Icons.done_all,
                AppColors.success,
                '98% success rate',
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Earnings',
                '\$8,450',
                Icons.attach_money,
                AppColors.investment,
                '+\$1,200',
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Rating',
                '4.9/5',
                Icons.star,
                AppColors.warning,
                '127 reviews',
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: isPositive ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsTab() {
    final pendingAssignments = _assets.where((asset) =>
      asset.status == 'pending' || asset.verificationRequired).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current Assignments',
                style: AppTextStyles.heading2,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Assignment filters coming soon')),
                  );
                },
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pendingAssignments.take(10).map((asset) => _buildAssignmentCard(asset)),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Asset asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAssetIcon(asset.type),
                  color: AppColors.warning,
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
                      style: AppTextStyles.heading4,
                    ),
                    Text(
                      'SPV ID: ${asset.spvId}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'URGENT',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Deadline: ${_formatDeadline()}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Fee: \$${(asset.id * 45 + 200)}',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showAssignmentDetails(asset),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptAssignment(asset),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Tasks',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          _buildVerificationStats(),
          const SizedBox(height: 24),
          _buildVerificationList(),
        ],
      ),
    );
  }

  Widget _buildVerificationStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('89', style: AppTextStyles.heading2.copyWith(color: AppColors.success)),
                    Text('Verified', style: AppTextStyles.body2),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('12', style: AppTextStyles.heading2.copyWith(color: AppColors.warning)),
                    Text('In Progress', style: AppTextStyles.body2),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('3', style: AppTextStyles.heading2.copyWith(color: AppColors.error)),
                    Text('Rejected', style: AppTextStyles.body2),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationList() {
    return Column(
      children: _assets.take(8).map((asset) => _buildVerificationCard(asset)).toList(),
    );
  }

  Widget _buildVerificationCard(Asset asset) {
    final status = _getVerificationStatus(asset);
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAssetIcon(asset.type),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.title, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                Text(asset.type.toUpperCase(), style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: AppTextStyles.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analytics',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          _buildPerformanceCharts(),
          const SizedBox(height: 24),
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildPerformanceCharts() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Performance Charts', style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            Text(
              'Advanced analytics and charts coming soon',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Response Time', '2.3h', 'avg', AppColors.info)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Accuracy Rate', '98.5%', 'verified', AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Client Rating', '4.9/5', 'stars', AppColors.warning)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Completion Rate', '96%', 'on time', AppColors.primary)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.body2),
          Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Dashboard',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          _buildEarningsOverview(),
          const SizedBox(height: 24),
          _buildRecentPayments(),
        ],
      ),
    );
  }

  Widget _buildEarningsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: AppTextStyles.body1.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 8),
          Text(
            '\$8,450.00',
            style: AppTextStyles.heading1.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Month', style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.8))),
                    Text('\$1,200', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending', style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.8))),
                    Text('\$450', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPayments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Payments',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        ...List.generate(8, (index) => _buildPaymentCard(index)),
      ],
    );
  }

  Widget _buildPaymentCard(int index) {
    final amount = [450, 320, 275, 180, 225, 390, 155, 280][index % 8];
    final date = DateTime.now().subtract(Duration(days: index * 3));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.payment, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification Payment #${1000 + index}', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                Text('${date.day}/${date.month}/${date.year}', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('\$${amount}', style: AppTextStyles.heading4.copyWith(color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _buildRecentAssignments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Assignments',
              style: AppTextStyles.heading3,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._assets.take(3).map((asset) => _buildAssignmentCard(asset)),
      ],
    );
  }

  // Helper methods
  IconData _getAssetIcon(String type) {
    switch (type) {
      case 'house': return Icons.house;
      case 'apartment': return Icons.apartment;
      case 'commercial': return Icons.business;
      case 'hotel': return Icons.hotel;
      case 'warehouse': return Icons.warehouse;
      case 'car': return Icons.directions_car;
      case 'gold': return Icons.star;
      case 'shares': return Icons.trending_up;
      case 'solar': return Icons.solar_power;
      default: return Icons.business;
    }
  }

  String _getVerificationStatus(Asset asset) {
    final statuses = ['VERIFIED', 'IN PROGRESS', 'PENDING', 'REJECTED'];
    return statuses[asset.id % statuses.length];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'VERIFIED': return AppColors.success;
      case 'IN PROGRESS': return AppColors.warning;
      case 'PENDING': return AppColors.info;
      case 'REJECTED': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String _formatDeadline() {
    final deadline = DateTime.now().add(Duration(days: 2 + (DateTime.now().millisecond % 5)));
    return '${deadline.day}/${deadline.month}/${deadline.year}';
  }

  void _showAssignmentDetails(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assignment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Asset: ${asset.title}', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Type: ${asset.type.toUpperCase()}', style: AppTextStyles.body2),
            Text('SPV ID: ${asset.spvId}', style: AppTextStyles.body2),
            Text('Location: ${asset.location?.shortAddress ?? 'Not specified'}', style: AppTextStyles.body2),
            const SizedBox(height: 16),
            Text('Required Tasks:', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('• Physical inspection and documentation', style: AppTextStyles.body2),
            Text('• Legal compliance verification', style: AppTextStyles.body2),
            Text('• Market valuation assessment', style: AppTextStyles.body2),
            Text('• Risk analysis report', style: AppTextStyles.body2),
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
              _acceptAssignment(asset);
            },
            child: const Text('Accept Assignment'),
          ),
        ],
      ),
    );
  }

  void _acceptAssignment(Asset asset) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assignment for ${asset.title} accepted successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}