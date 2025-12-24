import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/shared/widgets/accessible_tap.dart';

void main() {
  group('AccessibleTap', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTap(
              onTap: () {},
              semanticLabel: 'Test button',
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      expect(find.text('Tap me'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTap(
              onTap: () => tapped = true,
              semanticLabel: 'Test button',
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('has correct semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTap(
              onTap: () {},
              semanticLabel: 'Submit form',
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AccessibleTap));
      expect(semantics.label, 'Submit form');
    });

    testWidgets('has minimum touch target size of 48x48', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTap(
              onTap: () {},
              semanticLabel: 'Small button',
              child: const SizedBox(width: 20, height: 20),
            ),
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byType(ConstrainedBox));
      expect(box.constraints.minWidth, 48);
      expect(box.constraints.minHeight, 48);
    });

    testWidgets('shows tooltip when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTap(
              onTap: () {},
              semanticLabel: 'Info button',
              tooltip: 'More information',
              child: const Icon(Icons.info),
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('respects custom border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTap(
              onTap: () {},
              semanticLabel: 'Rounded button',
              borderRadius: BorderRadius.circular(16),
              child: const Text('Rounded'),
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('is disabled when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTap(
              onTap: null,
              semanticLabel: 'Disabled button',
              child: Text('Disabled'),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AccessibleTap));
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
    });
  });

  group('AccessibleIconButton', () {
    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.add,
              onPressed: () {},
              semanticLabel: 'Add item',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('has tooltip from semanticLabel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.settings,
              onPressed: () {},
              semanticLabel: 'Settings',
            ),
          ),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Settings');
    });

    testWidgets('uses custom tooltip when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.settings,
              onPressed: () {},
              semanticLabel: 'Settings button',
              tooltip: 'Open settings',
            ),
          ),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Open settings');
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.check,
              onPressed: () => pressed = true,
              semanticLabel: 'Confirm',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('respects custom color and size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.star,
              onPressed: () {},
              semanticLabel: 'Star',
              color: Colors.amber,
              size: 32,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.amber);
      expect(icon.size, 32);
    });
  });

  group('AccessibleCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCard(
              onTap: () {},
              semanticLabel: 'Card content',
              child: const Text('Card text'),
            ),
          ),
        ),
      );

      expect(find.text('Card text'), findsOneWidget);
    });

    testWidgets('is tappable', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCard(
              onTap: () => tapped = true,
              semanticLabel: 'Tappable card',
              child: const Text('Tap this card'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('has semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCard(
              onTap: () {},
              semanticLabel: 'Profile card',
              child: const Text('John Doe'),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AccessibleCard));
      expect(semantics.label, 'Profile card');
    });

    testWidgets('applies padding when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCard(
              onTap: () {},
              semanticLabel: 'Padded card',
              padding: const EdgeInsets.all(16),
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('respects custom elevation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCard(
              onTap: () {},
              semanticLabel: 'Elevated card',
              elevation: 4.0,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 4.0);
    });
  });
}
