import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationState.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark All Read'),
            ),
          IconButton(
            onPressed: () {
              ref.read(notificationProvider.notifier).refreshNotifications();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(notificationState),
    );
  }

  Widget _buildBody(NotificationState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load notifications',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).refreshNotifications();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see updates about your investments here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationProvider.notifier).refreshNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return _NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onMarkAsRead: () => ref.read(notificationProvider.notifier).markAsRead(notification.id),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      ref.read(notificationProvider.notifier).markAsRead(notification.id);
    }

    // Navigate to relevant screen if actionUrl is provided
    if (notification.actionUrl != null) {
      context.push(notification.actionUrl!);
    } else if (notification.assetId != null) {
      context.push('/asset/${notification.assetId}');
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: notification.isRead ? null : Theme.of(context).primaryColor.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NotificationIcon(type: notification.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _formatDate(notification.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            if (!notification.isRead)
                              TextButton(
                                onPressed: onMarkAsRead,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text(
                                  'Mark as read',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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

class _NotificationIcon extends StatelessWidget {
  final String type;

  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (type.toLowerCase()) {
      case 'portfolio':
        iconData = Icons.account_balance_wallet;
        backgroundColor = Colors.green.withOpacity(0.1);
        iconColor = Colors.green[700]!;
        break;
      case 'investment':
        iconData = Icons.trending_up;
        backgroundColor = Colors.blue.withOpacity(0.1);
        iconColor = Colors.blue[700]!;
        break;
      case 'asset_update':
        iconData = Icons.apartment;
        backgroundColor = Colors.orange.withOpacity(0.1);
        iconColor = Colors.orange[700]!;
        break;
      case 'price_alert':
        iconData = Icons.notifications_active;
        backgroundColor = Colors.red.withOpacity(0.1);
        iconColor = Colors.red[700]!;
        break;
      case 'system':
        iconData = Icons.settings;
        backgroundColor = Colors.grey.withOpacity(0.1);
        iconColor = Colors.grey[700]!;
        break;
      default:
        iconData = Icons.info;
        backgroundColor = Colors.blue.withOpacity(0.1);
        iconColor = Colors.blue[700]!;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}