import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Leave detail screen showing full information about a leave application
class LeaveDetailScreen extends StatefulWidget {
  final String leaveId;
  final VoidCallback? onCancel;

  const LeaveDetailScreen({
    super.key,
    required this.leaveId,
    this.onCancel,
  });

  @override
  State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  _LeaveDetail? _leaveDetail;

  @override
  void initState() {
    super.initState();
    _loadLeaveDetail();
  }

  Future<void> _loadLeaveDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _leaveDetail = _getMockLeaveDetail();
      });
    }
  }

  _LeaveDetail _getMockLeaveDetail() {
    return _LeaveDetail(
      id: widget.leaveId,
      type: 'Annual Leave',
      typeIcon: Icons.beach_access,
      typeColor: KFColors.primary600,
      startDate: DateTime(2026, 1, 2),
      endDate: DateTime(2026, 1, 3),
      days: 2,
      status: StatusType.approved,
      reason: 'Family vacation - visiting hometown for New Year celebration',
      appliedDate: DateTime(2025, 12, 20),
      approvedDate: DateTime(2025, 12, 21),
      approver: 'Mohd Razak bin Abdullah',
      approverPosition: 'Engineering Manager',
      attachments: [],
      timeline: [
        _TimelineItem(
          title: 'Approved',
          subtitle: 'By Mohd Razak bin Abdullah',
          date: DateTime(2025, 12, 21, 10, 30),
          icon: Icons.check_circle,
          color: KFColors.success600,
        ),
        _TimelineItem(
          title: 'Submitted',
          subtitle: 'Application submitted',
          date: DateTime(2025, 12, 20, 14, 15),
          icon: Icons.send,
          color: KFColors.primary600,
        ),
      ],
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Leave?'),
        content: const Text(
          'Are you sure you want to cancel this leave application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCancel?.call();
            },
            style: TextButton.styleFrom(foregroundColor: KFColors.error600),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Leave Detail'),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: KFSpacing.screenPadding,
      child: Column(
        children: const [
          KFSkeletonCard(height: 150),
          SizedBox(height: KFSpacing.space4),
          KFSkeletonCard(height: 200),
          SizedBox(height: KFSpacing.space4),
          KFSkeletonCard(height: 150),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadLeaveDetail,
    );
  }

  Widget _buildContent() {
    final detail = _leaveDetail!;

    return SingleChildScrollView(
      padding: KFSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(detail),
          const SizedBox(height: KFSpacing.space4),
          _buildDetailsCard(detail),
          const SizedBox(height: KFSpacing.space4),
          _buildApproverCard(detail),
          const SizedBox(height: KFSpacing.space4),
          _buildTimelineCard(detail),
          if (detail.status == StatusType.pending ||
              detail.status == StatusType.approved) ...[
            const SizedBox(height: KFSpacing.space6),
            _buildCancelButton(detail),
          ],
          const SizedBox(height: KFSpacing.space6),
        ],
      ),
    );
  }

  Widget _buildStatusCard(_LeaveDetail detail) {
    final statusColors = {
      StatusType.pending: KFColors.warning500,
      StatusType.approved: KFColors.success500,
      StatusType.rejected: KFColors.error500,
    };

    final statusBgColors = {
      StatusType.pending: KFColors.warning100,
      StatusType.approved: KFColors.success100,
      StatusType.rejected: KFColors.error100,
    };

    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: detail.typeColor.withOpacity(0.1),
                    borderRadius: KFRadius.radiusMd,
                  ),
                  child: Icon(
                    detail.typeIcon,
                    color: detail.typeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: KFSpacing.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.type,
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeXl,
                          fontWeight: KFTypography.bold,
                        ),
                      ),
                      const SizedBox(height: KFSpacing.space1),
                      Text(
                        '${detail.days} ${detail.days == 1 ? 'day' : 'days'}',
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeMd,
                          color: KFColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: KFSpacing.space4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KFSpacing.space3),
              decoration: BoxDecoration(
                color: statusBgColors[detail.status],
                borderRadius: KFRadius.radiusMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    detail.status == StatusType.approved
                        ? Icons.check_circle
                        : detail.status == StatusType.rejected
                            ? Icons.cancel
                            : Icons.schedule,
                    color: statusColors[detail.status],
                    size: 20,
                  ),
                  const SizedBox(width: KFSpacing.space2),
                  Text(
                    _getStatusLabel(detail.status),
                    style: TextStyle(
                      fontSize: KFTypography.fontSizeMd,
                      fontWeight: KFTypography.semiBold,
                      color: statusColors[detail.status],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(_LeaveDetail detail) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leave Details',
              style: TextStyle(
                fontSize: KFTypography.fontSizeMd,
                fontWeight: KFTypography.semiBold,
              ),
            ),
            const SizedBox(height: KFSpacing.space4),
            _buildDetailRow(
              'Start Date',
              _formatDate(detail.startDate),
              Icons.calendar_today,
            ),
            _buildDetailRow(
              'End Date',
              _formatDate(detail.endDate),
              Icons.event,
            ),
            _buildDetailRow(
              'Duration',
              '${detail.days} ${detail.days == 1 ? 'day' : 'days'}',
              Icons.access_time,
            ),
            _buildDetailRow(
              'Applied On',
              _formatDate(detail.appliedDate),
              Icons.edit_calendar,
            ),
            const SizedBox(height: KFSpacing.space3),
            const Divider(),
            const SizedBox(height: KFSpacing.space3),
            const Text(
              'Reason',
              style: TextStyle(
                fontSize: KFTypography.fontSizeSm,
                fontWeight: KFTypography.medium,
                color: KFColors.gray600,
              ),
            ),
            const SizedBox(height: KFSpacing.space2),
            Text(
              detail.reason,
              style: const TextStyle(
                fontSize: KFTypography.fontSizeSm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KFSpacing.space3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: KFColors.gray500),
          const SizedBox(width: KFSpacing.space3),
          Text(
            label,
            style: const TextStyle(
              fontSize: KFTypography.fontSizeSm,
              color: KFColors.gray600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: KFTypography.fontSizeSm,
              fontWeight: KFTypography.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApproverCard(_LeaveDetail detail) {
    if (detail.approver == null) return const SizedBox.shrink();

    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Approver',
              style: TextStyle(
                fontSize: KFTypography.fontSizeMd,
                fontWeight: KFTypography.semiBold,
              ),
            ),
            const SizedBox(height: KFSpacing.space3),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: KFColors.primary100,
                  child: Icon(
                    Icons.person,
                    color: KFColors.primary600,
                  ),
                ),
                const SizedBox(width: KFSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.approver!,
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeMd,
                          fontWeight: KFTypography.medium,
                        ),
                      ),
                      if (detail.approverPosition != null)
                        Text(
                          detail.approverPosition!,
                          style: const TextStyle(
                            fontSize: KFTypography.fontSizeSm,
                            color: KFColors.gray600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(_LeaveDetail detail) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(
                fontSize: KFTypography.fontSizeMd,
                fontWeight: KFTypography.semiBold,
              ),
            ),
            const SizedBox(height: KFSpacing.space4),
            ...detail.timeline.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == detail.timeline.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: 16,
                          color: item.color,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: KFColors.gray200,
                        ),
                    ],
                  ),
                  const SizedBox(width: KFSpacing.space3),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0 : KFSpacing.space4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: KFTypography.fontSizeSm,
                              fontWeight: KFTypography.semiBold,
                            ),
                          ),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: KFTypography.fontSizeXs,
                              color: KFColors.gray600,
                            ),
                          ),
                          Text(
                            _formatDateTime(item.date),
                            style: const TextStyle(
                              fontSize: KFTypography.fontSizeXs,
                              color: KFColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(_LeaveDetail detail) {
    final canCancel = detail.startDate.isAfter(DateTime.now());

    if (!canCancel) return const SizedBox.shrink();

    return KFDangerButton(
      label: 'Cancel Leave',
      onPressed: _showCancelConfirmation,
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $period';
  }

  String _getStatusLabel(StatusType status) {
    switch (status) {
      case StatusType.pending:
        return 'Pending Approval';
      case StatusType.approved:
        return 'Approved';
      case StatusType.rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}

class _LeaveDetail {
  final String id;
  final String type;
  final IconData typeIcon;
  final Color typeColor;
  final DateTime startDate;
  final DateTime endDate;
  final double days;
  final StatusType status;
  final String reason;
  final DateTime appliedDate;
  final DateTime? approvedDate;
  final String? approver;
  final String? approverPosition;
  final List<String> attachments;
  final List<_TimelineItem> timeline;

  _LeaveDetail({
    required this.id,
    required this.type,
    required this.typeIcon,
    required this.typeColor,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.status,
    required this.reason,
    required this.appliedDate,
    this.approvedDate,
    this.approver,
    this.approverPosition,
    required this.attachments,
    required this.timeline,
  });
}

class _TimelineItem {
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;

  _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });
}
