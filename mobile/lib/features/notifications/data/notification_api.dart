import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/notification.dart';

part 'notification_api.g.dart';

/// Notification API client.
class NotificationApi {
  final Dio _dio;

  NotificationApi(this._dio);

  /// GET /api/v1/notifications
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    final response = await _dio.get('/api/v1/notifications', queryParameters: {
      'page': page,
      'limit': limit,
      if (unreadOnly == true) 'unread_only': true,
    });
    return (response.data['data'] as List)
        .map((e) => AppNotification.fromJson(e))
        .toList();
  }

  /// GET /api/v1/notifications/count
  Future<int> getUnreadCount() async {
    final response = await _dio.get('/api/v1/notifications/count');
    return response.data['data']['unread'];
  }

  /// POST /api/v1/notifications/{id}/read
  Future<void> markAsRead(int id) async {
    await _dio.post('/api/v1/notifications/$id/read');
  }

  /// POST /api/v1/notifications/read-all
  Future<void> markAllAsRead() async {
    await _dio.post('/api/v1/notifications/read-all');
  }
}

@riverpod
NotificationApi notificationApi(NotificationApiRef ref) {
  final dio = ref.watch(dioClientProvider);
  return NotificationApi(dio);
}
