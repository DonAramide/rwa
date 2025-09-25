import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/api_key.dart';
import '../../../providers/api_key_provider.dart';

class SuperAdminApiKeys extends ConsumerStatefulWidget {
  const SuperAdminApiKeys({super.key});

  @override
  ConsumerState<SuperAdminApiKeys> createState() => _SuperAdminApiKeysState();
}

class _SuperAdminApiKeysState extends ConsumerState<SuperAdminApiKeys>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedService = 'All';

  final List<Tab> _tabs = [
    const Tab(text: 'Active Keys', icon: Icon(Icons.key)),
    const Tab(text: 'Usage Analytics', icon: Icon(Icons.analytics)),
    const Tab(text: 'Security Logs', icon: Icon(Icons.security)),
    const Tab(text: 'Rate Limits', icon: Icon(Icons.speed)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(apiKeyProvider.notifier).loadApiKeys();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyState = ref.watch(apiKeyProvider);

    return Column(
      children: [
        _buildApiKeyHeader(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveKeysTab(apiKeyState),
              _buildUsageAnalyticsTab(apiKeyState),
              _buildSecurityLogsTab(apiKeyState),
              _buildRateLimitsTab(apiKeyState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              Icon(Icons.key, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'API Key Management & Security',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showCreateApiKeyDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Generate New Key'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: _tabs,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveKeysTab(apiKeyState) {
    return Column(
      children: [
        _buildFiltersSection(),
        Expanded(child: _buildApiKeysGrid(apiKeyState)),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search API keys...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ['All', 'Active', 'Inactive', 'Expired', 'Revoked']
                  .map((filter) => DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: const InputDecoration(
                labelText: 'Service',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ['All', 'Internal API', 'External API', 'Webhook', 'Mobile', 'Web']
                  .map((service) => DropdownMenuItem(
                        value: service,
                        child: Text(service),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedService = value!);
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeysGrid(apiKeyState) {
    if (apiKeyState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (apiKeyState.apiKeys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.key_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No API keys found',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first API key to get started',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateApiKeyDialog,
              icon: const Icon(Icons.add),
              label: const Text('Generate API Key'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apiKeyState.apiKeys.length,
      itemBuilder: (context, index) => _buildApiKeyCard(apiKeyState.apiKeys[index]),
    );
  }

  Widget _buildApiKeyCard(ApiKey apiKey) {
    final statusColor = _getStatusColor(apiKey);
    final isExpiringSoon = _isExpiringSoon(apiKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpiringSoon ? AppColors.warning.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          width: isExpiringSoon ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            apiKey.name,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              apiKey.isActive ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isExpiringSoon) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'EXPIRES SOON',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        apiKey.description ?? 'No description',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleApiKeyAction(value, apiKey),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'regenerate', child: Text('Regenerate')),
                    const PopupMenuItem(value: 'logs', child: Text('View Logs')),
                    PopupMenuItem(
                      value: apiKey.isActive ? 'deactivate' : 'activate',
                      child: Text(apiKey.isActive ? 'Deactivate' : 'Activate'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      apiKey.maskedKey,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(apiKey.key),
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip('Service', apiKey.service),
                const SizedBox(width: 12),
                _buildInfoChip('Usage', '${apiKey.usageCount ?? 0} calls'),
                const SizedBox(width: 12),
                _buildInfoChip(
                  'Created',
                  _formatDate(apiKey.createdAt),
                ),
              ],
            ),
            if (apiKey.lastUsed != null || apiKey.expiresAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (apiKey.lastUsed != null) ...[
                    _buildInfoChip('Last Used', _formatDate(apiKey.lastUsed!)),
                    const SizedBox(width: 12),
                  ],
                  if (apiKey.expiresAt != null)
                    _buildInfoChip(
                      'Expires',
                      _formatDate(apiKey.expiresAt!),
                      color: isExpiringSoon ? AppColors.warning : null,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: apiKey.permissions.map((permission) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    permission,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textSecondary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color ?? AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUsageAnalyticsTab(apiKeyState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUsageMetrics(),
          const SizedBox(height: 24),
          _buildUsageChart(),
          const SizedBox(height: 24),
          _buildTopEndpoints(),
        ],
      ),
    );
  }

  Widget _buildUsageMetrics() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildMetricCard('Total Requests', '142,567', Icons.call_made, AppColors.primary, '+8.2%'),
        _buildMetricCard('Unique Keys', '23', Icons.key, AppColors.success, '+2'),
        _buildMetricCard('Error Rate', '0.8%', Icons.error_outline, AppColors.error, '-0.3%'),
        _buildMetricCard('Avg Response', '120ms', Icons.speed, AppColors.warning, '-15ms'),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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

  Widget _buildUsageChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API Usage Over Time',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text(
                'Usage Chart Placeholder\n(Chart implementation would go here)',
                textAlign: TextAlign.center,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopEndpoints() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Top API Endpoints',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              final endpoints = [
                {'endpoint': '/api/v1/assets', 'calls': '45,234', 'percentage': '32%'},
                {'endpoint': '/api/v1/banks', 'calls': '23,456', 'percentage': '16%'},
                {'endpoint': '/api/v1/users', 'calls': '18,765', 'percentage': '13%'},
                {'endpoint': '/api/v1/transactions', 'calls': '15,432', 'percentage': '11%'},
                {'endpoint': '/api/v1/auth', 'calls': '12,890', 'percentage': '9%'},
              ];
              final endpoint = endpoints[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  endpoint['endpoint']!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      endpoint['calls']!,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      endpoint['percentage']!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityLogsTab(apiKeyState) {
    return const Center(
      child: Text('Security Logs - Coming Soon'),
    );
  }

  Widget _buildRateLimitsTab(apiKeyState) {
    return const Center(
      child: Text('Rate Limits Management - Coming Soon'),
    );
  }

  void _showCreateApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateApiKeyDialog(),
    );
  }

  void _handleApiKeyAction(String action, ApiKey apiKey) {
    switch (action) {
      case 'edit':
        _showEditApiKeyDialog(apiKey);
        break;
      case 'regenerate':
        _regenerateApiKey(apiKey);
        break;
      case 'logs':
        _showApiKeyLogs(apiKey);
        break;
      case 'activate':
      case 'deactivate':
        _toggleApiKey(apiKey);
        break;
      case 'delete':
        _deleteApiKey(apiKey);
        break;
    }
  }

  void _showEditApiKeyDialog(ApiKey apiKey) {
    // Implementation for edit dialog
  }

  void _regenerateApiKey(ApiKey apiKey) {
    // Implementation for regenerate
  }

  void _showApiKeyLogs(ApiKey apiKey) {
    // Implementation for showing logs
  }

  void _toggleApiKey(ApiKey apiKey) {
    ref.read(apiKeyProvider.notifier).toggleApiKey(apiKey.id);
  }

  void _deleteApiKey(ApiKey apiKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete API Key'),
        content: Text('Are you sure you want to delete "${apiKey.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(apiKeyProvider.notifier).deleteApiKey(apiKey.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('API key copied to clipboard'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _applyFilters() {
    // Implementation for applying filters
  }

  Color _getStatusColor(ApiKey apiKey) {
    if (!apiKey.isActive) return AppColors.error;
    if (_isExpiringSoon(apiKey)) return AppColors.warning;
    return AppColors.success;
  }

  bool _isExpiringSoon(ApiKey apiKey) {
    if (apiKey.expiresAt == null) return false;
    final daysUntilExpiry = apiKey.expiresAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class CreateApiKeyDialog extends StatefulWidget {
  const CreateApiKeyDialog({super.key});

  @override
  State<CreateApiKeyDialog> createState() => _CreateApiKeyDialogState();
}

class _CreateApiKeyDialogState extends State<CreateApiKeyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedService = 'Internal API';
  ApiKeyType _selectedType = ApiKeyType.readWrite;
  ApiKeyScope _selectedScope = ApiKeyScope.bankAdmin;
  DateTime? _expirationDate;
  List<String> _selectedPermissions = [];

  final List<String> _availablePermissions = [
    'read:assets',
    'write:assets',
    'read:users',
    'write:users',
    'read:banks',
    'write:banks',
    'read:transactions',
    'write:transactions',
    'admin:all',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.key, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Generate New API Key',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'API Key Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedService,
                          decoration: const InputDecoration(
                            labelText: 'Service',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Internal API', 'External API', 'Webhook', 'Mobile', 'Web']
                              .map((service) => DropdownMenuItem(
                                    value: service,
                                    child: Text(service),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedService = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<ApiKeyType>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Access Type',
                            border: OutlineInputBorder(),
                          ),
                          items: ApiKeyType.values
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name.toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedType = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ApiKeyScope>(
                    value: _selectedScope,
                    decoration: const InputDecoration(
                      labelText: 'Access Scope',
                      border: OutlineInputBorder(),
                    ),
                    items: ApiKeyScope.values
                        .map((scope) => DropdownMenuItem(
                              value: scope,
                              child: Text(scope.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedScope = value!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Expiration Date (Optional):',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _selectExpirationDate,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _expirationDate != null
                              ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                              : 'Select Date',
                        ),
                      ),
                      if (_expirationDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setState(() => _expirationDate = null),
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear date',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permissions:',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availablePermissions.map((permission) {
                          final isSelected = _selectedPermissions.contains(permission);
                          return FilterChip(
                            label: Text(permission),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedPermissions.add(permission);
                                } else {
                                  _selectedPermissions.remove(permission);
                                }
                              });
                            },
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _createApiKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Generate API Key'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  void _createApiKey() {
    if (_formKey.currentState?.validate() == true) {
      // Implementation for creating API key
      Navigator.pop(context);
    }
  }
}