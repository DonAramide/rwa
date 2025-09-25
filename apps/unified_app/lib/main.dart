import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notifications_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/onboarding/investor_agent_onboarding.dart';
import 'features/auth/onboarding/professional_agent_onboarding.dart';
import 'features/auth/onboarding/verifier_onboarding.dart';
import 'features/auth/onboarding/admin_onboarding.dart';
import 'features/dashboard/unified_dashboard.dart';
import 'features/marketplace/marketplace_screen.dart';
import 'features/portfolio/portfolio_screen.dart';
import 'features/verification/verification_hub.dart';
import 'features/admin/admin_panel.dart';
import 'features/admin/api_key_management_screen.dart';
import 'features/asset_detail/asset_detail_screen.dart';
import 'features/rofr/rofr_screen.dart';
import 'features/wallet/wallet_connect_screen.dart';
import 'features/wallet/wallet_dashboard_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/asset_detail/asset_telemetry_screen.dart';
import 'features/super_admin/super_admin_dashboard.dart';
import 'features/rofr/rofr_screen.dart';
import 'features/rofr/shareholder_directory.dart';
import 'features/asset_upload/unified_asset_upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI for better font rendering
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const ProviderScope(child: UnifiedRWAApp()));
}

class UnifiedRWAApp extends ConsumerWidget {
  const UnifiedRWAApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        // Authentication routes
        GoRoute(
          path: '/login',
          builder: (ctx, st) => const LoginScreen(),
        ),
        GoRoute(
          path: '/role-selection',
          builder: (ctx, st) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (ctx, st) => const ForgotPasswordScreen(),
        ),
        
        // Onboarding routes
        GoRoute(
          path: '/onboarding/investor-agent',
          builder: (ctx, st) => const InvestorAgentOnboarding(),
        ),
        GoRoute(
          path: '/onboarding/professional-agent',
          builder: (ctx, st) => const ProfessionalAgentOnboarding(),
        ),
        GoRoute(
          path: '/onboarding/verifier',
          builder: (ctx, st) => const VerifierOnboarding(),
        ),
        GoRoute(
          path: '/onboarding/admin',
          builder: (ctx, st) => const AdminOnboarding(),
        ),
        
        // Main app routes
        GoRoute(
          path: '/',
          builder: (ctx, st) => const HomeScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (ctx, st) => const UnifiedDashboard(),
        ),
        GoRoute(
          path: '/marketplace',
          builder: (ctx, st) => const MarketplaceScreen(),
        ),
        GoRoute(
          path: '/portfolio',
          builder: (ctx, st) => const PortfolioScreen(),
        ),
        GoRoute(
          path: '/verification',
          builder: (ctx, st) => const VerificationHub(),
        ),
        GoRoute(
          path: '/admin',
          builder: (ctx, st) => const AdminPanel(),
        ),
        GoRoute(
          path: '/admin/api-keys',
          builder: (ctx, st) => const ApiKeyManagementScreen(),
        ),
        GoRoute(
          path: '/asset/:id',
          builder: (ctx, st) => AssetDetailScreen(id: st.pathParameters['id']!),
        ),
        GoRoute(
          path: '/rofr',
          builder: (ctx, st) => const RofrScreen(),
        ),
        GoRoute(
          path: '/wallet',
          builder: (ctx, st) => const WalletDashboardScreen(),
        ),
        GoRoute(
          path: '/wallet/connect',
          builder: (ctx, st) => const WalletConnectScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (ctx, st) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/asset/:id/telemetry',
          builder: (ctx, st) => AssetTelemetryScreen(
            assetId: st.pathParameters['id']!,
            assetTitle: st.uri.queryParameters['title'] ?? 'Asset',
          ),
        ),
        GoRoute(
          path: '/super-admin',
          builder: (ctx, st) => const SuperAdminDashboard(),
        ),
        GoRoute(
          path: '/rofr',
          builder: (ctx, st) => const RofrScreen(),
        ),
        GoRoute(
          path: '/shareholders/:assetId',
          builder: (ctx, st) => ShareholderDirectoryScreen(
            assetId: st.pathParameters['assetId']!,
            assetTitle: st.uri.queryParameters['title'] ?? 'Asset',
          ),
        ),
        GoRoute(
          path: '/asset-upload',
          builder: (ctx, st) => const UnifiedAssetUploadScreen(),
        ),
      ],
    );

    final themeNotifier = ref.watch(themeProvider.notifier);
    final currentThemeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'RWA Platform - Unified App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Initialize notifications provider when authenticated
    if (authState.isAuthenticated) {
      Future.microtask(() {
        ref.read(notificationProvider.notifier).loadNotifications();
      });
    }
    
    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('RWA Investor')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to RWA Investment Platform'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign In / Sign Up'),
              ),
            ],
          ),
        ),
      );
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'RWA Investor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        backgroundColor: AppColors.getSurface(isDark),
        elevation: 0,
        actions: [
          // Notification bell with badge
          Consumer(
            builder: (context, ref, child) {
              final unreadCount = ref.watch(unreadNotificationCountProvider);
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => context.go('/notifications'),
                    icon: Icon(
                      Icons.notifications,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () {
              final themeNotifier = ref.read(themeProvider.notifier);
              final currentTheme = ref.read(themeProvider);
              switch (currentTheme) {
                case AppThemeMode.light:
                  themeNotifier.setTheme(AppThemeMode.dark);
                  break;
                case AppThemeMode.dark:
                  themeNotifier.setTheme(AppThemeMode.system);
                  break;
                case AppThemeMode.system:
                  themeNotifier.setTheme(AppThemeMode.light);
                  break;
              }
            },
            icon: Icon(
              () {
                final currentTheme = ref.watch(themeProvider);
                return currentTheme == AppThemeMode.light
                    ? Icons.light_mode
                    : currentTheme == AppThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.brightness_auto;
              }(),
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            icon: Icon(
              Icons.logout,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authState.email ?? 'Investor',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ready to explore new investment opportunities?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    title: 'Marketplace',
                    subtitle: 'Browse assets',
                    icon: Icons.store,
                    color: AppColors.success,
                    onTap: () => context.go('/market'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    title: 'Portfolio',
                    subtitle: 'View holdings',
                    icon: Icons.account_balance_wallet,
                    color: AppColors.warning,
                    onTap: () => context.go('/portfolio'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    title: 'Wallet',
                    subtitle: 'Crypto payments',
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.portfolio,
                    onTap: () => context.go('/wallet'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    title: 'Verification',
                    subtitle: 'Asset verification',
                    icon: Icons.verified,
                    color: AppColors.verified,
                    onTap: () => context.go('/verification'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    title: 'Upload Asset',
                    subtitle: 'List new asset',
                    icon: Icons.upload,
                    color: AppColors.success,
                    onTap: () => context.go('/asset-upload'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    title: 'ROFR',
                    subtitle: 'Share transactions',
                    icon: Icons.gavel,
                    color: AppColors.portfolio,
                    onTap: () => context.go('/rofr'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Investment highlights
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.getSurface(isDark),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadow(isDark),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Investment Highlights',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildHighlightItem('Real Estate Assets', '15+ Available', Icons.home),
                  _buildHighlightItem('Vehicle Investments', '8 Options', Icons.local_shipping),
                  _buildHighlightItem('Land Opportunities', '12 Plots', Icons.landscape),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(isDark),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightItem(String title, String value, IconData icon) {
    return Consumer(
      builder: (context, ref, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.getTextSecondary(isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.getTextSecondary(isDark),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



