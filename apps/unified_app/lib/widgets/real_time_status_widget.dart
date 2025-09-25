import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/theme_service.dart';
import '../services/real_time_update_service.dart';

/// Widget showing real-time update status
class RealTimeStatusWidget extends ConsumerWidget {
  final bool showDetails;
  final bool compact;

  const RealTimeStatusWidget({
    super.key,
    this.showDetails = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateService = ref.read(realTimeUpdateServiceProvider);
    final status = ref.watch(realTimeUpdateStatusProvider);

    if (compact) {
      return _buildCompactStatus(context, ref, updateService, status);
    }

    return _buildFullStatus(context, ref, updateService, status);
  }

  Widget _buildCompactStatus(
    BuildContext context,
    WidgetRef ref,
    RealTimeUpdateService updateService,
    RealTimeUpdateStatus status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.isActive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.isActive
              ? AppColors.success.withOpacity(0.3)
              : AppColors.textSecondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.isActive ? Icons.wifi : Icons.wifi_off,
            size: 14,
            color: status.isActive ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            status.isActive ? 'Live' : 'Offline',
            style: AppTextStyles.caption.copyWith(
              color: status.isActive ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullStatus(
    BuildContext context,
    WidgetRef ref,
    RealTimeUpdateService updateService,
    RealTimeUpdateStatus status,
  ) {
    return Card(
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.isActive ? Icons.wifi : Icons.wifi_off,
                  color: status.isActive ? AppColors.success : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Real-Time Updates',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: status.isActive,
                  onChanged: (value) {
                    if (value) {
                      updateService.startUpdates();
                      ref.read(realTimeUpdateStatusProvider.notifier).state =
                          status.copyWith(isActive: true);
                    } else {
                      updateService.stopUpdates();
                      ref.read(realTimeUpdateStatusProvider.notifier).state =
                          status.copyWith(isActive: false);
                    }
                  },
                  activeColor: AppColors.success,
                ),
              ],
            ),

            if (showDetails) ...[
              const SizedBox(height: 16),
              _buildUpdateDetails(status),
            ],

            if (status.isActive) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your portfolio data is being updated in real-time',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateDetails(RealTimeUpdateStatus status) {
    return Column(
      children: [
        _buildUpdateDetailRow(
          'Portfolio',
          status.lastPortfolioUpdate,
          Icons.account_balance_wallet,
        ),
        const SizedBox(height: 8),
        _buildUpdateDetailRow(
          'Market Data',
          status.lastMarketUpdate,
          Icons.trending_up,
        ),
        const SizedBox(height: 8),
        _buildUpdateDetailRow(
          'Prices',
          status.lastPriceUpdate,
          Icons.attach_money,
        ),
      ],
    );
  }

  Widget _buildUpdateDetailRow(
    String label,
    DateTime? lastUpdate,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          lastUpdate != null
              ? _formatLastUpdate(lastUpdate)
              : 'Never',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatLastUpdate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}

/// Floating real-time indicator
class RealTimeFloatingIndicator extends ConsumerWidget {
  final VoidCallback? onTap;

  const RealTimeFloatingIndicator({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(realTimeUpdateStatusProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: status.isActive
              ? AppColors.success
              : AppColors.textSecondary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (status.isActive
                  ? AppColors.success
                  : AppColors.textSecondary).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status.isActive) ...[
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              ),
            ] else ...[
              Icon(
                Icons.wifi_off,
                color: AppColors.textOnPrimary,
                size: 14,
              ),
            ],
            const SizedBox(width: 6),
            Text(
              status.isActive ? 'Live' : 'Offline',
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

/// Settings panel for real-time updates
class RealTimeSettingsPanel extends ConsumerStatefulWidget {
  const RealTimeSettingsPanel({super.key});

  @override
  ConsumerState<RealTimeSettingsPanel> createState() => _RealTimeSettingsPanelState();
}

class _RealTimeSettingsPanelState extends ConsumerState<RealTimeSettingsPanel> {
  Duration portfolioInterval = const Duration(minutes: 2);
  Duration marketInterval = const Duration(minutes: 1);
  Duration priceInterval = const Duration(seconds: 30);

  @override
  Widget build(BuildContext context) {
    final updateService = ref.read(realTimeUpdateServiceProvider);
    final status = ref.watch(realTimeUpdateStatusProvider);

    return Card(
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-Time Update Settings',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Enable/Disable Toggle
            Row(
              children: [
                Text(
                  'Enable Real-Time Updates',
                  style: AppTextStyles.body1.copyWith(
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: status.isActive,
                  onChanged: (value) {
                    if (value) {
                      updateService.startUpdates();
                      ref.read(realTimeUpdateStatusProvider.notifier).state =
                          status.copyWith(isActive: true);
                    } else {
                      updateService.stopUpdates();
                      ref.read(realTimeUpdateStatusProvider.notifier).state =
                          status.copyWith(isActive: false);
                    }
                  },
                  activeColor: AppColors.success,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Update Intervals
            if (status.isActive) ...[
              Text(
                'Update Intervals',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              _buildIntervalSetting(
                'Portfolio Updates',
                portfolioInterval,
                (value) {
                  setState(() {
                    portfolioInterval = value;
                  });
                  updateService.setUpdateIntervals(portfolioInterval: value);
                },
              ),

              const SizedBox(height: 12),

              _buildIntervalSetting(
                'Market Data Updates',
                marketInterval,
                (value) {
                  setState(() {
                    marketInterval = value;
                  });
                  updateService.setUpdateIntervals(marketInterval: value);
                },
              ),

              const SizedBox(height: 12),

              _buildIntervalSetting(
                'Price Updates',
                priceInterval,
                (value) {
                  setState(() {
                    priceInterval = value;
                  });
                  updateService.setUpdateIntervals(priceInterval: value);
                },
              ),

              const SizedBox(height: 20),

              // Force Refresh Button
              ElevatedButton(
                onPressed: () => updateService.forceRefresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: Text(
                  'Force Refresh All Data',
                  style: TextStyle(color: AppColors.textOnPrimary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSetting(
    String label,
    Duration currentValue,
    Function(Duration) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _durationToSliderValue(currentValue),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (value) {
                  onChanged(_sliderValueToDuration(value));
                },
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: Text(
                _formatDuration(currentValue),
                style: AppTextStyles.body2.copyWith(
                  color: ThemeService.getTextSecondary(context),
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _durationToSliderValue(Duration duration) {
    if (duration.inSeconds <= 30) return 0;
    if (duration.inMinutes <= 1) return 1;
    if (duration.inMinutes <= 2) return 2;
    if (duration.inMinutes <= 5) return 3;
    if (duration.inMinutes <= 10) return 4;
    if (duration.inMinutes <= 15) return 5;
    if (duration.inMinutes <= 30) return 6;
    if (duration.inHours <= 1) return 7;
    if (duration.inHours <= 2) return 8;
    if (duration.inHours <= 4) return 9;
    return 10;
  }

  Duration _sliderValueToDuration(double value) {
    switch (value.round()) {
      case 0: return const Duration(seconds: 30);
      case 1: return const Duration(minutes: 1);
      case 2: return const Duration(minutes: 2);
      case 3: return const Duration(minutes: 5);
      case 4: return const Duration(minutes: 10);
      case 5: return const Duration(minutes: 15);
      case 6: return const Duration(minutes: 30);
      case 7: return const Duration(hours: 1);
      case 8: return const Duration(hours: 2);
      case 9: return const Duration(hours: 4);
      case 10: return const Duration(hours: 12);
      default: return const Duration(minutes: 2);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inHours}h';
    }
  }
}