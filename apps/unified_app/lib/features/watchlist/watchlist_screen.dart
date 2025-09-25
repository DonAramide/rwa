import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_service.dart';
import '../../models/asset.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/asset_card.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistState = ref.watch(watchlistProvider);
    final analytics = ref.read(watchlistProvider.notifier).getAnalytics();

    return Scaffold(
      backgroundColor: ThemeService.getScaffoldBackground(context),
      appBar: AppBar(
        title: Text(
          'My Watchlist',
          style: AppTextStyles.heading2.copyWith(color: ThemeService.getTextPrimary(context)),
        ),
        backgroundColor: ThemeService.getAppBarBackground(context),
        elevation: 0,
        actions: [
          // Clear watchlist button
          if (watchlistState.watchlistAssets.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearWatchlistDialog(context, ref);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 20, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Clear Watchlist'),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            onPressed: () => ref.read(watchlistProvider.notifier).refreshWatchlist(),
            icon: watchlistState.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: watchlistState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : watchlistState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error loading watchlist', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      Text(watchlistState.error!, style: AppTextStyles.body2),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(watchlistProvider.notifier).refreshWatchlist(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(watchlistProvider.notifier).refreshWatchlist(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Analytics Section
                        if (watchlistState.watchlistAssets.isNotEmpty) ...[
                          _buildAnalyticsSection(analytics),
                          const SizedBox(height: 32),
                        ],

                        // Watchlist Assets
                        if (watchlistState.watchlistAssets.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                'Watched Assets',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${watchlistState.watchlistAssets.length}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...watchlistState.watchlistAssets.map((asset) => _buildWatchlistAssetCard(
                            context,
                            ref,
                            asset,
                          )),
                        ] else ...[
                          _buildEmptyWatchlist(context),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAnalyticsSection(WatchlistAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeService.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeService.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Watchlist Analytics',
                style: AppTextStyles.heading3.copyWith(
                  color: ThemeService.getTextPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary Stats
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Assets',
                  analytics.totalAssets.toString(),
                  Icons.bookmark,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  'Avg NAV',
                  '\$${_formatCurrency(analytics.averageNav)}',
                  Icons.account_balance,
                  AppColors.success,
                ),
              ),
            ],
          ),

          if (analytics.assetTypes.isNotEmpty || analytics.locations.isNotEmpty) ...[
            const SizedBox(height: 20),

            // Asset Types
            if (analytics.assetTypes.isNotEmpty) ...[
              Text(
                'Asset Types',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analytics.assetTypes.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Text(
                      '${_formatAssetType(entry.key)} (${entry.value})',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            if (analytics.locations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Locations',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analytics.locations.entries.take(5).map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.info.withOpacity(0.2)),
                    ),
                    child: Text(
                      '${entry.key} (${entry.value})',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body2.copyWith(
                  color: ThemeService.getTextSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistAssetCard(BuildContext context, WidgetRef ref, Asset asset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    _getAssetIcon(asset.type),
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
                        asset.title,
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        asset.location?.city ?? 'Location not available',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_remove, size: 20, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Remove from Watchlist'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'view') {
                      context.push('/asset/${asset.id}');
                    } else if (value == 'remove') {
                      ref.read(watchlistProvider.notifier).removeFromWatchlist(asset.id.toString());
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailColumn('NAV', '\$${_formatCurrency(double.tryParse(asset.nav) ?? 0)}'),
                ),
                Expanded(
                  child: _buildDetailColumn('Type', _formatAssetType(asset.type)),
                ),
                Expanded(
                  child: _buildDetailColumn('Status', _formatStatus(asset.status)),
                ),
                Expanded(
                  child: _buildDetailColumn('Added', _formatDate(asset.createdAt)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/asset/${asset.id}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text(
                'View Asset Details',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
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
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyWatchlist(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: ThemeService.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeService.getBorder(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: ThemeService.getTextSecondary(context),
          ),
          const SizedBox(height: 24),
          Text(
            'No Assets in Watchlist',
            style: AppTextStyles.heading3.copyWith(
              color: ThemeService.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start adding assets to your watchlist to track their performance and get notified about updates.',
            style: AppTextStyles.body2.copyWith(
              color: ThemeService.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/marketplace'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Explore Marketplace',
              style: TextStyle(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearWatchlistDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Watchlist'),
        content: const Text('Are you sure you want to remove all assets from your watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(watchlistProvider.notifier).clearWatchlist();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Clear All', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatAssetType(String type) {
    switch (type.toLowerCase()) {
      case 'house':
        return 'House';
      case 'hotel':
        return 'Hotel';
      case 'truck':
        return 'Vehicle';
      case 'land':
        return 'Land';
      case 'office':
        return 'Office';
      case 'warehouse':
        return 'Warehouse';
      default:
        return type.toUpperCase();
    }
  }

  String _formatStatus(String status) {
    return status.toUpperCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    }
    return 'Just now';
  }

  IconData _getAssetIcon(String type) {
    switch (type.toLowerCase()) {
      case 'house':
        return Icons.home;
      case 'hotel':
        return Icons.hotel;
      case 'truck':
        return Icons.local_shipping;
      case 'land':
        return Icons.landscape;
      case 'office':
        return Icons.business;
      case 'warehouse':
        return Icons.warehouse;
      default:
        return Icons.account_balance;
    }
  }
}