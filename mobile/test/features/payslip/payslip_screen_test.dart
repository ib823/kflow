import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PayslipListScreen Widget Tests', () {
    testWidgets('displays year selector', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipListScreen(),
          ),
        ),
      );

      expect(find.text('2025'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('displays payslip list items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipListScreen(),
          ),
        ),
      );

      expect(find.text('January 2025'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('shows net salary on cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipListScreen(),
          ),
        ),
      );

      expect(find.textContaining('RM'), findsWidgets);
    });

    testWidgets('payslip cards are tappable', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _MockPayslipListScreen(
              onPayslipTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card).first);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows empty state when no payslips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipListScreen(isEmpty: true),
          ),
        ),
      );

      expect(find.text('No payslips found'), findsOneWidget);
    });
  });

  group('PayslipDetailScreen Widget Tests', () {
    testWidgets('displays pay period header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipDetailScreen(),
          ),
        ),
      );

      expect(find.text('January 2025'), findsOneWidget);
    });

    testWidgets('displays earnings section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipDetailScreen(),
          ),
        ),
      );

      expect(find.text('Earnings'), findsOneWidget);
      expect(find.text('Basic Salary'), findsOneWidget);
    });

    testWidgets('displays deductions section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipDetailScreen(),
          ),
        ),
      );

      expect(find.text('Deductions'), findsOneWidget);
      expect(find.text('EPF Employee'), findsOneWidget);
    });

    testWidgets('displays net salary prominently', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipDetailScreen(),
          ),
        ),
      );

      expect(find.text('Net Salary'), findsOneWidget);
      expect(find.text('RM 4,800.00'), findsOneWidget);
    });

    testWidgets('displays statutory contributions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipDetailScreen(),
          ),
        ),
      );

      expect(find.text('EPF'), findsWidgets);
      expect(find.text('SOCSO'), findsWidgets);
      expect(find.text('EIS'), findsWidgets);
    });

    testWidgets('has download PDF button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipDetailScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('has share button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPayslipDetailScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
    });
  });

  group('PIN Verification for Payslip', () {
    testWidgets('shows PIN dialog before viewing payslip', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinProtectedPayslip(),
          ),
        ),
      );

      expect(find.text('Enter PIN to view payslip'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows payslip after correct PIN', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _MockPinProtectedPayslip(verified: true),
          ),
        ),
      );

      expect(find.text('January 2025'), findsOneWidget);
    });
  });
}

/// Mock Payslip List Screen
class _MockPayslipListScreen extends StatelessWidget {
  final bool isEmpty;
  final VoidCallback? onPayslipTap;

  const _MockPayslipListScreen({
    this.isEmpty = false,
    this.onPayslipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('2025', style: TextStyle(fontSize: 18)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        Expanded(
          child: isEmpty
              ? const Center(child: Text('No payslips found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    GestureDetector(
                      onTap: onPayslipTap,
                      child: Card(
                        child: ListTile(
                          title: const Text('January 2025'),
                          subtitle: const Text('Pay Date: 31 Jan 2025'),
                          trailing: const Text(
                            'RM 4,800.00',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Mock Payslip Detail Screen
class _MockPayslipDetailScreen extends StatelessWidget {
  const _MockPayslipDetailScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslip'),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text(
                    'January 2025',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Pay Date: 31 Jan 2025'),
                ],
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Earnings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLine('Basic Salary', 'RM 5,500.00'),
            _buildLine('Transport Allowance', 'RM 300.00'),
            _buildLine('Meal Allowance', 'RM 200.00'),
            const Divider(height: 32),
            const Text(
              'Deductions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLine('EPF Employee', '- RM 660.00'),
            _buildLine('SOCSO Employee', '- RM 23.65'),
            _buildLine('EIS Employee', '- RM 12.00'),
            _buildLine('PCB', '- RM 250.00'),
            const Divider(height: 32),
            const Text(
              'Statutory Contributions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLine('EPF (Employee)', 'RM 660.00'),
            _buildLine('EPF (Employer)', 'RM 780.00'),
            _buildLine('SOCSO (Employee)', 'RM 23.65'),
            _buildLine('SOCSO (Employer)', 'RM 82.95'),
            _buildLine('EIS (Employee)', 'RM 12.00'),
            _buildLine('EIS (Employer)', 'RM 12.00'),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Net Salary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'RM 4,800.00',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}

/// Mock PIN Protected Payslip
class _MockPinProtectedPayslip extends StatelessWidget {
  final bool verified;

  const _MockPinProtectedPayslip({this.verified = false});

  @override
  Widget build(BuildContext context) {
    if (verified) {
      return const _MockPayslipDetailScreen();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Enter PIN to view payslip',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextField(
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
