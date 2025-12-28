import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/notification_repository.dart';
import '../../domain/models/notification.dart';

part 'notification_provider.g.dart';

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  Future<List<AppNotification>> build() async {
    return ref.watch(notificationRepositoryProvider).getNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).getNotifications(),
    );
  }

  Future<void> markAsRead(int id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
    // Update local state
    state.whenData((notifications) {
      state = AsyncData(
        notifications.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList(),
      );
    });
    // Refresh unread count
    ref.invalidate(unreadCountProvider);
  }

  Future<void> markAllAsRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead();
    // Update local state
    state.whenData((notifications) {
      state = AsyncData(
        notifications.map((n) => n.copyWith(isRead: true)).toList(),
      );
    });
    // Refresh unread count
    ref.invalidate(unreadCountProvider);
  }
}

@riverpod
Future<int> unreadCount(UnreadCountRef ref) async {
  return ref.watch(notificationRepositoryProvider).getUnreadCount();
}
