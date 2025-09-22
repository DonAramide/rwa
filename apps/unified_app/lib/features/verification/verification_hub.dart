import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class VerificationHub extends StatelessWidget {
  const VerificationHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Hub')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Verification Hub', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text('Coming soon...', style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}