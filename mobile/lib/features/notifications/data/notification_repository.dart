import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/notification.dart';
import 'notification_api.dart';

part 'notification_repository.g.dart';

/// Repository for notifications.
class NotificationRepository {
  final NotificationApi _api;

  NotificationRepository(this._api);

  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) =>
      _api.getNotifications(page: page, limit: limit, unreadOnly: unreadOnly);

  Future<int> getUnreadCount() => _api.getUnreadCount();

  Future<void> markAsRead(int id) => _api.markAsRead(id);

  Future<void> markAllAsRead() => _api.markAllAsRead();
}

@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return NotificationRepository(ref.watch(notificationApiProvider));
}
