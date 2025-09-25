import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_service.dart';
import 'components/investor_agent_dashboard.dart';
import 'components/professional_agent_dashboard.dart';
import 'components/verifier_dashboard.dart';
import 'components/admin_dashboard_clean.dart';
import '../merchant_admin/merchant_admin_dashboard.dart';

class UnifiedDashboard extends ConsumerStatefulWidget {
  const UnifiedDashboard({super.key});

  @override
  ConsumerState<UnifiedDashboard> createState() => _UnifiedDashboardState();
}

class _UnifiedDashboardState extends ConsumerState<UnifiedDashboard> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      Future.microtask(() {
        if (mounted) {
          context.go('/login');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userRole = authState.userRole;
    if (userRole == null) {
      Future.microtask(() {
        if (mounted) {
          context.go('/role-selection');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(userRole),
      body: _buildBody(userRole),
      bottomNavigationBar: _buildBottomNavBar(userRole),
      floatingActionButton: _buildFloatingActionButton(userRole),
    );
  }

  PreferredSizeWidget _buildAppBar(UserRole role) {
    final roleInfo = _getRoleInfo(role);
    
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: roleInfo.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              roleInfo.icon,
              color: roleInfo.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RWA Platform',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                roleInfo.title,
                style: AppTextStyles.heading3,
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Role Switcher
        PopupMenuButton<UserRole>(
          icon: const Icon(Icons.swap_horiz),
          tooltip: 'Switch Role',
          onSelected: (newRole) {
            ref.read(authProvider.notifier).switchRole(newRole);
          },
          itemBuilder: (context) => UserRole.values.map((role) {
            final info = _getRoleInfo(role);
            return PopupMenuItem<UserRole>(
              value: role,
              child: Row(
                children: [
                  Icon(info.icon, size: 20, color: info.color),
                  const SizedBox(width: 8),
                  Text(info.title),
                  if (role == roleInfo.role) ...[
                    const Spacer(),
                    Icon(Icons.check, size: 16, color: AppColors.success),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
        
        // Notifications
        IconButton(
          onPressed: () => _showNotifications(),
          icon: const Icon(Icons.notifications_outlined),
        ),
        
        // Profile Menu
        PopupMenuButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: roleInfo.color.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 20,
              color: roleInfo.color,
            ),
          ),
          itemBuilder: (context) => <PopupMenuEntry>[
            PopupMenuItem<void>(
              child: const Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Profile'),
                ],
              ),
              onTap: () => _showProfile(),
            ),
            PopupMenuItem<void>(
              child: const Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
              onTap: () => _showSettings(),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<void>(
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error),
                  ),
                ],
              ),
              onTap: () => _handleLogout(),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(UserRole role) {
    switch (role) {
      case UserRole.investorAgent:
        return const InvestorAgentDashboard();
      case UserRole.professionalAgent:
        return const ProfessionalAgentDashboard();
      case UserRole.verifier:
        return const VerifierDashboard();
      case UserRole.admin:
        return const AdminDashboardClean();
      case UserRole.superAdmin:
        return const AdminDashboardClean(); // Super admin uses admin dashboard with elevated permissions
      case UserRole.merchantWhiteLabel:
        return const AdminDashboardClean(); // Merchant partners use admin-style dashboard with custom branding
      case UserRole.merchantAdmin:
        return const MerchantAdminDashboard();
      case UserRole.merchantOperations:
        return const MerchantAdminDashboard();
    }
  }

  Widget? _buildBottomNavBar(UserRole role) {
    final navItems = _getNavItems(role);
    
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        _handleNavigation(role, index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _getRoleInfo(role).color,
      unselectedItemColor: AppColors.textSecondary,
      items: navItems.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        label: item.label,
      )).toList(),
    );
  }

  Widget? _buildFloatingActionButton(UserRole role) {
    switch (role) {
      case UserRole.investorAgent:
        return FloatingActionButton(
          onPressed: () => context.push('/marketplace'),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.textOnPrimary),
        );
      case UserRole.professionalAgent:
        return FloatingActionButton(
          onPressed: () => _showNewProjectAssignment(),
          backgroundColor: AppColors.warning,
          child: const Icon(Icons.assignment, color: AppColors.textOnPrimary),
        );
      case UserRole.verifier:
        return FloatingActionButton(
          onPressed: () => _showAvailableTasks(),
          backgroundColor: AppColors.info,
          child: const Icon(Icons.camera_alt, color: AppColors.textOnPrimary),
        );
      case UserRole.admin:
        return FloatingActionButton(
          onPressed: () => _showAdminActions(),
          backgroundColor: AppColors.error,
          child: const Icon(Icons.admin_panel_settings, color: AppColors.textOnPrimary),
        );
      case UserRole.superAdmin:
        return FloatingActionButton(
          onPressed: () => _showSuperAdminActions(),
          backgroundColor: AppColors.error,
          child: const Icon(Icons.shield, color: AppColors.textOnPrimary),
        );
      case UserRole.merchantWhiteLabel:
        return FloatingActionButton(
          onPressed: () => _showPartnerActions(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.account_balance, color: AppColors.textOnPrimary),
        );
      case UserRole.merchantAdmin:
        return FloatingActionButton(
          onPressed: () => _showBankAdminActions(),
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add_business, color: AppColors.textOnPrimary),
        );
      case UserRole.merchantOperations:
        return FloatingActionButton(
          onPressed: () => _showBankOperationsActions(),
          backgroundColor: Colors.teal,
          child: const Icon(Icons.payment, color: AppColors.textOnPrimary),
        );
    }
  }

  List<NavItem> _getNavItems(UserRole role) {
    switch (role) {
      case UserRole.investorAgent:
        return [
          NavItem(Icons.dashboard, 'Dashboard'),
          NavItem(Icons.store, 'Marketplace'),
          NavItem(Icons.account_balance_wallet, 'Portfolio'),
          NavItem(Icons.bookmark, 'Watchlist'),
          NavItem(Icons.how_to_vote, 'Governance'),
        ];
      case UserRole.professionalAgent:
        return [
          NavItem(Icons.dashboard, 'Dashboard'),
          NavItem(Icons.assignment, 'Assignments'),
          NavItem(Icons.verified, 'Verifications'),
          NavItem(Icons.analytics, 'Reports'),
          NavItem(Icons.account_circle, 'Profile'),
        ];
      case UserRole.verifier:
        return [
          NavItem(Icons.dashboard, 'Dashboard'),
          NavItem(Icons.camera_alt, 'Tasks'),
          NavItem(Icons.location_on, 'Map'),
          NavItem(Icons.star, 'Ratings'),
          NavItem(Icons.payment, 'Earnings'),
        ];
      case UserRole.admin:
        return [
          NavItem(Icons.dashboard, 'Dashboard'),
          NavItem(Icons.approval, 'Approvals'),
          NavItem(Icons.people, 'Users'),
          NavItem(Icons.security, 'Compliance'),
          NavItem(Icons.analytics, 'Analytics'),
        ];
      case UserRole.superAdmin:
        return [
          NavItem(Icons.dashboard, 'Dashboard'),
          NavItem(Icons.shield, 'Platform'),
          NavItem(Icons.business, 'Partners'),
          NavItem(Icons.settings, 'System'),
          NavItem(Icons.analytics, 'Analytics'),
        ];
      case UserRole.merchantWhiteLabel:
        return [
          NavItem(Icons.dashboard, 'Dashboard'),
          NavItem(Icons.people, 'Clients'),
          NavItem(Icons.account_balance, 'Banking'),
          NavItem(Icons.analytics, 'Reports'),
          NavItem(Icons.settings, 'Config'),
        ];
      case UserRole.merchantAdmin:
        return [
          NavItem(Icons.dashboard, 'Overview'),
          NavItem(Icons.people, 'Customers'),
          NavItem(Icons.receipt_long, 'Transactions'),
          NavItem(Icons.assessment, 'Proposals'),
          NavItem(Icons.analytics, 'Analytics'),
        ];
      case UserRole.merchantOperations:
        return [
          NavItem(Icons.dashboard, 'Overview'),
          NavItem(Icons.payment, 'Settlements'),
          NavItem(Icons.receipt_long, 'Transactions'),
          NavItem(Icons.people, 'Customers'),
          NavItem(Icons.settings, 'Settings'),
        ];
    }
  }

  RoleInfo _getRoleInfo(UserRole role) {
    switch (role) {
      case UserRole.investorAgent:
        return RoleInfo(
          role: role,
          title: 'Investor-Agent',
          icon: Icons.trending_up,
          color: AppColors.primary,
        );
      case UserRole.professionalAgent:
        return RoleInfo(
          role: role,
          title: 'Professional Agent',
          icon: Icons.verified,
          color: AppColors.warning,
        );
      case UserRole.verifier:
        return RoleInfo(
          role: role,
          title: 'Verifier',
          icon: Icons.camera_alt,
          color: AppColors.info,
        );
      case UserRole.admin:
        return RoleInfo(
          role: role,
          title: 'Admin',
          icon: Icons.admin_panel_settings,
          color: AppColors.error,
        );
      case UserRole.superAdmin:
        return RoleInfo(
          role: role,
          title: 'Super Admin',
          icon: Icons.shield,
          color: AppColors.error,
        );
      case UserRole.merchantWhiteLabel:
        return RoleInfo(
          role: role,
          title: 'Bank Partner',
          icon: Icons.account_balance,
          color: AppColors.primary,
        );
      case UserRole.merchantAdmin:
        return RoleInfo(
          role: role,
          title: 'Bank Admin',
          icon: Icons.admin_panel_settings,
          color: Colors.blue,
        );
      case UserRole.merchantOperations:
        return RoleInfo(
          role: role,
          title: 'Bank Operations',
          icon: Icons.business_center,
          color: Colors.teal,
        );
    }
  }

  void _handleNavigation(UserRole role, int index) {
    switch (role) {
      case UserRole.investorAgent:
        switch (index) {
          case 0: break; // Dashboard - already here
          case 1: context.push('/marketplace'); break;
          case 2: context.push('/portfolio'); break;
          case 3: context.push('/watchlist'); break;
          case 4: _showGovernance(); break;
        }
        break;
      case UserRole.professionalAgent:
        switch (index) {
          case 0: break; // Dashboard
          case 1: _showAssignments(); break;
          case 2: context.push('/verification'); break;
          case 3: _showReports(); break;
          case 4: _showProfile(); break;
        }
        break;
      case UserRole.verifier:
        switch (index) {
          case 0: break; // Dashboard
          case 1: _showAvailableTasks(); break;
          case 2: _showTaskMap(); break;
          case 3: _showRatings(); break;
          case 4: _showEarnings(); break;
        }
        break;
      case UserRole.admin:
        switch (index) {
          case 0: break; // Dashboard
          case 1: context.push('/admin'); break;
          case 2: _showUserManagement(); break;
          case 3: _showCompliance(); break;
          case 4: _showAnalytics(); break;
        }
        break;
      case UserRole.superAdmin:
        switch (index) {
          case 0: break; // Dashboard
          case 1: _showPlatformManagement(); break;
          case 2: _showPartnerManagement(); break;
          case 3: _showSystemSettings(); break;
          case 4: _showAnalytics(); break;
        }
        break;
      case UserRole.merchantWhiteLabel:
        switch (index) {
          case 0: break; // Dashboard
          case 1: _showClientManagement(); break;
          case 2: _showBankingInterface(); break;
          case 3: _showReports(); break;
          case 4: _showConfiguration(); break;
        }
        break;
      case UserRole.merchantAdmin:
        // Bank admin navigation is handled by the dashboard's internal tab controller
        break;
      case UserRole.merchantOperations:
        // Bank operations navigation is handled by the dashboard's internal tab controller
        break;
    }
  }

  // Placeholder methods for navigation actions
  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature coming soon')),
    );
  }

  void _showProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile feature coming soon')),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature coming soon')),
    );
  }

  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    context.go('/login');
  }

  void _showNewProjectAssignment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New project assignment feature coming soon')),
    );
  }

  void _showAvailableTasks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Available tasks feature coming soon')),
    );
  }

  void _showAdminActions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin actions feature coming soon')),
    );
  }

  void _showMonitoring() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Monitoring feature coming soon')),
    );
  }

  void _showGovernance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Governance feature coming soon')),
    );
  }

  void _showAssignments() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignments feature coming soon')),
    );
  }

  void _showReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reports feature coming soon')),
    );
  }

  void _showTaskMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task map feature coming soon')),
    );
  }

  void _showRatings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ratings feature coming soon')),
    );
  }

  void _showEarnings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Earnings feature coming soon')),
    );
  }

  void _showUserManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User management feature coming soon')),
    );
  }

  void _showCompliance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compliance feature coming soon')),
    );
  }

  void _showAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics feature coming soon')),
    );
  }

  void _showSuperAdminActions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Super admin actions feature coming soon')),
    );
  }

  void _showPartnerActions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partner actions feature coming soon')),
    );
  }

  void _showPlatformManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Platform management feature coming soon')),
    );
  }

  void _showPartnerManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partner management feature coming soon')),
    );
  }

  void _showSystemSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System settings feature coming soon')),
    );
  }

  void _showClientManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Client management feature coming soon')),
    );
  }

  void _showBankingInterface() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Banking interface feature coming soon')),
    );
  }

  void _showConfiguration() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration feature coming soon')),
    );
  }

  void _showBankAdminActions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bank admin actions feature coming soon')),
    );
  }

  void _showBankOperationsActions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bank operations actions feature coming soon')),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem(this.icon, this.label);
}

class RoleInfo {
  final UserRole role;
  final String title;
  final IconData icon;
  final Color color;

  RoleInfo({
    required this.role,
    required this.title,
    required this.icon,
    required this.color,
  });
}