import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data
    final notifications = [
      _NotificationData(
        id: 1,
        type: 'LEAVE_APPROVED',
        title: 'Leave Approved',
        body: 'Your annual leave request for Dec 28-31 has been approved',
        createdAt: '2 hours ago',
        isRead: false,
      ),
      _NotificationData(
        id: 2,
        type: 'PAYSLIP_READY',
        title: 'Payslip Ready',
        body: 'Your payslip for December 2025 is now available',
        createdAt: '1 day ago',
        isRead: false,
      ),
      _NotificationData(
        id: 3,
        type: 'DOCUMENT_EXPIRING',
        title: 'Document Expiring Soon',
        body: 'Your passport will expire in 30 days. Please renew it.',
        createdAt: '2 days ago',
        isRead: true,
      ),
      _NotificationData(
        id: 4,
        type: 'ANNOUNCEMENT',
        title: 'Office Closure',
        body: 'Office will be closed on Dec 25-26 for Christmas holidays',
        createdAt: '5 days ago',
        isRead: true,
      ),
      _NotificationData(
        id: 5,
        type: 'LEAVE_PENDING',
        title: 'Leave Request Pending',
        body: 'You have 2 pending leave requests awaiting your approval',
        createdAt: '1 week ago',
        isRead: true,
      ),
    ];

    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                // TODO: Mark all as read
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All marked as read')),
                );
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(notification: notification);
              },
            ),
    );
  }
}

class _NotificationData {
  final int id;
  final String type;
  final String title;
  final String body;
  final String createdAt;
  final bool isRead;

  _NotificationData({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  IconData get icon {
    switch (type) {
      case 'LEAVE_APPROVED':
        return Icons.check_circle;
      case 'LEAVE_REJECTED':
        return Icons.cancel;
      case 'LEAVE_PENDING':
        return Icons.schedule;
      case 'PAYSLIP_READY':
        return Icons.receipt_long;
      case 'DOCUMENT_EXPIRING':
        return Icons.warning_amber;
      case 'ANNOUNCEMENT':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case 'LEAVE_APPROVED':
        return AppColors.success;
      case 'LEAVE_REJECTED':
        return AppColors.error;
      case 'LEAVE_PENDING':
        return AppColors.warning;
      case 'PAYSLIP_READY':
        return AppColors.info;
      case 'DOCUMENT_EXPIRING':
        return AppColors.warning;
      case 'ANNOUNCEMENT':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final _NotificationData notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.isRead ? null : AppColors.primary.withOpacity(0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notification.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.icon,
            color: notification.color,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              notification.createdAt,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Mark as read and navigate
        },
      ),
    );
  }
}
