import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/api_client.dart';
import '../../models/merchant_models.dart';
import '../../widgets/theme_toggle.dart';
import 'widgets/merchant_dashboard_cards.dart';
import 'widgets/merchant_metrics_chart.dart';
import 'widgets/merchant_customer_list.dart';
import 'widgets/merchant_transaction_list.dart';
import 'widgets/merchant_asset_proposals.dart';
import 'widgets/merchant_settlements.dart';
import 'widgets/merchant_profile_settings.dart';

class MerchantAdminDashboard extends ConsumerStatefulWidget {
  const MerchantAdminDashboard({super.key});

  @override
  ConsumerState<MerchantAdminDashboard> createState() => _MerchantAdminDashboardState();
}

class _MerchantAdminDashboardState extends ConsumerState<MerchantAdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  MerchantDashboardAnalytics? _analytics;
  MerchantProfile? _profile;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        ApiClient.getMerchantDashboard(),
        ApiClient.getMerchantProfile(),
      ]);

      setState(() {
        _analytics = MerchantDashboardAnalytics.fromJson(results[0] as Map<String, dynamic>);
        _profile = MerchantProfile.fromJson(results[1] as Map<String, dynamic>);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          _profile?.name ?? 'Merchant Admin Dashboard',
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
        ),
        backgroundColor: AppColors.getSurface(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.getTextPrimary(isDark)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.getTextPrimary(isDark)),
            onPressed: _loadDashboardData,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ThemeToggle(isCompact: true),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.getTextSecondary(isDark),
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Customers', icon: Icon(Icons.people)),
            Tab(text: 'Transactions', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Asset Proposals', icon: Icon(Icons.request_quote)),
            Tab(text: 'Settlements', icon: Icon(Icons.payment)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
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
                        color: AppColors.error,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading dashboard',
                        style: AppTextStyles.heading5.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.getTextSecondary(isDark),
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
                    // Overview Tab
                    _buildOverviewTab(),
                    // Customers Tab
                    const MerchantCustomerList(),
                    // Transactions Tab
                    const MerchantTransactionList(),
                    // Asset Proposals Tab
                    const MerchantAssetProposals(),
                    // Settlements Tab
                    const MerchantSettlements(),
                    // Analytics Tab
                    _buildAnalyticsTab(),
                    // Settings Tab
                    MerchantProfileSettings(profile: _profile),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    if (_analytics == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard Cards
          MerchantDashboardCards(analytics: _analytics!),
          const SizedBox(height: 24),

          // Metrics Chart
          MerchantMetricsChart(metrics: _analytics!.metrics),
          const SizedBox(height: 24),

          // Quick Stats Row
          _buildQuickStatsRow(),
          const SizedBox(height: 24),

          // Recent Activity Summary
          _buildRecentActivitySummary(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_analytics == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analytics',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(Theme.of(context).brightness == Brightness.dark),
            ),
          ),
          const SizedBox(height: 16),

          // Detailed metrics
          MerchantMetricsChart(metrics: _analytics!.metrics),
          const SizedBox(height: 24),

          // Revenue breakdown
          _buildRevenueBreakdown(),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            'Assets',
            _analytics!.totalAssets.toString(),
            Icons.account_balance,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            'Investments',
            _analytics!.totalInvestments.toString(),
            Icons.trending_up,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            'Transactions',
            _analytics!.completedTransactions.toString(),
            Icons.receipt,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading5.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySummary() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Text(
            'Recent Activity Summary',
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActivityItem('Pending Approvals', _analytics!.pendingApprovals.toString(), isDark),
              _buildActivityItem('Active Investors', _analytics!.activeInvestors.toString(), isDark),
              _buildActivityItem('Revenue Earned', '\$${(_analytics!.revenueEarned / 1000).toStringAsFixed(1)}K', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.getTextSecondary(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRevenueBreakdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Text(
            'Revenue Breakdown',
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_analytics!.revenueBreakdown.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  Text(
                    '\$${(entry.value / 1000).toStringAsFixed(1)}K',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }
}