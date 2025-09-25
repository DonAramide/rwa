import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MerchantCustomerList extends StatelessWidget {
  const MerchantCustomerList({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Management',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Customer List',
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your customers and their investments',
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
      ),
    );
  }
}