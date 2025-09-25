import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? selectedRole;
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 40),
              
              // Role Selection Cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRoleCard(UserRole.investorAgent),
                      const SizedBox(height: 16),
                      _buildRoleCard(UserRole.professionalAgent),
                      const SizedBox(height: 16),
                      _buildRoleCard(UserRole.verifier),
                      const SizedBox(height: 16),
                      _buildRoleCard(UserRole.admin),
                      const SizedBox(height: 16),
                      _buildRoleCard(UserRole.superAdmin),
                    ],
                  ),
                ),
              ),
              
              // Continue Button
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios),
            ),
            const Spacer(),
            Image.asset(
              'assets/images/rwa_logo.png',
              height: 40,
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Choose Your Role',
          style: AppTextStyles.heading1,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Select how you\'d like to participate in the RWA ecosystem. You can always upgrade your role later.',
          style: AppTextStyles.body1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(UserRole role) {
    final isSelected = selectedRole == role;
    final roleInfo = _getRoleInfo(role);
    
    return GestureDetector(
      onTap: () => setState(() {
        selectedRole = role;
        showDetails = true;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
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
                  // Radio Button
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Role Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: roleInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      roleInfo.icon,
                      color: roleInfo.color,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Role Title and Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              roleInfo.title,
                              style: AppTextStyles.heading3,
                            ),
                            if (roleInfo.badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: roleInfo.badgeColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  roleInfo.badge!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          roleInfo.subtitle,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Key Features
              _buildKeyFeatures(roleInfo.keyFeatures),
              
              const SizedBox(height: 16),
              
              // Requirements and Fees
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'Registration',
                      roleInfo.registrationFee,
                      Icons.attach_money,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      'Requirements',
                      roleInfo.requirements,
                      Icons.verified_user,
                      AppColors.info,
                    ),
                  ),
                ],
              ),
              
              // Detailed View
              if (isSelected && showDetails) ...[
                const SizedBox(height: 20),
                _buildDetailedInfo(roleInfo),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyFeatures(List<String> features) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((feature) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          feature,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo(RoleInfo roleInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you can do:',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...roleInfo.capabilities.map((capability) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    capability,
                    style: AppTextStyles.body2,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          const SizedBox(height: 16),
          
          Text(
            'How you earn:',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...roleInfo.earnings.map((earning) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.payments,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    earning,
                    style: AppTextStyles.body2,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final canContinue = selectedRole != null;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      child: ElevatedButton(
        onPressed: canContinue ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.border,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          canContinue ? 'Continue as ${_getRoleInfo(selectedRole!).title}' : 'Select a Role',
          style: AppTextStyles.button.copyWith(
            color: canContinue ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (selectedRole == null) return;
    
    // Store selected role
    ref.read(authProvider.notifier).setSelectedRole(selectedRole!);
    
    // Navigate to appropriate onboarding flow
    switch (selectedRole!) {
      case UserRole.investorAgent:
        context.push('/onboarding/investor-agent');
        break;
      case UserRole.professionalAgent:
        context.push('/onboarding/professional-agent');
        break;
      case UserRole.verifier:
        context.push('/onboarding/verifier');
        break;
      case UserRole.admin:
        context.push('/onboarding/admin');
        break;
      case UserRole.superAdmin:
        context.go('/super-admin'); // Navigate directly to Super Admin Dashboard
        break;
      case UserRole.merchantWhiteLabel:
        context.push('/onboarding/admin'); // Bank white-label uses admin-style onboarding
        break;
      case UserRole.merchantAdmin:
        context.push('/onboarding/admin'); // Bank admin uses admin-style onboarding
        break;
      case UserRole.merchantOperations:
        context.push('/onboarding/admin'); // Bank operations uses admin-style onboarding
        break;
    }
  }

  RoleInfo _getRoleInfo(UserRole role) {
    switch (role) {
      case UserRole.investorAgent:
        return RoleInfo(
          title: 'Investor-Agent',
          subtitle: 'Invest & monitor projects automatically',
          icon: Icons.trending_up,
          color: AppColors.primary,
          badge: 'AUTO UPGRADE',
          badgeColor: AppColors.success,
          registrationFee: 'FREE',
          requirements: 'Basic KYC',
          keyFeatures: ['Invest in projects', 'Monitor & flag', 'Vote on governance'],
          capabilities: [
            'Browse and invest in RWA projects',
            'Automatically become an agent when investing',
            'Monitor project progress and flag issues',
            'Vote on platform governance decisions',
            'Request on-demand verifications',
            'Earn governance tokens and revenue sharing'
          ],
          earnings: [
            'Revenue sharing from successful projects',
            'Governance token rewards for participation',
            'Reputation bonuses for accurate flagging',
            'Early access to premium projects'
          ],
        );
        
      case UserRole.professionalAgent:
        return RoleInfo(
          title: 'Professional Agent',
          subtitle: 'Expert verification & oversight',
          icon: Icons.verified,
          color: AppColors.warning,
          badge: 'EXPERT',
          badgeColor: AppColors.warning,
          registrationFee: 'FREE',
          requirements: 'Professional License',
          keyFeatures: ['Legal verification', 'Expert reports', 'High commissions'],
          capabilities: [
            'Verify legal documents and compliance',
            'Validate asset ownership and rights',
            'Supervise project milestones',
            'Provide expert reports and opinions',
            'Participate in dispute resolution',
            'Build professional reputation on platform'
          ],
          earnings: [
            '2-5% commission on verified projects',
            'Hourly/project-based service fees',
            'Performance bonuses for accuracy',
            'Premium rates for specialized expertise',
            'Long-term retainer opportunities'
          ],
        );
        
      case UserRole.verifier:
        return RoleInfo(
          title: 'Verifier',
          subtitle: 'On-demand site visits & checks',
          icon: Icons.camera_alt,
          color: AppColors.info,
          badge: 'GIG WORK',
          badgeColor: AppColors.info,
          registrationFee: 'FREE',
          requirements: 'Smartphone & Transport',
          keyFeatures: ['Site visits', 'Photo reports', 'Flexible schedule'],
          capabilities: [
            'Accept verification tasks in your area',
            'Perform site visits and documentation',
            'Take photos and GPS-tagged evidence',
            'Submit simple inspection reports',
            'Build ratings through quality work',
            'Flexible part-time or full-time work'
          ],
          earnings: [
            '\$50-500 per verification task',
            'Distance-based travel compensation',
            'Speed bonuses for quick completion',
            'Rating bonuses for quality work',
            'Geographic exclusivity opportunities'
          ],
        );
        
      case UserRole.admin:
        return RoleInfo(
          title: 'Platform Admin',
          subtitle: 'Platform oversight & compliance',
          icon: Icons.admin_panel_settings,
          color: AppColors.error,
          badge: 'RESTRICTED',
          badgeColor: AppColors.error,
          registrationFee: 'INVITE ONLY',
          requirements: 'Platform Team',
          keyFeatures: ['Project approval', 'Dispute resolution', 'Compliance'],
          capabilities: [
            'Review and approve project listings',
            'Coordinate professional agents',
            'Monitor platform compliance',
            'Resolve disputes and issues',
            'Manage escrow and fund releases',
            'Ensure regulatory compliance'
          ],
          earnings: [
            'Platform equity and tokens',
            'Performance-based bonuses',
            'Long-term incentive plans',
            'Platform success sharing'
          ],
        );

      case UserRole.superAdmin:
        return RoleInfo(
          title: 'Super Administrator',
          subtitle: 'Full platform administration & white-label management',
          icon: Icons.shield,
          color: AppColors.error,
          badge: 'SUPER ADMIN',
          badgeColor: AppColors.error,
          registrationFee: 'INVITE ONLY',
          requirements: 'Platform Leadership',
          keyFeatures: ['Platform control', 'White-label management', 'Full access'],
          capabilities: [
            'Full platform administration and control',
            'Manage white-label partner configurations',
            'Override all platform decisions and settings',
            'Access to all financial and operational data',
            'System-wide compliance and security oversight',
            'Partner onboarding and relationship management'
          ],
          earnings: [
            'Platform ownership stakes',
            'Strategic partnership revenue',
            'Long-term equity participation',
            'Performance-based leadership bonuses'
          ],
        );

      case UserRole.merchantWhiteLabel:
        return RoleInfo(
          title: 'Bank Partner',
          subtitle: 'White-label banking partner with custom branding',
          icon: Icons.account_balance,
          color: AppColors.primary,
          badge: 'PARTNER',
          badgeColor: AppColors.primary,
          registrationFee: 'PARTNERSHIP',
          requirements: 'Banking License',
          keyFeatures: ['Custom branding', 'Partner dashboard', 'Client management'],
          capabilities: [
            'White-label platform access with custom branding',
            'Manage bank clients and their RWA investments',
            'Integrate with existing banking infrastructure',
            'Compliance reporting and regulatory oversight',
            'Custom fee structures and revenue sharing',
            'Dedicated partner support and training'
          ],
          earnings: [
            'Revenue sharing from client activities',
            'Partnership fee structures',
            'Cross-selling opportunities',
            'Strategic banking integration benefits'
          ],
        );

      case UserRole.merchantAdmin:
        return RoleInfo(
          title: 'Bank Admin',
          subtitle: 'Bank administration and customer management',
          icon: Icons.admin_panel_settings,
          color: Colors.blue,
          badge: 'ADMIN',
          badgeColor: Colors.blue,
          registrationFee: 'EMPLOYEE',
          requirements: 'Bank Employment',
          keyFeatures: ['Customer management', 'Asset oversight', 'Revenue tracking'],
          capabilities: [
            'Manage bank customer accounts and investments',
            'Oversee asset proposals and approvals',
            'Monitor transaction processing and settlements',
            'Access comprehensive analytics and reporting',
            'Configure bank profile and branding settings',
            'Handle compliance and regulatory requirements'
          ],
          earnings: [
            'Employee salary and benefits',
            'Performance-based bonuses',
            'Professional development opportunities',
            'Bank revenue participation programs'
          ],
        );

      case UserRole.merchantOperations:
        return RoleInfo(
          title: 'Bank Operations',
          subtitle: 'Bank operations and transaction processing',
          icon: Icons.business_center,
          color: Colors.teal,
          badge: 'OPS',
          badgeColor: Colors.teal,
          registrationFee: 'EMPLOYEE',
          requirements: 'Operations Team',
          keyFeatures: ['Transaction processing', 'Settlement management', 'Operational oversight'],
          capabilities: [
            'Process and verify financial transactions',
            'Manage settlement processes and reconciliation',
            'Monitor operational metrics and performance',
            'Handle customer support and operations issues',
            'Coordinate with compliance and risk management',
            'Maintain operational documentation and procedures'
          ],
          earnings: [
            'Operations team salary structure',
            'Efficiency and accuracy bonuses',
            'Cross-training opportunities',
            'Operational excellence rewards'
          ],
        );
    }
  }
}

class RoleInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final Color badgeColor;
  final String registrationFee;
  final String requirements;
  final List<String> keyFeatures;
  final List<String> capabilities;
  final List<String> earnings;

  RoleInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    required this.badgeColor,
    required this.registrationFee,
    required this.requirements,
    required this.keyFeatures,
    required this.capabilities,
    required this.earnings,
  });
}