import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/accessible_tap.dart';
import '../../../../core/router/app_router.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'Apply Leave',
              color: AppColors.primary,
              onTap: () => context.push(AppRoutes.leaveApply),
            ),
            _QuickActionButton(
              icon: Icons.history,
              label: 'Leave History',
              color: AppColors.info,
              onTap: () => context.push(AppRoutes.leaveHistory),
            ),
            _QuickActionButton(
              icon: Icons.receipt_long,
              label: 'View Payslip',
              color: AppColors.success,
              onTap: () => context.push(AppRoutes.payslipList),
            ),
            _QuickActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Clock In',
              color: AppColors.warning,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attendance feature coming soon'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleTap(
      onTap: onTap,
      semanticLabel: label,
      semanticHint: 'Tap to $label',
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
