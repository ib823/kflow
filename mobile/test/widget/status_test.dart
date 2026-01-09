import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/core/widgets/kf_status.dart';
import '../helpers/test_app.dart';

void main() {
  group('KFStatusChip', () {
    testWidgets('renders approved status', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatusChip(
          label: 'Approved',
          type: StatusType.approved,
        ),
      );

      expect(find.text('Approved'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders pending status', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatusChip(
          label: 'Pending',
          type: StatusType.pending,
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('renders rejected status', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatusChip(
          label: 'Rejected',
          type: StatusType.rejected,
        ),
      );

      expect(find.text('Rejected'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('renders cancelled status', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatusChip(
          label: 'Cancelled',
          type: StatusType.cancelled,
        ),
      );

      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('renders processing status', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatusChip(
          label: 'Processing',
          type: StatusType.processing,
        ),
      );

      expect(find.text('Processing'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('renders draft status', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatusChip(
          label: 'Draft',
          type: StatusType.draft,
        ),
      );

      expect(find.text('Draft'), findsOneWidget);
      expect(find.byIcon(Icons.edit_note), findsOneWidget);
    });

    testWidgets('hides icon when showIcon is false', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatusChip(
          label: 'Approved',
          type: StatusType.approved,
          showIcon: false,
        ),
      );

      expect(find.text('Approved'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });
  });

  group('KFBadge', () {
    testWidgets('shows count on child', (tester) async {
      await tester.pumpTestableWidget(
        const KFBadge(
          count: 5,
          child: Icon(Icons.notifications),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('hides badge when count is 0', (tester) async {
      await tester.pumpTestableWidget(
        const KFBadge(
          count: 0,
          child: Icon(Icons.notifications),
        ),
      );

      expect(find.text('0'), findsNothing);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('shows badge when count is 0 and showZero is true', (tester) async {
      await tester.pumpTestableWidget(
        const KFBadge(
          count: 0,
          showZero: true,
          child: Icon(Icons.notifications),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('shows 99+ for counts over 99', (tester) async {
      await tester.pumpTestableWidget(
        const KFBadge(
          count: 150,
          child: Icon(Icons.notifications),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('uses custom color', (tester) async {
      await tester.pumpTestableWidget(
        const KFBadge(
          count: 5,
          color: Colors.blue,
          child: Icon(Icons.notifications),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });
  });

  group('KFEmptyState', () {
    testWidgets('renders icon and title', (tester) async {
      await tester.pumpTestableWidget(
        const KFEmptyState(
          icon: Icons.inbox,
          title: 'No items found',
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('shows description when provided', (tester) async {
      await tester.pumpTestableWidget(
        const KFEmptyState(
          icon: Icons.inbox,
          title: 'No items found',
          description: 'Try adding some items to get started.',
        ),
      );

      expect(find.text('Try adding some items to get started.'), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      await tester.pumpTestableWidget(
        KFEmptyState(
          icon: Icons.inbox,
          title: 'No items found',
          actionLabel: 'Add Item',
          onAction: () {},
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('calls onAction when button pressed', (tester) async {
      bool actionCalled = false;

      await tester.pumpTestableWidget(
        KFEmptyState(
          icon: Icons.inbox,
          title: 'No items found',
          actionLabel: 'Add Item',
          onAction: () => actionCalled = true,
        ),
      );

      await tester.tap(find.text('Add Item'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('hides action button when onAction is null', (tester) async {
      await tester.pumpTestableWidget(
        const KFEmptyState(
          icon: Icons.inbox,
          title: 'No items found',
          actionLabel: 'Add Item',
          onAction: null,
        ),
      );

      expect(find.text('Add Item'), findsNothing);
    });
  });

  group('KFErrorState', () {
    testWidgets('renders default error title', (tester) async {
      await tester.pumpTestableWidget(
        const KFErrorState(),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows custom title', (tester) async {
      await tester.pumpTestableWidget(
        const KFErrorState(title: 'Connection Error'),
      );

      expect(find.text('Connection Error'), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpTestableWidget(
        const KFErrorState(
          message: 'Please check your internet connection.',
        ),
      );

      expect(find.text('Please check your internet connection.'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry provided', (tester) async {
      await tester.pumpTestableWidget(
        KFErrorState(onRetry: () {}),
      );

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('calls onRetry when button pressed', (tester) async {
      bool retryCalled = false;

      await tester.pumpTestableWidget(
        KFErrorState(onRetry: () => retryCalled = true),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpTestableWidget(
        const KFErrorState(),
      );

      expect(find.text('Try Again'), findsNothing);
    });
  });

  group('KFInfoBanner', () {
    testWidgets('renders message with info icon', (tester) async {
      await tester.pumpTestableWidget(
        const KFInfoBanner(
          message: 'Your session will expire in 5 minutes.',
        ),
      );

      expect(find.text('Your session will expire in 5 minutes.'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('uses custom icon', (tester) async {
      await tester.pumpTestableWidget(
        const KFInfoBanner(
          message: 'Warning message',
          icon: Icons.warning,
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('shows dismiss button when onDismiss provided', (tester) async {
      await tester.pumpTestableWidget(
        KFInfoBanner(
          message: 'Dismissible banner',
          onDismiss: () {},
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onDismiss when close icon tapped', (tester) async {
      bool dismissed = false;

      await tester.pumpTestableWidget(
        KFInfoBanner(
          message: 'Dismissible banner',
          onDismiss: () => dismissed = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('uses custom colors', (tester) async {
      await tester.pumpTestableWidget(
        const KFInfoBanner(
          message: 'Custom colored banner',
          backgroundColor: Colors.amber,
          textColor: Colors.black,
        ),
      );

      expect(find.text('Custom colored banner'), findsOneWidget);
    });
  });
}
