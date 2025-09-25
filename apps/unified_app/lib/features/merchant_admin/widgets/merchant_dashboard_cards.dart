import 'package:flutter/material.dart';
import '../../../models/merchant_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MerchantDashboardCards extends StatelessWidget {
  final MerchantDashboardAnalytics analytics;

  const MerchantDashboardCards({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildCard(
            'Total AUM',
            '\$${(analytics.totalAum / 1000000).toStringAsFixed(1)}M',
            Icons.account_balance_wallet,
            AppColors.primary,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            'Active Investors',
            analytics.activeInvestors.toString(),
            Icons.people,
            AppColors.success,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            'Pending Approvals',
            analytics.pendingApprovals.toString(),
            Icons.pending_actions,
            AppColors.warning,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            'Revenue Earned',
            '\$${(analytics.revenueEarned / 1000).toStringAsFixed(0)}K',
            Icons.monetization_on,
            AppColors.info,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
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
}