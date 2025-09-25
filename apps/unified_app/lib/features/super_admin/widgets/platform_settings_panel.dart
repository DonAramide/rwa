import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PlatformSettingsPanel extends ConsumerStatefulWidget {
  const PlatformSettingsPanel({super.key});

  @override
  ConsumerState<PlatformSettingsPanel> createState() => _PlatformSettingsPanelState();
}

class _PlatformSettingsPanelState extends ConsumerState<PlatformSettingsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _settingsTabController;

  final List<Tab> _settingsTabs = const [
    Tab(text: 'General'),
    Tab(text: 'Security'),
    Tab(text: 'Notifications'),
    Tab(text: 'API Settings'),
  ];

  // General Settings
  bool _maintenanceMode = false;
  bool _newRegistrations = true;
  bool _emailVerification = true;
  String _platformName = 'RWA Investment Platform';
  String _supportEmail = 'support@rwa-platform.com';

  // Security Settings
  bool _twoFactorRequired = false;
  bool _ipWhitelisting = false;
  int _sessionTimeout = 24;
  int _passwordMinLength = 8;
  bool _requireSpecialChars = true;

  // Notification Settings
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _alertsEnabled = true;

  // API Settings
  int _rateLimit = 1000;
  int _maxRequestSize = 10;
  bool _apiLogging = true;
  String _apiVersion = 'v1';

  @override
  void initState() {
    super.initState();
    _settingsTabController = TabController(length: _settingsTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _settingsTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.surface,
          child: Row(
            children: [
              Icon(Icons.settings, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Platform Settings',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _saveAllSettings,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save All Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Tab bar
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _settingsTabController,
            tabs: _settingsTabs,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _settingsTabController,
            children: [
              _buildGeneralSettings(),
              _buildSecuritySettings(),
              _buildNotificationSettings(),
              _buildApiSettings(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsSection(
            'Platform Information',
            [
              _buildTextFieldSetting(
                'Platform Name',
                _platformName,
                (value) => setState(() => _platformName = value),
                'The public name of your platform',
              ),
              _buildTextFieldSetting(
                'Support Email',
                _supportEmail,
                (value) => setState(() => _supportEmail = value),
                'Email address for user support queries',
              ),
            ],
          ),

          const SizedBox(height: 32),

          _buildSettingsSection(
            'Platform Access',
            [
              _buildSwitchSetting(
                'Maintenance Mode',
                'Temporarily disable platform access for maintenance',
                _maintenanceMode,
                (value) => setState(() => _maintenanceMode = value),
                isWarning: _maintenanceMode,
              ),
              _buildSwitchSetting(
                'Allow New Registrations',
                'Enable new user account creation',
                _newRegistrations,
                (value) => setState(() => _newRegistrations = value),
              ),
              _buildSwitchSetting(
                'Require Email Verification',
                'Users must verify email before accessing platform',
                _emailVerification,
                (value) => setState(() => _emailVerification = value),
              ),
            ],
          ),

          const SizedBox(height: 32),

          _buildSettingsSection(
            'Regional Settings',
            [
              _buildDropdownSetting(
                'Default Currency',
                'USD',
                ['USD', 'EUR', 'GBP', 'JPY', 'CAD'],
                (value) => {},
              ),
              _buildDropdownSetting(
                'Default Timezone',
                'UTC',
                ['UTC', 'EST', 'PST', 'GMT', 'CET'],
                (value) => {},
              ),
              _buildDropdownSetting(
                'Date Format',
                'MM/DD/YYYY',
                ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
                (value) => {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsSection(
            'Authentication',
            [
              _buildSwitchSetting(
                'Require Two-Factor Authentication',
                'All users must enable 2FA to access platform',
                _twoFactorRequired,
                (value) => setState(() => _twoFactorRequired = value),
              ),
              _buildNumberFieldSetting(
                'Session Timeout (hours)',
                _sessionTimeout,
                (value) => setState(() => _sessionTimeout = value),
                'Auto-logout users after this period of inactivity',
              ),
            ],
          ),

          const SizedBox(height: 32),

          _buildSettingsSection(
            'Password Policy',
            [
              _buildNumberFieldSetting(
                'Minimum Password Length',
                _passwordMinLength,
                (value) => setState(() => _passwordMinLength = value),
                'Minimum number of characters required',
              ),
              _buildSwitchSetting(
                'Require Special Characters',
                'Passwords must contain special characters',
                _requireSpecialChars,
                (value) => setState(() => _requireSpecialChars = value),
              ),
            ],
          ),

          const SizedBox(height: 32),

          _buildSettingsSection(
            'Access Control',
            [
              _buildSwitchSetting(
                'IP Whitelisting',
                'Restrict access to specific IP addresses',
                _ipWhitelisting,
                (value) => setState(() => _ipWhitelisting = value),
              ),
              if (_ipWhitelisting) ...[
                const SizedBox(height: 16),
                _buildTextAreaSetting(
                  'Allowed IP Addresses',
                  '192.168.1.0/24\n10.0.0.0/8',
                  (value) => {},
                  'Enter IP addresses or CIDR blocks, one per line',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsSection(
            'Global Notifications',
            [
              _buildSwitchSetting(
                'Email Notifications',
                'Send notifications via email',
                _emailNotifications,
                (value) => setState(() => _emailNotifications = value),
              ),
              _buildSwitchSetting(
                'SMS Notifications',
                'Send notifications via SMS',
                _smsNotifications,
                (value) => setState(() => _smsNotifications = value),
              ),
              _buildSwitchSetting(
                'Push Notifications',
                'Send push notifications to mobile apps',
                _pushNotifications,
                (value) => setState(() => _pushNotifications = value),
              ),
            ],
          ),

          const SizedBox(height: 32),

          _buildSettingsSection(
            'Alert Settings',
            [
              _buildSwitchSetting(
                'System Alerts Enabled',
                'Generate alerts for system events',
                _alertsEnabled,
                (value) => setState(() => _alertsEnabled = value),
              ),
            ],
          ),

          const SizedBox(height: 32),

          _buildSettingsSection(
            'Email Templates',
            [
              _buildActionSetting(
                'Welcome Email',
                'Configure the email sent to new users',
                'Edit Template',
                () => _editEmailTemplate('welcome'),
              ),
              _buildActionSetting(
                'Password Reset Email',
                'Configure the password reset email template',
                'Edit Template',
                () => _editEmailTemplate('password_reset'),
              ),
              _buildActionSetting(
                'Transaction Confirmation',
                'Configure transaction confirmation emails',
                'Edit Template',
                () => _editEmailTemplate('transaction'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApiSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsSection(
            'API Configuration',
            [
              _buildTextFieldSetting(
                'API Version',
                _apiVersion,
                (value) => setState(() => _apiVersion = value),
                'Current API version',
                readOnly: true,
              ),
              _buildNumberFieldSetting(
                'Rate Limit (requests/hour)',
                _rateLimit,
                (value) => setState(() => _rateLimit = value),
                'Maximum requests per hour per API key',
              ),
              _buildNumberFieldSetting(
                'Max Request Size (MB)',
                _maxRequestSize,
                (value) => setState(() => _maxRequestSize = value),
                'Maximum size for API requests',
              ),
            ],
          ),

          const SizedBox(height: 32),

          _buildSettingsSection(
            'API Monitoring',
            [
              _buildSwitchSetting(
                'API Request Logging',
                'Log all API requests for monitoring',
                _apiLogging,
                (value) => setState(() => _apiLogging = value),
              ),
            ],
          ),

          const SizedBox(height: 32),

          _buildSettingsSection(
            'API Keys Management',
            [
              _buildActionSetting(
                'Generate Master API Key',
                'Create a new master API key for super admin access',
                'Generate Key',
                () => _generateMasterApiKey(),
              ),
              _buildActionSetting(
                'Revoke All API Keys',
                'Immediately revoke all active API keys (requires regeneration)',
                'Revoke All',
                () => _revokeAllApiKeys(),
                isDangerous: true,
              ),
            ],
          ),

          const SizedBox(height: 32),

          _buildSettingsSection(
            'Webhooks',
            [
              _buildActionSetting(
                'Configure Webhooks',
                'Set up webhooks for external integrations',
                'Manage Webhooks',
                () => _manageWebhooks(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: isWarning && value ? AppColors.warning : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isWarning && value ? AppColors.warning : AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSetting(
    String title,
    String value,
    ValueChanged<String> onChanged,
    String description, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: description,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: readOnly ? AppColors.textSecondary.withOpacity(0.1) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberFieldSetting(
    String title,
    int value,
    ValueChanged<int> onChanged,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final intVal = int.tryParse(val);
              if (intVal != null) onChanged(intVal);
            },
            decoration: InputDecoration(
              hintText: description,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaSetting(
    String title,
    String value,
    ValueChanged<String> onChanged,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: description,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting<T>(
    String title,
    T value,
    List<T> options,
    ValueChanged<T?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option.toString()),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSetting(
    String title,
    String description,
    String buttonText,
    VoidCallback onPressed, {
    bool isDangerous = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDangerous ? AppColors.error : AppColors.primary,
              side: BorderSide(
                color: isDangerous ? AppColors.error : AppColors.primary,
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void _saveAllSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Platform settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editEmailTemplate(String templateType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Edit Email Template',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: 500,
          child: TextFormField(
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Enter email template HTML...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
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
                const SnackBar(content: Text('Email template updated')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save Template', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _generateMasterApiKey() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Generate Master API Key',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will generate a new master API key with full platform access. Store it securely as it cannot be retrieved again.',
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
              _showGeneratedApiKey();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Generate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showGeneratedApiKey() {
    const mockApiKey = 'sk_test_your_stripe_test_key_here';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Master API Key Generated',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your new master API key:',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
              ),
              child: SelectableText(
                mockApiKey,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please store this key securely. It will not be shown again.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('I\'ve Saved It', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _revokeAllApiKeys() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Revoke All API Keys',
          style: AppTextStyles.heading3.copyWith(color: AppColors.error),
        ),
        content: Text(
          'This will immediately revoke ALL active API keys. All API access will be disabled until new keys are generated. This action cannot be undone.',
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
                const SnackBar(
                  content: Text('All API keys have been revoked'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Revoke All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _manageWebhooks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Webhook management feature coming soon')),
    );
  }
}