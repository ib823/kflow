import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';

class LeaveRequestScreen extends ConsumerWidget {
  final int requestId;

  const LeaveRequestScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data
    final request = {
      'id': requestId,
      'leave_type': {'code': 'AL', 'name': 'Annual Leave', 'color': '#4CAF50'},
      'date_from': '2025-12-28',
      'date_to': '2025-12-31',
      'total_days': 4.0,
      'reason': 'Year-end family vacation',
      'status': 'APPROVED',
      'approver': {'name': 'Raj Kumar'},
      'approved_at': '2025-12-20T14:30:00',
      'created_at': '2025-12-18T09:15:00',
    };

    final status = request['status'] as String;
    final canCancel = status == 'PENDING';

    Color statusColor;
    switch (status) {
      case 'APPROVED':
        statusColor = AppColors.success;
        break;
      case 'PENDING':
        statusColor = AppColors.warning;
        break;
      case 'REJECTED':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Status Card
          Card(
            elevation: 0,
            color: statusColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status == 'APPROVED'
                          ? Icons.check_circle
                          : status == 'PENDING'
                              ? Icons.schedule
                              : Icons.cancel,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                        ),
                        if (status == 'APPROVED') ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Approved by ${(request['approver'] as Map)['name']}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Leave Details
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(height: AppSpacing.xl),
                  _DetailRow(
                    label: 'Leave Type',
                    value: (request['leave_type'] as Map)['name'] as String,
                  ),
                  _DetailRow(
                    label: 'From Date',
                    value: request['date_from'] as String,
                  ),
                  _DetailRow(
                    label: 'To Date',
                    value: request['date_to'] as String,
                  ),
                  _DetailRow(
                    label: 'Total Days',
                    value: '${(request['total_days'] as double).toStringAsFixed(0)} days',
                  ),
                  if (request['reason'] != null)
                    _DetailRow(
                      label: 'Reason',
                      value: request['reason'] as String,
                    ),
                  _DetailRow(
                    label: 'Applied On',
                    value: (request['created_at'] as String).substring(0, 10),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Cancel Button
          if (canCancel)
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancel Leave Request?'),
                    content: const Text(
                      'Are you sure you want to cancel this leave request?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Call API to cancel
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Leave request cancelled'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          context.pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Yes, Cancel'),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: const Text('Cancel Request'),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
