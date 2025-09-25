import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_service.dart';
import '../../../widgets/recent_transactions_widget.dart';

class InvestorAgentDashboard extends ConsumerWidget {
  const InvestorAgentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(context),
          const SizedBox(height: 24),

          // Portfolio Overview
          _buildPortfolioOverview(context),
          const SizedBox(height: 24),

          // Investment Opportunities
          _buildInvestmentOpportunities(context),
          const SizedBox(height: 24),

          // Agent Activities
          _buildAgentActivities(context),
          const SizedBox(height: 24),

          // Recent Transactions
          RecentTransactionsWidget(
            compact: true,
            limit: 5,
            onViewAll: () {
              // Navigate to full transactions screen or show dialog
            },
          ),
          const SizedBox(height: 24),

          // Governance & Rewards
          _buildGovernanceSection(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeService.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeService.getBorder(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Investor-Agent Dashboard',
                style: AppTextStyles.heading2.copyWith(color: ThemeService.getTextPrimary(context)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome back! You\'re now an active investor and agent in the RWA ecosystem.',
            style: AppTextStyles.body1.copyWith(
              color: ThemeService.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'AUTO-UPGRADED TO AGENT',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Overview',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
              context,
                'Total Invested',
                '\$125,000',
                Icons.account_balance_wallet,
                AppColors.primary,
                '+12.5%',
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
              context,
                'Active Projects',
                '8',
                Icons.business,
                AppColors.info,
                '+2 new',
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
              context,
                'Monthly Return',
                '\$3,200',
                Icons.trending_up,
                AppColors.success,
                '+8.2%',
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
              context,
                'Agent Rewards',
                '\$450',
                Icons.stars,
                AppColors.warning,
                '+\$120',
                true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.getBorder(context)),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: AppTextStyles.caption.copyWith(
                    color: isPositive ? AppColors.success : AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentOpportunities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Investment Opportunities',
              style: AppTextStyles.heading3,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/marketplace'),
              child: Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: EdgeInsets.only(right: index == 2 ? 0 : 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeService.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeService.getBorder(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.home,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Premium Office Complex',
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Downtown Manhattan',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '\$2.5M',
                          style: AppTextStyles.heading3,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '12% APY',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.65,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '65% funded • 15 days left',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agent Activities',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeService.getCardBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeService.getBorder(context)),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'Project Monitoring',
                '8 active projects',
                Icons.monitor,
                AppColors.info,
                'All projects on track',
              ),
              const Divider(),
              _buildActivityItem(
                'Issue Flagging',
                '3 flags this month',
                Icons.flag,
                AppColors.warning,
                '+50 reputation points',
              ),
              const Divider(),
              _buildActivityItem(
                'Verification Requests',
                '2 pending',
                Icons.verified_user,
                AppColors.primary,
                'Est. completion: 3 days',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String status,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Governance & Rewards',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeService.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeService.getBorder(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Active Proposals',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '3 proposals',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your vote matters',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeService.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeService.getBorder(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: AppColors.warning,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reputation Score',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1,250 pts',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Top 15% of agents',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}