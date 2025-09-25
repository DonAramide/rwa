import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../core/api_client.dart';

// Notification models
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final String? assetId;
  final String? actionUrl;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.createdAt,
    required this.isRead,
    this.assetId,
    this.actionUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      assetId: json['assetId'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? assetId,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      assetId: assetId ?? this.assetId,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}

// Notification state
class NotificationState {
  final bool isLoading;
  final List<AppNotification> notifications;
  final String? error;
  final int unreadCount;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<AppNotification>? notifications,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// Notification notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Note: This endpoint would need to be added to the API
      final response = await ApiClient.getNotifications();
      final notificationsData = response['items'] as List? ?? [];

      final notifications = notificationsData
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();

      final unreadCount = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadCount: unreadCount,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Update local state immediately for better UX
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId && !notification.isRead) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );

      // Call API to persist the change
      await ApiClient.markNotificationAsRead(notificationId);
    } catch (e) {
      // Revert the change if API call fails
      await loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );

      // Call API to persist the change
      await ApiClient.markAllNotificationsAsRead();
    } catch (e) {
      // Revert the change if API call fails
      await loadNotifications();
    }
  }

  void addLocalNotification(AppNotification notification) {
    final updatedNotifications = [notification, ...state.notifications];
    final unreadCount = notification.isRead ? state.unreadCount : state.unreadCount + 1;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: unreadCount,
    );
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }
}

// Providers
final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

// Computed providers
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

final recentNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationProvider).notifications;
  return notifications.take(5).toList();
});

final portfolioNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationProvider).notifications;
  return notifications.where((n) => n.type == 'portfolio' || n.type == 'investment').toList();
});

final assetUpdatesProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationProvider).notifications;
  return notifications.where((n) => n.type == 'asset_update' || n.type == 'price_alert').toList();
});