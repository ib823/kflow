import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/core/widgets/kf_button.dart';
import 'package:kerjaflow/core/widgets/kf_card.dart';
import 'package:kerjaflow/core/widgets/kf_status.dart';
import '../helpers/test_app.dart';

/// Golden tests for visual regression testing
/// Run with: flutter test --update-goldens
void main() {
  group('Button Goldens', () {
    testWidgets('KFPrimaryButton light mode', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: SizedBox(
            width: 200,
            child: KFPrimaryButton(
              label: 'Primary Button',
              onPressed: () {},
            ),
          ),
        ),
        themeMode: ThemeMode.light,
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/primary_button_light.png'),
      );
    });

    testWidgets('KFPrimaryButton dark mode', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: SizedBox(
            width: 200,
            child: KFPrimaryButton(
              label: 'Primary Button',
              onPressed: () {},
            ),
          ),
        ),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/primary_button_dark.png'),
      );
    });

    testWidgets('KFPrimaryButton loading state', (tester) async {
      await tester.pumpTestableWidget(
        const Center(
          child: SizedBox(
            width: 200,
            child: KFPrimaryButton(
              label: 'Loading',
              isLoading: true,
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/primary_button_loading.png'),
      );
    });

    testWidgets('KFSecondaryButton light mode', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: SizedBox(
            width: 200,
            child: KFSecondaryButton(
              label: 'Secondary Button',
              onPressed: () {},
            ),
          ),
        ),
        themeMode: ThemeMode.light,
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/secondary_button_light.png'),
      );
    });

    testWidgets('KFDangerButton variants', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                child: KFDangerButton(
                  label: 'Delete',
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: KFDangerButton(
                  label: 'Cancel',
                  isOutlined: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/danger_buttons.png'),
      );
    });

    testWidgets('Button sizes', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                child: KFPrimaryButton(
                  label: 'Small',
                  size: ButtonSize.small,
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: KFPrimaryButton(
                  label: 'Medium',
                  size: ButtonSize.medium,
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: KFPrimaryButton(
                  label: 'Large',
                  size: ButtonSize.large,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/button_sizes.png'),
      );
    });
  });

  group('Card Goldens', () {
    testWidgets('KFPayslipCard light mode', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: SizedBox(
            width: 180,
            height: 160,
            child: KFPayslipCard(
              month: 'January',
              year: '2026',
              netAmount: 4250.00,
              isNew: true,
              onTap: () {},
            ),
          ),
        ),
        themeMode: ThemeMode.light,
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/payslip_card_light.png'),
      );
    });

    testWidgets('KFPayslipCard dark mode', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: SizedBox(
            width: 180,
            height: 160,
            child: KFPayslipCard(
              month: 'January',
              year: '2026',
              netAmount: 4250.00,
              isNew: true,
              onTap: () {},
            ),
          ),
        ),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/payslip_card_dark.png'),
      );
    });

    testWidgets('KFLeaveBalanceCard', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: SizedBox(
            width: 300,
            child: KFLeaveBalanceCard(
              leaveType: 'Annual Leave',
              icon: Icons.beach_access,
              color: Colors.green,
              balance: 12,
              total: 16,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/leave_balance_card.png'),
      );
    });

    testWidgets('KFNotificationCard states', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KFNotificationCard(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  title: 'Leave Approved',
                  message: 'Your annual leave request has been approved.',
                  time: '2m ago',
                  isRead: false,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                KFNotificationCard(
                  icon: Icons.notifications,
                  title: 'New Payslip',
                  message: 'Your December 2025 payslip is available.',
                  time: '1h ago',
                  isRead: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/notification_cards.png'),
      );
    });
  });

  group('Status Goldens', () {
    testWidgets('Status chips all types', (tester) async {
      await tester.pumpTestableWidget(
        const Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              KFStatusChip(label: 'Approved', type: StatusType.approved),
              KFStatusChip(label: 'Pending', type: StatusType.pending),
              KFStatusChip(label: 'Rejected', type: StatusType.rejected),
              KFStatusChip(label: 'Cancelled', type: StatusType.cancelled),
              KFStatusChip(label: 'Processing', type: StatusType.processing),
              KFStatusChip(label: 'Draft', type: StatusType.draft),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/status_chips.png'),
      );
    });

    testWidgets('KFBadge variants', (tester) async {
      await tester.pumpTestableWidget(
        const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KFBadge(
                count: 5,
                child: Icon(Icons.notifications, size: 32),
              ),
              SizedBox(width: 24),
              KFBadge(
                count: 99,
                child: Icon(Icons.mail, size: 32),
              ),
              SizedBox(width: 24),
              KFBadge(
                count: 150,
                child: Icon(Icons.chat, size: 32),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/badges.png'),
      );
    });

    testWidgets('KFEmptyState', (tester) async {
      await tester.pumpTestableWidget(
        KFEmptyState(
          icon: Icons.inbox,
          title: 'No items found',
          description: 'Try adding some items to get started.',
          actionLabel: 'Add Item',
          onAction: () {},
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/empty_state.png'),
      );
    });

    testWidgets('KFErrorState', (tester) async {
      await tester.pumpTestableWidget(
        KFErrorState(
          title: 'Connection Error',
          message: 'Please check your internet connection and try again.',
          onRetry: () {},
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/error_state.png'),
      );
    });

    testWidgets('KFInfoBanner', (tester) async {
      await tester.pumpTestableWidget(
        Center(
          child: SizedBox(
            width: 350,
            child: KFInfoBanner(
              message: 'Your session will expire in 5 minutes.',
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/info_banner.png'),
      );
    });
  });
}
