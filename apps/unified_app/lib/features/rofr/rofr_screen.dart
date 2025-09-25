import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_service.dart';
import '../../models/rofr_models.dart';
import '../../providers/rofr_provider.dart';
import '../../services/rofr_notification_service.dart';
import 'shareholder_directory.dart';

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
      backgroundColor: ThemeService.getScaffoldBackground(context),
      appBar: AppBar(
        title: Text(
          'Right of First Refusal',
          style: AppTextStyles.heading2.copyWith(color: ThemeService.getTextPrimary(context)),
        ),
        backgroundColor: ThemeService.getAppBarBackground(context),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => ref.read(rofrProvider.notifier).loadUserRofrOffers(),
            icon: rofrState.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.refresh, color: ThemeService.getTextSecondary(context)),
            tooltip: 'Refresh ROFR offers',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: ThemeService.getTextSecondary(context)),
            onSelected: (value) {
              switch (value) {
                case 'create_offer':
                  _showCreateOfferDialog(context);
                  break;
                case 'my_offers':
                  _showMyOffersDialog(context);
                  break;
                case 'help':
                  _showHelpDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'create_offer',
                child: Row(
                  children: [
                    Icon(Icons.add_circle, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Create ROFR Offer'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'my_offers',
                child: Row(
                  children: [
                    Icon(Icons.list_alt, size: 20, color: AppColors.info),
                    const SizedBox(width: 8),
                    const Text('My Active Offers'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    const Text('ROFR Guide'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: ThemeService.getTextSecondary(context),
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
      color: ThemeService.getCardBackground(context),
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
                  child: OutlinedButton.icon(
                    onPressed: () => _showResponseDialog(offer, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(Icons.close, size: 20, color: AppColors.error),
                    label: Text(
                      'Decline',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showShareholderDirectory(offer),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.info),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(Icons.people, size: 20, color: AppColors.info),
                    label: Text(
                      'View Shareholders',
                      style: TextStyle(color: AppColors.info),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAdvancedPurchaseDialog(offer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.shopping_cart, size: 20, color: Colors.white),
                    label: const Text(
                      'Purchase',
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

  void _showShareholderDirectory(RofrOffer offer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShareholderDirectoryScreen(
          assetId: offer.assetId,
          assetTitle: offer.assetTitle,
        ),
      ),
    );
  }

  void _showAdvancedPurchaseDialog(RofrOffer offer) {
    _selectedShares = 1;
    _responseMessage = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ThemeService.getCardBackground(context),
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Purchase ROFR Shares',
                  style: AppTextStyles.heading3.copyWith(
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.assetTitle,
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Offered by', style: AppTextStyles.caption),
                                Text(offer.sellerName, style: AppTextStyles.body2),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Available shares', style: AppTextStyles.caption),
                                Text('${offer.sharesOffered}', style: AppTextStyles.body2),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Price per share', style: AppTextStyles.caption),
                                Text('\$${offer.pricePerShare.toStringAsFixed(2)}', style: AppTextStyles.body2),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Expires in', style: AppTextStyles.caption),
                                Text('${offer.timeRemaining.inHours}h ${offer.timeRemaining.inMinutes % 60}m',
                                  style: AppTextStyles.body2.copyWith(color: offer.timeRemaining.inHours < 24 ? AppColors.error : null)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Share selection
                Text(
                  'Number of shares to purchase:',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _selectedShares.toDouble(),
                        min: 1,
                        max: offer.sharesOffered.toDouble(),
                        divisions: offer.sharesOffered > 1 ? offer.sharesOffered - 1 : 1,
                        label: _selectedShares.toString(),
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _selectedShares = value.round();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 60,
                      child: Text(
                        _selectedShares.toString(),
                        style: AppTextStyles.heading4.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                // Quick selection buttons
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildQuickSelectButton(setState, '25%', (offer.sharesOffered * 0.25).round()),
                    _buildQuickSelectButton(setState, '50%', (offer.sharesOffered * 0.5).round()),
                    _buildQuickSelectButton(setState, '75%', (offer.sharesOffered * 0.75).round()),
                    _buildQuickSelectButton(setState, 'All', offer.sharesOffered),
                  ],
                ),

                const SizedBox(height: 20),

                // Cost calculation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shares:', style: AppTextStyles.body1),
                          Text('$_selectedShares', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Price per share:', style: AppTextStyles.body1),
                          Text('\$${offer.pricePerShare.toStringAsFixed(2)}', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Cost:', style: AppTextStyles.heading4.copyWith(fontWeight: FontWeight.bold)),
                          Text('\$${(_selectedShares * offer.pricePerShare).toStringAsFixed(2)}',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold
                            )),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Optional message
                Text(
                  'Message to seller (optional):',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => _responseMessage = value,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Thank you for this opportunity. I look forward to...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: TextStyle(color: ThemeService.getTextPrimary(context)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: ThemeService.getTextSecondary(context))),
            ),
            ElevatedButton.icon(
              onPressed: () => _submitAdvancedResponse(offer, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.check_circle, size: 20, color: Colors.white),
              label: const Text(
                'Confirm Purchase',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectButton(StateSetter setState, String label, int shares) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedShares = shares.clamp(1, 99999);
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: AppColors.primary),
        minimumSize: Size.zero,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showCreateOfferDialog(BuildContext context) {
    final assetController = TextEditingController();
    final sharesController = TextEditingController();
    final priceController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeService.getCardBackground(context),
        title: Row(
          children: [
            Icon(Icons.add_circle, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Create ROFR Offer',
              style: AppTextStyles.heading3.copyWith(
                color: ThemeService.getTextPrimary(context),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: assetController,
                decoration: const InputDecoration(
                  labelText: 'Asset Title',
                  hintText: 'Select or enter asset name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sharesController,
                      decoration: const InputDecoration(
                        labelText: 'Shares to Sell',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price per Share',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Reason for sale, urgency, etc.',
                  border: OutlineInputBorder(),
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
            onPressed: () => _submitCreateOffer(
              assetController.text,
              sharesController.text,
              priceController.text,
              notesController.text,
            ),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Create Offer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMyOffersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeService.getCardBackground(context),
        title: Text('My Active ROFR Offers', style: AppTextStyles.heading3),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 2, // Mock data
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Icon(Icons.gavel, color: AppColors.primary),
              ),
              title: Text('Premium Office Complex'),
              subtitle: Text('50 shares at \$125.00 each\n2 responses received'),
              trailing: Text('32h left', style: TextStyle(color: AppColors.warning)),
              isThreeLine: true,
            ),
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeService.getCardBackground(context),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.info),
            const SizedBox(width: 12),
            Text('ROFR Guide', style: AppTextStyles.heading3),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('What is Right of First Refusal?',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'ROFR gives existing shareholders the first opportunity to purchase shares before they\'re offered to the public market.',
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: 16),
              Text('How it works:',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '1. A shareholder decides to sell shares\n'
                '2. All existing shareholders are notified\n'
                '3. Shareholders have 48 hours to respond\n'
                '4. Accepted shares are allocated by response order\n'
                '5. Remaining shares go to public market',
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: 16),
              Text('Benefits:',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '• Maintain control over ownership structure\n'
                '• Get first access to investment opportunities\n'
                '• Prevent dilution from external investors',
                style: AppTextStyles.body2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _submitCreateOffer(String asset, String shares, String price, String notes) async {
    if (asset.isEmpty || shares.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sharesNum = int.tryParse(shares);
    final priceNum = double.tryParse(price);

    if (sharesNum == null || priceNum == null || sharesNum <= 0 || priceNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();

    final success = await ref.read(rofrProvider.notifier).createRofrOffer(
      assetId: 'asset_${DateTime.now().millisecondsSinceEpoch}',
      assetTitle: asset,
      sharesOffered: sharesNum,
      pricePerShare: priceNum,
      notes: notes.isNotEmpty ? notes : null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success != null
                ? 'ROFR offer created! Shareholders have been notified.'
                : 'Failed to create ROFR offer. Please try again.',
          ),
          backgroundColor: success != null ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _submitAdvancedResponse(RofrOffer offer, bool isAccepting) async {
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
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? isAccepting
                          ? 'Purchase request submitted successfully! Total: \$${(_selectedShares * offer.pricePerShare).toStringAsFixed(2)}'
                          : 'Offer declined successfully.'
                      : 'Failed to submit response. Please try again.',
                ),
              ),
            ],
          ),
          backgroundColor: success
              ? (isAccepting ? AppColors.success : AppColors.info)
              : AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}