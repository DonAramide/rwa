import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_service.dart';
import '../../../models/user_role.dart';
import '../../../models/merchant_models.dart';
import '../../../providers/super_admin_provider.dart';
import '../../../providers/users_provider.dart';

class UserManagementPanel extends ConsumerStatefulWidget {
  const UserManagementPanel({super.key});

  @override
  ConsumerState<UserManagementPanel> createState() => _UserManagementPanelState();
}

class _UserManagementPanelState extends ConsumerState<UserManagementPanel>
    with SingleTickerProviderStateMixin {
  late TabController _userTabController;
  String _selectedMerchant = 'all';
  String _selectedRole = 'all';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  final List<Tab> _userTabs = const [
    Tab(
      text: 'All Users',
      height: 48,
    ),
    Tab(
      text: 'Merchant Users',
      height: 48,
    ),
    Tab(
      text: 'Investors',
      height: 48,
    ),
    Tab(
      text: 'Agents',
      height: 48,
    ),
    Tab(
      text: 'Permissions',
      height: 48,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _userTabController = TabController(length: _userTabs.length, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).loadUsers();
      ref.read(agentsProvider.notifier).loadAgents();
      ref.read(activitiesProvider.notifier).loadActivities();
    });
  }

  @override
  void dispose() {
    _userTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final superAdminState = ref.watch(superAdminProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header with user stats
        _buildUserStatsHeader(superAdminState, isDark),

        // Search and filters
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.getSurface(isDark),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users by name, email, or role...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                  filled: true,
                  fillColor: AppColors.getBackground(isDark),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMerchant,
                      decoration: InputDecoration(
                        labelText: 'Filter by Merchant',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('All Merchants')),
                        ...superAdminState.merchants.map((merchant) =>
                          DropdownMenuItem(value: merchant.id, child: Text(merchant.name))
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMerchant = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Filter by Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Roles')),
                        DropdownMenuItem(value: 'superAdmin', child: Text('Super Admin')),
                        DropdownMenuItem(value: 'merchantAdmin', child: Text('Merchant Admin')),
                        DropdownMenuItem(value: 'merchantOperations', child: Text('Merchant Operations')),
                        DropdownMenuItem(value: 'professionalAgent', child: Text('Professional Agent')),
                        DropdownMenuItem(value: 'investorAgent', child: Text('Investor Agent')),
                        DropdownMenuItem(value: 'verifier', child: Text('Verifier')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tab bar for user categories
        Container(
          color: AppColors.getSurface(isDark),
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _userTabController,
              tabs: _userTabs,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.getTextSecondary(isDark),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _userTabController,
            children: [
              _buildAllUsersTab(superAdminState, isDark),
              _buildMerchantUsersTab(superAdminState, isDark),
              _buildInvestorsTab(superAdminState, isDark),
              _buildAgentsTab(superAdminState, isDark),
              _buildPermissionsTab(superAdminState, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserStatsHeader(superAdminState, bool isDark) {
    // Mock user statistics - replace with actual data
    final totalUsers = 15847;
    final activeUsers = 12456;
    final merchantUsers = 234;
    final investors = 11890;
    final agents = 1723;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(isDark)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Management',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateUserDialog(isDark),
                icon: const Icon(Icons.person_add, color: AppColors.textOnPrimary),
                label: const Text('Add User', style: TextStyle(color: AppColors.textOnPrimary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildUserStatCard(
                  'Total Users',
                  totalUsers.toString(),
                  Icons.people,
                  AppColors.primary,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserStatCard(
                  'Active Users',
                  activeUsers.toString(),
                  Icons.people_alt,
                  Colors.green,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserStatCard(
                  'Merchant Users',
                  merchantUsers.toString(),
                  Icons.account_balance,
                  Colors.blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserStatCard(
                  'Investors',
                  investors.toString(),
                  Icons.trending_up,
                  Colors.orange,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserStatCard(
                  'Agents',
                  agents.toString(),
                  Icons.support_agent,
                  Colors.purple,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
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
              Icon(Icons.more_vert, color: AppColors.getTextSecondary(isDark), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllUsersTab(superAdminState, bool isDark) {
    // Mock user data - replace with actual data
    final users = _getMockUsers();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUsersTable(users, isDark),
        ],
      ),
    );
  }

  Widget _buildMerchantUsersTab(superAdminState, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Merchant Users',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Merchant user breakdown by institution
          ...superAdminState.merchants.map((merchant) => _buildMerchantUserSection(merchant, isDark)),
        ],
      ),
    );
  }

  Widget _buildInvestorsTab(superAdminState, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investor Management',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Investor analytics and management
          Row(
            children: [
              Expanded(
                child: _buildInvestorMetricCard('Total Investors', '11,890', Icons.people, Colors.orange, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInvestorMetricCard('Active This Month', '8,234', Icons.trending_up, Colors.green, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInvestorMetricCard('Total Invested', '\$45.2M', Icons.monetization_on, Colors.blue, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInvestorMetricCard('Avg. Investment', '\$3,800', Icons.show_chart, Colors.purple, isDark),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Investor list by merchant
          _buildInvestorsByMerchant(superAdminState.merchants, isDark),
        ],
      ),
    );
  }

  Widget _buildAgentsTab(superAdminState, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agent Management',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Agent breakdown
          Row(
            children: [
              Expanded(
                child: _buildAgentTypeCard('Professional Agents', '1,234', Icons.verified_user, Colors.green, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAgentTypeCard('Verifiers', '489', Icons.fact_check, Colors.blue, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAgentTypeCard('Active Assignments', '2,156', Icons.assignment, Colors.orange, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAgentTypeCard('Completed Tasks', '45,678', Icons.task_alt, Colors.purple, isDark),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Agent performance table
          _buildAgentPerformanceTable(isDark),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab(superAdminState, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role Permissions Management',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Permission matrix
          _buildPermissionMatrix(isDark),
        ],
      ),
    );
  }

  Widget _buildUsersTable(List<Map<String, dynamic>> users, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getBackground(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 3, child: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 2, child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 2, child: Text('Merchant', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 2, child: Text('Last Active', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          // Table rows
          ...users.map((user) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user['name'][0].toString().toUpperCase(),
                          style: const TextStyle(color: AppColors.textOnPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.getTextPrimary(isDark),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              user['email'],
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user['role']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getRoleColor(user['role']).withOpacity(0.3)),
                    ),
                    child: Text(
                      user['role'],
                      style: TextStyle(
                        color: _getRoleColor(user['role']),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    user['merchant'] ?? 'N/A',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['status'] == 'Active' ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user['status'],
                      style: TextStyle(
                        color: user['status'] == 'Active' ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    user['lastActive'],
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: PopupMenuButton<String>(
                    onSelected: (value) => _handleUserAction(value, user),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit User')),
                      const PopupMenuItem(value: 'permissions', child: Text('Manage Permissions')),
                      const PopupMenuItem(value: 'suspend', child: Text('Suspend User')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete User')),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMerchantUserSection(MerchantProfile merchant, bool isDark) {
    // Mock merchant users - replace with actual data
    final merchantUsers = _getMockMerchantUsers(merchant.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.name,
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${merchantUsers.length} users • ${merchant.status.toUpperCase()}',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddMerchantUserDialog(merchant, isDark),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Merchant user roles breakdown
          Row(
            children: [
              Expanded(
                child: _buildUserRoleCount('Merchant Admin', merchantUsers.where((u) => u['role'] == 'Merchant Admin').length, Colors.blue, isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUserRoleCount('Operations', merchantUsers.where((u) => u['role'] == 'Merchant Operations').length, Colors.green, isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUserRoleCount('Agents', merchantUsers.where((u) => u['role'] == 'Professional Agent').length, Colors.orange, isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUserRoleCount('Investors', merchantUsers.where((u) => u['role'] == 'Investor Agent').length, Colors.purple, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserRoleCount(String role, int count, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count.toString(),
            style: AppTextStyles.heading4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            role,
            style: AppTextStyles.caption.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorMetricCard(String title, String value, IconData icon, Color color, bool isDark) {
    return InkWell(
      onTap: () {
        _showMetricDetails(title, value);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getBorder(isDark)),
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
              Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showMetricDetails(String title, String value) {
    // Show detailed information about the metric
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Value: $value'),
            const SizedBox(height: 16),
            const Text('Detailed analytics and trends would appear here.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorsByMerchant(List<MerchantProfile> merchants, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getBackground(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              'Investors by Merchant',
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...merchants.map((merchant) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.getBorder(isDark))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    merchant.name,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${(merchant.totalUsers ?? 0).toInt()} users',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '\$${((merchant.totalRevenue ?? 0) / 1000).toStringAsFixed(0)}K invested',
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () => _viewMerchantInvestors(merchant),
                    child: const Text('View'),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildAgentTypeCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentPerformanceTable(bool isDark) {
    final agentsState = ref.watch(agentsProvider);

    if (agentsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (agentsState.error != null) {
      return Center(
        child: Text('Error: ${agentsState.error}'),
      );
    }

    final agents = agentsState.agents;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getBackground(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Agent', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          ...agents.map((agent) => InkWell(
            onTap: () => _showAgentDetailsDialog(agent),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.getBorder(isDark))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.name,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.getTextPrimary(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          agent.location,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: agent.type == 'Professional Agent'
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        agent.type as String,
                        style: AppTextStyles.caption.copyWith(
                          color: agent.type == 'Professional Agent' ? AppColors.primary : AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          agent.rating.toString(),
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.getTextPrimary(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${agent.completedTasks} completed',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${agent.activeTasks} active',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '\$${(agent.revenue / 1000).toStringAsFixed(0)}K',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: PopupMenuButton<String>(
                      onSelected: (value) => _handleAgentAction(value, agent),
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'view', child: Text('View Details')),
                        PopupMenuItem(value: 'tasks', child: Text('Manage Tasks')),
                        PopupMenuItem(value: 'message', child: Text('Send Message')),
                        PopupMenuItem(value: 'kyc', child: Text('Review KYC')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPermissionMatrix(bool isDark) {
    final permissions = [
      'Create Assets',
      'Edit Assets',
      'Delete Assets',
      'Approve Assets',
      'View Analytics',
      'Manage Users',
      'Access API',
      'System Settings',
    ];

    final roles = UserRole.values;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith((states) => AppColors.getBackground(isDark)),
          columns: [
            const DataColumn(label: Text('Permission', style: TextStyle(fontWeight: FontWeight.bold))),
            ...roles.map((role) => DataColumn(
              label: Text(
                role.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
          ],
          rows: permissions.map((permission) => DataRow(
            cells: [
              DataCell(Text(permission)),
              ...roles.map((role) => DataCell(
                Switch(
                  value: _hasPermission(role, permission),
                  onChanged: (value) => _togglePermission(role, permission, value),
                  activeColor: AppColors.primary,
                ),
              )),
            ],
          )).toList(),
        ),
      ),
    );
  }

  // Mock data methods
  List<Map<String, dynamic>> _getMockUsers() {
    return [
      {'name': 'John Smith', 'email': 'john@example.com', 'role': 'Super Admin', 'merchant': null, 'status': 'Active', 'lastActive': '2 hours ago'},
      {'name': 'Sarah Johnson', 'email': 'sarah@premiermerchant.com', 'role': 'Merchant Admin', 'merchant': 'Premier Merchant', 'status': 'Active', 'lastActive': '5 mins ago'},
      {'name': 'Mike Chen', 'email': 'mike@investcorp.com', 'role': 'Professional Agent', 'merchant': 'InvestCorp', 'status': 'Active', 'lastActive': '1 hour ago'},
      {'name': 'Emma Davis', 'email': 'emma@user.com', 'role': 'Investor Agent', 'merchant': 'Global Finance', 'status': 'Active', 'lastActive': '3 hours ago'},
      {'name': 'James Wilson', 'email': 'james@verify.com', 'role': 'Verifier', 'merchant': null, 'status': 'Inactive', 'lastActive': '2 days ago'},
    ];
  }

  List<Map<String, dynamic>> _getMockMerchantUsers(String merchantName) {
    return [
      {'name': 'Admin User', 'role': 'Merchant Admin', 'email': 'admin@merchant.com'},
      {'name': 'Operations Manager', 'role': 'Merchant Operations', 'email': 'ops@merchant.com'},
      {'name': 'Investment Agent', 'role': 'Professional Agent', 'email': 'agent@merchant.com'},
      {'name': 'Client Manager', 'role': 'Investor Agent', 'email': 'client@merchant.com'},
    ];
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Super Admin':
        return Colors.red;
      case 'Merchant Admin':
        return Colors.blue;
      case 'Professional Agent':
        return Colors.green;
      case 'Investor Agent':
        return Colors.orange;
      case 'Verifier':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  bool _hasPermission(UserRole role, String permission) {
    // Mock permission logic - replace with actual permission system
    switch (role) {
      case UserRole.superAdmin:
        return true; // Super admin has all permissions
      case UserRole.merchantAdmin:
        return !['System Settings'].contains(permission);
      case UserRole.professionalAgent:
        return ['Create Assets', 'Edit Assets', 'View Analytics'].contains(permission);
      case UserRole.investorAgent:
        return ['Create Assets', 'View Analytics'].contains(permission);
      default:
        return false;
    }
  }

  void _togglePermission(UserRole role, String permission, bool value) {
    // TODO: Implement permission toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${value ? 'Granted' : 'Revoked'} $permission for ${role.displayName}'),
      ),
    );
  }

  void _showCreateUserDialog(bool isDark) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    String selectedRole = 'Investor Agent';
    String selectedMerchant = 'None';
    bool sendWelcomeEmail = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: AppColors.surface,
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New User',
                      style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'User Role *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.security),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Merchant Admin', child: Text('Merchant Admin')),
                          DropdownMenuItem(value: 'Professional Agent', child: Text('Professional Agent')),
                          DropdownMenuItem(value: 'Investor Agent', child: Text('Investor Agent')),
                          DropdownMenuItem(value: 'Verifier', child: Text('Verifier')),
                        ],
                        onChanged: (value) => setState(() => selectedRole = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedMerchant,
                        decoration: const InputDecoration(
                          labelText: 'Assign to Merchant',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'None', child: Text('None')),
                          DropdownMenuItem(value: 'Premier Merchant', child: Text('Premier Merchant')),
                          DropdownMenuItem(value: 'InvestCorp', child: Text('InvestCorp')),
                          DropdownMenuItem(value: 'Global Finance', child: Text('Global Finance')),
                          DropdownMenuItem(value: 'TechVentures', child: Text('TechVentures')),
                        ],
                        onChanged: (value) => setState(() => selectedMerchant = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: sendWelcomeEmail,
                  onChanged: (value) => setState(() => sendWelcomeEmail = value!),
                  title: const Text('Send welcome email with login instructions'),
                  subtitle: const Text('User will receive an email with their temporary password'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: AppColors.info, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The user will be created with a temporary password and prompted to change it on first login.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty || emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all required fields')),
                          );
                          return;
                        }
                        Navigator.of(context).pop();
                        _createUser(
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          role: selectedRole,
                          merchant: selectedMerchant != 'None' ? selectedMerchant : null,
                          sendWelcomeEmail: sendWelcomeEmail,
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Create User', style: TextStyle(color: AppColors.textOnPrimary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createUser({
    required String name,
    required String email,
    required String phone,
    required String role,
    String? merchant,
    required bool sendWelcomeEmail,
  }) {
    // TODO: Implement actual user creation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User "$name" created successfully! ${sendWelcomeEmail ? 'Welcome email sent.' : ''}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showAddMerchantUserDialog(MerchantProfile merchant, bool isDark) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    String selectedRole = 'Investor Agent';
    bool sendWelcomeEmail = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: AppColors.surface,
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add User to ${merchant.name}',
                      style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role within Merchant *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.security),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Merchant Admin', child: Text('Merchant Admin')),
                    DropdownMenuItem(value: 'Professional Agent', child: Text('Professional Agent')),
                    DropdownMenuItem(value: 'Investor Agent', child: Text('Investor Agent')),
                  ],
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: sendWelcomeEmail,
                  onChanged: (value) => setState(() => sendWelcomeEmail = value!),
                  title: const Text('Send welcome email'),
                  subtitle: const Text('User will receive login instructions'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty || emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all required fields')),
                          );
                          return;
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${nameController.text} added to ${merchant.name} as $selectedRole'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Add User', style: TextStyle(color: AppColors.textOnPrimary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'view':
        _showUserDetailsDialog(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'manage':
        _showManageUserDialog(user);
        break;
      case 'activate':
        _activateUser(user);
        break;
      case 'deactivate':
        _deactivateUser(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action action for ${user['name']}')),
        );
    }
  }

  void _showUserDetailsDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Details',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Name', user['name']),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Role', user['role']),
              _buildDetailRow('Merchant', user['merchant'] ?? 'N/A'),
              _buildDetailRow('Status', user['status']),
              _buildDetailRow('Last Active', user['lastActive']),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showEditUserDialog(user);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Edit User', style: TextStyle(color: AppColors.textOnPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final TextEditingController nameController = TextEditingController(text: user['name']);
    final TextEditingController emailController = TextEditingController(text: user['email']);
    String selectedRole = user['role'];
    String selectedStatus = user['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: AppColors.surface,
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit User',
                      style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Super Admin', child: Text('Super Admin')),
                          DropdownMenuItem(value: 'Merchant Admin', child: Text('Merchant Admin')),
                          DropdownMenuItem(value: 'Professional Agent', child: Text('Professional Agent')),
                          DropdownMenuItem(value: 'Investor Agent', child: Text('Investor Agent')),
                          DropdownMenuItem(value: 'Verifier', child: Text('Verifier')),
                        ],
                        onChanged: (value) => setState(() => selectedRole = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Active', child: Text('Active')),
                          DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                          DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                        ],
                        onChanged: (value) => setState(() => selectedStatus = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement save user changes
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${nameController.text} updated successfully')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Save Changes', style: TextStyle(color: AppColors.textOnPrimary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showManageUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage ${user['name']}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Reset Password'),
                subtitle: const Text('Send password reset email'),
                onTap: () {
                  Navigator.of(context).pop();
                  _resetUserPassword(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.key),
                title: const Text('Manage Permissions'),
                subtitle: const Text('Configure user access rights'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPermissionsDialog(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('View Activity Log'),
                subtitle: const Text('See user activity history'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showActivityLogDialog(user);
                },
              ),
              if (user['role'] != 'Super Admin') ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: const Text('Suspend User'),
                  subtitle: const Text('Temporarily disable access'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _suspendUser(user);
                  },
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _activateUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Activate User',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to activate ${user['name']}?',
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
                SnackBar(content: Text('${user['name']} has been activated')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Activate', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }

  void _deactivateUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Deactivate User',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to deactivate ${user['name']}?',
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
                SnackBar(content: Text('${user['name']} has been deactivated')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Deactivate', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete User',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete ${user['name']}? This action cannot be undone.',
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
                SnackBar(content: Text('${user['name']} has been deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }

  void _resetUserPassword(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent to ${user['name']}')),
    );
  }

  void _showPermissionsDialog(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening permissions for ${user['name']}')),
    );
  }

  void _showActivityLogDialog(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening activity log for ${user['name']}')),
    );
  }

  void _suspendUser(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user['name']} has been suspended')),
    );
  }

  void _viewMerchantInvestors(MerchantProfile merchant) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Investors - ${merchant.name}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Investors: 156',
                          style: AppTextStyles.heading4.copyWith(color: AppColors.primary),
                        ),
                        Text(
                          'Active: 142  •  Pending: 8  •  Inactive: 6',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search investors...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: 'All Status',
                    items: const [
                      DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _getMockInvestors().length,
                  itemBuilder: (context, index) {
                    final investor = _getMockInvestors()[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            investor['name'][0].toUpperCase(),
                            style: const TextStyle(color: AppColors.textOnPrimary),
                          ),
                        ),
                        title: Text(investor['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(investor['email']),
                            Text('Invested: \$${investor['totalInvestment']}  •  KYC: ${investor['kycStatus']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: investor['status'] == 'Active'
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                investor['status'],
                                style: TextStyle(
                                  color: investor['status'] == 'Active' ? AppColors.success : AppColors.warning,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (value) => _handleInvestorAction(value, investor),
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'view', child: Text('View Profile')),
                                PopupMenuItem(value: 'investments', child: Text('View Investments')),
                                PopupMenuItem(value: 'message', child: Text('Send Message')),
                                PopupMenuItem(value: 'kyc', child: Text('Manage KYC')),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _handleInvestorAction('view', investor),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockInvestors() {
    return [
      {
        'name': 'Alice Johnson',
        'email': 'alice@investor.com',
        'status': 'Active',
        'totalInvestment': '125,000',
        'kycStatus': 'Verified',
        'joinDate': '2023-08-15',
        'location': 'New York, USA',
      },
      {
        'name': 'Bob Chen',
        'email': 'bob@investments.com',
        'status': 'Active',
        'totalInvestment': '87,500',
        'kycStatus': 'Verified',
        'joinDate': '2023-09-22',
        'location': 'Singapore',
      },
      {
        'name': 'Carol Davis',
        'email': 'carol@wealth.com',
        'status': 'Pending',
        'totalInvestment': '0',
        'kycStatus': 'Pending',
        'joinDate': '2024-01-10',
        'location': 'London, UK',
      },
      {
        'name': 'David Miller',
        'email': 'david@portfolio.com',
        'status': 'Active',
        'totalInvestment': '250,000',
        'kycStatus': 'Verified',
        'joinDate': '2023-07-03',
        'location': 'Toronto, Canada',
      },
    ];
  }

  void _handleInvestorAction(String action, Map<String, dynamic> investor) {
    switch (action) {
      case 'view':
        _showInvestorProfile(investor);
        break;
      case 'investments':
        _showInvestorInvestments(investor);
        break;
      case 'message':
        _sendMessageToInvestor(investor);
        break;
      case 'kyc':
        _manageInvestorKYC(investor);
        break;
    }
  }

  void _showInvestorProfile(Map<String, dynamic> investor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 600,
          height: 650,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Investor Profile - ${investor['name']}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information
                      _buildAgentInfoSection('Personal Information', [
                        _buildDetailRow('Full Name', investor['name']),
                        _buildDetailRow('Email Address', investor['email']),
                        _buildDetailRow('Location', investor['location']),
                        _buildDetailRow('Account Status', investor['status']),
                        _buildDetailRow('Join Date', investor['joinDate']),
                      ]),
                      const SizedBox(height: 24),

                      // Investment Summary
                      _buildAgentInfoSection('Investment Summary', [
                        _buildDetailRow('Total Investment', '\$${investor['totalInvestment']}'),
                        _buildDetailRow('Active Assets', '12 assets'),
                        _buildDetailRow('Portfolio Value', '\$${(double.parse(investor['totalInvestment'].replaceAll(',', '')) * 1.15).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
                        _buildDetailRow('ROI', '+15.2%'),
                        _buildDetailRow('Risk Level', 'Moderate'),
                      ]),
                      const SizedBox(height: 24),

                      // KYC & Compliance
                      _buildAgentInfoSection('KYC & Compliance', [
                        _buildDetailRow('KYC Status', investor['kycStatus']),
                        _buildDetailRow('Identity Verification', 'Completed'),
                        _buildDetailRow('Address Verification', 'Completed'),
                        _buildDetailRow('Financial Verification', 'Completed'),
                        _buildDetailRow('Risk Assessment', 'Low Risk'),
                      ]),
                      const SizedBox(height: 24),

                      // Recent Activity
                      Text(
                        'Recent Activity',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            _buildActivityItem('Invested in Tech Startup #456', '2 days ago', AppColors.success),
                            _buildActivityItem('Updated profile information', '1 week ago', AppColors.info),
                            _buildActivityItem('Completed KYC verification', '2 weeks ago', AppColors.warning),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showInvestorInvestments(investor);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('View Investments', style: TextStyle(color: AppColors.textOnPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInvestorInvestments(Map<String, dynamic> investor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Investments - ${investor['name']}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Invested',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          '\$${investor['totalInvestment']}',
                          style: AppTextStyles.heading4.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Assets',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          '12 assets',
                          style: AppTextStyles.heading4.copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total ROI',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          '+15.2%',
                          style: AppTextStyles.heading4.copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildInvestmentItem('Tech Startup Alpha', 'Technology', '\$25,000', '+18.5%', AppColors.success),
                    _buildInvestmentItem('Green Energy Project', 'Energy', '\$40,000', '+12.3%', AppColors.success),
                    _buildInvestmentItem('Real Estate Fund', 'Real Estate', '\$35,000', '+8.7%', AppColors.success),
                    _buildInvestmentItem('Healthcare Innovation', 'Healthcare', '\$15,000', '-2.1%', AppColors.error),
                    _buildInvestmentItem('Manufacturing Plant', 'Manufacturing', '\$10,000', '+22.4%', AppColors.success),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Generating investment report for ${investor['name']}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                    child: const Text('Generate Report', style: TextStyle(color: AppColors.textOnPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestmentItem(String name, String category, String amount, String roi, Color roiColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            name[0],
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        subtitle: Text(category),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              amount,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              roi,
              style: AppTextStyles.caption.copyWith(
                color: roiColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessageToInvestor(Map<String, dynamic> investor) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Send Message to ${investor['name']}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (subjectController.text.isEmpty || messageController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in both subject and message')),
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Message sent to ${investor['name']}'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Send Message', style: TextStyle(color: AppColors.textOnPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _manageInvestorKYC(Map<String, dynamic> investor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KYC Management - ${investor['name']}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: investor['kycStatus'] == 'Verified'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: investor['kycStatus'] == 'Verified'
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      investor['kycStatus'] == 'Verified' ? Icons.verified : Icons.pending,
                      color: investor['kycStatus'] == 'Verified' ? AppColors.success : AppColors.warning,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status: ${investor['kycStatus']}',
                          style: AppTextStyles.heading4.copyWith(
                            color: investor['kycStatus'] == 'Verified' ? AppColors.success : AppColors.warning,
                          ),
                        ),
                        Text(
                          investor['kycStatus'] == 'Verified'
                              ? 'All KYC requirements have been met'
                              : 'KYC verification in progress',
                          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKYCSection('Identity Verification', [
                        _buildKYCItem('Government ID', 'Completed', AppColors.success),
                        _buildKYCItem('Photo Verification', 'Completed', AppColors.success),
                        _buildKYCItem('Background Check', 'Completed', AppColors.success),
                      ]),
                      const SizedBox(height: 16),
                      _buildKYCSection('Address Verification', [
                        _buildKYCItem('Utility Bill', 'Completed', AppColors.success),
                        _buildKYCItem('Bank Statement', 'Completed', AppColors.success),
                      ]),
                      const SizedBox(height: 16),
                      _buildKYCSection('Financial Verification', [
                        _buildKYCItem('Income Verification', 'Completed', AppColors.success),
                        _buildKYCItem('Source of Funds', 'Completed', AppColors.success),
                        _buildKYCItem('Risk Assessment', 'Completed', AppColors.success),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  if (investor['kycStatus'] != 'Verified') ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('KYC approved for ${investor['name']}'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      child: const Text('Approve KYC', style: TextStyle(color: AppColors.textOnPrimary)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Generating KYC report for ${investor['name']}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                    child: const Text('Generate Report', style: TextStyle(color: AppColors.textOnPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKYCSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildKYCItem(String item, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item,
            style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAgentDetailsDialog(Agent agent) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 700,
          height: 650,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agent Profile - ${agent['name']}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildAgentInfoSection('Basic Information', [
                        _buildDetailRow('Name', agent.name),
                        _buildDetailRow('Type', agent.type),
                        _buildDetailRow('Email', agent.email),
                        _buildDetailRow('Phone', agent.phone),
                        _buildDetailRow('Location', agent.location),
                        _buildDetailRow('Status', agent.status),
                        _buildDetailRow('Last Active', agent.lastActive),
                      ]),
                      const SizedBox(height: 24),

                      // Performance Metrics
                      _buildAgentInfoSection('Performance Metrics', [
                        _buildDetailRow('Rating', '⭐ ${agent.rating}/5.0'),
                        _buildDetailRow('Tasks Completed', '${agent.completedTasks} tasks'),
                        _buildDetailRow('Active Tasks', '${agent.activeTasks} tasks'),
                        _buildDetailRow('Revenue Generated', '\$${agent.revenue}'),
                        _buildDetailRow('Join Date', agent.joinDate),
                      ]),
                      const SizedBox(height: 24),

                      // KYC & Compliance
                      _buildAgentInfoSection('KYC & Compliance', [
                        _buildDetailRow('KYC Status', agent['kycStatus']),
                        _buildDetailRow('Background Check', 'Passed'),
                        _buildDetailRow('License Status', 'Valid'),
                        _buildDetailRow('Compliance Score', '98%'),
                      ]),
                      const SizedBox(height: 24),

                      // Specialties
                      Text(
                        'Specialties',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (agent['specialties'] as List<String>).map((specialty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Text(
                              specialty,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showAgentTaskManagement(agent);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Manage Tasks', style: TextStyle(color: AppColors.textOnPrimary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _sendMessageToAgent(agent);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                    child: const Text('Send Message', style: TextStyle(color: AppColors.textOnPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _handleAgentAction(String action, Agent agent) {
    switch (action) {
      case 'view':
        _showAgentDetailsDialog(agent);
        break;
      case 'tasks':
        _showAgentTaskManagement(agent);
        break;
      case 'message':
        _sendMessageToAgent(agent);
        break;
      case 'kyc':
        _reviewAgentKYC(agent);
        break;
    }
  }

  void _showAgentTaskManagement(Map<String, dynamic> agent) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task Management - ${agent['name']}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTaskStatusCard('Active Tasks', agent.activeTasks.toString(), AppColors.warning),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTaskStatusCard('Completed', agent.completedTasks.toString(), AppColors.success),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTaskStatusCard('Pending Review', '3', AppColors.info),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildTaskItem('Asset Verification - Tech Startup #456', 'In Progress', 'Due: Tomorrow', AppColors.warning),
                    _buildTaskItem('KYC Review - Investment Fund', 'Pending', 'Due: 3 days', AppColors.info),
                    _buildTaskItem('Due Diligence - Real Estate Project', 'In Progress', 'Due: 1 week', AppColors.warning),
                    _buildTaskItem('Compliance Check - Manufacturing Asset', 'Completed', 'Completed 2 hours ago', AppColors.success),
                    _buildTaskItem('Document Review - Energy Project', 'Completed', 'Completed yesterday', AppColors.success),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Assigning new task to ${agent['name']}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Assign New Task', style: TextStyle(color: AppColors.textOnPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskStatusCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String status, String dueDate, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(dueDate),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessageToAgent(Map<String, dynamic> agent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening message dialog for ${agent['name']}')),
    );
  }

  void _reviewAgentKYC(Map<String, dynamic> agent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening KYC review for ${agent['name']}')),
    );
  }
}