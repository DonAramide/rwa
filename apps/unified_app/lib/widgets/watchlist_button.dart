import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/theme_service.dart';
import '../models/asset.dart';
import '../providers/watchlist_provider.dart';

/// A button widget for adding/removing assets from watchlist
class WatchlistButton extends ConsumerWidget {
  final Asset asset;
  final bool showLabel;
  final double? iconSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const WatchlistButton({
    super.key,
    required this.asset,
    this.showLabel = false,
    this.iconSize,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInWatchlist = ref.watch(isInWatchlistProvider(asset.id.toString()));
    final watchlistState = ref.watch(watchlistProvider);

    final activeCol = activeColor ?? AppColors.error;
    final inactiveCol = inactiveColor ?? AppColors.textSecondary;

    if (showLabel) {
      return ElevatedButton.icon(
        onPressed: watchlistState.isLoading
            ? null
            : () => _toggleWatchlist(ref, context),
        icon: Icon(
          isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
          size: iconSize ?? 20,
        ),
        label: Text(isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist'),
        style: ElevatedButton.styleFrom(
          foregroundColor: isInWatchlist ? AppColors.textOnPrimary : activeCol,
          backgroundColor: isInWatchlist ? activeCol : ThemeService.getCardBackground(context),
          side: BorderSide(color: activeCol),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }

    return IconButton(
      onPressed: watchlistState.isLoading
          ? null
          : () => _toggleWatchlist(ref, context),
      icon: Icon(
        isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
        color: isInWatchlist ? activeCol : inactiveCol,
        size: iconSize ?? 24,
      ),
      tooltip: isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
    );
  }

  Future<void> _toggleWatchlist(WidgetRef ref, BuildContext context) async {
    final isInWatchlist = ref.read(isInWatchlistProvider(asset.id.toString()));

    await ref.read(watchlistProvider.notifier).toggleWatchlist(asset);

    if (context.mounted) {
      final message = isInWatchlist
          ? 'Removed from watchlist'
          : 'Added to watchlist';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isInWatchlist ? Icons.bookmark_remove : Icons.bookmark_add,
                color: AppColors.textOnPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: isInWatchlist ? AppColors.warning : AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// A floating watchlist badge showing the count of watched assets
class WatchlistBadge extends ConsumerWidget {
  final VoidCallback? onTap;

  const WatchlistBadge({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(watchlistCountProvider);

    if (count == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark,
              color: AppColors.textOnPrimary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}