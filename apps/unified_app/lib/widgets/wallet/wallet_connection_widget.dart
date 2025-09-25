import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/wallet_provider.dart';
import '../../models/wallet.dart';

class WalletConnectionWidget extends ConsumerStatefulWidget {
  final bool showBalances;
  final VoidCallback? onConnected;

  const WalletConnectionWidget({
    super.key,
    this.showBalances = true,
    this.onConnected,
  });

  @override
  ConsumerState<WalletConnectionWidget> createState() => _WalletConnectionWidgetState();
}

class _WalletConnectionWidgetState extends ConsumerState<WalletConnectionWidget> {
  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final isConnected = ref.watch(isWalletConnectedProvider);

    if (!isConnected) {
      return _buildConnectionCard();
    }

    return _buildConnectedWalletCard(walletState);
  }

  Widget _buildConnectionCard() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Connect Wallet',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Connect your crypto wallet to view balances, make transactions, and participate in the RWA ecosystem.',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Wallet connection options
            Column(
              children: [
                _buildWalletOption(
                  title: 'MetaMask',
                  subtitle: 'Connect using MetaMask browser extension',
                  icon: Icons.extension,
                  onTap: () => _connectWallet(WalletType.metamask),
                ),
                const SizedBox(height: 12),
                _buildWalletOption(
                  title: 'WalletConnect',
                  subtitle: 'Connect using WalletConnect protocol',
                  icon: Icons.qr_code_scanner,
                  onTap: () => _connectWallet(WalletType.walletConnect),
                ),
                const SizedBox(height: 12),
                _buildWalletOption(
                  title: 'Coinbase Wallet',
                  subtitle: 'Connect using Coinbase Wallet',
                  icon: Icons.currency_bitcoin,
                  onTap: () => _connectWallet(WalletType.coinbaseWallet),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isConnecting = ref.watch(walletProvider).isConnecting;

    return GestureDetector(
      onTap: isConnecting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.background,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isConnecting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedWalletCard(WalletState walletState) {
    final wallet = walletState.connectedWallet!;
    final balances = walletState.balances;

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet Connected',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${wallet.address.substring(0, 6)}...${wallet.address.substring(wallet.address.length - 4)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'refresh',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Refresh Balances'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'network',
                      child: Row(
                        children: [
                          Icon(Icons.network_check, size: 20, color: AppColors.info),
                          const SizedBox(width: 8),
                          Text('Switch Network'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'disconnect',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Disconnect'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'refresh':
                        ref.read(walletProvider.notifier).refreshBalances();
                        break;
                      case 'network':
                        _showNetworkSelector();
                        break;
                      case 'disconnect':
                        _disconnectWallet();
                        break;
                    }
                  },
                ),
              ],
            ),

            if (widget.showBalances && balances.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Wallet Balances',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Balances grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: balances.entries.map((entry) =>
                  _buildBalanceCard(entry.key, entry.value)
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String symbol, double balance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            symbol,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            balance.toStringAsFixed(symbol == 'ETH' ? 4 : 2),
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connectWallet(WalletType walletType) async {
    try {
      await ref.read(walletProvider.notifier).connectWallet(walletType);
      if (widget.onConnected != null) {
        widget.onConnected!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect wallet: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _disconnectWallet() async {
    try {
      await ref.read(walletProvider.notifier).disconnectWallet();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to disconnect wallet: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showNetworkSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Switch Network',
          style: AppTextStyles.heading3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNetworkOption('1', 'Ethereum Mainnet', 'ETH'),
            _buildNetworkOption('137', 'Polygon', 'MATIC'),
            _buildNetworkOption('56', 'BNB Smart Chain', 'BNB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkOption(String chainId, String name, String symbol) {
    return ListTile(
      title: Text(name),
      subtitle: Text(symbol),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          symbol.substring(0, 1),
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () async {
        Navigator.of(context).pop();
        await ref.read(walletProvider.notifier).switchNetwork(chainId);
      },
    );
  }
}