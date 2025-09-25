import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/api_key.dart';
import '../../providers/api_key_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ApiKeyManagementScreen extends ConsumerStatefulWidget {
  const ApiKeyManagementScreen({super.key});

  @override
  ConsumerState<ApiKeyManagementScreen> createState() => _ApiKeyManagementScreenState();
}

class _ApiKeyManagementScreenState extends ConsumerState<ApiKeyManagementScreen> {
  String? _selectedApiKeyId;
  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    final apiKeyState = ref.watch(apiKeyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('API Key Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() {
              _showCreateForm = true;
            }),
            tooltip: 'Add API Key',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(apiKeyProvider.notifier).loadApiKeys(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: apiKeyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : apiKeyState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${apiKeyState.error}',
                        style: AppTextStyles.body1.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(apiKeyProvider.notifier).loadApiKeys(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _showCreateForm
                  ? _buildCreateApiKeyForm()
                  : _buildApiKeyList(apiKeyState.apiKeys),
    );
  }

  Widget _buildApiKeyList(List<ApiKey> apiKeys) {
    if (apiKeys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vpn_key_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No API Keys',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first API key to get started',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _showCreateForm = true;
              }),
              icon: const Icon(Icons.add),
              label: const Text('Create API Key'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apiKeys.length,
      itemBuilder: (context, index) {
        final apiKey = apiKeys[index];
        return _buildApiKeyCard(apiKey);
      },
    );
  }

  Widget _buildApiKeyCard(ApiKey apiKey) {
    final isSelected = _selectedApiKeyId == apiKey.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: apiKey.isActive
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: apiKey.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          child: Text(
                            apiKey.isActive ? 'Active' : 'Inactive',
                            style: AppTextStyles.caption.copyWith(
                              color: apiKey.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      apiKey.service.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (apiKey.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        apiKey.description!,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleApiKeyAction(value, apiKey),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(Icons.toggle_on, size: 16),
                        SizedBox(width: 8),
                        Text('Toggle Status'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logs',
                    child: Row(
                      children: [
                        Icon(Icons.list_alt, size: 16),
                        SizedBox(width: 8),
                        Text('View Logs'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    apiKey.maskedKey,
                    style: AppTextStyles.body2.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () => _copyApiKey(apiKey.key),
                  tooltip: 'Copy API Key',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...apiKey.permissions.map((permission) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      permission,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Created: ${_formatDate(apiKey.createdAt)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (apiKey.lastUsed != null)
                Text(
                  'Last used: ${_formatDate(apiKey.lastUsed!)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          if (isSelected) ...[
            const SizedBox(height: 16),
            _buildApiKeyLogs(apiKey.id),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildApiKeyLogs(String apiKeyId) {
    final callLogs = ref.watch(apiKeyProvider).callLogs;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16),
              const SizedBox(width: 8),
              Text(
                'Recent API Calls',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (callLogs.isEmpty)
            Text(
              'No recent API calls',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...callLogs.take(5).map((log) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: log.statusCode >= 200 && log.statusCode < 300
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${log.method} ${log.endpoint}',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      Text(
                        '${log.statusCode}',
                        style: AppTextStyles.caption.copyWith(
                          color: log.statusCode >= 200 && log.statusCode < 300
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${log.responseTime.toStringAsFixed(1)}ms',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildCreateApiKeyForm() {
    final nameController = TextEditingController();
    final keyController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedService = 'custom';
    List<String> selectedPermissions = [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Create New API Key',
                  style: AppTextStyles.heading2,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _showCreateForm = false;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'API Key Name',
                hintText: 'Enter a descriptive name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedService,
              decoration: const InputDecoration(
                labelText: 'Service',
                border: OutlineInputBorder(),
              ),
              items: ApiKeyService.values.map((service) {
                return DropdownMenuItem(
                  value: service.value,
                  child: Text(service.displayName),
                );
              }).toList(),
              onChanged: (value) {
                selectedService = value ?? 'custom';
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter the API key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter a description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Permissions',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getPermissionsForService(selectedService).map((permission) {
                final isSelected = selectedPermissions.contains(permission);
                return FilterChip(
                  selected: isSelected,
                  label: Text(permission),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedPermissions.add(permission);
                      } else {
                        selectedPermissions.remove(permission);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _showCreateForm = false;
                    }),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _createApiKey(
                      nameController.text,
                      selectedService,
                      keyController.text,
                      descriptionController.text,
                      selectedPermissions,
                    ),
                    child: const Text('Create API Key'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  List<String> _getPermissionsForService(String service) {
    switch (service) {
      case 'google_maps':
        return ['maps', 'geocoding', 'places', 'directions'];
      case 'stripe':
        return ['payments', 'refunds', 'customers', 'subscriptions'];
      case 'twilio':
        return ['sms', 'voice', 'video', 'chat'];
      case 'sendgrid':
        return ['email', 'templates', 'marketing', 'transactional'];
      case 'firebase':
        return ['auth', 'firestore', 'storage', 'messaging'];
      case 'aws':
        return ['s3', 'lambda', 'ec2', 'rds', 'sns'];
      default:
        return ['read', 'write', 'admin', 'execute'];
    }
  }

  void _handleApiKeyAction(String action, ApiKey apiKey) {
    switch (action) {
      case 'edit':
        _editApiKey(apiKey);
        break;
      case 'toggle':
        _toggleApiKey(apiKey);
        break;
      case 'logs':
        _viewApiKeyLogs(apiKey);
        break;
      case 'delete':
        _deleteApiKey(apiKey);
        break;
    }
  }

  void _editApiKey(ApiKey apiKey) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  void _toggleApiKey(ApiKey apiKey) {
    ref.read(apiKeyProvider.notifier).updateApiKey(
          apiKey.id,
          {'isActive': !apiKey.isActive},
        );
  }

  void _viewApiKeyLogs(ApiKey apiKey) {
    setState(() {
      _selectedApiKeyId = _selectedApiKeyId == apiKey.id ? null : apiKey.id;
    });

    if (_selectedApiKeyId == apiKey.id) {
      ref.read(apiKeyProvider.notifier).loadApiCallLogs(apiKey.id);
    }
  }

  void _deleteApiKey(ApiKey apiKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete API Key'),
        content: Text('Are you sure you want to delete "${apiKey.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(apiKeyProvider.notifier).deleteApiKey(apiKey.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _createApiKey(
    String name,
    String service,
    String key,
    String description,
    List<String> permissions,
  ) {
    if (name.isEmpty || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    ref.read(apiKeyProvider.notifier).createApiKey(
          name: name,
          service: service,
          key: key,
          description: description.isEmpty ? null : description,
          permissions: permissions,
        );

    setState(() {
      _showCreateForm = false;
    });
  }

  void _copyApiKey(String apiKey) {
    Clipboard.setData(ClipboardData(text: apiKey));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key copied to clipboard')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}