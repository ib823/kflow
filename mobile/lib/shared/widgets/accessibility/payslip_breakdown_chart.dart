import 'package:flutter/material.dart';

/// Payslip line item model
class PayslipLineItem {
  final String code;
  final String name;
  final double amount;

  const PayslipLineItem({
    required this.code,
    required this.name,
    required this.amount,
  });
}

/// Visual payslip breakdown for low-literacy users
/// Research: Du et al. 2025 - Data visualization improves financial literacy
/// - Horizontal bar chart showing earnings vs deductions
/// - Color-coded with icons
/// - Percentage labels
/// - Screen reader descriptions
class PayslipBreakdownChart extends StatelessWidget {
  final double grossEarnings;
  final double totalDeductions;
  final double netPay;
  final List<PayslipLineItem> earnings;
  final List<PayslipLineItem> deductions;
  final String currencySymbol;

  const PayslipBreakdownChart({
    super.key,
    required this.grossEarnings,
    required this.totalDeductions,
    required this.netPay,
    required this.earnings,
    required this.deductions,
    this.currencySymbol = 'RM',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Payslip breakdown. Gross earnings $currencySymbol${grossEarnings.toStringAsFixed(2)}, '
          'Deductions $currencySymbol${totalDeductions.toStringAsFixed(2)}, '
          'Net pay $currencySymbol${netPay.toStringAsFixed(2)}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Bar
          _buildSummaryBar(theme),

          const SizedBox(height: 24),

          // Earnings breakdown
          _buildSection(
            title: 'Earnings',
            icon: Icons.arrow_upward_rounded,
            iconColor: const Color(0xFF27AE60),
            items: earnings,
            total: grossEarnings,
            theme: theme,
          ),

          const SizedBox(height: 16),

          // Deductions breakdown
          _buildSection(
            title: 'Deductions',
            icon: Icons.arrow_downward_rounded,
            iconColor: const Color(0xFFC0392B),
            items: deductions,
            total: grossEarnings,
            theme: theme,
            isDeduction: true,
          ),

          const Divider(height: 32),

          // Net Pay highlight
          _buildNetPayHighlight(theme),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(ThemeData theme) {
    final netPercent = grossEarnings > 0 ? (netPay / grossEarnings) * 100 : 0;
    final deductionsPercent = grossEarnings > 0 ? (totalDeductions / grossEarnings) * 100 : 0;

    return Column(
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Row(
              children: [
                // Net Pay (what you keep)
                Expanded(
                  flex: netPercent.round().clamp(1, 100),
                  child: Container(
                    color: const Color(0xFF2980B9),
                    child: Center(
                      child: Text(
                        '${netPercent.toStringAsFixed(0)}%',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // Deductions
                if (deductionsPercent > 0)
                  Expanded(
                    flex: deductionsPercent.round().clamp(1, 100),
                    child: Container(
                      color: const Color(0xFFE74C3C),
                      child: Center(
                        child: Text(
                          '${deductionsPercent.toStringAsFixed(0)}%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(
              color: const Color(0xFF2980B9),
              label: 'You Keep',
              icon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(width: 24),
            _legendItem(
              color: const Color(0xFFE74C3C),
              label: 'Deductions',
              icon: Icons.remove_circle_outline_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<PayslipLineItem> items,
    required double total,
    required ThemeData theme,
    bool isDeduction = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildBarItem(item, total, theme, isDeduction)),
      ],
    );
  }

  Widget _buildBarItem(
    PayslipLineItem item,
    double total,
    ThemeData theme,
    bool isDeduction,
  ) {
    final percent = total > 0 ? (item.amount / total) * 100 : 0;
    final barColor = isDeduction
        ? const Color(0xFFE74C3C)
        : const Color(0xFF27AE60);

    return Semantics(
      label: '${item.name}: $currencySymbol${item.amount.toStringAsFixed(2)}, '
          '${percent.toStringAsFixed(1)} percent of gross',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(item.code),
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(item.name, style: theme.textTheme.bodyMedium),
                  ],
                ),
                Text(
                  '$currencySymbol ${item.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (percent / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetPayHighlight(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2980B9), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2980B9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Pay',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1A5276),
                  ),
                ),
                Text(
                  '$currencySymbol ${netPay.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A5276),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String code) {
    switch (code.toUpperCase()) {
      case 'BASIC':
        return Icons.payments_rounded;
      case 'OT':
      case 'OVERTIME':
        return Icons.schedule_rounded;
      case 'ALLOWANCE':
        return Icons.card_giftcard_rounded;
      case 'BONUS':
        return Icons.star_rounded;
      case 'EPF':
      case 'KWSP':
        return Icons.savings_rounded;
      case 'SOCSO':
      case 'PERKESO':
        return Icons.health_and_safety_rounded;
      case 'EIS':
        return Icons.work_off_rounded;
      case 'PCB':
      case 'TAX':
        return Icons.receipt_long_rounded;
      default:
        return Icons.monetization_on_rounded;
    }
  }
}
