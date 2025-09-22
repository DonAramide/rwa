import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';
import '../models/analytics_model.dart';

class AnalyticsTab extends ConsumerStatefulWidget {
  const AnalyticsTab({super.key});

  @override
  ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab> with AutomaticKeepAliveClientMixin {
  String selectedPeriod = '30d';
  String selectedGranularity = 'monthly';
  int selectedTabIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).loadAllAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final analyticsState = ref.watch(analyticsProvider);

    return Scaffold(
      body: Column(
        children: [
          // Header with period selector
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Analytics Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _PeriodSelector(
                  selectedPeriod: selectedPeriod,
                  onChanged: (period) {
                    setState(() => selectedPeriod = period);
                    ref.read(analyticsProvider.notifier).loadDashboardStats(period);
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => ref.read(analyticsProvider.notifier).loadAllAnalytics(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),

          // Content with tabs
          Expanded(
            child: analyticsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : DefaultTabController(
                  length: 6,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        onTap: (index) => setState(() => selectedTabIndex = index),
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Revenue'),
                          Tab(text: 'Users'),
                          Tab(text: 'Assets'),
                          Tab(text: 'Transactions'),
                          Tab(text: 'Geographic'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _OverviewTab(analyticsState),
                            _RevenueTab(analyticsState),
                            _UsersTab(analyticsState),
                            _AssetsTab(analyticsState),
                            _TransactionsTab(analyticsState),
                            _GeographicTab(analyticsState),
                          ],
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
}

class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedPeriod,
      items: const [
        DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
        DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
        DropdownMenuItem(value: '90d', child: Text('Last 90 days')),
        DropdownMenuItem(value: '12m', child: Text('Last 12 months')),
      ],
      onChanged: (value) => onChanged(value!),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final AnalyticsState state;

  const _OverviewTab(this.state);

  @override
  Widget build(BuildContext context) {
    if (state.dashboardStats == null) {
      return const Center(child: Text('No data available'));
    }

    final stats = state.dashboardStats!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Total Revenue',
                  value: NumberFormat.currency(symbol: '\$').format(stats.totalRevenue),
                  change: stats.revenueGrowth,
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiCard(
                  title: 'Total Users',
                  value: NumberFormat.decimalPattern().format(stats.totalUsers),
                  change: stats.userGrowth,
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiCard(
                  title: 'Active Assets',
                  value: NumberFormat.decimalPattern().format(stats.totalAssets),
                  change: stats.assetGrowth,
                  icon: Icons.business,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiCard(
                  title: 'Transactions',
                  value: NumberFormat.decimalPattern().format(stats.totalTransactions),
                  change: stats.transactionGrowth,
                  icon: Icons.swap_horiz,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Quick Charts Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _QuickRevenueChart(state.revenueData),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _AssetTypeDistribution(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final double change;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: change >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        change >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: change >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${change.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: change >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueTab extends StatelessWidget {
  final AnalyticsState state;

  const _RevenueTab(this.state);

  @override
  Widget build(BuildContext context) {
    if (state.revenueData == null) {
      return const Center(child: Text('No revenue data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Revenue Summary Cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total Revenue',
                  value: NumberFormat.currency(symbol: '\$').format(state.revenueData!.summary.total),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Platform Fees',
                  value: NumberFormat.currency(symbol: '\$').format(state.revenueData!.summary.platformFees),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Management Fees',
                  value: NumberFormat.currency(symbol: '\$').format(state.revenueData!.summary.managementFees),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Verification Fees',
                  value: NumberFormat.currency(symbol: '\$').format(state.revenueData!.summary.verificationFees),
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Revenue Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Trend',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: _RevenueChart(state.revenueData!),
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

class _RevenueChart extends StatelessWidget {
  final RevenueAnalytics data;

  const _RevenueChart(this.data);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.MMM(),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compactCurrency(symbol: '\$'),
      ),
      legend: const Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: [
        AreaSeries<RevenueDataPoint, DateTime>(
          name: 'Platform Fees',
          dataSource: data.data,
          xValueMapper: (datum, _) => DateTime.parse(datum.date),
          yValueMapper: (datum, _) => datum.platformFees,
          color: Colors.blue.withOpacity(0.3),
          borderColor: Colors.blue,
        ),
        AreaSeries<RevenueDataPoint, DateTime>(
          name: 'Management Fees',
          dataSource: data.data,
          xValueMapper: (datum, _) => DateTime.parse(datum.date),
          yValueMapper: (datum, _) => datum.managementFees,
          color: Colors.orange.withOpacity(0.3),
          borderColor: Colors.orange,
        ),
        AreaSeries<RevenueDataPoint, DateTime>(
          name: 'Verification Fees',
          dataSource: data.data,
          xValueMapper: (datum, _) => DateTime.parse(datum.date),
          yValueMapper: (datum, _) => datum.verificationFees,
          color: Colors.purple.withOpacity(0.3),
          borderColor: Colors.purple,
        ),
      ],
    );
  }
}

class _UsersTab extends StatelessWidget {
  final AnalyticsState state;

  const _UsersTab(this.state);

  @override
  Widget build(BuildContext context) {
    if (state.userGrowthData == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Growth Metrics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // User Growth Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Growth Over Time',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: _UserGrowthChart(state.userGrowthData!),
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

class _UserGrowthChart extends StatelessWidget {
  final UserGrowthMetrics data;

  const _UserGrowthChart(this.data);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.MMM(),
      ),
      primaryYAxis: NumericAxis(),
      legend: const Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: [
        LineSeries<UserGrowthDataPoint, DateTime>(
          name: 'Total Investors',
          dataSource: data.data,
          xValueMapper: (datum, _) => DateTime.parse(datum.date),
          yValueMapper: (datum, _) => datum.totalInvestors,
          color: Colors.blue,
          width: 3,
        ),
        LineSeries<UserGrowthDataPoint, DateTime>(
          name: 'Total Agents',
          dataSource: data.data,
          xValueMapper: (datum, _) => DateTime.parse(datum.date),
          yValueMapper: (datum, _) => datum.totalAgents,
          color: Colors.green,
          width: 3,
        ),
        LineSeries<UserGrowthDataPoint, DateTime>(
          name: 'Active Users',
          dataSource: data.data,
          xValueMapper: (datum, _) => DateTime.parse(datum.date),
          yValueMapper: (datum, _) => datum.activeUsers,
          color: Colors.orange,
          width: 3,
        ),
      ],
    );
  }
}

class _AssetsTab extends StatelessWidget {
  final AnalyticsState state;

  const _AssetsTab(this.state);

  @override
  Widget build(BuildContext context) {
    if (state.assetPerformance == null) {
      return const Center(child: Text('No asset data available'));
    }

    final assets = state.assetPerformance!['assets'] as List;
    final summary = state.assetPerformance!['summary'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Performance Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Asset Summary Cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total Assets',
                  value: summary['totalAssets'].toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Total Value',
                  value: NumberFormat.currency(symbol: '\$').format(summary['totalValue']),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Avg Performance',
                  value: '${summary['avgPerformance'].toStringAsFixed(1)}%',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Best Performer',
                  value: summary['bestPerformer']['title'].toString().split(' ').take(2).join(' '),
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Asset Performance Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asset Performance Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Asset')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('NAV')),
                        DataColumn(label: Text('Performance')),
                        DataColumn(label: Text('Total Return')),
                      ],
                      rows: assets.map<DataRow>((asset) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 200,
                                child: Text(
                                  asset['title'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getAssetTypeColor(asset['type']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  asset['type'].toString().replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(
                                    color: _getAssetTypeColor(asset['type']),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(NumberFormat.currency(symbol: '\$').format(asset['nav']))),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    asset['performance'] >= 0 ? Icons.trending_up : Icons.trending_down,
                                    size: 16,
                                    color: asset['performance'] >= 0 ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${asset['performance'].toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: asset['performance'] >= 0 ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                '${asset['totalReturn'].toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: asset['totalReturn'] >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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

  Color _getAssetTypeColor(String type) {
    switch (type) {
      case 'real_estate':
        return Colors.blue;
      case 'vehicle':
        return Colors.green;
      case 'equipment':
        return Colors.orange;
      case 'land':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _TransactionsTab extends StatelessWidget {
  final AnalyticsState state;

  const _TransactionsTab(this.state);

  @override
  Widget build(BuildContext context) {
    if (state.transactionVolume == null) {
      return const Center(child: Text('No transaction data available'));
    }

    final data = state.transactionVolume!['data'] as List;
    final summary = state.transactionVolume!['summary'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Volume Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Transaction Summary Cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total Transactions',
                  value: NumberFormat.decimalPattern().format(summary['totalTransactions']),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Total Volume',
                  value: NumberFormat.compactCurrency(symbol: '\$').format(summary['totalVolume']),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Avg Daily Volume',
                  value: NumberFormat.compactCurrency(symbol: '\$').format(summary['avgDailyVolume']),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Growth Rate',
                  value: '+18.7%',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Transaction Volume Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Volume Trends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat.MMM(),
                      ),
                      primaryYAxis: NumericAxis(
                        numberFormat: NumberFormat.compactCurrency(symbol: '\$'),
                      ),
                      legend: const Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: [
                        ColumnSeries<Map<String, dynamic>, DateTime>(
                          name: 'Investment Volume',
                          dataSource: data.cast<Map<String, dynamic>>(),
                          xValueMapper: (datum, _) => DateTime.parse(datum['date']),
                          yValueMapper: (datum, _) => datum['investmentVolume'],
                          color: Colors.blue,
                        ),
                        ColumnSeries<Map<String, dynamic>, DateTime>(
                          name: 'Trade Volume',
                          dataSource: data.cast<Map<String, dynamic>>(),
                          xValueMapper: (datum, _) => DateTime.parse(datum['date']),
                          yValueMapper: (datum, _) => datum['tradeVolume'],
                          color: Colors.green,
                        ),
                        ColumnSeries<Map<String, dynamic>, DateTime>(
                          name: 'Distribution Volume',
                          dataSource: data.cast<Map<String, dynamic>>(),
                          xValueMapper: (datum, _) => DateTime.parse(datum['date']),
                          yValueMapper: (datum, _) => datum['distributionVolume'],
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Transaction Count Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Count Trends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat.MMM(),
                      ),
                      primaryYAxis: const NumericAxis(),
                      legend: const Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: [
                        LineSeries<Map<String, dynamic>, DateTime>(
                          name: 'Investments',
                          dataSource: data.cast<Map<String, dynamic>>(),
                          xValueMapper: (datum, _) => DateTime.parse(datum['date']),
                          yValueMapper: (datum, _) => datum['investments'],
                          color: Colors.blue,
                          width: 3,
                        ),
                        LineSeries<Map<String, dynamic>, DateTime>(
                          name: 'Trades',
                          dataSource: data.cast<Map<String, dynamic>>(),
                          xValueMapper: (datum, _) => DateTime.parse(datum['date']),
                          yValueMapper: (datum, _) => datum['trades'],
                          color: Colors.green,
                          width: 3,
                        ),
                        LineSeries<Map<String, dynamic>, DateTime>(
                          name: 'Distributions',
                          dataSource: data.cast<Map<String, dynamic>>(),
                          xValueMapper: (datum, _) => DateTime.parse(datum['date']),
                          yValueMapper: (datum, _) => datum['distributions'],
                          color: Colors.orange,
                          width: 3,
                        ),
                      ],
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
}

class _GeographicTab extends StatelessWidget {
  final AnalyticsState state;

  const _GeographicTab(this.state);

  @override
  Widget build(BuildContext context) {
    if (state.geographicData == null) {
      return const Center(child: Text('No geographic data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geographic Distribution',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // World Map
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Global Distribution Map',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: SfMaps(
                      layers: [
                        MapShapeLayer(
                          source: MapShapeSource.asset(
                            'assets/world_map.json',
                            shapeDataField: 'ISO2',
                          ),
                          dataSource: state.geographicData!.countries.map((country) => {
                            'ISO2': country.code,
                            'users': country.users,
                            'volume': country.volume,
                          }).toList(),
                          primaryValueMapper: (index) => state.geographicData!.countries[index].code,
                          dataLabelMapper: (index) => state.geographicData!.countries[index].country,
                          shapeColorValueMapper: (index) {
                            switch (state.geographicData!.metric) {
                              case 'volume':
                                return state.geographicData!.countries[index].volume;
                              case 'assets':
                                return state.geographicData!.countries[index].assets.toDouble();
                              default:
                                return state.geographicData!.countries[index].users.toDouble();
                            }
                          },
                          shapeColorMappers: const [
                            MapColorMapper(from: 0, to: 100, color: Colors.blue, minOpacity: 0.1, maxOpacity: 0.4),
                            MapColorMapper(from: 100, to: 500, color: Colors.blue, minOpacity: 0.4, maxOpacity: 0.6),
                            MapColorMapper(from: 500, to: 1000, color: Colors.blue, minOpacity: 0.6, maxOpacity: 0.8),
                            MapColorMapper(from: 1000, to: 5000, color: Colors.blue, minOpacity: 0.8, maxOpacity: 1.0),
                          ],
                          strokeColor: Colors.grey[300]!,
                          strokeWidth: 0.5,
                          showDataLabels: false,
                          tooltipSettings: const MapTooltipSettings(
                            color: Colors.black87,
                            strokeColor: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        MapShapeLayer(
                          source: MapShapeSource.asset(
                            'assets/world_map.json',
                            shapeDataField: 'ISO2',
                          ),
                          initialMarkersCount: state.geographicData!.countries.length,
                          markerBuilder: (context, index) {
                            final country = state.geographicData!.countries[index];
                            return MapMarker(
                              latitude: country.lat,
                              longitude: country.lng,
                              child: Container(
                                width: _getMarkerSize(country.users),
                                height: _getMarkerSize(country.users),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    country.users > 999 ? '${(country.users / 1000).toStringAsFixed(0)}K' : country.users.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: state.geographicData!.metric,
                        items: const [
                          DropdownMenuItem(value: 'users', child: Text('Users')),
                          DropdownMenuItem(value: 'assets', child: Text('Assets')),
                          DropdownMenuItem(value: 'volume', child: Text('Volume')),
                        ],
                        onChanged: (value) {
                          // TODO: Implement metric change
                        },
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.circle, color: Colors.blue, size: 12),
                      const SizedBox(width: 4),
                      const Text('Low Activity', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 20),
                      const Icon(Icons.circle, color: Colors.red, size: 12),
                      const SizedBox(width: 4),
                      const Text('User Concentration', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Country list
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Countries',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...state.geographicData!.countries.take(10).map((country) {
                    return ListTile(
                      leading: Text(
                        country.code,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      title: Text(country.country),
                      trailing: Text(
                        '${country.users} users',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMarkerSize(int users) {
    if (users > 2000) return 24.0;
    if (users > 1000) return 20.0;
    if (users > 500) return 16.0;
    if (users > 100) return 12.0;
    return 8.0;
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRevenueChart extends StatelessWidget {
  final RevenueAnalytics? data;

  const _QuickRevenueChart(this.data);

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data!.data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.total);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
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
}

class _AssetTypeDistribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 68.5,
                      title: '68.5%',
                      color: Colors.blue,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: 15.6,
                      title: '15.6%',
                      color: Colors.orange,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: 9.1,
                      title: '9.1%',
                      color: Colors.green,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: 6.8,
                      title: '6.8%',
                      color: Colors.purple,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
}