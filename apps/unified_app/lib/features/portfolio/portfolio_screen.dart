import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/asset.dart';
import '../../providers/rofr_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/portfolio/portfolio_performance_chart.dart';
import '../../widgets/portfolio/portfolio_analysis_widget.dart';
import '../../widgets/wallet/wallet_connection_widget.dart';
import '../../widgets/real_time_status_widget.dart';
import '../../widgets/recent_transactions_widget.dart';
import '../../providers/transactions_provider.dart';
import '../../core/theme/theme_service.dart';
import '../../services/portfolio_export_service.dart';
import '../../services/real_time_update_service.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    // Load portfolio data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(portfolioProvider.notifier).loadPortfolio();
      ref.read(transactionsProvider.notifier).refreshTransactions();
      // Start real-time updates
      ref.read(realTimeUpdateServiceProvider).startUpdates();
      ref.read(realTimeUpdateStatusProvider.notifier).state =
          ref.read(realTimeUpdateStatusProvider).copyWith(isActive: true);
    });
  }

  @override
  void dispose() {
    // Stop real-time updates when leaving screen
    ref.read(realTimeUpdateServiceProvider).stopUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioProvider);
    final summary = ref.watch(portfolioSummaryProvider);
    final holdings = ref.watch(holdingsProvider);
    return Scaffold(
      backgroundColor: ThemeService.getScaffoldBackground(context),
      appBar: AppBar(
        title: Text(
          'My Portfolio',
          style: AppTextStyles.heading2.copyWith(color: ThemeService.getTextPrimary(context)),
        ),
        backgroundColor: ThemeService.getAppBarBackground(context),
        elevation: 0,
        actions: [
          // Real-time status indicator
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: RealTimeStatusWidget(compact: true),
            ),
          ),
          // Export Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Portfolio',
            onSelected: (value) => _handleExport(value, holdings, summary),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 20, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Export as CSV'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => ref.read(portfolioProvider.notifier).refreshPortfolio(),
            icon: portfolioState.isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: portfolioState.isLoading && holdings.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : portfolioState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error loading portfolio', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(portfolioState.error!, style: AppTextStyles.body2),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(portfolioProvider.notifier).loadPortfolio(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(portfolioProvider.notifier).refreshPortfolio(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // Portfolio Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Portfolio Value',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${summary?.totalValue.toStringAsFixed(2) ?? '0.00'}',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem('Assets Owned', summary?.totalHoldings.toString() ?? '0'),
                      ),
                      Expanded(
                        child: _buildSummaryItem('Total Return', '${summary?.totalReturn.toStringAsFixed(1) ?? '0.0'}%'),
                      ),
                      Expanded(
                        child: _buildSummaryItem('Monthly Income', '\$${summary?.monthlyIncome.toStringAsFixed(2) ?? '0.00'}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Performance Chart Section
            const PortfolioPerformanceChart(
              title: 'Portfolio Performance',
              height: 300,
              showBenchmark: true,
            ),

            if (holdings.isNotEmpty)
              const SizedBox(height: 32),

            // Wallet Section
            WalletConnectionWidget(
              showBalances: true,
              onConnected: () {
                // Refresh portfolio data when wallet connects
                ref.read(portfolioProvider.notifier).refreshPortfolio();
              },
            ),

            const SizedBox(height: 32),

            // Real-Time Updates Section
            RealTimeStatusWidget(
              showDetails: true,
            ),

            const SizedBox(height: 32),

            // Portfolio Analysis Section
            if (holdings.isNotEmpty)
              PortfolioAnalysisWidget(
                holdings: holdings,
                onRefresh: () => ref.read(portfolioProvider.notifier).refreshPortfolio(),
              ),

            if (holdings.isNotEmpty)
              const SizedBox(height: 32),

            // Recent Transactions Section
            RecentTransactionsWidget(
              compact: false,
              limit: 8,
            ),

            const SizedBox(height: 32),

            // Holdings Section
            Text(
              'Your Holdings',
              style: AppTextStyles.heading3.copyWith(
                color: ThemeService.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 16),

            // Display holdings from provider
            if (holdings.isNotEmpty)
              ...holdings.map((holding) => _buildHoldingFromApiCard(holding)),
            if (holdings.isEmpty && !portfolioState.isLoading)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ThemeService.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 64,
                      color: ThemeService.getTextSecondary(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Holdings Found',
                      style: AppTextStyles.heading3.copyWith(
                        color: ThemeService.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start investing to see your portfolio here',
                      style: AppTextStyles.body2.copyWith(
                        color: ThemeService.getTextSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textOnPrimary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingFromApiCard(Holding holding) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAssetIcon(holding.assetType),
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
                        holding.assetTitle,
                        style: AppTextStyles.heading4.copyWith(
                          color: ThemeService.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated ${_formatTimeAgo(holding.updatedAt)}',
                        style: AppTextStyles.body2.copyWith(
                          color: ThemeService.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: ThemeService.getTextSecondary(context),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'sell',
                      child: Row(
                        children: [
                          Icon(Icons.sell, size: 20, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Text('Sell Shares'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'sell') {
                      _showSellSharesFromApiDialog(holding);
                    } else if (value == 'details') {
                      // Navigate to asset details
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Holdings details
            Row(
              children: [
                Expanded(
                  child: _buildDetailColumn('Balance', holding.balance.toStringAsFixed(2)),
                ),
                Expanded(
                  child: _buildDetailColumn('Value', '\$${holding.value.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildDetailColumn('Return', '${holding.returnPercent >= 0 ? '+' : ''}${holding.returnPercent.toStringAsFixed(1)}%',
                    textColor: holding.returnPercent >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
                Expanded(
                  child: _buildDetailColumn('Monthly Income', '\$${holding.monthlyIncome.toStringAsFixed(2)}'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Locked vs Available balance
            if (holding.lockedBalance > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Locked Balance',
                        style: AppTextStyles.caption.copyWith(
                          color: ThemeService.getTextSecondary(context),
                        ),
                      ),
                      Text(
                        '${holding.lockedBalance.toStringAsFixed(2)} / ${holding.balance.toStringAsFixed(2)}',
                        style: AppTextStyles.caption.copyWith(
                          color: ThemeService.getTextSecondary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: holding.lockedBalance / holding.balance,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingCard(PortfolioHolding holding) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAssetIcon(holding.asset.type),
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
                        holding.asset.title,
                        style: AppTextStyles.heading4.copyWith(
                          color: ThemeService.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        holding.asset.location?.shortAddress ?? 'Location not available',
                        style: AppTextStyles.body2.copyWith(
                          color: ThemeService.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: ThemeService.getTextSecondary(context),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'sell',
                      child: Row(
                        children: [
                          Icon(Icons.sell, size: 20, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Text('Sell Shares'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'sell') {
                      _showSellSharesDialog(holding);
                    } else if (value == 'details') {
                      // Navigate to asset details
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Holdings details
            Row(
              children: [
                Expanded(
                  child: _buildDetailColumn('Shares Owned', holding.sharesOwned.toString()),
                ),
                Expanded(
                  child: _buildDetailColumn('Purchase Price', '\$${holding.avgPurchasePrice.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildDetailColumn('Current Value', '\$${holding.currentValue.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildDetailColumn(
                    'P&L',
                    '${holding.profitLoss >= 0 ? '+' : ''}\$${holding.profitLoss.toStringAsFixed(2)}',
                    textColor: holding.profitLoss >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ownership percentage bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ownership',
                      style: AppTextStyles.caption.copyWith(
                        color: ThemeService.getTextSecondary(context),
                      ),
                    ),
                    Text(
                      '${holding.ownershipPercentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: ThemeService.getTextSecondary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: holding.ownershipPercentage / 100,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, {Color? textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showSellSharesDialog(PortfolioHolding holding) {
    int sharesToSell = 1;
    double pricePerShare = holding.avgPurchasePrice;
    String notes = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Sell Shares',
            style: AppTextStyles.heading3,
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.asset.title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'You own ${holding.sharesOwned} shares',
                  style: AppTextStyles.body2.copyWith(
                    color: ThemeService.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 24),

                // Number of shares to sell
                Text(
                  'Shares to sell:',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: sharesToSell.toDouble(),
                        min: 1,
                        max: holding.sharesOwned.toDouble(),
                        divisions: holding.sharesOwned - 1,
                        label: sharesToSell.toString(),
                        onChanged: (value) {
                          setState(() {
                            sharesToSell = value.round();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 60,
                      child: Text(
                        sharesToSell.toString(),
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price per share
                Text(
                  'Price per share (\$):',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter price per share',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    pricePerShare = double.tryParse(value) ?? pricePerShare;
                  },
                  controller: TextEditingController(
                    text: pricePerShare.toStringAsFixed(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Total value
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Value:',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${(sharesToSell * pricePerShare).toStringAsFixed(2)}',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                Text(
                  'Notes (optional):',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => notes = value,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add a note for potential buyers...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ROFR explanation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Right of First Refusal: Existing shareholders will have 48 hours to purchase your shares before they\'re offered to the public market.',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _initiateSale(holding, sharesToSell, pricePerShare, notes),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: const Text(
                'Initiate Sale',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initiateSale(
    PortfolioHolding holding,
    int sharesToSell,
    double pricePerShare,
    String notes,
  ) async {
    Navigator.of(context).pop();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Initiating ROFR process...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Create ROFR offer
    final offerId = await ref.read(rofrProvider.notifier).createRofrOffer(
      assetId: holding.asset.id.toString(),
      assetTitle: holding.asset.title,
      sharesOffered: sharesToSell,
      pricePerShare: pricePerShare,
      notes: notes.isNotEmpty ? notes : null,
    );

    if (mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            offerId != null
                ? 'ROFR offer created! Existing shareholders have been notified.'
                : 'No existing shareholders found. Your shares will be listed on the market.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showSellSharesFromApiDialog(Holding holding) {
    double sharesToSell = 1.0;
    double pricePerShare = holding.value / holding.balance;
    String notes = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Sell Shares',
            style: AppTextStyles.heading3,
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.assetTitle,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'You have ${holding.balance.toStringAsFixed(2)} shares available',
                  style: AppTextStyles.body2.copyWith(
                    color: ThemeService.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 24),

                // Number of shares to sell
                Text(
                  'Shares to sell:',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: sharesToSell,
                        min: 0.1,
                        max: holding.balance,
                        divisions: (holding.balance * 10).round(),
                        label: sharesToSell.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            sharesToSell = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 80,
                      child: Text(
                        sharesToSell.toStringAsFixed(1),
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price per share
                Text(
                  'Price per share (\$):',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter price per share',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    pricePerShare = double.tryParse(value) ?? pricePerShare;
                  },
                  controller: TextEditingController(
                    text: pricePerShare.toStringAsFixed(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Total value
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Value:',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${(sharesToSell * pricePerShare).toStringAsFixed(2)}',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                Text(
                  'Notes (optional):',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => notes = value,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add a note for potential buyers...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ROFR explanation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Right of First Refusal: Existing shareholders will have 48 hours to purchase your shares before they\'re offered to the public market.',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _initiateApiSale(holding, sharesToSell, pricePerShare, notes),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: const Text(
                'Initiate Sale',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initiateApiSale(
    Holding holding,
    double sharesToSell,
    double pricePerShare,
    String notes,
  ) async {
    Navigator.of(context).pop();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Initiating ROFR process...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Create ROFR offer
    final offerId = await ref.read(rofrProvider.notifier).createRofrOffer(
      assetId: holding.assetId,
      assetTitle: holding.assetTitle,
      sharesOffered: sharesToSell.round(),
      pricePerShare: pricePerShare,
      notes: notes.isNotEmpty ? notes : null,
    );

    if (mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            offerId != null
                ? 'ROFR offer created! Existing shareholders have been notified.'
                : 'No existing shareholders found. Your shares will be listed on the market.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }


  IconData _getAssetIcon(String type) {
    switch (type.toLowerCase()) {
      case 'house':
      case 'residential':
        return Icons.home;
      case 'hotel':
      case 'hospitality':
        return Icons.hotel;
      case 'truck':
      case 'vehicle':
      case 'transport':
        return Icons.local_shipping;
      case 'land':
      case 'agriculture':
        return Icons.landscape;
      case 'office':
      case 'commercial':
        return Icons.business;
      case 'warehouse':
      case 'industrial':
        return Icons.warehouse;
      default:
        return Icons.account_balance;
    }
  }

  List<PortfolioHolding> _getMockHoldings() {
    return [
      PortfolioHolding(
        asset: Asset(
          id: 1,
          title: 'Premium Office Complex Downtown',
          description: 'Prime commercial real estate in downtown business district',
          type: 'house',
          spvId: 'SPV001',
          status: 'active',
          nav: '850000',
          verificationRequired: false,
          createdAt: DateTime.now().subtract(Duration(days: 180)),
          images: [],
          location: AssetLocation(
            latitude: 40.7128,
            longitude: -74.0060,
            address: '123 Business Ave',
            city: 'New York',
            state: 'NY',
            country: 'USA',
          ),
        ),
        sharesOwned: 100,
        avgPurchasePrice: 120.0,
        currentValue: 12500.0,
        ownershipPercentage: 10.0,
        purchaseDate: DateTime.now().subtract(Duration(days: 180)),
      ),
      PortfolioHolding(
        asset: Asset(
          id: 2,
          title: 'Luxury Residential Apartments',
          description: 'High-end residential complex with modern amenities',
          type: 'hotel',
          spvId: 'SPV002',
          status: 'active',
          nav: '1200000',
          verificationRequired: false,
          createdAt: DateTime.now().subtract(Duration(days: 120)),
          images: [],
          location: AssetLocation(
            latitude: 34.0522,
            longitude: -118.2437,
            address: '456 Luxury Blvd',
            city: 'Los Angeles',
            state: 'CA',
            country: 'USA',
          ),
        ),
        sharesOwned: 75,
        avgPurchasePrice: 195.0,
        currentValue: 15000.0,
        ownershipPercentage: 5.0,
        purchaseDate: DateTime.now().subtract(Duration(days: 120)),
      ),
      PortfolioHolding(
        asset: Asset(
          id: 3,
          title: 'Commercial Vehicle Fleet',
          description: 'Fleet of delivery trucks for logistics operations',
          type: 'truck',
          spvId: 'SPV003',
          status: 'active',
          nav: '500000',
          verificationRequired: false,
          createdAt: DateTime.now().subtract(Duration(days: 90)),
          images: [],
          location: AssetLocation(
            latitude: 41.8781,
            longitude: -87.6298,
            address: '789 Transport St',
            city: 'Chicago',
            state: 'IL',
            country: 'USA',
          ),
        ),
        sharesOwned: 100,
        avgPurchasePrice: 98.0,
        currentValue: 10000.0,
        ownershipPercentage: 20.0,
        purchaseDate: DateTime.now().subtract(Duration(days: 90)),
      ),
    ];
  }

  /// Handle export functionality
  Future<void> _handleExport(
    String format,
    List<Holding> holdings,
    PortfolioSummary? summary,
  ) async {
    if (holdings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No holdings to export'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Preparing ${format.toUpperCase()} export...'),
                ],
              ),
            ),
          ),
        ),
      );

      if (format == 'pdf') {
        await _exportToPdf(holdings, summary);
      } else if (format == 'csv') {
        await _exportToCsv(holdings, summary);
      }

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportToPdf(List<Holding> holdings, PortfolioSummary? summary) async {
    final pdfData = await PortfolioExportService.exportToPdf(
      holdings: holdings,
      summary: summary,
      investorName: 'Investor', // You can get this from auth state
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdfData,
      name: 'Portfolio_Statement_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: AppColors.textOnPrimary),
              const SizedBox(width: 8),
              Text('Portfolio PDF exported successfully'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportToCsv(List<Holding> holdings, PortfolioSummary? summary) async {
    final csvData = await PortfolioExportService.exportToCsv(
      holdings: holdings,
      summary: summary,
    );

    final fileName = 'Portfolio_Export_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final filePath = await PortfolioExportService.saveCsvToFile(csvData, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.table_chart, color: AppColors.textOnPrimary),
                const SizedBox(width: 8),
                Expanded(child: Text('CSV exported: $fileName.csv')),
              ],
            ),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Share',
              textColor: AppColors.textOnPrimary,
              onPressed: () => _shareFile(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      // If file saving fails, show data in a dialog for copying
      if (mounted) {
        _showCsvDataDialog(csvData, fileName);
      }
    }
  }

  void _shareFile(String filePath) {
    Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Portfolio Export',
      text: 'Here is my portfolio export from RWA Platform',
    );
  }

  void _showCsvDataDialog(String csvData, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('CSV Export Data'),
        content: Container(
          width: 400,
          height: 300,
          child: Column(
            children: [
              Text(
                'Copy the data below and save as $fileName.csv',
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      csvData,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class PortfolioHolding {
  final Asset asset;
  final int sharesOwned;
  final double avgPurchasePrice;
  final double currentValue;
  final double ownershipPercentage;
  final DateTime purchaseDate;

  double get profitLoss => currentValue - (sharesOwned * avgPurchasePrice);

  PortfolioHolding({
    required this.asset,
    required this.sharesOwned,
    required this.avgPurchasePrice,
    required this.currentValue,
    required this.ownershipPercentage,
    required this.purchaseDate,
  });
}