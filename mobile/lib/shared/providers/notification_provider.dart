import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../models/notification.dart';

part 'notification_provider.g.dart';

/// State for notifications with pagination support
class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.nextCursor,
    this.hasMore = false,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    String? nextCursor,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  Future<NotificationState> build() async {
    return _fetchNotifications();
  }

  Future<NotificationState> _fetchNotifications({String? cursor}) async {
    try {
      final dio = ref.read(dioClientProvider);

      final response = await dio.get('/notifications', queryParameters: {
        'limit': 20,
        if (cursor != null) 'cursor': cursor,
      });

      final data = response.data as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();

      final unreadCount = data['unread_count'] as int? ??
          items.where((n) => !n.isRead).length;

      return NotificationState(
        notifications: items,
        unreadCount: unreadCount,
        nextCursor: data['next_cursor'] as String?,
        hasMore: data['has_more'] as bool? ?? false,
      );
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      return NotificationState(error: error.message);
    } catch (e) {
      return NotificationState(error: e.toString());
    }
  }

  /// Refresh notifications (pull to refresh)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchNotifications());
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoading) return;

    state = AsyncValue.data(current.copyWith(isLoading: true));

    try {
      final dio = ref.read(dioClientProvider);

      final response = await dio.get('/notifications', queryParameters: {
        'limit': 20,
        'cursor': current.nextCursor,
      });

      final data = response.data as Map<String, dynamic>;
      final newItems = (data['items'] as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(current.copyWith(
        notifications: [...current.notifications, ...newItems],
        nextCursor: data['next_cursor'] as String?,
        hasMore: data['has_more'] as bool? ?? false,
        isLoading: false,
      ));
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      state = AsyncValue.data(current.copyWith(
        error: error.message,
        isLoading: false,
      ));
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(int id) async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.post('/notifications/$id/read');

      // Update local state
      final current = state.valueOrNull;
      if (current != null) {
        final updated = current.notifications.map((n) {
          if (n.id == id && !n.isRead) {
            return AppNotification(
              id: n.id,
              type: n.type,
              title: n.title,
              titleMs: n.titleMs,
              body: n.body,
              bodyMs: n.bodyMs,
              isRead: true,
              deepLink: n.deepLink,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();

        state = AsyncValue.data(current.copyWith(
          notifications: updated,
          unreadCount: (current.unreadCount - 1).clamp(0, current.unreadCount),
        ));
      }
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.post('/notifications/read-all');

      // Update local state
      final current = state.valueOrNull;
      if (current != null) {
        final updated = current.notifications.map((n) {
          if (!n.isRead) {
            return AppNotification(
              id: n.id,
              type: n.type,
              title: n.title,
              titleMs: n.titleMs,
              body: n.body,
              bodyMs: n.bodyMs,
              isRead: true,
              deepLink: n.deepLink,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();

        state = AsyncValue.data(current.copyWith(
          notifications: updated,
          unreadCount: 0,
        ));
      }
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }

  /// Delete a notification
  Future<void> delete(int id) async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.delete('/notifications/$id');

      // Update local state
      final current = state.valueOrNull;
      if (current != null) {
        final notification = current.notifications.firstWhere((n) => n.id == id);
        final wasUnread = !notification.isRead;

        state = AsyncValue.data(current.copyWith(
          notifications: current.notifications.where((n) => n.id != id).toList(),
          unreadCount: wasUnread
              ? (current.unreadCount - 1).clamp(0, current.unreadCount)
              : current.unreadCount,
        ));
      }
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }
}

/// Provider for unread count (badge display)
@riverpod
Future<int> unreadNotificationCount(UnreadNotificationCountRef ref) async {
  final notificationState = await ref.watch(notificationNotifierProvider.future);
  return notificationState.unreadCount;
}

/// Provider for filtering notifications by type
@riverpod
Future<List<AppNotification>> notificationsByType(
  NotificationsByTypeRef ref,
  String type,
) async {
  final notificationState = await ref.watch(notificationNotifierProvider.future);
  return notificationState.notifications.where((n) => n.type == type).toList();
}
