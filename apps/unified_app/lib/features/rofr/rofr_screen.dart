import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/rofr_models.dart';
import '../../providers/rofr_provider.dart';

class RofrScreen extends ConsumerStatefulWidget {
  const RofrScreen({super.key});

  @override
  ConsumerState<RofrScreen> createState() => _RofrScreenState();
}

class _RofrScreenState extends ConsumerState<RofrScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedShares = 0;
  String _responseMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load ROFR data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rofrProvider.notifier).loadUserRofrOffers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rofrState = ref.watch(rofrProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Right of First Refusal',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Active Offers'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: rofrState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveOffersTab(rofrState),
                _buildNotificationsTab(rofrState),
              ],
            ),
    );
  }

  Widget _buildActiveOffersTab(RofrState rofrState) {
    final activeOffers = rofrState.offers
        .where((offer) => offer.status == RofrStatus.pending && !offer.isExpired)
        .toList();

    if (activeOffers.isEmpty) {
      return _buildEmptyState(
        'No Active ROFR Offers',
        'You\'ll see opportunities to purchase shares from co-owners here.',
        Icons.gavel,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activeOffers.length,
      itemBuilder: (context, index) {
        return _buildOfferCard(activeOffers[index]);
      },
    );
  }

  Widget _buildNotificationsTab(RofrState rofrState) {
    final notifications = rofrState.notifications;

    if (notifications.isEmpty) {
      return _buildEmptyState(
        'No ROFR Notifications',
        'You\'ll receive notifications when co-owners offer shares for sale.',
        Icons.notifications_none,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(notifications[index]);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(RofrOffer offer) {
    final timeRemaining = offer.timeRemaining;
    final hoursRemaining = timeRemaining.inHours;
    final isUrgent = hoursRemaining < 24;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with asset and urgency indicator
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.assetTitle,
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Offered by ${offer.sellerName}',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Urgent',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Offer details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Shares Offered',
                    offer.sharesOffered.toString(),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Price per Share',
                    '\$${offer.pricePerShare.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Total Value',
                    '\$${offer.totalValue.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Time remaining
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUrgent
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: isUrgent ? AppColors.error : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hoursRemaining > 0
                          ? 'Time remaining: ${hoursRemaining}h ${timeRemaining.inMinutes % 60}m'
                          : 'EXPIRED',
                      style: AppTextStyles.body2.copyWith(
                        color: isUrgent ? AppColors.error : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (offer.notes != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seller\'s Note:',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.notes!,
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showResponseDialog(offer, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Decline',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _showResponseDialog(offer, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Purchase Shares',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(RofrNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead
          ? AppColors.surface
          : AppColors.primary.withOpacity(0.05),
      child: ListTile(
        onTap: () {
          if (!notification.isRead) {
            ref.read(rofrProvider.notifier)
                .markNotificationAsRead(notification.id);
          }
        },
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? AppColors.textSecondary.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.2),
          child: Icon(
            Icons.gavel,
            color: notification.isRead
                ? AppColors.textSecondary
                : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatNotificationDate(notification.sentDate),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showResponseDialog(RofrOffer offer, bool isAccepting) {
    _selectedShares = isAccepting ? offer.sharesOffered : 0;
    _responseMessage = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            isAccepting ? 'Purchase Shares' : 'Decline Offer',
            style: AppTextStyles.heading3,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${offer.assetTitle}',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: \$${offer.pricePerShare.toStringAsFixed(2)} per share',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              if (isAccepting) ...[
                Text(
                  'Number of shares to purchase:',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _selectedShares.toDouble(),
                        min: 1,
                        max: offer.sharesOffered.toDouble(),
                        divisions: offer.sharesOffered - 1,
                        label: _selectedShares.toString(),
                        onChanged: (value) {
                          setState(() {
                            _selectedShares = value.round();
                          });
                        },
                      ),
                    ),
                    Text(
                      _selectedShares.toString(),
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                        'Total Cost:',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${(_selectedShares * offer.pricePerShare).toStringAsFixed(2)}',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Text(
                'Message (optional):',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => _responseMessage = value,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isAccepting
                      ? 'Thank you for the opportunity...'
                      : 'Thank you, but I\'ll pass on this offer...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _submitResponse(offer, isAccepting),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAccepting
                    ? AppColors.success
                    : AppColors.error,
              ),
              child: Text(
                isAccepting ? 'Purchase' : 'Decline',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitResponse(RofrOffer offer, bool isAccepting) async {
    final response = isAccepting ? RofrStatus.accepted : RofrStatus.rejected;
    final sharesRequested = isAccepting ? _selectedShares : 0;

    final success = await ref.read(rofrProvider.notifier).respondToRofrOffer(
      offerId: offer.id,
      response: response,
      sharesRequested: sharesRequested,
      message: _responseMessage.isNotEmpty ? _responseMessage : null,
    );

    if (mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? isAccepting
                    ? 'Purchase request submitted successfully!'
                    : 'Offer declined successfully.'
                : 'Failed to submit response. Please try again.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  String _formatNotificationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}