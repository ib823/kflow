import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required int id,
    @JsonKey(name: 'type') required String type,
    required String title,
    @JsonKey(name: 'title_ms') String? titleMs,
    required String body,
    @JsonKey(name: 'body_ms') String? bodyMs,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'deep_link') String? deepLink,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

@freezed
class NotificationList with _$NotificationList {
  const factory NotificationList({
    required List<AppNotification> items,
    @JsonKey(name: 'next_cursor') String? nextCursor,
    @JsonKey(name: 'has_more') @Default(false) bool hasMore,
  }) = _NotificationList;

  factory NotificationList.fromJson(Map<String, dynamic> json) =>
      _$NotificationListFromJson(json);
}
