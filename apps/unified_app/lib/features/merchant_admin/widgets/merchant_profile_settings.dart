import 'package:flutter/material.dart';
import '../../../models/merchant_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MerchantProfileSettings extends StatelessWidget {
  final MerchantProfile? profile;

  const MerchantProfileSettings({
    super.key,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Settings',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (profile != null) ...[
            _buildProfileCard(isDark),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 64,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Profile Settings',
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure your merchant profile',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
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
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile!.name,
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile!.legalName,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  profile!.status.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Country', profile!.country, isDark),
          _buildInfoRow('Domain', profile!.domain, isDark),
          if (profile!.contactInfo != null) ...[
            _buildInfoRow('Contact', profile!.contactInfo!.email, isDark),
          ],
          _buildInfoRow(
            'Commission Rate',
            '${(profile!.commissionRateBps / 100).toStringAsFixed(2)}%',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}