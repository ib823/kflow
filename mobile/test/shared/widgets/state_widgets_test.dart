import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/shared/widgets/empty_state.dart';
import 'package:kerjaflow/shared/widgets/loading_state.dart';

void main() {
  group('LoadingState', () {
    testWidgets('displays circular progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(message: 'Loading data...'),
          ),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('has accessible label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(message: 'Please wait'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(LoadingState));
      expect(semantics.label, 'Please wait');
    });

    testWidgets('uses compact layout when specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(compact: true),
          ),
        ),
      );

      expect(find.byType(LoadingState), findsOneWidget);
    });
  });

  group('ErrorState', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(message: 'Something went wrong'),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(message: 'Error'),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays retry button when callback provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button pressed', (tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Error',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('uses custom icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Network error',
              icon: Icons.wifi_off,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('has accessible error label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(message: 'Connection failed'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ErrorState));
      expect(semantics.label, 'Error: Connection failed');
    });
  });

  group('EmptyState', () {
    testWidgets('displays icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No items',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Nothing here',
            ),
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('displays description when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No messages',
              description: 'Your inbox is empty',
            ),
          ),
        ),
      );

      expect(find.text('Your inbox is empty'), findsOneWidget);
    });

    testWidgets('displays action button when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'No items',
              actionText: 'Add Item',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('calls onAction when action button pressed', (tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'No items',
              actionText: 'Add Item',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add Item'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('has accessible label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No messages',
              description: 'Check back later',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(EmptyState));
      expect(semantics.label, 'No messages. Check back later');
    });
  });

  group('EmptyStates Presets', () {
    testWidgets('notifications preset displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStates.notifications(),
          ),
        ),
      );

      expect(find.text('No notifications'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    });

    testWidgets('leaveRequests preset displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStates.leaveRequests(),
          ),
        ),
      );

      expect(find.text('No leave requests'), findsOneWidget);
    });

    testWidgets('payslips preset displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStates.payslips(),
          ),
        ),
      );

      expect(find.text('No payslips available'), findsOneWidget);
    });

    testWidgets('networkError preset displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStates.networkError(),
          ),
        ),
      );

      expect(find.text('Connection error'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
    });

    testWidgets('searchResults preset with query', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStates.searchResults(query: 'test'),
          ),
        ),
      );

      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('No results for "test"'), findsOneWidget);
    });

    testWidgets('error preset with custom message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStates.error(message: 'Custom error message'),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Custom error message'), findsOneWidget);
    });
  });

  group('SkeletonCard', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('respects custom height and width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(height: 100, width: 200),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SkeletonCard),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxHeight, 100);
    });

    testWidgets('excludes semantics for screen readers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      expect(find.byType(ExcludeSemantics), findsOneWidget);
    });
  });

  group('SkeletonListItem', () {
    testWidgets('renders with leading by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonListItem(),
          ),
        ),
      );

      expect(find.byType(SkeletonListItem), findsOneWidget);
    });

    testWidgets('can hide leading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonListItem(hasLeading: false),
          ),
        ),
      );

      expect(find.byType(SkeletonListItem), findsOneWidget);
    });

    testWidgets('can show trailing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonListItem(hasTrailing: true),
          ),
        ),
      );

      expect(find.byType(SkeletonListItem), findsOneWidget);
    });
  });

  group('SkeletonListView', () {
    testWidgets('renders default 5 items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonListView(),
          ),
        ),
      );

      expect(find.byType(SkeletonListItem), findsNWidgets(5));
    });

    testWidgets('renders custom item count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonListView(itemCount: 3),
          ),
        ),
      );

      expect(find.byType(SkeletonListItem), findsNWidgets(3));
    });

    testWidgets('has accessible loading label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonListView(),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(SkeletonListView));
      expect(semantics.label, 'Loading content');
    });
  });
}
