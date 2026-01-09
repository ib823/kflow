import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/core/widgets/kf_card.dart';
import 'package:kerjaflow/core/widgets/kf_status.dart';
import '../helpers/test_app.dart';

void main() {
  group('KFCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpTestableWidget(
        const KFCard(
          child: Text('Card Content'),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpTestableWidget(
        KFCard(
          onTap: () => tapped = true,
          child: const Text('Tap Me'),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('calls onLongPress when long pressed', (tester) async {
      bool longPressed = false;

      await tester.pumpTestableWidget(
        KFCard(
          onLongPress: () => longPressed = true,
          child: const Text('Long Press Me'),
        ),
      );

      await tester.longPress(find.text('Long Press Me'));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpTestableWidget(
        const KFCard(
          padding: EdgeInsets.all(24),
          child: Text('Padded'),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.all(24));
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpTestableWidget(
        const KFCard(child: Text('Dark')),
        themeMode: ThemeMode.dark,
      );

      expect(find.text('Dark'), findsOneWidget);
    });
  });

  group('KFElevatedCard', () {
    testWidgets('renders with elevation', (tester) async {
      await tester.pumpTestableWidget(
        const KFElevatedCard(
          child: Text('Elevated'),
        ),
      );

      expect(find.text('Elevated'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpTestableWidget(
        KFElevatedCard(
          onTap: () => tapped = true,
          child: const Text('Tap'),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('KFPayslipCard', () {
    testWidgets('renders month and year', (tester) async {
      await tester.pumpTestableWidget(
        const KFPayslipCard(
          month: 'January',
          year: '2026',
          netAmount: 4250.00,
        ),
      );

      expect(find.text('JANUARY'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
    });

    testWidgets('displays formatted amount with currency', (tester) async {
      await tester.pumpTestableWidget(
        const KFPayslipCard(
          month: 'January',
          year: '2026',
          netAmount: 4250.00,
          currencyCode: 'RM',
        ),
      );

      expect(find.textContaining('RM'), findsOneWidget);
      expect(find.textContaining('4,250.00'), findsOneWidget);
    });

    testWidgets('shows NEW badge when isNew is true', (tester) async {
      await tester.pumpTestableWidget(
        const KFPayslipCard(
          month: 'January',
          year: '2026',
          netAmount: 4250.00,
          isNew: true,
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('does not show NEW badge when isNew is false', (tester) async {
      await tester.pumpTestableWidget(
        const KFPayslipCard(
          month: 'January',
          year: '2026',
          netAmount: 4250.00,
          isNew: false,
        ),
      );

      expect(find.text('NEW'), findsNothing);
    });

    testWidgets('shows Paid status when isPaid is true', (tester) async {
      await tester.pumpTestableWidget(
        const KFPayslipCard(
          month: 'January',
          year: '2026',
          netAmount: 4250.00,
          isPaid: true,
        ),
      );

      expect(find.text('Paid'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows Processing status when isPaid is false', (tester) async {
      await tester.pumpTestableWidget(
        const KFPayslipCard(
          month: 'January',
          year: '2026',
          netAmount: 4250.00,
          isPaid: false,
        ),
      );

      expect(find.text('Processing'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });
  });

  group('KFLeaveBalanceCard', () {
    testWidgets('renders leave type', (tester) async {
      await tester.pumpTestableWidget(
        const KFLeaveBalanceCard(
          leaveType: 'Annual Leave',
          icon: Icons.beach_access,
          color: Colors.green,
          balance: 12,
          total: 16,
        ),
      );

      expect(find.text('Annual Leave'), findsOneWidget);
    });

    testWidgets('displays balance correctly', (tester) async {
      await tester.pumpTestableWidget(
        const KFLeaveBalanceCard(
          leaveType: 'Annual Leave',
          icon: Icons.beach_access,
          color: Colors.green,
          balance: 12,
          total: 16,
        ),
      );

      expect(find.text('12'), findsOneWidget);
      expect(find.textContaining('/ 16 days'), findsOneWidget);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpTestableWidget(
        const KFLeaveBalanceCard(
          leaveType: 'Annual Leave',
          icon: Icons.beach_access,
          color: Colors.green,
          balance: 12,
          total: 16,
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpTestableWidget(
        KFLeaveBalanceCard(
          leaveType: 'Annual Leave',
          icon: Icons.beach_access,
          color: Colors.green,
          balance: 12,
          total: 16,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Annual Leave'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('KFStatsCard', () {
    testWidgets('renders title and value', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatsCard(
          title: 'Total Leave',
          value: '27',
          icon: Icons.event,
        ),
      );

      expect(find.text('Total Leave'), findsOneWidget);
      expect(find.text('27'), findsOneWidget);
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatsCard(
          title: 'Total Leave',
          value: '27',
          subtitle: 'days remaining',
          icon: Icons.event,
        ),
      );

      expect(find.text('days remaining'), findsOneWidget);
    });

    testWidgets('displays icon', (tester) async {
      await tester.pumpTestableWidget(
        const KFStatsCard(
          title: 'Total Leave',
          value: '27',
          icon: Icons.event,
        ),
      );

      expect(find.byIcon(Icons.event), findsOneWidget);
    });
  });

  group('KFApprovalCard', () {
    testWidgets('renders employee name', (tester) async {
      await tester.pumpTestableWidget(
        const KFApprovalCard(
          employeeName: 'Sarah Abdullah',
          leaveType: 'Annual Leave',
        ),
      );

      expect(find.text('Sarah Abdullah'), findsOneWidget);
    });

    testWidgets('shows employee initial when no avatar', (tester) async {
      await tester.pumpTestableWidget(
        const KFApprovalCard(
          employeeName: 'Sarah Abdullah',
          leaveType: 'Annual Leave',
        ),
      );

      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('shows status badge', (tester) async {
      await tester.pumpTestableWidget(
        const KFApprovalCard(
          employeeName: 'Sarah Abdullah',
          leaveType: 'Annual Leave',
          status: StatusType.pending,
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows approve and reject buttons', (tester) async {
      await tester.pumpTestableWidget(
        KFApprovalCard(
          employeeName: 'Sarah Abdullah',
          leaveType: 'Annual Leave',
          onApprove: () {},
          onReject: () {},
        ),
      );

      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('calls onApprove when Approve tapped', (tester) async {
      bool approved = false;

      await tester.pumpTestableWidget(
        KFApprovalCard(
          employeeName: 'Sarah Abdullah',
          leaveType: 'Annual Leave',
          onApprove: () => approved = true,
          onReject: () {},
        ),
      );

      await tester.tap(find.text('Approve'));
      await tester.pump();

      expect(approved, isTrue);
    });

    testWidgets('calls onReject when Reject tapped', (tester) async {
      bool rejected = false;

      await tester.pumpTestableWidget(
        KFApprovalCard(
          employeeName: 'Sarah Abdullah',
          leaveType: 'Annual Leave',
          onApprove: () {},
          onReject: () => rejected = true,
        ),
      );

      await tester.tap(find.text('Reject'));
      await tester.pump();

      expect(rejected, isTrue);
    });
  });

  group('KFNotificationCard', () {
    testWidgets('renders title and message', (tester) async {
      await tester.pumpTestableWidget(
        const KFNotificationCard(
          icon: Icons.check_circle,
          title: 'Leave Approved',
          message: 'Your leave request has been approved.',
        ),
      );

      expect(find.text('Leave Approved'), findsOneWidget);
      expect(find.text('Your leave request has been approved.'), findsOneWidget);
    });

    testWidgets('shows unread indicator when not read', (tester) async {
      await tester.pumpTestableWidget(
        const KFNotificationCard(
          icon: Icons.check_circle,
          title: 'Leave Approved',
          message: 'Your leave request has been approved.',
          isRead: false,
        ),
      );

      // Find the small blue dot indicator
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasIndicator = containers.any((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.shape == BoxShape.circle &&
              c.constraints?.maxWidth == 8;
        }
        return false;
      });
      expect(hasIndicator, isTrue);
    });

    testWidgets('shows time', (tester) async {
      await tester.pumpTestableWidget(
        const KFNotificationCard(
          icon: Icons.check_circle,
          title: 'Leave Approved',
          message: 'Your leave request has been approved.',
          time: '2h ago',
        ),
      );

      expect(find.text('2h ago'), findsOneWidget);
    });
  });
}
