import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Notification list screen showing all notifications
class NotificationListScreen extends StatefulWidget {
  final void Function(String notificationId)? onNotificationTap;

  const NotificationListScreen({
    super.key,
    this.onNotificationTap,
  });

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<_NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _notifications = _getMockNotifications();
      });
    }
  }

  List<_NotificationItem> _getMockNotifications() {
    return [
      _NotificationItem(
        id: 'notif-001',
        type: NotificationType.payslip,
        title: 'December 2025 Payslip Released',
        message: 'Your payslip for December 2025 is now available for viewing.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      _NotificationItem(
        id: 'notif-002',
        type: NotificationType.leaveApproved,
        title: 'Leave Request Approved',
        message: 'Your annual leave request for 2-3 Jan 2026 has been approved by Mohd Razak.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      _NotificationItem(
        id: 'notif-003',
        type: NotificationType.announcement,
        title: 'Company Announcement',
        message: 'Office closure notice: The office will be closed on 1st January 2026 for New Year.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
      ),
      _NotificationItem(
        id: 'notif-004',
        type: NotificationType.reminder,
        title: 'Leave Balance Reminder',
        message: 'You have 12 days of annual leave remaining. Remember to plan your leave before year end.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      _NotificationItem(
        id: 'notif-005',
        type: NotificationType.leaveRejected,
        title: 'Leave Request Rejected',
        message: 'Your annual leave request for 15 Dec 2025 has been rejected.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
      ),
      _NotificationItem(
        id: 'notif-006',
        type: NotificationType.system,
        title: 'Profile Update Required',
        message: 'Please update your emergency contact information in your profile.',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        isRead: true,
      ),
    ];
  }

  Future<void> _onRefresh() async {
    await _loadNotifications();
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _NotificationItem(
          id: _notifications[i].id,
          type: _notifications[i].type,
          title: _notifications[i].title,
          message: _notifications[i].message,
          timestamp: _notifications[i].timestamp,
          isRead: true,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KFAppBar(
        title: 'Notifications',
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationList(),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: KFSpacing.screenPadding,
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: KFSpacing.space3),
          child: KFSkeletonCard(height: 100),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadNotifications,
    );
  }

  Widget _buildEmptyState() {
    return const KFEmptyState(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      message: 'You\'re all caught up! Check back later for updates.',
    );
  }

  Widget _buildNotificationList() {
    return KFRefreshable(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: KFSpacing.screenPadding,
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: KFSpacing.space3),
            child: _buildNotificationCard(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(_NotificationItem notification) {
    final iconData = _getNotificationIcon(notification.type);
    final iconColor = _getNotificationColor(notification.type);

    return KFNotificationCard(
      icon: iconData,
      iconColor: iconColor,
      title: notification.title,
      message: notification.message,
      timestamp: notification.timestamp,
      isRead: notification.isRead,
      onTap: () {
        // Mark as read when tapped
        setState(() {
          final index = _notifications.indexOf(notification);
          if (index != -1) {
            _notifications[index] = _NotificationItem(
              id: notification.id,
              type: notification.type,
              title: notification.title,
              message: notification.message,
              timestamp: notification.timestamp,
              isRead: true,
            );
          }
        });
        widget.onNotificationTap?.call(notification.id);
      },
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.payslip:
        return Icons.receipt_long;
      case NotificationType.leaveApproved:
        return Icons.check_circle;
      case NotificationType.leaveRejected:
        return Icons.cancel;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.payslip:
        return KFColors.primary600;
      case NotificationType.leaveApproved:
        return KFColors.success600;
      case NotificationType.leaveRejected:
        return KFColors.error600;
      case NotificationType.announcement:
        return KFColors.secondary500;
      case NotificationType.reminder:
        return KFColors.warning500;
      case NotificationType.system:
        return KFColors.gray600;
    }
  }
}

enum NotificationType {
  payslip,
  leaveApproved,
  leaveRejected,
  announcement,
  reminder,
  system,
}

class _NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  _NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}
