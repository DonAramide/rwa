import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'components/investor_agent_dashboard.dart';
import 'components/professional_agent_dashboard.dart';
import 'components/verifier_dashboard.dart';
import 'components/admin_dashboard.dart';

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userRole = authState.userRole;
    if (userRole == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/role-selection');
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
        return const AdminDashboard();
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
          child: const Icon(Icons.add, color: Colors.white),
        );
      case UserRole.professionalAgent:
        return FloatingActionButton(
          onPressed: () => _showNewProjectAssignment(),
          backgroundColor: AppColors.warning,
          child: const Icon(Icons.assignment, color: Colors.white),
        );
      case UserRole.verifier:
        return FloatingActionButton(
          onPressed: () => _showAvailableTasks(),
          backgroundColor: AppColors.info,
          child: const Icon(Icons.camera_alt, color: Colors.white),
        );
      case UserRole.admin:
        return FloatingActionButton(
          onPressed: () => _showAdminActions(),
          backgroundColor: AppColors.error,
          child: const Icon(Icons.admin_panel_settings, color: Colors.white),
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
          NavItem(Icons.flag, 'Monitoring'),
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
    }
  }

  void _handleNavigation(UserRole role, int index) {
    switch (role) {
      case UserRole.investorAgent:
        switch (index) {
          case 0: break; // Dashboard - already here
          case 1: context.push('/marketplace'); break;
          case 2: context.push('/portfolio'); break;
          case 3: context.push('/rofr'); break;
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