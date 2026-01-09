import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../widgets/rejection_reason_dialog.dart';

/// S-051: Approval Detail Screen
///
/// Manager view for leave request approval with:
/// - Full leave request details
/// - Employee info with photo
/// - Leave type, dates, duration
/// - Reason and attachments
/// - Approve button (green) with confirmation
/// - Reject button (red) with mandatory reason
class ApprovalDetailScreen extends ConsumerStatefulWidget {
  final String leaveRequestId;

  const ApprovalDetailScreen({
    super.key,
    required this.leaveRequestId,
  });

  @override
  ConsumerState<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends ConsumerState<ApprovalDetailScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;
  Map<String, dynamic>? _leaveRequest;

  @override
  void initState() {
    super.initState();
    _loadLeaveRequest();
  }

  Future<void> _loadLeaveRequest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock leave request data
      _leaveRequest = {
        'id': widget.leaveRequestId,
        'status': 'pending',
        'employee': {
          'id': 'emp001',
          'name': 'Ahmad bin Ali',
          'employee_no': 'TC001',
          'department': 'Operations',
          'position': 'Technician',
          'avatar_url': null,
        },
        'leave_type': 'Annual Leave',
        'start_date': DateTime.now().add(const Duration(days: 5)),
        'end_date': DateTime.now().add(const Duration(days: 7)),
        'duration': 3,
        'duration_unit': 'days',
        'reason': 'Family vacation planned for the long weekend. Will be traveling outstation.',
        'submitted_at': DateTime.now().subtract(const Duration(hours: 2)),
        'attachments': <Map<String, dynamic>>[],
        'leave_balance': {
          'before': 14,
          'after': 11,
        },
      };

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Confirm Approval'),
        content: const Text(
          'Are you sure you want to approve this leave request? '
          'The employee will be notified immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processApproval(true, null);
    }
  }

  Future<void> _handleReject() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const RejectionReasonDialog(),
    );

    if (reason != null && reason.length >= 10) {
      await _processApproval(false, reason);
    }
  }

  Future<void> _processApproval(bool approved, String? reason) async {
    setState(() => _isProcessing = true);

    try {
      // Simulate API call
      // POST /api/v1/leave/{id}/approve or /api/v1/leave/{id}/reject
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approved
                  ? 'Leave request approved successfully'
                  : 'Leave request rejected',
            ),
            backgroundColor: approved ? AppColors.success : AppColors.error,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Approval'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _isLoading || _error != null || _leaveRequest?['status'] != 'pending'
          ? null
          : _buildActionButtons(),
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
            Text('Failed to load leave request'),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _loadLeaveRequest,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final request = _leaveRequest!;
    final employee = request['employee'] as Map<String, dynamic>;
    final balance = request['leave_balance'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge (if already processed)
          if (request['status'] != 'pending')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: request['status'] == 'approved'
                    ? AppColors.successSurface
                    : AppColors.errorSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    request['status'] == 'approved'
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: request['status'] == 'approved'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    request['status'] == 'approved' ? 'Approved' : 'Rejected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: request['status'] == 'approved'
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),

          // Employee info card
          Card(
            elevation: 0,
            color: AppColors.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      employee['name'].toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['name'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          employee['position'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${employee['department']} • ${employee['employee_no']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Leave details
          _buildSectionTitle('Leave Details'),
          Card(
            elevation: 0,
            color: AppColors.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Leave Type',
                    request['leave_type'] as String,
                    icon: Icons.event_note,
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildDetailRow(
                    'Start Date',
                    _formatDate(request['start_date'] as DateTime),
                    icon: Icons.calendar_today,
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildDetailRow(
                    'End Date',
                    _formatDate(request['end_date'] as DateTime),
                    icon: Icons.calendar_today,
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildDetailRow(
                    'Duration',
                    '${request['duration']} ${request['duration_unit']}',
                    icon: Icons.timelapse,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Leave balance
          _buildSectionTitle('Leave Balance Impact'),
          Card(
            elevation: 0,
            color: AppColors.infoSurface,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Before',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${balance['before']} days',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: AppColors.info),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'After',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${balance['after']} days',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Reason
          _buildSectionTitle('Reason'),
          Card(
            elevation: 0,
            color: AppColors.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                request['reason'] as String,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Attachments
          if ((request['attachments'] as List).isNotEmpty) ...[
            _buildSectionTitle('Attachments'),
            Card(
              elevation: 0,
              color: AppColors.surfaceVariant,
              child: Column(
                children: (request['attachments'] as List).map<Widget>((att) {
                  return ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(att['name'] as String),
                    trailing: const Icon(Icons.visibility),
                    onTap: () {
                      // Open attachment viewer
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Submitted timestamp
          Text(
            'Submitted: ${_formatDateTime(request['submitted_at'] as DateTime)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
        ],
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Reject button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _handleReject,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Approve button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _handleApprove,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
