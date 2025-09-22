import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wallet.dart';
import '../../providers/wallet_provider.dart';

class WalletConnectScreen extends ConsumerWidget {
  const WalletConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Connect Wallet',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 32),

            // Wallet Options
            _buildWalletOptions(context, ref, walletState),
            const SizedBox(height: 32),

            // Features Section
            _buildFeatures(),
            const SizedBox(height: 32),

            // Security Notice
            _buildSecurityNotice(),

            // Error Display
            if (walletState.error != null) ...[
              const SizedBox(height: 24),
              _buildErrorMessage(walletState.error!, ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Your Crypto Wallet',
          style: AppTextStyles.heading1.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          'Choose your preferred wallet to start investing in real-world assets using cryptocurrency.',
          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildWalletOptions(BuildContext context, WidgetRef ref, WalletState walletState) {
    final supportedWallets = [
      WalletType.metamask,
      WalletType.browser,
      WalletType.walletConnect,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Wallets',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        ...supportedWallets.map((walletType) => _buildWalletOption(
          context,
          ref,
          walletType,
          walletState.isConnecting,
        )),
      ],
    );
  }

  Widget _buildWalletOption(
    BuildContext context,
    WidgetRef ref,
    WalletType walletType,
    bool isConnecting,
  ) {
    final isMetaMask = walletType == WalletType.metamask;
    final walletService = ref.read(walletServiceProvider);

    bool isAvailable = true;
    String? unavailableReason;

    if (isMetaMask && !walletService.isMetaMaskAvailable) {
      isAvailable = false;
      unavailableReason = 'MetaMask not installed';
    } else if (walletType == WalletType.browser && !walletService.isEthereumAvailable) {
      isAvailable = false;
      unavailableReason = 'No Ethereum provider found';
    } else if (walletType == WalletType.walletConnect) {
      isAvailable = false;
      unavailableReason = 'Coming soon';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isAvailable && !isConnecting
              ? () => _connectWallet(context, ref, walletType)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAvailable
                    ? AppColors.border
                    : AppColors.border.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Wallet Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getWalletIcon(walletType),
                    size: 24,
                    color: isAvailable ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),

                // Wallet Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        walletType.displayName,
                        style: AppTextStyles.heading4.copyWith(
                          color: isAvailable
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAvailable
                            ? _getWalletDescription(walletType)
                            : unavailableReason!,
                        style: AppTextStyles.body2.copyWith(
                          color: isAvailable
                              ? AppColors.textSecondary
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status/Action
                if (isConnecting) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ] else if (!isAvailable && isMetaMask) ...[
                  TextButton(
                    onPressed: () => _openMetaMaskInstall(),
                    child: const Text('Install'),
                  ),
                ] else if (isAvailable) ...[
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.security,
        'title': 'Secure Transactions',
        'description': 'All transactions are secured by blockchain technology',
      },
      {
        'icon': Icons.speed,
        'title': 'Fast Payments',
        'description': 'Instant cryptocurrency payments for asset investments',
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Multiple Currencies',
        'description': 'Support for ETH, USDC, USDT and more',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Connect Your Wallet?',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureItem(
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['description'] as String,
        )),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your wallet credentials are never stored on our servers. All transactions are processed securely through your wallet.',
              style: AppTextStyles.body2.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.body2.copyWith(color: AppColors.error),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(walletProvider.notifier).clearError(),
            icon: Icon(
              Icons.close,
              color: AppColors.error,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWalletIcon(WalletType walletType) {
    switch (walletType) {
      case WalletType.metamask:
        return Icons.account_balance_wallet;
      case WalletType.walletConnect:
        return Icons.qr_code;
      case WalletType.browser:
        return Icons.web;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _getWalletDescription(WalletType walletType) {
    switch (walletType) {
      case WalletType.metamask:
        return 'Connect using MetaMask browser extension';
      case WalletType.walletConnect:
        return 'Scan QR code with your mobile wallet';
      case WalletType.browser:
        return 'Connect using any Ethereum-compatible browser wallet';
      default:
        return 'Connect your crypto wallet';
    }
  }

  Future<void> _connectWallet(BuildContext context, WidgetRef ref, WalletType walletType) async {
    await ref.read(walletProvider.notifier).connectWallet(walletType);

    // If connection successful, go back
    final walletState = ref.read(walletProvider);
    if (walletState.isConnected && context.mounted) {
      Navigator.pop(context);
    }
  }

  void _openMetaMaskInstall() {
    // In a real app, you'd open the MetaMask installation page
    print('Opening MetaMask installation page...');
  }
}