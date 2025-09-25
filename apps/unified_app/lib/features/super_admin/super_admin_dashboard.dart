import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/super_admin_provider.dart';
import '../../widgets/theme_toggle.dart';
import 'widgets/global_metrics_overview.dart';
import 'widgets/merchant_management_panel.dart';
import 'widgets/user_management_panel.dart';
import 'widgets/asset_management_panel.dart';
import 'widgets/reports_dashboard.dart';
import 'widgets/system_health_monitor.dart';
import 'widgets/global_analytics_dashboard.dart';
import 'widgets/super_admin_api_keys.dart';
import 'widgets/audit_log_viewer.dart';

class SuperAdminDashboard extends ConsumerStatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  ConsumerState<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends ConsumerState<SuperAdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = [
    const Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
    const Tab(text: 'Merchants', icon: Icon(Icons.account_balance)),
    const Tab(text: 'User Management', icon: Icon(Icons.people)),
    const Tab(text: 'Asset Management', icon: Icon(Icons.business_center)),
    const Tab(text: 'Reports', icon: Icon(Icons.assessment)),
    const Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
    const Tab(text: 'API Keys', icon: Icon(Icons.key)),
    const Tab(text: 'System Health', icon: Icon(Icons.monitor_heart)),
    const Tab(text: 'Audit Logs', icon: Icon(Icons.history)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(superAdminProvider.notifier).loadDashboardData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final superAdminState = ref.watch(superAdminProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.admin_panel_settings,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super Admin Dashboard',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Master Platform Control',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // Global refresh button
          IconButton(
            icon: superAdminState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: superAdminState.isLoading
                ? null
                : () => ref.read(superAdminProvider.notifier).refreshAllData(),
            tooltip: 'Refresh All Data',
          ),
          const SizedBox(width: 8),
          const ThemeToggle(),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: superAdminState.error != null
          ? _buildErrorView(superAdminState.error!)
          : TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                const GlobalMetricsOverview(),

                // Merchants Management Tab
                const MerchantManagementPanel(),

                // User Management Tab
                const UserManagementPanel(),

                // Asset Management Tab
                const AssetManagementPanel(),

                // Reports Tab
                const ReportsDashboard(),

                // Analytics Tab
                const GlobalAnalyticsDashboard(),

                // API Keys Tab
                const SuperAdminApiKeys(),

                // System Health Tab
                const SystemHealthMonitor(),

                // Audit Logs Tab
                const AuditLogViewer(),
              ],
            ),
    );
  }

  Widget _buildErrorView(String error) {
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
            'Failed to load dashboard',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(superAdminProvider.notifier).loadDashboardData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}