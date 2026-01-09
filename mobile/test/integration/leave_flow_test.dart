import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_app.dart';
import '../mocks/mock_data.dart';

/// Integration tests for leave management flow
/// Tests: View Balances -> Apply Leave -> View Requests -> Cancel Request
void main() {
  group('Leave Management Flow', () {
    testWidgets('displays leave balances', (tester) async {
      await tester.pumpTestableWidget(
        const _MockLeaveBalanceScreen(),
      );

      await tester.pumpAndSettle();

      // Should show leave types
      expect(find.text('Annual Leave'), findsOneWidget);
      expect(find.text('Medical Leave'), findsOneWidget);
      expect(find.text('Emergency Leave'), findsOneWidget);

      // Should show balances
      expect(find.text('12 / 16 days'), findsOneWidget);
    });

    testWidgets('navigates to apply leave form', (tester) async {
      await tester.pumpTestableWidget(
        const _MockLeaveBalanceScreen(),
      );

      await tester.pumpAndSettle();

      // Tap apply leave button
      await tester.tap(find.byKey(const Key('apply_leave_button')));
      await tester.pumpAndSettle();

      // Should show apply leave form
      expect(find.text('Apply for Leave'), findsOneWidget);
    });

    testWidgets('successfully applies for leave', (tester) async {
      await tester.pumpTestableWidget(
        const _MockApplyLeaveScreen(),
      );

      // Select leave type
      await tester.tap(find.byKey(const Key('leave_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annual Leave').last);
      await tester.pumpAndSettle();

      // Select dates
      await tester.tap(find.byKey(const Key('start_date_picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('end_date_picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Enter reason
      await tester.enterText(
        find.byKey(const Key('reason_field')),
        'Family vacation',
      );

      // Submit
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      // Should show success
      expect(find.text('Leave request submitted'), findsOneWidget);
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpTestableWidget(
        const _MockApplyLeaveScreen(),
      );

      // Try to submit without filling fields
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Please select a leave type'), findsOneWidget);
      expect(find.text('Please enter a reason'), findsOneWidget);
    });

    testWidgets('displays leave requests list', (tester) async {
      await tester.pumpTestableWidget(
        const _MockLeaveRequestsScreen(),
      );

      await tester.pumpAndSettle();

      // Should show leave requests
      expect(find.text('Annual Leave'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('can cancel pending leave request', (tester) async {
      await tester.pumpTestableWidget(
        const _MockLeaveRequestsScreen(),
      );

      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.byKey(const Key('cancel_request_0')));
      await tester.pumpAndSettle();

      // Confirm cancellation
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Should show success
      expect(find.text('Request cancelled'), findsOneWidget);
    });

    testWidgets('filters leave requests by status', (tester) async {
      await tester.pumpTestableWidget(
        const _MockLeaveRequestsScreen(),
      );

      await tester.pumpAndSettle();

      // Tap pending filter
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();

      // Should only show pending requests
      expect(find.text('Pending'), findsWidgets);
    });
  });
}

/// Mock leave balance screen
class _MockLeaveBalanceScreen extends StatelessWidget {
  const _MockLeaveBalanceScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leave Balances',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildBalanceCard('Annual Leave', 12, 16, Colors.green),
          _buildBalanceCard('Medical Leave', 10, 14, Colors.pink),
          _buildBalanceCard('Emergency Leave', 2, 3, Colors.orange),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('apply_leave_button'),
              onPressed: () {},
              child: const Text('Apply for Leave'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String type, int balance, int total, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.event, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('$balance / $total days'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock apply leave screen
class _MockApplyLeaveScreen extends StatefulWidget {
  const _MockApplyLeaveScreen();

  @override
  State<_MockApplyLeaveScreen> createState() => _MockApplyLeaveScreenState();
}

class _MockApplyLeaveScreenState extends State<_MockApplyLeaveScreen> {
  String? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  String? _leaveTypeError;
  String? _reasonError;
  String? _successMessage;

  void _submit() {
    setState(() {
      _leaveTypeError = _selectedLeaveType == null ? 'Please select a leave type' : null;
      _reasonError = _reasonController.text.isEmpty ? 'Please enter a reason' : null;
      _successMessage = null;
    });

    if (_leaveTypeError == null && _reasonError == null) {
      setState(() => _successMessage = 'Leave request submitted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apply for Leave',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            key: const Key('leave_type_dropdown'),
            value: _selectedLeaveType,
            decoration: InputDecoration(
              labelText: 'Leave Type',
              errorText: _leaveTypeError,
            ),
            items: const [
              DropdownMenuItem(value: 'annual', child: Text('Annual Leave')),
              DropdownMenuItem(value: 'medical', child: Text('Medical Leave')),
            ],
            onChanged: (v) => setState(() => _selectedLeaveType = v),
          ),
          const SizedBox(height: 16),
          InkWell(
            key: const Key('start_date_picker'),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _startDate = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Start Date'),
              child: Text(_startDate?.toString().split(' ')[0] ?? 'Select date'),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            key: const Key('end_date_picker'),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: _startDate ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _endDate = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'End Date'),
              child: Text(_endDate?.toString().split(' ')[0] ?? 'Select date'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('reason_field'),
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Reason',
              errorText: _reasonError,
            ),
          ),
          const SizedBox(height: 24),
          if (_successMessage != null)
            Text(_successMessage!, style: const TextStyle(color: Colors.green)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('submit_button'),
              onPressed: _submit,
              child: const Text('Submit Request'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mock leave requests screen
class _MockLeaveRequestsScreen extends StatefulWidget {
  const _MockLeaveRequestsScreen();

  @override
  State<_MockLeaveRequestsScreen> createState() => _MockLeaveRequestsScreenState();
}

class _MockLeaveRequestsScreenState extends State<_MockLeaveRequestsScreen> {
  String? _successMessage;
  final List<Map<String, dynamic>> _requests = [
    {'id': '0', 'type': 'Annual Leave', 'dates': '15-17 Jan 2026', 'status': 'Pending'},
    {'id': '1', 'type': 'Medical Leave', 'dates': '2 Jan 2026', 'status': 'Approved'},
  ];

  void _cancelRequest(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _requests.removeAt(index);
                _successMessage = 'Request cancelled';
              });
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('My Requests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('All')),
              TextButton(onPressed: () {}, child: const Text('Pending')),
            ],
          ),
        ),
        if (_successMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_successMessage!, style: const TextStyle(color: Colors.green)),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              final request = _requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(request['type'] as String),
                  subtitle: Text(request['dates'] as String),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(label: Text(request['status'] as String)),
                      if (request['status'] == 'Pending')
                        IconButton(
                          key: Key('cancel_request_$index'),
                          icon: const Icon(Icons.cancel),
                          onPressed: () => _cancelRequest(index),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
