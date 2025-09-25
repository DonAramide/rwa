import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/super_admin_provider.dart';

enum AuditLogLevel { info, warning, error, critical }
enum AuditLogCategory { user, bank, asset, transaction, system, security }

class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final AuditLogLevel level;
  final AuditLogCategory category;
  final String action;
  final String userId;
  final String userName;
  final String userRole;
  final String? entityId;
  final String? entityType;
  final Map<String, dynamic> details;
  final String? ipAddress;
  final String? userAgent;
  final String? location;

  AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.category,
    required this.action,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.entityId,
    this.entityType,
    required this.details,
    this.ipAddress,
    this.userAgent,
    this.location,
  });
}

class AuditLogViewer extends ConsumerStatefulWidget {
  const AuditLogViewer({super.key});

  @override
  ConsumerState<AuditLogViewer> createState() => _AuditLogViewerState();
}

class _AuditLogViewerState extends ConsumerState<AuditLogViewer> {
  final TextEditingController _searchController = TextEditingController();
  AuditLogLevel? _selectedLevel;
  AuditLogCategory? _selectedCategory;
  String? _selectedUser;
  DateTimeRange? _selectedDateRange;
  List<AuditLogEntry> _filteredLogs = [];
  List<AuditLogEntry> _allLogs = [];
  bool _autoRefresh = true;
  int _refreshInterval = 30; // seconds

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );
    _loadAuditLogs();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAuditLogs() {
    // Generate sample audit log data
    _allLogs = _generateSampleAuditLogs();
    _applyFilters();
    // Delay provider call to avoid build-time modification
    Future.microtask(() {
      ref.read(superAdminProvider.notifier).loadAuditLogs();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        // Date range filter
        if (_selectedDateRange != null) {
          if (log.timestamp.isBefore(_selectedDateRange!.start) ||
              log.timestamp.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }

        // Level filter
        if (_selectedLevel != null && log.level != _selectedLevel) {
          return false;
        }

        // Category filter
        if (_selectedCategory != null && log.category != _selectedCategory) {
          return false;
        }

        // User filter
        if (_selectedUser != null && _selectedUser!.isNotEmpty && log.userName != _selectedUser) {
          return false;
        }

        // Search filter
        if (_searchController.text.isNotEmpty) {
          final searchTerm = _searchController.text.toLowerCase();
          if (!log.action.toLowerCase().contains(searchTerm) &&
              !log.userName.toLowerCase().contains(searchTerm) &&
              !log.details.toString().toLowerCase().contains(searchTerm)) {
            return false;
          }
        }

        return true;
      }).toList();

      // Sort by timestamp (newest first)
      _filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  void _startAutoRefresh() {
    if (_autoRefresh) {
      Future.delayed(Duration(seconds: _refreshInterval), () {
        if (mounted && _autoRefresh) {
          _loadAuditLogs();
          _startAutoRefresh();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAuditLogHeader(),
        _buildFiltersPanel(),
        Expanded(child: _buildAuditLogsList()),
      ],
    );
  }

  Widget _buildAuditLogHeader() {
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
      child: Row(
        children: [
          Icon(Icons.history, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            'Audit Logs & Activity Tracking',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '${_filteredLogs.length} entries',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: _autoRefresh,
            onChanged: (value) {
              setState(() {
                _autoRefresh = value;
                if (value) _startAutoRefresh();
              });
            },
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Auto Refresh',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<AuditLogLevel?>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Level',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Levels')),
                    ...AuditLogLevel.values.map((level) => DropdownMenuItem(
                      value: level,
                      child: Row(
                        children: [
                          Icon(_getLevelIcon(level), color: _getLevelColor(level), size: 16),
                          const SizedBox(width: 8),
                          Text(_getLevelName(level)),
                        ],
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedLevel = value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<AuditLogCategory?>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                    ...AuditLogCategory.values.map((category) => DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(category), size: 16),
                          const SizedBox(width: 8),
                          Text(_getCategoryName(category)),
                        ],
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _selectedDateRange != null
                        ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'
                        : 'Select Date Range',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _exportLogs,
                icon: const Icon(Icons.download),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsList() {
    if (_filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No audit logs found',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or date range',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) => _buildAuditLogItem(_filteredLogs[index]),
    );
  }

  Widget _buildAuditLogItem(AuditLogEntry log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getLevelColor(log.level).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getLevelColor(log.level).withOpacity(0.1),
          child: Icon(
            _getLevelIcon(log.level),
            color: _getLevelColor(log.level),
            size: 18,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.action,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getCategoryColor(log.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getCategoryName(log.category),
                style: TextStyle(
                  color: _getCategoryColor(log.category),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${log.userName} (${log.userRole})',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(log.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('User ID', log.userId),
                _buildDetailRow('IP Address', log.ipAddress ?? 'Unknown'),
                _buildDetailRow('Location', log.location ?? 'Unknown'),
                if (log.entityId != null && log.entityType != null) ...[
                  _buildDetailRow('Entity Type', log.entityType!),
                  _buildDetailRow('Entity ID', log.entityId!),
                ],
                if (log.userAgent != null)
                  _buildDetailRow('User Agent', log.userAgent!),
                const SizedBox(height: 8),
                Text(
                  'Details:',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Text(
                    _formatDetails(log.details),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDetails(Map<String, dynamic> details) {
    final buffer = StringBuffer();
    details.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString().trim();
  }

  IconData _getLevelIcon(AuditLogLevel level) {
    switch (level) {
      case AuditLogLevel.info:
        return Icons.info_outline;
      case AuditLogLevel.warning:
        return Icons.warning_outlined;
      case AuditLogLevel.error:
        return Icons.error_outline;
      case AuditLogLevel.critical:
        return Icons.dangerous_outlined;
    }
  }

  Color _getLevelColor(AuditLogLevel level) {
    switch (level) {
      case AuditLogLevel.info:
        return AppColors.info;
      case AuditLogLevel.warning:
        return AppColors.warning;
      case AuditLogLevel.error:
        return AppColors.error;
      case AuditLogLevel.critical:
        return Colors.red[800]!;
    }
  }

  String _getLevelName(AuditLogLevel level) {
    return level.name.toUpperCase();
  }

  IconData _getCategoryIcon(AuditLogCategory category) {
    switch (category) {
      case AuditLogCategory.user:
        return Icons.person;
      case AuditLogCategory.bank:
        return Icons.account_balance;
      case AuditLogCategory.asset:
        return Icons.real_estate_agent;
      case AuditLogCategory.transaction:
        return Icons.receipt_long;
      case AuditLogCategory.system:
        return Icons.settings;
      case AuditLogCategory.security:
        return Icons.security;
    }
  }

  Color _getCategoryColor(AuditLogCategory category) {
    switch (category) {
      case AuditLogCategory.user:
        return AppColors.info;
      case AuditLogCategory.bank:
        return AppColors.primary;
      case AuditLogCategory.asset:
        return AppColors.success;
      case AuditLogCategory.transaction:
        return AppColors.warning;
      case AuditLogCategory.system:
        return Colors.purple;
      case AuditLogCategory.security:
        return AppColors.error;
    }
  }

  String _getCategoryName(AuditLogCategory category) {
    return category.name.toUpperCase();
  }

  List<AuditLogEntry> _generateSampleAuditLogs() {
    final now = DateTime.now();
    return [
      AuditLogEntry(
        id: '1',
        timestamp: now.subtract(const Duration(minutes: 5)),
        level: AuditLogLevel.info,
        category: AuditLogCategory.user,
        action: 'User Login',
        userId: 'user123',
        userName: 'John Doe',
        userRole: 'InvestorAgent',
        details: {'success': true, 'method': 'email_password'},
        ipAddress: '192.168.1.100',
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        location: 'Lagos, Nigeria',
      ),
      AuditLogEntry(
        id: '2',
        timestamp: now.subtract(const Duration(minutes: 15)),
        level: AuditLogLevel.warning,
        category: AuditLogCategory.security,
        action: 'Failed Login Attempt',
        userId: 'unknown',
        userName: 'Anonymous',
        userRole: 'Unknown',
        details: {'attempts': 3, 'reason': 'invalid_credentials'},
        ipAddress: '192.168.1.50',
        location: 'Unknown',
      ),
      AuditLogEntry(
        id: '3',
        timestamp: now.subtract(const Duration(hours: 1)),
        level: AuditLogLevel.info,
        category: AuditLogCategory.bank,
        action: 'Bank Registration',
        userId: 'admin456',
        userName: 'Admin User',
        userRole: 'SuperAdmin',
        entityId: 'bank789',
        entityType: 'Bank',
        details: {'bank_name': 'First National Bank', 'status': 'approved'},
        ipAddress: '10.0.0.1',
        userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
        location: 'Abuja, Nigeria',
      ),
      AuditLogEntry(
        id: '4',
        timestamp: now.subtract(const Duration(hours: 2)),
        level: AuditLogLevel.error,
        category: AuditLogCategory.system,
        action: 'Database Connection Failed',
        userId: 'system',
        userName: 'System',
        userRole: 'System',
        details: {'error': 'Connection timeout', 'retry_count': 3},
        ipAddress: 'localhost',
      ),
      AuditLogEntry(
        id: '5',
        timestamp: now.subtract(const Duration(hours: 3)),
        level: AuditLogLevel.info,
        category: AuditLogCategory.asset,
        action: 'Asset Verification Completed',
        userId: 'verifier123',
        userName: 'Jane Smith',
        userRole: 'Verifier',
        entityId: 'asset456',
        entityType: 'Asset',
        details: {'asset_type': 'Real Estate', 'verification_status': 'approved'},
        ipAddress: '192.168.1.200',
        userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X)',
        location: 'Port Harcourt, Nigeria',
      ),
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
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedLevel = null;
      _selectedCategory = null;
      _selectedUser = null;
      _selectedDateRange = DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      );
    });
    _applyFilters();
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting audit logs...'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}