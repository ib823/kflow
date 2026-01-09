import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Notification type
enum NotificationType {
  @JsonValue('leave_approved')
  leaveApproved,
  @JsonValue('leave_rejected')
  leaveRejected,
  @JsonValue('leave_request')
  leaveRequest,
  @JsonValue('payslip_available')
  payslipAvailable,
  @JsonValue('announcement')
  announcement,
  @JsonValue('reminder')
  reminder,
  @JsonValue('system')
  system,
}

/// App notification model
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationType type,
    required String title,
    required String message,
    @Default(false) bool isRead,
    String? actionUrl,
    Map<String, dynamic>? data,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
