import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// App notification from GET /api/v1/notifications
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required int id,
    required String title,
    required String body,
    required String type,
    required bool isRead,
    required DateTime createdAt,
    Map<String, dynamic>? data,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

/// Notification types
enum NotificationType {
  leaveApproved,
  leaveRejected,
  leavePending,
  payslipReady,
  documentExpiring,
  permitExpiring,
  general,
}

extension NotificationTypeX on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.leaveApproved:
        return 'leave_approved';
      case NotificationType.leaveRejected:
        return 'leave_rejected';
      case NotificationType.leavePending:
        return 'leave_pending';
      case NotificationType.payslipReady:
        return 'payslip_ready';
      case NotificationType.documentExpiring:
        return 'document_expiring';
      case NotificationType.permitExpiring:
        return 'permit_expiring';
      case NotificationType.general:
        return 'general';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'leave_approved':
        return NotificationType.leaveApproved;
      case 'leave_rejected':
        return NotificationType.leaveRejected;
      case 'leave_pending':
        return NotificationType.leavePending;
      case 'payslip_ready':
        return NotificationType.payslipReady;
      case 'document_expiring':
        return NotificationType.documentExpiring;
      case 'permit_expiring':
        return NotificationType.permitExpiring;
      default:
        return NotificationType.general;
    }
  }
}
