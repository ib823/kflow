import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/core/widgets/kf_button.dart';
import '../helpers/test_app.dart';

void main() {
  group('KFPrimaryButton', () {
    testWidgets('renders label correctly', (tester) async {
      await tester.pumpTestableWidget(
        const KFPrimaryButton(label: 'Submit'),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpTestableWidget(
        KFPrimaryButton(
          label: 'Submit',
          onPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpTestableWidget(
        const KFPrimaryButton(label: 'Submit'),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpTestableWidget(
        const KFPrimaryButton(
          label: 'Submit',
          isLoading: true,
          onPressed: null,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('shows leading icon when provided', (tester) async {
      await tester.pumpTestableWidget(
        KFPrimaryButton(
          label: 'Add',
          leadingIcon: Icons.add,
          onPressed: () {},
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows trailing icon when provided', (tester) async {
      await tester.pumpTestableWidget(
        KFPrimaryButton(
          label: 'Next',
          trailingIcon: Icons.arrow_forward,
          onPressed: () {},
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('respects size parameter', (tester) async {
      await tester.pumpTestableWidget(
        KFPrimaryButton(
          label: 'Small',
          size: ButtonSize.small,
          onPressed: () {},
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 36);
    });

    testWidgets('respects isFullWidth parameter', (tester) async {
      await tester.pumpTestableWidget(
        KFPrimaryButton(
          label: 'Not Full',
          isFullWidth: false,
          onPressed: () {},
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, isNull);
    });
  });

  group('KFSecondaryButton', () {
    testWidgets('renders as outlined button', (tester) async {
      await tester.pumpTestableWidget(
        KFSecondaryButton(
          label: 'Cancel',
          onPressed: () {},
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpTestableWidget(
        const KFSecondaryButton(
          label: 'Cancel',
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpTestableWidget(
        KFSecondaryButton(
          label: 'Cancel',
          onPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });

  group('KFTextButton', () {
    testWidgets('renders as text button', (tester) async {
      await tester.pumpTestableWidget(
        KFTextButton(
          label: 'Learn More',
          onPressed: () {},
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Learn More'), findsOneWidget);
    });

    testWidgets('shows leading icon', (tester) async {
      await tester.pumpTestableWidget(
        KFTextButton(
          label: 'Help',
          leadingIcon: Icons.help_outline,
          onPressed: () {},
        ),
      );

      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });
  });

  group('KFDangerButton', () {
    testWidgets('renders filled danger button by default', (tester) async {
      await tester.pumpTestableWidget(
        KFDangerButton(
          label: 'Delete',
          onPressed: () {},
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('renders outlined when isOutlined is true', (tester) async {
      await tester.pumpTestableWidget(
        KFDangerButton(
          label: 'Cancel',
          isOutlined: true,
          onPressed: () {},
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpTestableWidget(
        const KFDangerButton(
          label: 'Delete',
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('KFIconButton', () {
    testWidgets('renders icon', (tester) async {
      await tester.pumpTestableWidget(
        KFIconButton(
          icon: Icons.settings,
          onPressed: () {},
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('shows tooltip when provided', (tester) async {
      await tester.pumpTestableWidget(
        KFIconButton(
          icon: Icons.settings,
          tooltip: 'Settings',
          onPressed: () {},
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpTestableWidget(
        KFIconButton(
          icon: Icons.add,
          onPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });

  group('KFFAB', () {
    testWidgets('renders floating action button', (tester) async {
      await tester.pumpTestableWidget(
        KFFAB(
          icon: Icons.add,
          onPressed: () {},
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders extended FAB with label', (tester) async {
      await tester.pumpTestableWidget(
        KFFAB(
          icon: Icons.add,
          label: 'Add Item',
          extended: true,
          onPressed: () {},
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('renders mini FAB', (tester) async {
      await tester.pumpTestableWidget(
        KFFAB(
          icon: Icons.edit,
          mini: true,
          onPressed: () {},
        ),
      );

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.mini, isTrue);
    });
  });

  group('KFSuccessButton', () {
    testWidgets('renders with success styling', (tester) async {
      await tester.pumpTestableWidget(
        KFSuccessButton(
          label: 'Confirm',
          onPressed: () {},
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('shows leading icon', (tester) async {
      await tester.pumpTestableWidget(
        KFSuccessButton(
          label: 'Approve',
          leadingIcon: Icons.check,
          onPressed: () {},
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpTestableWidget(
        const KFSuccessButton(
          label: 'Saving',
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
