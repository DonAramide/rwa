import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeService {
  /// Get background color based on current theme
  static Color getBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkBackground : AppColors.background;
  }

  /// Get surface color based on current theme
  static Color getSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSurface : AppColors.surface;
  }

  /// Get surface variant color based on current theme
  static Color getSurfaceVariant(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
  }

  /// Get primary text color based on current theme
  static Color getTextPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  }

  /// Get secondary text color based on current theme
  static Color getTextSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  }

  /// Get tertiary text color based on current theme
  static Color getTextTertiary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
  }

  /// Get border color based on current theme
  static Color getBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkBorder : AppColors.border;
  }

  /// Get outline color based on current theme
  static Color getOutline(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkOutline : AppColors.outline;
  }

  /// Get divider color based on current theme
  static Color getDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkDivider : AppColors.divider;
  }

  /// Get card background color - context-aware
  static Color getCardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSurface : Colors.white;
  }

  /// Get container background color for content areas
  static Color getContainerBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSurfaceVariant : AppColors.backgroundLight;
  }

  /// Check if current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get text color that contrasts with background
  static Color getContrastingTextColor(BuildContext context, Color backgroundColor) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.textPrimary : AppColors.darkTextPrimary;
  }

  /// Get a color with proper contrast for the current theme
  static Color getThemedColor(BuildContext context, Color lightColor, Color darkColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColor : lightColor;
  }

  /// Get shadow color based on current theme
  static Color getShadowColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkShadow : AppColors.shadow;
  }

  /// Get scaffold background color
  static Color getScaffoldBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkBackground : AppColors.background;
  }

  /// Get app bar background color
  static Color getAppBarBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSurface : AppColors.surface;
  }

  /// Get appropriate text color for colored backgrounds (status colors, etc.)
  static Color getTextOnColoredBackground(Color backgroundColor) {
    // For colored backgrounds, always use white or very light text for readability
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.4 ? Colors.black87 : Colors.white;
  }

  /// Get theme-appropriate icon color
  static Color getIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  }

  /// Get disabled text color
  static Color getDisabledTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
  }

  /// Get input field background color
  static Color getInputBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSurfaceVariant : AppColors.backgroundLight;
  }
}