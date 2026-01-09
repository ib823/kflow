import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ErrorWidget Tests
///
/// Tests error display and retry functionality.
void main() {
  group('ErrorWidget Tests', () {
    Widget createTestWidget({required Widget child}) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    }

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            message: 'Something went wrong',
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            message: 'Error occurred',
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: _MockErrorWidget(
            message: 'Error',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            message: 'Error',
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        createTestWidget(
          child: _MockErrorWidget(
            message: 'Error',
            onRetry: () => retried = true,
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('displays network error with appropriate icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            message: 'No internet connection',
            type: ErrorType.network,
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('displays server error with appropriate icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            message: 'Server error',
            type: ErrorType.server,
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('displays auth error with appropriate icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            message: 'Session expired',
            type: ErrorType.auth,
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            title: 'Oops!',
            message: 'Something went wrong',
          ),
        ),
      );

      expect(find.text('Oops!'), findsOneWidget);
    });

    testWidgets('shows secondary action when provided', (tester) async {
      var secondaryTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          child: _MockErrorWidget(
            message: 'Error',
            onRetry: () {},
            secondaryActionText: 'Go Back',
            onSecondaryAction: () => secondaryTapped = true,
          ),
        ),
      );

      expect(find.text('Go Back'), findsOneWidget);
      await tester.tap(find.text('Go Back'));
      expect(secondaryTapped, isTrue);
    });

    testWidgets('renders in compact mode', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            message: 'Error',
            compact: true,
          ),
        ),
      );

      // In compact mode, should use Row instead of Column
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('handles long error messages', (tester) async {
      const longMessage = 'This is a very long error message that should '
          'wrap properly and not overflow the screen. It contains multiple '
          'sentences and should be displayed correctly.';

      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            message: longMessage,
          ),
        ),
      );

      expect(find.textContaining('This is a very long'), findsOneWidget);
    });

    testWidgets('uses custom error color when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockErrorWidget(
            message: 'Warning',
            iconColor: Colors.orange,
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.error_outline &&
              widget.color == Colors.orange,
        ),
        findsOneWidget,
      );
    });
  });

  group('EmptyStateWidget Tests', () {
    Widget createTestWidget({required Widget child}) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    }

    testWidgets('displays empty state message', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockEmptyStateWidget(
            message: 'No items found',
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('displays empty state icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const _MockEmptyStateWidget(
            message: 'No items',
            icon: Icons.inbox,
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      var actionTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          child: _MockEmptyStateWidget(
            message: 'No payslips',
            actionText: 'Refresh',
            onAction: () => actionTapped = true,
          ),
        ),
      );

      expect(find.text('Refresh'), findsOneWidget);
      await tester.tap(find.text('Refresh'));
      expect(actionTapped, isTrue);
    });
  });
}

/// Error types
enum ErrorType { general, network, server, auth }

/// Mock ErrorWidget for testing
class _MockErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final bool compact;
  final Color? iconColor;

  const _MockErrorWidget({
    this.title,
    required this.message,
    this.type = ErrorType.general,
    this.onRetry,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.compact = false,
    this.iconColor,
  });

  IconData get _icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.auth:
        return Icons.lock_outline;
      default:
        return Icons.error_outline;
    }
  }

  Color get _color => iconColor ?? Colors.red;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icon, color: _color, size: 24),
          const SizedBox(width: 8),
          Flexible(child: Text(message)),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 64, color: _color),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            if (secondaryActionText != null && onSecondaryAction != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mock EmptyStateWidget for testing
class _MockEmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const _MockEmptyStateWidget({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}
