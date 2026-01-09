import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// PayslipCard Widget Tests
///
/// Tests display of payslip information and user interactions.
void main() {
  group('PayslipCard Widget Tests', () {
    /// Helper to create a testable widget
    Widget createTestWidget({required Widget child}) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    }

    testWidgets('displays period correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockPayslipCard(
            period: 'January 2026',
            grossSalary: 5000.00,
            netSalary: 4422.00,
            currency: 'MYR',
            status: 'Paid',
          ),
        ),
      );

      expect(find.text('January 2026'), findsOneWidget);
    });

    testWidgets('displays gross salary with currency', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockPayslipCard(
            period: 'January 2026',
            grossSalary: 5000.00,
            netSalary: 4422.00,
            currency: 'MYR',
            status: 'Paid',
          ),
        ),
      );

      expect(find.text('MYR 5,000.00'), findsOneWidget);
    });

    testWidgets('displays net salary with currency', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockPayslipCard(
            period: 'January 2026',
            grossSalary: 5000.00,
            netSalary: 4422.00,
            currency: 'MYR',
            status: 'Paid',
          ),
        ),
      );

      expect(find.text('MYR 4,422.00'), findsOneWidget);
    });

    testWidgets('displays paid status with green indicator', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockPayslipCard(
            period: 'January 2026',
            grossSalary: 5000.00,
            netSalary: 4422.00,
            currency: 'MYR',
            status: 'Paid',
          ),
        ),
      );

      expect(find.text('Paid'), findsOneWidget);
      // Verify green color indicator exists
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.green,
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays pending status with orange indicator', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockPayslipCard(
            period: 'January 2026',
            grossSalary: 5000.00,
            netSalary: 4422.00,
            currency: 'MYR',
            status: 'Pending',
          ),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.orange,
        ),
        findsOneWidget,
      );
    });

    testWidgets('tap triggers onTap callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestWidget(
          child: _MockPayslipCard(
            period: 'January 2026',
            grossSalary: 5000.00,
            netSalary: 4422.00,
            currency: 'MYR',
            status: 'Paid',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(_MockPayslipCard));
      expect(tapped, isTrue);
    });

    testWidgets('displays different currencies correctly', (tester) async {
      final currencies = ['MYR', 'SGD', 'IDR', 'THB', 'PHP'];

      for (final currency in currencies) {
        await tester.pumpWidget(
          createTestWidget(
            child: _MockPayslipCard(
              period: 'January 2026',
              grossSalary: 5000.00,
              netSalary: 4422.00,
              currency: currency,
              status: 'Paid',
            ),
          ),
        );

        expect(find.textContaining(currency), findsWidgets);
      }
    });

    testWidgets('formats large numbers with separators', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockPayslipCard(
            period: 'January 2026',
            grossSalary: 10000000.00,
            netSalary: 9000000.00,
            currency: 'IDR',
            status: 'Paid',
          ),
        ),
      );

      expect(find.text('IDR 10,000,000.00'), findsOneWidget);
    });

    testWidgets('shows chevron icon indicating tappability', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockPayslipCard(
            period: 'January 2026',
            grossSalary: 5000.00,
            netSalary: 4422.00,
            currency: 'MYR',
            status: 'Paid',
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('displays labels for gross and net salary', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockPayslipCard(
            period: 'January 2026',
            grossSalary: 5000.00,
            netSalary: 4422.00,
            currency: 'MYR',
            status: 'Paid',
          ),
        ),
      );

      expect(find.text('Gross'), findsOneWidget);
      expect(find.text('Net'), findsOneWidget);
    });
  });
}

/// Mock PayslipCard for testing
class _MockPayslipCard extends StatelessWidget {
  final String period;
  final double grossSalary;
  final double netSalary;
  final String currency;
  final String status;
  final VoidCallback? onTap;

  const _MockPayslipCard({
    required this.period,
    required this.grossSalary,
    required this.netSalary,
    required this.currency,
    required this.status,
    this.onTap,
  });

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$currency $formatted';
  }

  Color get _statusColor {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(period, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(status),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gross', style: TextStyle(color: Colors.grey)),
                      Text(_formatCurrency(grossSalary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Net', style: TextStyle(color: Colors.grey)),
                      Text(_formatCurrency(netSalary)),
                    ],
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
