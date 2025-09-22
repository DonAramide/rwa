import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AssetDetailScreen extends StatelessWidget {
  final String id;
  
  const AssetDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Asset Details - $id')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Asset Details', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text('Asset ID: $id', style: AppTextStyles.body1),
            const SizedBox(height: 8),
            Text('Coming soon...', style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}