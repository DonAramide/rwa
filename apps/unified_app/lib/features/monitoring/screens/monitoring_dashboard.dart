import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flag.dart';
import '../models/iot_device.dart';
import '../providers/monitoring_provider.dart';
import '../providers/iot_provider.dart';
import '../widgets/flag_card.dart';
import '../widgets/create_flag_dialog.dart';
import '../widgets/investor_agent_stats_card.dart';
import '../widgets/leaderboard_card.dart';
import '../widgets/iot_metrics_card.dart';
import '../widgets/iot_device_card.dart';

class MonitoringDashboard extends ConsumerStatefulWidget {
  const MonitoringDashboard({super.key});

  @override
  ConsumerState<MonitoringDashboard> createState() => _MonitoringDashboardState();
}

class _MonitoringDashboardState extends ConsumerState<MonitoringDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FlagStatus? _selectedStatus;
  FlagType? _selectedType;
  FlagSeverity? _selectedSeverity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(iotDevicesProvider.notifier).loadDevices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () => _showCreateFlagDialog(context),
            tooltip: 'Create Flag',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(flagsProvider),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Flags', icon: Icon(Icons.flag_outlined)),
            Tab(text: 'My Flags', icon: Icon(Icons.person_flag)),
            Tab(text: 'IoT Devices', icon: Icon(Icons.sensors)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllFlagsTab(),
          _buildMyFlagsTab(),
          _buildIoTDevicesTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildAllFlagsTab() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _buildFlagsList(
            provider: flagsProvider(FlagFilters(
              status: _selectedStatus,
              type: _selectedType,
              severity: _selectedSeverity,
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildMyFlagsTab() {
    return _buildFlagsList(
      provider: myFlagsProvider(const PaginationParams()),
    );
  }

  Widget _buildIoTDevicesTab() {
    return Column(
      children: [
        const IoTMetricsCard(),
        const SizedBox(height: 16),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final iotState = ref.watch(iotDevicesProvider);

              if (iotState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (iotState.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${iotState.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(iotDevicesProvider.notifier).loadDevices(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (iotState.devices.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sensors_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No IoT devices found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Connect devices to monitor your assets',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: iotState.devices.length,
                itemBuilder: (context, index) {
                  final device = iotState.devices[index];
                  return IoTDeviceCard(device: device);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InvestorAgentStatsCard(),
          const SizedBox(height: 24),
          const LeaderboardCard(),
          const SizedBox(height: 24),
          _buildTrendingFlags(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildStatusFilter(),
          _buildTypeFilter(),
          _buildSeverityFilter(),
          if (_hasActiveFilters())
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButton<FlagStatus?>(
      value: _selectedStatus,
      hint: const Text('Status'),
      onChanged: (value) => setState(() => _selectedStatus = value),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Statuses')),
        ...FlagStatus.values.map((status) => DropdownMenuItem(
              value: status,
              child: Text(status.name),
            )),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return DropdownButton<FlagType?>(
      value: _selectedType,
      hint: const Text('Type'),
      onChanged: (value) => setState(() => _selectedType = value),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Types')),
        ...FlagType.values.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type.name),
            )),
      ],
    );
  }

  Widget _buildSeverityFilter() {
    return DropdownButton<FlagSeverity?>(
      value: _selectedSeverity,
      hint: const Text('Severity'),
      onChanged: (value) => setState(() => _selectedSeverity = value),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Severities')),
        ...FlagSeverity.values.map((severity) => DropdownMenuItem(
              value: severity,
              child: Text(severity.name),
            )),
      ],
    );
  }

  bool _hasActiveFilters() {
    return _selectedStatus != null || _selectedType != null || _selectedSeverity != null;
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedType = null;
      _selectedSeverity = null;
    });
  }

  Widget _buildFlagsList({required ProviderBase provider}) {
    return Consumer(
      builder: (context, ref, child) {
        final flagsAsync = ref.watch(provider);

        return flagsAsync.when(
          data: (flagResponse) {
            if (flagResponse.flags.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flag_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No flags found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: flagResponse.flags.length,
              itemBuilder: (context, index) {
                final flag = flagResponse.flags[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FlagCard(flag: flag),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(provider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendingFlags() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trending Flags',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final escalatedAsync = ref.watch(escalatedFlagsProvider);

                return escalatedAsync.when(
                  data: (flagResponse) {
                    if (flagResponse.flags.isEmpty) {
                      return const Text('No escalated flags currently.');
                    }

                    return Column(
                      children: flagResponse.flags.take(3).map((flag) {
                        return ListTile(
                          leading: Icon(
                            Icons.trending_up,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(flag.title),
                          subtitle: Text('${flag.upvotes} upvotes'),
                          trailing: Chip(
                            label: Text(flag.severityDisplayName),
                            backgroundColor: _getSeverityColor(flag.severity),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error loading trending flags: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(FlagSeverity severity) {
    switch (severity) {
      case FlagSeverity.low:
        return Colors.green.shade100;
      case FlagSeverity.medium:
        return Colors.orange.shade100;
      case FlagSeverity.high:
        return Colors.red.shade100;
      case FlagSeverity.critical:
        return Colors.red.shade300;
    }
  }

  void _showCreateFlagDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateFlagDialog(),
    );
  }
}