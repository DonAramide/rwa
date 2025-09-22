import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary colors
  static const Color secondary = Color(0xFF64748B);
  static const Color secondaryLight = Color(0xFF94A3B8);
  static const Color secondaryDark = Color(0xFF475569);

  // Background colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF1F5F9);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Border colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFCBD5E1);
  static const Color outline = Color(0xFFE2E8F0);

  // Divider colors
  static const Color divider = Color(0xFFE2E8F0);

  // Shadow colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x26000000);

  // Glass morphism colors
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);

  // Cloud background gradient colors
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color powderBlue = Color(0xFFB0E0E6);
  static const Color aliceBlue = Color(0xFFF0F8FF);
  static const Color cloudWhite = Color(0xFFFFFFFF);

  // Investment specific colors
  static const Color investment = Color(0xFF059669);
  static const Color investmentLight = Color(0xFF10B981);
  static const Color investmentDark = Color(0xFF047857);

  static const Color portfolio = Color(0xFF7C3AED);
  static const Color portfolioLight = Color(0xFF8B5CF6);
  static const Color portfolioDark = Color(0xFF6D28D9);

  // KYC Status colors
  static const Color kycPending = Color(0xFFF59E0B);
  static const Color kycApproved = Color(0xFF10B981);
  static const Color kycRejected = Color(0xFFEF4444);

  // Asset status colors
  static const Color assetActive = Color(0xFF10B981);
  static const Color assetInactive = Color(0xFF64748B);
  static const Color assetPending = Color(0xFFF59E0B);

  // Verification colors
  static const Color verified = Color(0xFF10B981);
  static const Color unverified = Color(0xFFEF4444);
  static const Color pendingVerification = Color(0xFFF59E0B);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkOutline = Color(0xFF475569);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkDivider = Color(0xFF475569);

  // Dark mode text colors
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Dark mode glass morphism
  static const Color darkGlass = Color(0x1AFFFFFF);
  static const Color darkGlassBorder = Color(0x4DFFFFFF);

  // Dark mode shadow
  static const Color darkShadow = Color(0x40000000);
  static const Color darkShadowLight = Color(0x26000000);
  static const Color darkShadowDark = Color(0x66000000);

  // Theme-aware getters
  static Color getBackground(bool isDark) => isDark ? darkBackground : background;
  static Color getSurface(bool isDark) => isDark ? darkSurface : surface;
  static Color getSurfaceVariant(bool isDark) => isDark ? darkSurfaceVariant : surfaceVariant;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : textPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : textSecondary;
  static Color getTextTertiary(bool isDark) => isDark ? darkTextTertiary : textTertiary;
  static Color getOutline(bool isDark) => isDark ? darkOutline : outline;
  static Color getBorder(bool isDark) => isDark ? darkBorder : border;
  static Color getDivider(bool isDark) => isDark ? darkDivider : divider;
  static Color getShadow(bool isDark) => isDark ? darkShadow : shadow;
}