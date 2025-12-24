import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/shared/models/notification.dart';

void main() {
  group('AppNotification Model', () {
    test('creates AppNotification from JSON', () {
      final json = {
        'id': 1,
        'type': 'LEAVE_APPROVED',
        'title': 'Leave Approved',
        'title_ms': 'Cuti Diluluskan',
        'body': 'Your annual leave request has been approved',
        'body_ms': 'Permohonan cuti tahunan anda telah diluluskan',
        'is_read': false,
        'deep_link': 'kerjaflow://leave/123',
        'created_at': '2025-01-15T10:30:00Z',
      };

      final notification = AppNotification.fromJson(json);

      expect(notification.id, 1);
      expect(notification.type, 'LEAVE_APPROVED');
      expect(notification.title, 'Leave Approved');
      expect(notification.body, 'Your annual leave request has been approved');
      expect(notification.isRead, isFalse);
      expect(notification.deepLink, 'kerjaflow://leave/123');
    });

    test('AppNotification type string works', () {
      const notification = AppNotification(
        id: 1,
        type: 'LEAVE_APPROVED',
        title: 'Leave Approved',
        body: 'Your leave was approved',
      );

      expect(notification.type, 'LEAVE_APPROVED');
    });

    test('AppNotification equality works', () {
      const notification1 = AppNotification(
        id: 1,
        type: 'LEAVE_APPROVED',
        title: 'Leave Approved',
        body: 'Your leave was approved',
        isRead: false,
        createdAt: '2025-01-15T10:30:00Z',
      );

      const notification2 = AppNotification(
        id: 1,
        type: 'LEAVE_APPROVED',
        title: 'Leave Approved',
        body: 'Your leave was approved',
        isRead: false,
        createdAt: '2025-01-15T10:30:00Z',
      );

      expect(notification1, equals(notification2));
    });

    test('AppNotification with deep link', () {
      const notification = AppNotification(
        id: 1,
        type: 'LEAVE_APPROVED',
        title: 'Leave Approved',
        body: 'Your leave was approved',
        deepLink: 'kerjaflow://leave/123',
      );

      expect(notification.deepLink, isNotNull);
      expect(notification.deepLink, contains('leave'));
    });

    test('AppNotification without deep link', () {
      const notification = AppNotification(
        id: 1,
        type: 'ANNOUNCEMENT',
        title: 'General Announcement',
        body: 'Company meeting tomorrow',
      );

      expect(notification.deepLink, isNull);
    });

    test('AppNotification supports Malaysian translations', () {
      const notification = AppNotification(
        id: 1,
        type: 'LEAVE_APPROVED',
        title: 'Leave Approved',
        titleMs: 'Cuti Diluluskan',
        body: 'Your leave was approved',
        bodyMs: 'Cuti anda telah diluluskan',
      );

      expect(notification.titleMs, 'Cuti Diluluskan');
      expect(notification.bodyMs, 'Cuti anda telah diluluskan');
    });
  });

  group('NotificationList Model', () {
    test('creates NotificationList from JSON', () {
      final json = {
        'items': [
          {
            'id': 1,
            'type': 'LEAVE_APPROVED',
            'title': 'Leave Approved',
            'body': 'Approved',
            'is_read': false,
            'created_at': '2025-01-15T10:30:00Z',
          },
          {
            'id': 2,
            'type': 'PAYSLIP_READY',
            'title': 'Payslip Ready',
            'body': 'Your payslip is ready',
            'is_read': true,
            'created_at': '2025-01-14T09:00:00Z',
          },
        ],
        'next_cursor': 'abc123',
        'has_more': true,
      };

      final list = NotificationList.fromJson(json);

      expect(list.items.length, 2);
      expect(list.nextCursor, 'abc123');
      expect(list.hasMore, isTrue);
    });

    test('NotificationList empty state', () {
      const list = NotificationList(
        items: [],
        hasMore: false,
      );

      expect(list.items, isEmpty);
      expect(list.hasMore, isFalse);
      expect(list.nextCursor, isNull);
    });
  });
}
