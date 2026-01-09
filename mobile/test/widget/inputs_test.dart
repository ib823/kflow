import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/core/widgets/kf_input.dart';
import '../helpers/test_app.dart';

void main() {
  group('KFTextField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextField(label: 'Employee ID'),
      );

      expect(find.text('Employee ID'), findsOneWidget);
    });

    testWidgets('shows hint text', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextField(hint: 'Enter your ID'),
      );

      expect(find.text('Enter your ID'), findsOneWidget);
    });

    testWidgets('shows error text', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextField(
          label: 'Email',
          error: 'Invalid email format',
        ),
      );

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('shows helper text', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextField(
          label: 'Password',
          helper: 'At least 8 characters',
        ),
      );

      expect(find.text('At least 8 characters'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? value;

      await tester.pumpTestableWidget(
        KFTextField(
          label: 'Name',
          onChanged: (v) => value = v,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'John');
      expect(value, 'John');
    });

    testWidgets('shows prefix icon', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextField(
          label: 'Email',
          prefixIcon: Icons.email,
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextField(
          label: 'Disabled',
          enabled: false,
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });

    testWidgets('is read only when readOnly is true', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextField(
          label: 'Read Only',
          readOnly: true,
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.readOnly, isTrue);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextField(
          label: 'Password',
          obscureText: true,
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.obscureText, isTrue);
    });
  });

  group('KFPasswordField', () {
    testWidgets('renders with password label', (tester) async {
      await tester.pumpTestableWidget(
        const KFPasswordField(),
      );

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('obscures text by default', (tester) async {
      await tester.pumpTestableWidget(
        const KFPasswordField(),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.obscureText, isTrue);
    });

    testWidgets('toggles visibility when icon pressed', (tester) async {
      await tester.pumpTestableWidget(
        const KFPasswordField(),
      );

      // Initially obscured
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows lock icon', (tester) async {
      await tester.pumpTestableWidget(
        const KFPasswordField(),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows error text', (tester) async {
      await tester.pumpTestableWidget(
        const KFPasswordField(
          error: 'Password is required',
        ),
      );

      expect(find.text('Password is required'), findsOneWidget);
    });
  });

  group('KFSearchField', () {
    testWidgets('renders with search icon', (tester) async {
      await tester.pumpTestableWidget(
        const KFSearchField(),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows hint text', (tester) async {
      await tester.pumpTestableWidget(
        const KFSearchField(hint: 'Search employees...'),
      );

      expect(find.text('Search employees...'), findsOneWidget);
    });

    testWidgets('shows clear button when text entered', (tester) async {
      await tester.pumpTestableWidget(
        const KFSearchField(),
      );

      // No clear button initially
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Clear button appears
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears text when clear button pressed', (tester) async {
      final controller = TextEditingController(text: 'initial');

      await tester.pumpTestableWidget(
        KFSearchField(controller: controller),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(controller.text, isEmpty);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? value;

      await tester.pumpTestableWidget(
        KFSearchField(onChanged: (v) => value = v),
      );

      await tester.enterText(find.byType(TextField), 'search');
      expect(value, 'search');
    });

    testWidgets('calls onClear when cleared', (tester) async {
      bool cleared = false;
      final controller = TextEditingController(text: 'test');

      await tester.pumpTestableWidget(
        KFSearchField(
          controller: controller,
          onClear: () => cleared = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(cleared, isTrue);
    });
  });

  group('KFDropdown', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpTestableWidget(
        KFDropdown<String>(
          label: 'Leave Type',
          items: const [
            DropdownMenuItem(value: 'annual', child: Text('Annual')),
            DropdownMenuItem(value: 'medical', child: Text('Medical')),
          ],
          onChanged: (_) {},
        ),
      );

      expect(find.text('Leave Type'), findsOneWidget);
    });

    testWidgets('shows selected value', (tester) async {
      await tester.pumpTestableWidget(
        KFDropdown<String>(
          value: 'annual',
          items: const [
            DropdownMenuItem(value: 'annual', child: Text('Annual')),
            DropdownMenuItem(value: 'medical', child: Text('Medical')),
          ],
          onChanged: (_) {},
        ),
      );

      expect(find.text('Annual'), findsOneWidget);
    });

    testWidgets('calls onChanged when selection changes', (tester) async {
      String? selected;

      await tester.pumpTestableWidget(
        KFDropdown<String>(
          items: const [
            DropdownMenuItem(value: 'annual', child: Text('Annual')),
            DropdownMenuItem(value: 'medical', child: Text('Medical')),
          ],
          onChanged: (v) => selected = v,
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select an item
      await tester.tap(find.text('Medical').last);
      await tester.pumpAndSettle();

      expect(selected, 'medical');
    });
  });

  group('KFDatePicker', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpTestableWidget(
        const KFDatePicker(label: 'Start Date'),
      );

      expect(find.text('Start Date'), findsOneWidget);
    });

    testWidgets('shows calendar icon', (tester) async {
      await tester.pumpTestableWidget(
        const KFDatePicker(label: 'Start Date'),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('shows selected date', (tester) async {
      await tester.pumpTestableWidget(
        KFDatePicker(
          label: 'Start Date',
          value: DateTime(2026, 1, 15),
        ),
      );

      expect(find.text('15/1/2026'), findsOneWidget);
    });

    testWidgets('shows hint when no value', (tester) async {
      await tester.pumpTestableWidget(
        const KFDatePicker(
          label: 'Start Date',
          hint: 'Select start date',
        ),
      );

      expect(find.text('Select start date'), findsOneWidget);
    });
  });

  group('KFTextArea', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextArea(label: 'Reason'),
      );

      expect(find.text('Reason'), findsOneWidget);
    });

    testWidgets('accepts multiline input', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextArea(
          label: 'Description',
          minLines: 3,
          maxLines: 5,
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.minLines, 3);
      expect(field.maxLines, 5);
    });

    testWidgets('respects maxLength', (tester) async {
      await tester.pumpTestableWidget(
        const KFTextArea(
          label: 'Reason',
          maxLength: 200,
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.maxLength, 200);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? value;

      await tester.pumpTestableWidget(
        KFTextArea(
          label: 'Reason',
          onChanged: (v) => value = v,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Family vacation');
      expect(value, 'Family vacation');
    });
  });
}
