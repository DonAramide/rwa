import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_service.dart';
import '../../../providers/super_admin_provider.dart';
import '../../../providers/users_provider.dart';

class ReportsDashboard extends ConsumerStatefulWidget {
  const ReportsDashboard({super.key});

  @override
  ConsumerState<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends ConsumerState<ReportsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  String _selectedMerchantFilter = 'All Banks';
  String _selectedReportType = 'Overview';

  final List<Tab> _tabs = [
    const Tab(text: 'Activity Overview', icon: Icon(Icons.analytics)),
    const Tab(text: 'Merchant Reports', icon: Icon(Icons.account_balance)),
    const Tab(text: 'User Activity', icon: Icon(Icons.people)),
    const Tab(text: 'Asset Reports', icon: Icon(Icons.real_estate_agent)),
    const Tab(text: 'Transaction Reports', icon: Icon(Icons.receipt_long)),
    const Tab(text: 'Compliance Reports', icon: Icon(Icons.gavel)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(superAdminProvider.notifier).loadReportsData();
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

    return Column(
      children: [
        _buildReportsHeader(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActivityOverview(superAdminState),
              _buildMerchantReports(superAdminState),
              _buildUserActivityReports(superAdminState),
              _buildAssetReports(superAdminState),
              _buildTransactionReports(superAdminState),
              _buildComplianceReports(superAdminState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService.getSurface(context),
        boxShadow: [
          BoxShadow(
            color: ThemeService.getShadowColor(context),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Reports & Analytics Dashboard',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _buildDateRangeSelector(),
              const SizedBox(width: 16),
              _buildExportButton(),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: _tabs,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return OutlinedButton.icon(
      onPressed: _selectDateRange,
      icon: const Icon(Icons.date_range),
      label: Text(
        '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildExportButton() {
    return PopupMenuButton<String>(
      onSelected: _exportReport,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
        const PopupMenuItem(value: 'excel', child: Text('Export as Excel')),
        const PopupMenuItem(value: 'csv', child: Text('Export as CSV')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download, color: AppColors.textOnPrimary, size: 18),
            SizedBox(width: 8),
            Text('Export', style: TextStyle(color: AppColors.textOnPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityOverview(superAdminState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          _buildActivityChart(),
          const SizedBox(height: 24),
          _buildRecentActivitiesList(),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildMetricCard(
          'Total Users',
          '1,234',
          Icons.people,
          AppColors.success,
          '+12.5%',
        ),
        _buildMetricCard(
          'Active Merchants',
          '45',
          Icons.account_balance,
          AppColors.primary,
          '+3.2%',
        ),
        _buildMetricCard(
          'Assets Listed',
          '892',
          Icons.real_estate_agent,
          AppColors.warning,
          '+8.7%',
        ),
        _buildMetricCard(
          'Transactions',
          '5,678',
          Icons.receipt_long,
          AppColors.info,
          '+15.3%',
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                change,
                style: TextStyle(
                  color: change.startsWith('+') ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Overview - Last 30 Days',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSampleData(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Recent Activities',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: ThemeService.getDivider(context),
            ),
            itemBuilder: (context, index) => _buildActivityItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activitiesState = ref.watch(activitiesProvider);

    if (activitiesState.isLoading || activitiesState.activities.isEmpty) {
      return const SizedBox.shrink();
    }

    final activity = activitiesState.activities[index % activitiesState.activities.length];
    IconData icon;
    Color iconColor;

    switch (activity.type) {
      case 'merchant':
        icon = Icons.account_balance;
        iconColor = AppColors.primary;
        break;
      case 'asset':
        icon = Icons.real_estate_agent;
        iconColor = AppColors.success;
        break;
      case 'user':
        icon = Icons.person;
        iconColor = AppColors.info;
        break;
      case 'transaction':
        icon = Icons.receipt_long;
        iconColor = AppColors.warning;
        break;
      default:
        icon = Icons.gavel;
        iconColor = AppColors.error;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        activity.action!,
        style: AppTextStyles.body1.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        activity.user!,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        _formatTimestamp(activity.timestamp),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMerchantReports(superAdminState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMerchantFilters(),
          const SizedBox(height: 16),
          _buildMerchantPerformanceChart(),
          const SizedBox(height: 16),
          _buildBankListTable(),
        ],
      ),
    );
  }

  Widget _buildMerchantFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedMerchantFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Bank',
              border: OutlineInputBorder(),
            ),
            items: ['All Banks', 'First National', 'City Bank', 'Metro Bank']
                .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
                .toList(),
            onChanged: (value) => setState(() => _selectedMerchantFilter = value!),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedReportType,
            decoration: const InputDecoration(
              labelText: 'Report Type',
              border: OutlineInputBorder(),
            ),
            items: ['Overview', 'Performance', 'Compliance', 'Revenue']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _selectedReportType = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildMerchantPerformanceChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Performance Comparison',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const banks = ['First\nNational', 'City\nBank', 'Metro\nBank', 'Union\nBank'];
                        if (value.toInt() < banks.length) {
                          return Text(banks[value.toInt()], textAlign: TextAlign.center);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: AppColors.primary)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 72, color: AppColors.success)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 68, color: AppColors.warning)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 91, color: AppColors.info)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankListTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.getBorder(context)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Bank Performance Summary',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Bank Name')),
                DataColumn(label: Text('Active Users')),
                DataColumn(label: Text('Assets Listed')),
                DataColumn(label: Text('Transactions')),
                DataColumn(label: Text('Revenue')),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                _buildDataRow('First National Bank', '245', '89', '1,234', '\$45,678', 'Active'),
                _buildDataRow('City Bank', '189', '67', '987', '\$32,456', 'Active'),
                _buildDataRow('Metro Bank', '156', '45', '654', '\$23,789', 'Active'),
                _buildDataRow('Union Bank', '234', '78', '1,456', '\$56,789', 'Active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String bank, String users, String assets, String transactions, String revenue, String status) {
    return DataRow(
      cells: [
        DataCell(Text(bank)),
        DataCell(Text(users)),
        DataCell(Text(assets)),
        DataCell(Text(transactions)),
        DataCell(Text(revenue)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserActivityReports(superAdminState) {
    return const Center(
      child: Text('User Activity Reports - Coming Soon'),
    );
  }

  Widget _buildAssetReports(superAdminState) {
    return const Center(
      child: Text('Asset Reports - Coming Soon'),
    );
  }

  Widget _buildTransactionReports(superAdminState) {
    return const Center(
      child: Text('Transaction Reports - Coming Soon'),
    );
  }

  Widget _buildComplianceReports(superAdminState) {
    return const Center(
      child: Text('Compliance Reports - Coming Soon'),
    );
  }

  List<FlSpot> _generateSampleData() {
    return [
      const FlSpot(0, 20),
      const FlSpot(1, 35),
      const FlSpot(2, 28),
      const FlSpot(3, 45),
      const FlSpot(4, 38),
      const FlSpot(5, 52),
      const FlSpot(6, 48),
    ];
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _exportReport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting report as $format...'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return timestamp; // Return original if parsing fails
    }
  }
}