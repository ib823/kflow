import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class LeaveBalanceScreen extends ConsumerWidget {
  const LeaveBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data - replace with actual provider
    final balances = [
      _LeaveBalanceData('AL', 'Annual Leave', 'Cuti Tahunan', 10, 14, '#4CAF50'),
      _LeaveBalanceData('MC', 'Medical Leave', 'Cuti Sakit', 12, 14, '#F44336'),
      _LeaveBalanceData('EL', 'Emergency Leave', 'Cuti Kecemasan', 2, 3, '#FF9800'),
      _LeaveBalanceData('CL', 'Compassionate Leave', 'Cuti Ehsan', 3, 3, '#9E9E9E'),
      _LeaveBalanceData('UL', 'Unpaid Leave', 'Cuti Tanpa Gaji', 30, 30, '#795548'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Balance'),
        actions: [
          Semantics(
            label: 'View leave history',
            child: IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Leave History',
              onPressed: () => context.push(AppRoutes.leaveHistory),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: balances.length,
        itemBuilder: (context, index) {
          final balance = balances[index];
          return _LeaveBalanceCard(balance: balance);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.leaveApply),
        icon: const Icon(Icons.add),
        label: const Text('Apply Leave'),
      ),
    );
  }
}

class _LeaveBalanceData {
  final String code;
  final String name;
  final String nameMs;
  final double available;
  final double entitled;
  final String colorHex;

  _LeaveBalanceData(
    this.code,
    this.name,
    this.nameMs,
    this.available,
    this.entitled,
    this.colorHex,
  );

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
}

class _LeaveBalanceCard extends StatelessWidget {
  final _LeaveBalanceData balance;

  const _LeaveBalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final progress = balance.available / balance.entitled;
    final taken = balance.entitled - balance.available;

    return Semantics(
      label: '${balance.name}, ${balance.available.toStringAsFixed(0)} days available of ${balance.entitled.toStringAsFixed(0)} entitled, ${taken.toStringAsFixed(0)} days taken',
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: balance.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        balance.code,
                        style: TextStyle(
                          color: balance.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          balance.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          balance.nameMs,
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
                        '${balance.available.toStringAsFixed(balance.available.truncateToDouble() == balance.available ? 0 : 1)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: balance.color,
                            ),
                      ),
                      Text(
                        'days left',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(balance.color),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Taken: ${taken.toStringAsFixed(taken.truncateToDouble() == taken ? 0 : 1)} days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    'Entitled: ${balance.entitled.toStringAsFixed(balance.entitled.truncateToDouble() == balance.entitled ? 0 : 1)} days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
