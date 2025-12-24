import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class LeaveHistoryScreen extends ConsumerWidget {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data
    final requests = [
      _LeaveRequestData(1, 'AL', 'Annual Leave', '2025-12-28', '2025-12-31', 4, 'APPROVED'),
      _LeaveRequestData(2, 'MC', 'Medical Leave', '2025-12-15', '2025-12-15', 1, 'APPROVED'),
      _LeaveRequestData(3, 'AL', 'Annual Leave', '2025-11-20', '2025-11-22', 3, 'PENDING'),
      _LeaveRequestData(4, 'EL', 'Emergency Leave', '2025-11-10', '2025-11-10', 1, 'REJECTED'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _LeaveRequestCard(
            request: request,
            onTap: () => context.push('/leave/request/${request.id}'),
          );
        },
      ),
    );
  }
}

class _LeaveRequestData {
  final int id;
  final String code;
  final String typeName;
  final String dateFrom;
  final String dateTo;
  final double totalDays;
  final String status;

  _LeaveRequestData(
    this.id,
    this.code,
    this.typeName,
    this.dateFrom,
    this.dateTo,
    this.totalDays,
    this.status,
  );

  Color get statusColor {
    switch (status) {
      case 'APPROVED':
        return AppColors.success;
      case 'PENDING':
        return AppColors.warning;
      case 'REJECTED':
        return AppColors.error;
      case 'CANCELLED':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get typeColor {
    switch (code) {
      case 'AL':
        return const Color(0xFF4CAF50);
      case 'MC':
        return const Color(0xFFF44336);
      case 'EL':
        return const Color(0xFFFF9800);
      default:
        return AppColors.primary;
    }
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final _LeaveRequestData request;
  final VoidCallback onTap;

  const _LeaveRequestCard({
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateRange = request.dateFrom == request.dateTo
        ? request.dateFrom
        : '${request.dateFrom} - ${request.dateTo}';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      color: Colors.grey.shade50,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: request.typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      request.code,
                      style: TextStyle(
                        color: request.typeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${request.totalDays.toStringAsFixed(request.totalDays.truncateToDouble() == request.totalDays ? 0 : 1)}d',
                      style: TextStyle(
                        color: request.typeColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.typeName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      dateRange,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: request.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    color: request.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
