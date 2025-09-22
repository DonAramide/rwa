import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../core/theme/app_colors.dart';

class ThemeToggle extends ConsumerWidget {
  final bool showLabel;
  final bool isCompact;

  const ThemeToggle({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isCompact) {
      return IconButton(
        onPressed: () => _toggleTheme(themeNotifier, themeMode),
        icon: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: AppColors.getTextPrimary(isDark),
        ),
        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      );
    }

    return PopupMenuButton<AppThemeMode>(
      onSelected: (mode) => themeNotifier.setTheme(mode),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AppThemeMode.light,
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                color: themeMode == AppThemeMode.light
                    ? AppColors.primary
                    : AppColors.getTextSecondary(isDark),
              ),
              const SizedBox(width: 12),
              Text(
                'Light Mode',
                style: TextStyle(
                  color: themeMode == AppThemeMode.light
                      ? AppColors.primary
                      : AppColors.getTextPrimary(isDark),
                  fontWeight: themeMode == AppThemeMode.light
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (themeMode == AppThemeMode.light) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: AppThemeMode.dark,
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                color: themeMode == AppThemeMode.dark
                    ? AppColors.primary
                    : AppColors.getTextSecondary(isDark),
              ),
              const SizedBox(width: 12),
              Text(
                'Dark Mode',
                style: TextStyle(
                  color: themeMode == AppThemeMode.dark
                      ? AppColors.primary
                      : AppColors.getTextPrimary(isDark),
                  fontWeight: themeMode == AppThemeMode.dark
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (themeMode == AppThemeMode.dark) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: AppThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.brightness_auto,
                color: themeMode == AppThemeMode.system
                    ? AppColors.primary
                    : AppColors.getTextSecondary(isDark),
              ),
              const SizedBox(width: 12),
              Text(
                'System',
                style: TextStyle(
                  color: themeMode == AppThemeMode.system
                      ? AppColors.primary
                      : AppColors.getTextPrimary(isDark),
                  fontWeight: themeMode == AppThemeMode.system
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (themeMode == AppThemeMode.system) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.getOutline(isDark),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getThemeIcon(themeMode, isDark),
              size: 18,
              color: AppColors.getTextPrimary(isDark),
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                _getThemeLabel(themeMode),
                style: TextStyle(
                  color: AppColors.getTextPrimary(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.getTextSecondary(isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTheme(ThemeNotifier notifier, AppThemeMode currentMode) {
    switch (currentMode) {
      case AppThemeMode.light:
        notifier.setTheme(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        notifier.setTheme(AppThemeMode.system);
        break;
      case AppThemeMode.system:
        notifier.setTheme(AppThemeMode.light);
        break;
    }
  }

  IconData _getThemeIcon(AppThemeMode mode, bool isDark) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return isDark ? Icons.dark_mode : Icons.light_mode;
    }
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'Auto';
    }
  }
}