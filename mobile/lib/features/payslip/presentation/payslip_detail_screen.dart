import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';

class PayslipDetailScreen extends ConsumerWidget {
  final int payslipId;

  const PayslipDetailScreen({super.key, required this.payslipId});

  String _formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data
    final payslip = {
      'pay_period': 'December 2025',
      'pay_date': '2025-12-31',
      'employee': {
        'full_name': 'John Doe',
        'employee_no': 'TC002',
        'ic_no': '****5678',
        'epf_no': '23456789',
        'bank_name': 'Maybank',
        'bank_account_no': '****7890',
      },
      'earnings': [
        {'code': 'BASIC', 'name': 'Basic Salary', 'amount': 5500.00},
        {'code': 'ALLOW_TRANS', 'name': 'Transport Allowance', 'amount': 300.00},
        {'code': 'ALLOW_MEAL', 'name': 'Meal Allowance', 'amount': 200.00},
      ],
      'deductions': [
        {'code': 'EPF_EE', 'name': 'EPF (Employee)', 'amount': 660.00},
        {'code': 'SOCSO_EE', 'name': 'SOCSO (Employee)', 'amount': 23.65},
        {'code': 'EIS_EE', 'name': 'EIS (Employee)', 'amount': 12.00},
        {'code': 'PCB', 'name': 'PCB (Tax)', 'amount': 250.00},
      ],
      'summary': {
        'basic_salary': 5500.00,
        'gross_salary': 6000.00,
        'total_deductions': 945.65,
        'net_salary': 5054.35,
      },
      'statutory': {
        'epf_employee': 660.00,
        'epf_employer': 780.00,
        'socso_employee': 23.65,
        'socso_employer': 82.95,
        'eis_employee': 12.00,
        'eis_employer': 12.00,
      },
    };

    final employee = payslip['employee'] as Map;
    final earnings = payslip['earnings'] as List;
    final deductions = payslip['deductions'] as List;
    final summary = payslip['summary'] as Map;
    final statutory = payslip['statutory'] as Map;

    return Scaffold(
      appBar: AppBar(
        title: Text(payslip['pay_period'] as String),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading PDF...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing payslip...')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // View PDF Button
          ElevatedButton.icon(
            onPressed: () => context.push('/payslips/$payslipId/pdf'),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('View PDF'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Employee Info Card
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee['full_name'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow('Employee No', employee['employee_no'] as String),
                  _InfoRow('IC No', employee['ic_no'] as String),
                  _InfoRow('EPF No', employee['epf_no'] as String),
                  _InfoRow('Bank', employee['bank_name'] as String),
                  _InfoRow('Account', employee['bank_account_no'] as String),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Earnings
          _SectionCard(
            title: 'Earnings',
            color: AppColors.success,
            items: earnings.map((e) => _LineItem(
              name: e['name'] as String,
              amount: e['amount'] as double,
            )).toList(),
            total: summary['gross_salary'] as double,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Deductions
          _SectionCard(
            title: 'Deductions',
            color: AppColors.error,
            items: deductions.map((d) => _LineItem(
              name: d['name'] as String,
              amount: d['amount'] as double,
            )).toList(),
            total: summary['total_deductions'] as double,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Net Salary
          Card(
            elevation: 0,
            color: AppColors.primary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Salary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _formatCurrency(summary['net_salary'] as double),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Statutory Contributions
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statutory Contributions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(height: AppSpacing.xl),
                  _StatutoryRow(
                    'EPF',
                    statutory['epf_employee'] as double,
                    statutory['epf_employer'] as double,
                  ),
                  _StatutoryRow(
                    'SOCSO',
                    statutory['socso_employee'] as double,
                    statutory['socso_employer'] as double,
                  ),
                  _StatutoryRow(
                    'EIS',
                    statutory['eis_employee'] as double,
                    statutory['eis_employer'] as double,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _LineItem {
  final String name;
  final double amount;

  _LineItem({required this.name, required this.amount});
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<_LineItem> items;
  final double total;

  const _SectionCard({
    required this.title,
    required this.color,
    required this.items,
    required this.total,
  });

  String _formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.name),
                  Text(_formatCurrency(item.amount)),
                ],
              ),
            )),
            const Divider(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total $title',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatCurrency(total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatutoryRow extends StatelessWidget {
  final String label;
  final double employee;
  final double employer;

  const _StatutoryRow(this.label, this.employee, this.employer);

  String _formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            flex: 3,
            child: Text(
              'Employee: ${_formatCurrency(employee)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Employer: ${_formatCurrency(employer)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
