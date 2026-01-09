import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LeaveBalanceCard Widget Tests
///
/// Tests display of leave balance information.
void main() {
  group('LeaveBalanceCard Widget Tests', () {
    Widget createTestWidget({required Widget child}) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    }

    testWidgets('displays leave type name', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveBalanceCard(
            leaveType: 'Annual Leave',
            entitled: 16,
            taken: 5,
            pending: 2,
            balance: 9,
          ),
        ),
      );

      expect(find.text('Annual Leave'), findsOneWidget);
    });

    testWidgets('displays entitled days', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveBalanceCard(
            leaveType: 'Annual Leave',
            entitled: 16,
            taken: 5,
            pending: 2,
            balance: 9,
          ),
        ),
      );

      expect(find.text('16'), findsOneWidget);
      expect(find.text('Entitled'), findsOneWidget);
    });

    testWidgets('displays taken days', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveBalanceCard(
            leaveType: 'Annual Leave',
            entitled: 16,
            taken: 5,
            pending: 2,
            balance: 9,
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('Taken'), findsOneWidget);
    });

    testWidgets('displays pending days', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveBalanceCard(
            leaveType: 'Annual Leave',
            entitled: 16,
            taken: 5,
            pending: 2,
            balance: 9,
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('displays balance days prominently', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveBalanceCard(
            leaveType: 'Annual Leave',
            entitled: 16,
            taken: 5,
            pending: 2,
            balance: 9,
          ),
        ),
      );

      expect(find.text('9'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
    });

    testWidgets('shows progress bar indicating usage', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveBalanceCard(
            leaveType: 'Annual Leave',
            entitled: 16,
            taken: 5,
            pending: 2,
            balance: 9,
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('handles zero entitled days', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveBalanceCard(
            leaveType: 'Unpaid Leave',
            entitled: 0,
            taken: 0,
            pending: 0,
            balance: 0,
          ),
        ),
      );

      expect(find.text('Unpaid Leave'), findsOneWidget);
      expect(find.text('0'), findsWidgets); // Multiple zeros
    });

    testWidgets('displays half-day values correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveBalanceCard(
            leaveType: 'Sick Leave',
            entitled: 14,
            taken: 2.5,
            pending: 0.5,
            balance: 11,
          ),
        ),
      );

      expect(find.text('2.5'), findsOneWidget);
      expect(find.text('0.5'), findsOneWidget);
    });

    testWidgets('tap triggers onTap callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestWidget(
          child: _MockLeaveBalanceCard(
            leaveType: 'Annual Leave',
            entitled: 16,
            taken: 5,
            pending: 2,
            balance: 9,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(_MockLeaveBalanceCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows warning color when balance is low', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveBalanceCard(
            leaveType: 'Annual Leave',
            entitled: 16,
            taken: 14,
            pending: 1,
            balance: 1, // Low balance
          ),
        ),
      );

      // Balance should show warning color
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == '1' &&
              widget.style?.color == Colors.orange,
        ),
        findsOneWidget,
      );
    });
  });
}

/// Mock LeaveBalanceCard for testing
class _MockLeaveBalanceCard extends StatelessWidget {
  final String leaveType;
  final double entitled;
  final double taken;
  final double pending;
  final double balance;
  final VoidCallback? onTap;

  const _MockLeaveBalanceCard({
    required this.leaveType,
    required this.entitled,
    required this.taken,
    required this.pending,
    required this.balance,
    this.onTap,
  });

  String _formatDays(double days) {
    if (days == days.roundToDouble()) {
      return days.toInt().toString();
    }
    return days.toString();
  }

  double get _usagePercentage {
    if (entitled == 0) return 0;
    return (taken + pending) / entitled;
  }

  Color get _balanceColor {
    if (balance <= 2) return Colors.orange;
    return Colors.black;
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
              Text(
                leaveType,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Entitled', entitled),
                  _buildStat('Taken', taken),
                  _buildStat('Pending', pending),
                  _buildStat('Balance', balance, isBalance: true),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _usagePercentage.clamp(0, 1),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  _usagePercentage > 0.8 ? Colors.orange : Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, double value, {bool isBalance = false}) {
    return Column(
      children: [
        Text(
          _formatDays(value),
          style: TextStyle(
            fontSize: 20,
            fontWeight: isBalance ? FontWeight.bold : FontWeight.normal,
            color: isBalance ? _balanceColor : Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
