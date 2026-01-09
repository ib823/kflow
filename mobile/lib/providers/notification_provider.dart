import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';

/// Notification list notifier
class NotificationListNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationListNotifier() : super(const AsyncValue.loading());

  /// Fetch notifications
  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for development
      state = AsyncValue.data([
        AppNotification(
          id: 'notif-1',
          type: NotificationType.leaveApproved,
          title: 'Leave Approved',
          message: 'Your annual leave request for 15-17 Jan has been approved.',
          isRead: false,
          actionUrl: '/leave/leave-1',
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        AppNotification(
          id: 'notif-2',
          type: NotificationType.payslipAvailable,
          title: 'New Payslip Available',
          message: 'Your December 2025 payslip is now available.',
          isRead: false,
          actionUrl: '/payslips/dec-2025',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        AppNotification(
          id: 'notif-3',
          type: NotificationType.leaveRequest,
          title: 'Leave Request',
          message: 'Sarah Abdullah submitted a leave request.',
          isRead: false,
          actionUrl: '/approvals/apr-001',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        AppNotification(
          id: 'notif-4',
          type: NotificationType.announcement,
          title: 'Company Announcement',
          message: 'Upcoming maintenance scheduled for this weekend.',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AppNotification(
          id: 'notif-5',
          type: NotificationType.reminder,
          title: 'Leave Balance Reminder',
          message: 'You have 12 days of annual leave remaining.',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.map((n) {
          if (n.id == id && !n.isRead) {
            return AppNotification(
              id: n.id,
              type: n.type,
              title: n.title,
              message: n.message,
              isRead: true,
              actionUrl: n.actionUrl,
              data: n.data,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList(),
      );
    });
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications
            .map((n) => AppNotification(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  message: n.message,
                  isRead: true,
                  actionUrl: n.actionUrl,
                  data: n.data,
                  createdAt: n.createdAt,
                ))
            .toList(),
      );
    });
  }

  /// Delete notification
  Future<void> delete(String id) async {
    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.where((n) => n.id != id).toList(),
      );
    });
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    state = const AsyncValue.data([]);
  }

  /// Refresh notifications
  Future<void> refresh() => fetchNotifications();
}

/// Notification list provider
final notificationListProvider = StateNotifierProvider<NotificationListNotifier,
    AsyncValue<List<AppNotification>>>((ref) {
  final notifier = NotificationListNotifier();
  notifier.fetchNotifications();
  return notifier;
});

/// Unread notification count provider (for badge)
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider);
  return notifications.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

/// Has unread notifications provider
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(unreadNotificationCountProvider) > 0;
});
