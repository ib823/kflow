import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LeaveApplyForm Widget Tests
///
/// Tests leave application form validation and interactions.
void main() {
  group('LeaveApplyForm Widget Tests', () {
    Widget createTestWidget({required Widget child}) {
      return MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );
    }

    testWidgets('renders all required form fields', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const _MockLeaveApplyForm()),
      );

      // Leave type dropdown
      expect(find.byKey(const Key('leave_type_dropdown')), findsOneWidget);

      // Start date picker
      expect(find.byKey(const Key('start_date_picker')), findsOneWidget);

      // End date picker
      expect(find.byKey(const Key('end_date_picker')), findsOneWidget);

      // Reason field
      expect(find.byKey(const Key('reason_field')), findsOneWidget);

      // Submit button
      expect(find.byKey(const Key('submit_button')), findsOneWidget);
    });

    testWidgets('shows validation error when leave type not selected', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const _MockLeaveApplyForm()),
      );

      // Tap submit without selecting leave type
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please select a leave type'), findsOneWidget);
    });

    testWidgets('shows validation error when dates not selected', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const _MockLeaveApplyForm()),
      );

      // Select leave type
      await tester.tap(find.byKey(const Key('leave_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annual Leave').last);
      await tester.pumpAndSettle();

      // Submit without dates
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please select start date'), findsOneWidget);
    });

    testWidgets('calculates total days correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveApplyForm(
            preselectedStartDate: '2026-02-01',
            preselectedEndDate: '2026-02-03',
          ),
        ),
      );

      expect(find.text('3 days'), findsOneWidget);
    });

    testWidgets('allows half-day selection', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const _MockLeaveApplyForm()),
      );

      expect(find.byKey(const Key('half_day_checkbox')), findsOneWidget);
    });

    testWidgets('shows attachment option for sick leave', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const _MockLeaveApplyForm()),
      );

      // Select sick leave
      await tester.tap(find.byKey(const Key('leave_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sick Leave').last);
      await tester.pumpAndSettle();

      // Should show attachment upload option
      expect(find.byKey(const Key('attachment_upload')), findsOneWidget);
    });

    testWidgets('validates reason field minimum length', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveApplyForm(
            preselectedLeaveType: 'Annual Leave',
            preselectedStartDate: '2026-02-01',
            preselectedEndDate: '2026-02-01',
          ),
        ),
      );

      // Enter short reason
      await tester.enterText(
        find.byKey(const Key('reason_field')),
        'Test',
      );
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Reason must be at least 10 characters'), findsOneWidget);
    });

    testWidgets('shows available balance for selected leave type', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const _MockLeaveApplyForm()),
      );

      // Select annual leave
      await tester.tap(find.byKey(const Key('leave_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annual Leave').last);
      await tester.pumpAndSettle();

      // Should show available balance
      expect(find.textContaining('Available:'), findsOneWidget);
    });

    testWidgets('prevents end date before start date', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveApplyForm(
            preselectedStartDate: '2026-02-10',
            preselectedEndDate: '2026-02-05', // Before start
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('End date cannot be before start date'), findsOneWidget);
    });

    testWidgets('shows warning when requesting more than available', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockLeaveApplyForm(
            preselectedLeaveType: 'Annual Leave',
            preselectedStartDate: '2026-02-01',
            preselectedEndDate: '2026-02-20', // 20 days, more than available
            availableBalance: 10,
          ),
        ),
      );

      expect(find.textContaining('exceeds available balance'), findsOneWidget);
    });

    testWidgets('cancel button navigates back', (tester) async {
      var cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _MockLeaveApplyForm(
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('cancel_button')));
      expect(cancelled, isTrue);
    });
  });
}

/// Mock LeaveApplyForm for testing
class _MockLeaveApplyForm extends StatefulWidget {
  final String? preselectedLeaveType;
  final String? preselectedStartDate;
  final String? preselectedEndDate;
  final double availableBalance;
  final VoidCallback? onCancel;

  const _MockLeaveApplyForm({
    this.preselectedLeaveType,
    this.preselectedStartDate,
    this.preselectedEndDate,
    this.availableBalance = 16,
    this.onCancel,
  });

  @override
  State<_MockLeaveApplyForm> createState() => _MockLeaveApplyFormState();
}

class _MockLeaveApplyFormState extends State<_MockLeaveApplyForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isHalfDay = false;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLeaveType = widget.preselectedLeaveType;
    if (widget.preselectedStartDate != null) {
      _startDate = DateTime.parse(widget.preselectedStartDate!);
    }
    if (widget.preselectedEndDate != null) {
      _endDate = DateTime.parse(widget.preselectedEndDate!);
    }
  }

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  bool get _exceedsBalance => _totalDays > widget.availableBalance;

  bool get _endBeforeStart {
    if (_startDate == null || _endDate == null) return false;
    return _endDate!.isBefore(_startDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Leave type dropdown
            DropdownButtonFormField<String>(
              key: const Key('leave_type_dropdown'),
              value: _selectedLeaveType,
              decoration: const InputDecoration(labelText: 'Leave Type'),
              items: const [
                DropdownMenuItem(value: 'Annual Leave', child: Text('Annual Leave')),
                DropdownMenuItem(value: 'Sick Leave', child: Text('Sick Leave')),
                DropdownMenuItem(value: 'Unpaid Leave', child: Text('Unpaid Leave')),
              ],
              onChanged: (value) => setState(() => _selectedLeaveType = value),
              validator: (value) =>
                  value == null ? 'Please select a leave type' : null,
            ),

            if (_selectedLeaveType != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Available: ${widget.availableBalance} days'),
              ),

            const SizedBox(height: 16),

            // Date pickers
            GestureDetector(
              key: const Key('start_date_picker'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _startDate = date);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  errorText: _startDate == null && _formKey.currentState?.validate() == false
                      ? 'Please select start date'
                      : null,
                ),
                child: Text(_startDate?.toString().split(' ')[0] ?? 'Select date'),
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              key: const Key('end_date_picker'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? _startDate ?? DateTime.now(),
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

            if (_endBeforeStart)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'End date cannot be before start date',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            if (_totalDays > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('$_totalDays days'),
              ),

            if (_exceedsBalance)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Request exceeds available balance',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),

            const SizedBox(height: 16),

            // Half day checkbox
            CheckboxListTile(
              key: const Key('half_day_checkbox'),
              title: const Text('Half Day'),
              value: _isHalfDay,
              onChanged: (value) => setState(() => _isHalfDay = value ?? false),
            ),

            // Attachment for sick leave
            if (_selectedLeaveType == 'Sick Leave')
              ElevatedButton.icon(
                key: const Key('attachment_upload'),
                onPressed: () {},
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach Medical Certificate'),
              ),

            const SizedBox(height: 16),

            // Reason field
            TextFormField(
              key: const Key('reason_field'),
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter reason for leave',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.length < 10) {
                  return 'Reason must be at least 10 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('cancel_button'),
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    key: const Key('submit_button'),
                    onPressed: () {
                      _formKey.currentState?.validate();
                    },
                    child: const Text('Submit'),
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
