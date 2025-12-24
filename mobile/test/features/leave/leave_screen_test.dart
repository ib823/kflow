import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LeaveBalanceScreen Widget Tests', () {
    testWidgets('displays leave balance cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveBalanceScreen(),
          ),
        ),
      );

      expect(find.text('Annual Leave'), findsOneWidget);
      expect(find.text('Medical Leave'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
    });

    testWidgets('displays available and entitled days', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveBalanceScreen(),
          ),
        ),
      );

      expect(find.text('Available: 9'), findsOneWidget);
      expect(find.text('Entitled: 14'), findsOneWidget);
    });

    testWidgets('shows apply button on balance card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveBalanceScreen(),
          ),
        ),
      );

      expect(find.text('Apply'), findsNWidgets(2));
    });
  });

  group('LeaveApplyScreen Widget Tests', () {
    testWidgets('displays leave type dropdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveApplyScreen(),
          ),
        ),
      );

      expect(find.text('Leave Type'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('displays date picker fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveApplyScreen(),
          ),
        ),
      );

      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
    });

    testWidgets('displays reason text field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveApplyScreen(),
          ),
        ),
      );

      expect(find.text('Reason'), findsOneWidget);
    });

    testWidgets('displays submit button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveApplyScreen(),
          ),
        ),
      );

      expect(find.text('Submit Request'), findsOneWidget);
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveApplyScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Submit Request'));
      await tester.pump();

      expect(find.text('Please select a leave type'), findsOneWidget);
    });

    testWidgets('shows half-day option', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveApplyScreen(),
          ),
        ),
      );

      expect(find.text('Half Day'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });

  group('LeaveHistoryScreen Widget Tests', () {
    testWidgets('displays status tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveHistoryScreen(),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
    });

    testWidgets('displays leave request cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveHistoryScreen(),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('shows status badge on cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveHistoryScreen(),
          ),
        ),
      );

      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('displays date range on cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLeaveHistoryScreen(),
          ),
        ),
      );

      expect(find.textContaining('Jan'), findsWidgets);
    });
  });
}

/// Mock Leave Balance Screen
class _MockLeaveBalanceScreen extends StatelessWidget {
  const _MockLeaveBalanceScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LeaveBalanceCard(
          name: 'Annual Leave',
          available: 9,
          entitled: 14,
          color: Colors.green,
        ),
        _LeaveBalanceCard(
          name: 'Medical Leave',
          available: 14,
          entitled: 14,
          color: Colors.red,
        ),
      ],
    );
  }
}

class _LeaveBalanceCard extends StatelessWidget {
  final String name;
  final int available;
  final int entitled;
  final Color color;

  const _LeaveBalanceCard({
    required this.name,
    required this.available,
    required this.entitled,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available: $available'),
                Text('Entitled: $entitled'),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock Leave Apply Screen
class _MockLeaveApplyScreen extends StatefulWidget {
  const _MockLeaveApplyScreen();

  @override
  State<_MockLeaveApplyScreen> createState() => _MockLeaveApplyScreenState();
}

class _MockLeaveApplyScreenState extends State<_MockLeaveApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLeaveType;
  bool _isHalfDay = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Leave Type'),
            DropdownButtonFormField<String>(
              value: _selectedLeaveType,
              items: const [
                DropdownMenuItem(value: 'AL', child: Text('Annual Leave')),
                DropdownMenuItem(value: 'MC', child: Text('Medical Leave')),
              ],
              onChanged: (value) => setState(() => _selectedLeaveType = value),
              validator: (value) => value == null ? 'Please select a leave type' : null,
            ),
            const SizedBox(height: 16),
            const Text('Start Date'),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            const Text('End Date'),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isHalfDay,
                  onChanged: (value) => setState(() => _isHalfDay = value ?? false),
                ),
                const Text('Half Day'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Reason'),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter reason for leave',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _formKey.currentState?.validate(),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Submit Request'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock Leave History Screen
class _MockLeaveHistoryScreen extends StatelessWidget {
  const _MockLeaveHistoryScreen();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRequestList(),
                _buildRequestList(),
                _buildRequestList(),
                _buildRequestList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Annual Leave'),
            subtitle: const Text('15 Jan - 17 Jan 2025'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PENDING',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
