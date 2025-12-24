import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class PayslipListScreen extends ConsumerWidget {
  const PayslipListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data
    final payslips = [
      {'id': 1, 'pay_period': '2025-12', 'pay_date': '2025-12-31', 'net_salary': 4800.00},
      {'id': 2, 'pay_period': '2025-11', 'pay_date': '2025-11-30', 'net_salary': 4800.00},
      {'id': 3, 'pay_period': '2025-10', 'pay_date': '2025-10-31', 'net_salary': 4650.00},
      {'id': 4, 'pay_period': '2025-09', 'pay_date': '2025-09-30', 'net_salary': 4800.00},
      {'id': 5, 'pay_period': '2025-08', 'pay_date': '2025-08-31', 'net_salary': 4800.00},
      {'id': 6, 'pay_period': '2025-07', 'pay_date': '2025-07-31', 'net_salary': 4800.00},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslips'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (year) {
              // TODO: Filter by year
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 2025, child: Text('2025')),
              const PopupMenuItem(value: 2024, child: Text('2024')),
              const PopupMenuItem(value: 2023, child: Text('2023')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: payslips.length,
        itemBuilder: (context, index) {
          final payslip = payslips[index];
          return _PayslipCard(
            payPeriod: payslip['pay_period'] as String,
            payDate: payslip['pay_date'] as String,
            netSalary: payslip['net_salary'] as double,
            onTap: () {
              // Navigate to PIN verification first, then payslip detail
              context.push(
                '${AppRoutes.pinVerify}?returnTo=/payslips/${payslip['id']}',
              );
            },
          );
        },
      ),
    );
  }
}

class _PayslipCard extends StatelessWidget {
  final String payPeriod;
  final String payDate;
  final double netSalary;
  final VoidCallback onTap;

  const _PayslipCard({
    required this.payPeriod,
    required this.payDate,
    required this.netSalary,
    required this.onTap,
  });

  String _formatPeriod(String period) {
    final parts = period.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }

  String _formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPeriod(payPeriod),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Paid on $payDate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(netSalary),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PIN required',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
