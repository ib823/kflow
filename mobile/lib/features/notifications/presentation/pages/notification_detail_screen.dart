import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Notification detail screen showing full notification content
class NotificationDetailScreen extends StatefulWidget {
  final String notificationId;
  final VoidCallback? onActionTap;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
    this.onActionTap,
  });

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  _NotificationDetail? _notification;

  @override
  void initState() {
    super.initState();
    _loadNotificationDetail();
  }

  Future<void> _loadNotificationDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _notification = _getMockNotificationDetail();
      });
    }
  }

  _NotificationDetail _getMockNotificationDetail() {
    // Different notification based on ID prefix
    if (widget.notificationId.contains('001')) {
      return _NotificationDetail(
        id: widget.notificationId,
        type: _NotificationType.payslip,
        title: 'December 2025 Payslip Released',
        message:
            'Your payslip for December 2025 is now available for viewing.\n\nPay Period: 1 - 31 December 2025\nNet Pay: RM 4,422.00\n\nYou can view and download your payslip from the Payslip section.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionLabel: 'View Payslip',
        actionType: _ActionType.viewPayslip,
      );
    } else if (widget.notificationId.contains('002')) {
      return _NotificationDetail(
        id: widget.notificationId,
        type: _NotificationType.leaveApproved,
        title: 'Leave Request Approved',
        message:
            'Your annual leave request for 2-3 Jan 2026 has been approved by Mohd Razak.\n\nLeave Type: Annual Leave\nDuration: 2 days\nApproved By: Mohd Razak bin Abdullah\nApproved On: 21 Dec 2025 at 10:30 AM',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        actionLabel: 'View Leave Details',
        actionType: _ActionType.viewLeave,
      );
    } else if (widget.notificationId.contains('003')) {
      return _NotificationDetail(
        id: widget.notificationId,
        type: _NotificationType.announcement,
        title: 'Company Announcement',
        message:
            'Dear Team,\n\nPlease be informed that the office will be closed on 1st January 2026 (Thursday) in conjunction with New Year\'s Day.\n\nNormal operations will resume on 2nd January 2026 (Friday).\n\nWishing everyone a Happy New Year!\n\nBest regards,\nHuman Resources Department',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        actionLabel: null,
        actionType: null,
      );
    } else {
      return _NotificationDetail(
        id: widget.notificationId,
        type: _NotificationType.system,
        title: 'Profile Update Required',
        message:
            'Your emergency contact information needs to be updated.\n\nPlease ensure your emergency contact details are current and accurate. This information is important for your safety and for HR records.\n\nYou can update this information in your Profile settings.',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        actionLabel: 'Update Profile',
        actionType: _ActionType.updateProfile,
      );
    }
  }

  IconData _getIcon(_NotificationType type) {
    switch (type) {
      case _NotificationType.payslip:
        return Icons.receipt_long;
      case _NotificationType.leaveApproved:
        return Icons.check_circle;
      case _NotificationType.leaveRejected:
        return Icons.cancel;
      case _NotificationType.announcement:
        return Icons.campaign;
      case _NotificationType.reminder:
        return Icons.schedule;
      case _NotificationType.system:
        return Icons.settings;
    }
  }

  Color _getColor(_NotificationType type) {
    switch (type) {
      case _NotificationType.payslip:
        return KFColors.primary600;
      case _NotificationType.leaveApproved:
        return KFColors.success600;
      case _NotificationType.leaveRejected:
        return KFColors.error600;
      case _NotificationType.announcement:
        return KFColors.secondary500;
      case _NotificationType.reminder:
        return KFColors.warning500;
      case _NotificationType.system:
        return KFColors.gray600;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year} at $hour:$minute $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Notification'),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: KFSpacing.screenPadding,
      child: Column(
        children: [
          KFSkeletonCard(height: 100),
          SizedBox(height: KFSpacing.space4),
          KFSkeletonCard(height: 200),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadNotificationDetail,
    );
  }

  Widget _buildContent() {
    final notification = _notification!;
    final iconData = _getIcon(notification.type);
    final iconColor = _getColor(notification.type);

    return SingleChildScrollView(
      padding: KFSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon and title header
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: 36,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: KFSpacing.space4),
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeXl,
                    fontWeight: KFTypography.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: KFSpacing.space2),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeSm,
                    color: KFColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KFSpacing.space6),
          // Message content
          KFCard(
            child: Padding(
              padding: const EdgeInsets.all(KFSpacing.space4),
              child: Text(
                notification.message,
                style: const TextStyle(
                  fontSize: KFTypography.fontSizeMd,
                  height: 1.6,
                ),
              ),
            ),
          ),
          // Action button
          if (notification.actionLabel != null) ...[
            const SizedBox(height: KFSpacing.space6),
            KFPrimaryButton(
              label: notification.actionLabel!,
              onPressed: widget.onActionTap,
            ),
          ],
          const SizedBox(height: KFSpacing.space6),
        ],
      ),
    );
  }
}

enum _NotificationType {
  payslip,
  leaveApproved,
  leaveRejected,
  announcement,
  reminder,
  system,
}

enum _ActionType {
  viewPayslip,
  viewLeave,
  updateProfile,
}

class _NotificationDetail {
  final String id;
  final _NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? actionLabel;
  final _ActionType? actionType;

  _NotificationDetail({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.actionLabel,
    this.actionType,
  });
}
