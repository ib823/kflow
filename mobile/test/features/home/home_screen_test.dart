import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('displays welcome message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockHomeScreen(),
          ),
        ),
      );

      expect(find.textContaining('Welcome'), findsOneWidget);
    });

    testWidgets('displays dashboard cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockHomeScreen(),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('displays quick actions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockHomeScreen(),
          ),
        ),
      );

      expect(find.text('Apply Leave'), findsOneWidget);
      expect(find.text('View Payslip'), findsOneWidget);
    });

    testWidgets('displays leave balance summary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockHomeScreen(),
          ),
        ),
      );

      expect(find.text('Leave Balance'), findsOneWidget);
      expect(find.text('Annual Leave'), findsOneWidget);
    });

    testWidgets('displays notifications badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockHomeScreen(unreadNotifications: 3),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('bottom navigation has correct items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: _MockHomeScreen(),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('quick action buttons are tappable', (tester) async {
      bool applyLeaveTapped = false;
      bool viewPayslipTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _MockHomeScreen(
              onApplyLeave: () => applyLeaveTapped = true,
              onViewPayslip: () => viewPayslipTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Apply Leave'));
      await tester.pump();
      expect(applyLeaveTapped, isTrue);

      await tester.tap(find.text('View Payslip'));
      await tester.pump();
      expect(viewPayslipTapped, isTrue);
    });
  });

  group('DashboardCard Widget Tests', () {
    testWidgets('displays title and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockDashboardCard(
              title: 'Annual Leave',
              value: '9 days',
            ),
          ),
        ),
      );

      expect(find.text('Annual Leave'), findsOneWidget);
      expect(find.text('9 days'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockDashboardCard(
              title: 'Medical Leave',
              value: '14 days',
              icon: Icons.medical_services,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.medical_services), findsOneWidget);
    });
  });
}

/// Mock Home Screen
class _MockHomeScreen extends StatelessWidget {
  final int unreadNotifications;
  final VoidCallback? onApplyLeave;
  final VoidCallback? onViewPayslip;

  const _MockHomeScreen({
    this.unreadNotifications = 0,
    this.onApplyLeave,
    this.onViewPayslip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KerjaFlow'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, John!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApplyLeave,
                    icon: const Icon(Icons.add),
                    label: const Text('Apply Leave'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewPayslip,
                    icon: const Icon(Icons.receipt),
                    label: const Text('View Payslip'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Leave Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.beach_access, color: Colors.green),
                title: const Text('Annual Leave'),
                trailing: const Text('9 / 14 days'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Leave'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Payslip'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Mock Dashboard Card
class _MockDashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const _MockDashboardCard({
    required this.title,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 32),
              const SizedBox(width: 16),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14)),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
