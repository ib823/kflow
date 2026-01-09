import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';

/// Notification type enum
enum NotificationType {
  leaveApproved,
  leaveRejected,
  payslipAvailable,
  documentExpiring,
  approvalPending,
  announcement,
  systemAlert,
}

/// S-070: Notification Detail Screen
///
/// Display full notification content with:
/// - Auto mark as read on open
/// - Deep linking to related screens
/// - Delete option
/// - Timestamp with relative time
class NotificationDetailScreen extends ConsumerStatefulWidget {
  final String notificationId;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
  });

  @override
  ConsumerState<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends ConsumerState<NotificationDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _notification;

  // Mock notifications database
  final Map<String, Map<String, dynamic>> _mockNotifications = {
    '1': {
      'id': '1',
      'type': NotificationType.leaveApproved,
      'title': 'Leave Approved',
      'message': 'Your annual leave request for 10-12 January 2026 has been approved by your manager.',
      'related_id': '101',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(hours: 2)),
    },
    '2': {
      'id': '2',
      'type': NotificationType.payslipAvailable,
      'title': 'Payslip Available',
      'message': 'Your payslip for December 2025 is now available. Tap to view details.',
      'related_id': '1',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(days: 1)),
    },
    '3': {
      'id': '3',
      'type': NotificationType.documentExpiring,
      'title': 'Document Expiring Soon',
      'message': 'Your Work Permit will expire in 30 days. Please ensure to renew it before expiry to avoid any issues.',
      'related_id': '1',
      'is_read': true,
      'created_at': DateTime.now().subtract(const Duration(days: 3)),
    },
    '4': {
      'id': '4',
      'type': NotificationType.approvalPending,
      'title': 'Approval Required',
      'message': 'Ahmad bin Ali has submitted a leave request that requires your approval. Please review and respond.',
      'related_id': '201',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(hours: 5)),
    },
    '5': {
      'id': '5',
      'type': NotificationType.announcement,
      'title': 'Company Announcement',
      'message': 'Dear all employees,\n\nWe are pleased to announce that KerjaFlow has been recognized as the Best Workforce Management Platform in ASEAN for 2025.\n\nThank you for your continued support and dedication.\n\nBest regards,\nHuman Resources',
      'related_id': null,
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(days: 7)),
    },
    '6': {
      'id': '6',
      'type': NotificationType.leaveRejected,
      'title': 'Leave Rejected',
      'message': 'Your emergency leave request for 5 January 2026 has been rejected. Reason: Insufficient staffing during the requested period.',
      'related_id': '102',
      'is_read': true,
      'created_at': DateTime.now().subtract(const Duration(days: 2)),
    },
  };

  @override
  void initState() {
    super.initState();
    _loadNotification();
  }

  Future<void> _loadNotification() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final notification = _mockNotifications[widget.notificationId];
      if (notification == null) {
        throw Exception('Notification not found');
      }

      _notification = notification;

      // Mark as read
      if (!(_notification!['is_read'] as bool)) {
        await _markAsRead();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _markAsRead() async {
    // Simulate API call: POST /api/v1/notifications/{id}/read
    await Future.delayed(const Duration(milliseconds: 100));
    _notification!['is_read'] = true;
  }

  Future<void> _deleteNotification() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
      context.pop();
    }
  }

  void _navigateToRelatedScreen() {
    if (_notification == null) return;

    final type = _notification!['type'] as NotificationType;
    final relatedId = _notification!['related_id'] as String?;

    if (relatedId == null) return;

    switch (type) {
      case NotificationType.leaveApproved:
      case NotificationType.leaveRejected:
        context.push('/leave/request/$relatedId');
        break;
      case NotificationType.payslipAvailable:
        context.push('/payslips/$relatedId');
        break;
      case NotificationType.documentExpiring:
        context.push('/documents/$relatedId');
        break;
      case NotificationType.approvalPending:
        context.push('/approval/$relatedId');
        break;
      case NotificationType.announcement:
      case NotificationType.systemAlert:
        // Stay on this screen for announcements/alerts
        break;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.leaveApproved:
        return Icons.check_circle;
      case NotificationType.leaveRejected:
        return Icons.cancel;
      case NotificationType.payslipAvailable:
        return Icons.receipt_long;
      case NotificationType.documentExpiring:
        return Icons.warning_amber;
      case NotificationType.approvalPending:
        return Icons.pending_actions;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.systemAlert:
        return Icons.notifications_active;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.leaveApproved:
        return AppColors.success;
      case NotificationType.leaveRejected:
        return AppColors.error;
      case NotificationType.payslipAvailable:
        return AppColors.primary;
      case NotificationType.documentExpiring:
        return AppColors.warning;
      case NotificationType.approvalPending:
        return AppColors.info;
      case NotificationType.announcement:
        return AppColors.primary;
      case NotificationType.systemAlert:
        return AppColors.error;
    }
  }

  bool _hasDeepLink(NotificationType type) {
    return type != NotificationType.announcement && type != NotificationType.systemAlert;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _notification != null ? _deleteNotification : null,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text('Failed to load notification'),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _loadNotification,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final notification = _notification!;
    final type = notification['type'] as NotificationType;
    final createdAt = notification['created_at'] as DateTime;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type indicator with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  size: 32,
                  color: _getTypeColor(type),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatRelativeTime(createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.xl),

          // Message content
          Text(
            notification['message'] as String,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Action button for deep linking
          if (_hasDeepLink(type) && notification['related_id'] != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToRelatedScreen,
                icon: const Icon(Icons.open_in_new),
                label: Text(_getActionButtonLabel(type)),
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Timestamp
          Center(
            child: Text(
              'Received on ${createdAt.day}/${createdAt.month}/${createdAt.year} at ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActionButtonLabel(NotificationType type) {
    switch (type) {
      case NotificationType.leaveApproved:
      case NotificationType.leaveRejected:
        return 'View Leave Request';
      case NotificationType.payslipAvailable:
        return 'View Payslip';
      case NotificationType.documentExpiring:
        return 'View Document';
      case NotificationType.approvalPending:
        return 'Review Request';
      default:
        return 'View Details';
    }
  }
}
