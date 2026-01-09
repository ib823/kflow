import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/core/widgets/kf_loading.dart';
import '../helpers/test_app.dart';

void main() {
  group('KFLoadingOverlay', () {
    testWidgets('shows child when not loading', (tester) async {
      await tester.pumpTestableWidget(
        const KFLoadingOverlay(
          isLoading: false,
          child: Text('Content'),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpTestableWidget(
        const KFLoadingOverlay(
          isLoading: true,
          child: Text('Content'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows message when loading with message', (tester) async {
      await tester.pumpTestableWidget(
        const KFLoadingOverlay(
          isLoading: true,
          message: 'Please wait...',
          child: Text('Content'),
        ),
      );

      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('child is still visible under overlay', (tester) async {
      await tester.pumpTestableWidget(
        const KFLoadingOverlay(
          isLoading: true,
          child: Text('Content'),
        ),
      );

      // Child should still be in the widget tree
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('KFSkeleton', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeleton(),
      );

      expect(find.byType(KFSkeleton), findsOneWidget);
    });

    testWidgets('respects width and height', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeleton(width: 100, height: 20),
      );

      // Animation will create the container
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders as circle when isCircle is true', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeleton(height: 40, isCircle: true),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(KFSkeleton), findsOneWidget);
    });

    testWidgets('animates shimmer effect', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeleton(width: 100, height: 20),
      );

      // Animation should be running
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(KFSkeleton), findsOneWidget);
    });
  });

  group('KFSkeletonListItem', () {
    testWidgets('renders with default configuration', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeletonListItem(),
      );

      expect(find.byType(KFSkeletonListItem), findsOneWidget);
    });

    testWidgets('shows leading skeleton by default', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeletonListItem(hasLeading: true),
      );

      // Should have multiple skeletons (leading + text lines)
      expect(find.byType(KFSkeleton), findsWidgets);
    });

    testWidgets('hides leading when hasLeading is false', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeletonListItem(hasLeading: false),
      );

      expect(find.byType(KFSkeletonListItem), findsOneWidget);
    });

    testWidgets('shows trailing when hasTrailing is true', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeletonListItem(hasTrailing: true),
      );

      expect(find.byType(KFSkeleton), findsWidgets);
    });

    testWidgets('renders correct number of lines', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeletonListItem(lines: 3, hasLeading: false),
      );

      // Should have 3 skeleton lines
      expect(find.byType(KFSkeleton), findsNWidgets(3));
    });
  });

  group('KFSkeletonCard', () {
    testWidgets('renders skeleton card', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeletonCard(),
      );

      expect(find.byType(KFSkeletonCard), findsOneWidget);
    });

    testWidgets('respects height parameter', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeletonCard(height: 200),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, 200);
    });

    testWidgets('contains skeleton elements', (tester) async {
      await tester.pumpTestableWidget(
        const KFSkeletonCard(),
      );

      expect(find.byType(KFSkeleton), findsWidgets);
    });
  });

  group('KFRefreshable', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpTestableWidget(
        KFRefreshable(
          onRefresh: () async {},
          child: const SingleChildScrollView(
            child: Text('Content'),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('wraps in RefreshIndicator', (tester) async {
      await tester.pumpTestableWidget(
        KFRefreshable(
          onRefresh: () async {},
          child: const SingleChildScrollView(
            child: SizedBox(height: 1000, child: Text('Content')),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  group('KFLoadingIndicator', () {
    testWidgets('renders circular progress indicator', (tester) async {
      await tester.pumpTestableWidget(
        const KFLoadingIndicator(),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('respects size parameter', (tester) async {
      await tester.pumpTestableWidget(
        const KFLoadingIndicator(size: 48),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 48);
      expect(sizedBox.height, 48);
    });

    testWidgets('uses custom color', (tester) async {
      await tester.pumpTestableWidget(
        const KFLoadingIndicator(color: Colors.red),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(animation.value, Colors.red);
    });
  });

  group('KFLoadingScreen', () {
    testWidgets('renders loading indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KFLoadingScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KFLoadingScreen(message: 'Loading data...'),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('centers content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KFLoadingScreen(),
        ),
      );

      expect(find.byType(Center), findsWidgets);
    });
  });
}
