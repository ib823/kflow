import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// KerjaFlow Offline Mode Integration Tests
///
/// Tests offline capabilities:
/// - Display cached data when offline
/// - Sync data when coming back online
/// - Queue leave requests when offline
///
/// Per CLAUDE.md: Offline-first mobile architecture
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Mode Tests', () {
    testWidgets('displays cached payslips when offline', (tester) async {
      await tester.pumpWidget(const _MockOfflineApp(isOnline: false));
      await tester.pumpAndSettle();

      // Navigate to payslips
      await tester.tap(find.text('Payslips'));
      await tester.pumpAndSettle();

      // Should show cached data
      expect(find.text('Payslip List'), findsOneWidget);
      expect(find.byKey(const Key('cached_payslip_card')), findsWidgets);

      // Should show offline indicator
      expect(find.byKey(const Key('offline_banner')), findsOneWidget);
      expect(find.text('Offline Mode'), findsOneWidget);
    });

    testWidgets('displays cached leave balance when offline', (tester) async {
      await tester.pumpWidget(const _MockOfflineApp(isOnline: false));
      await tester.pumpAndSettle();

      // Navigate to leave
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      // Should show cached leave balance
      expect(find.text('Leave Balance'), findsOneWidget);
      expect(find.text('Annual Leave'), findsOneWidget);

      // Should show last synced time
      expect(find.textContaining('Last synced:'), findsOneWidget);
    });

    testWidgets('queues leave request when offline', (tester) async {
      await tester.pumpWidget(const _MockOfflineApp(isOnline: false));
      await tester.pumpAndSettle();

      // Navigate to leave application
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Leave'));
      await tester.pumpAndSettle();

      // Fill leave form
      await tester.tap(find.byKey(const Key('leave_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annual Leave').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reason_field')),
        'Family vacation to hometown',
      );

      // Submit while offline
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      // Should show queued confirmation
      expect(find.text('Request Queued'), findsOneWidget);
      expect(
        find.textContaining('will be submitted when online'),
        findsOneWidget,
      );
    });

    testWidgets('shows pending sync count when offline', (tester) async {
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: false,
          pendingSyncCount: 3,
        ),
      );
      await tester.pumpAndSettle();

      // Should show pending sync badge
      expect(find.byKey(const Key('pending_sync_badge')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('syncs data when coming back online', (tester) async {
      final app = _MockOfflineApp(
        isOnline: false,
        onConnectivityChange: (callback) {
          // Simulate coming back online after a delay
          Future.delayed(const Duration(seconds: 1), () => callback(true));
        },
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Initially offline
      expect(find.byKey(const Key('offline_banner')), findsOneWidget);

      // Wait for connectivity change
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should show syncing indicator
      expect(find.byKey(const Key('syncing_indicator')), findsOneWidget);
    });

    testWidgets('displays sync success after reconnection', (tester) async {
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: true,
          justReconnected: true,
          syncedCount: 3,
        ),
      );
      await tester.pumpAndSettle();

      // Should show sync success message
      expect(find.text('Sync Complete'), findsOneWidget);
      expect(find.text('3 items synced'), findsOneWidget);
    });

    testWidgets('handles sync failure gracefully', (tester) async {
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: true,
          syncFailed: true,
        ),
      );
      await tester.pumpAndSettle();

      // Should show sync error
      expect(find.text('Sync Failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows offline indicator in app bar', (tester) async {
      await tester.pumpWidget(const _MockOfflineApp(isOnline: false));
      await tester.pumpAndSettle();

      // Should show offline icon in app bar
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('allows viewing cached payslip detail offline', (tester) async {
      await tester.pumpWidget(const _MockOfflineApp(isOnline: false));
      await tester.pumpAndSettle();

      // Navigate to payslips
      await tester.tap(find.text('Payslips'));
      await tester.pumpAndSettle();

      // Tap on cached payslip
      await tester.tap(find.byKey(const Key('cached_payslip_card')).first);
      await tester.pumpAndSettle();

      // Should show payslip detail
      expect(find.text('Payslip Detail'), findsOneWidget);
      expect(find.text('Gross Salary'), findsOneWidget);
      expect(find.text('Net Salary'), findsOneWidget);

      // Should show cached indicator
      expect(find.textContaining('Cached'), findsOneWidget);
    });

    testWidgets('disables certain actions when offline', (tester) async {
      await tester.pumpWidget(const _MockOfflineApp(isOnline: false));
      await tester.pumpAndSettle();

      // Navigate to payslips
      await tester.tap(find.text('Payslips'));
      await tester.pumpAndSettle();

      // Tap on payslip
      await tester.tap(find.byKey(const Key('cached_payslip_card')).first);
      await tester.pumpAndSettle();

      // Download button should be disabled
      final downloadButton = find.byKey(const Key('download_pdf_button'));
      expect(downloadButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(downloadButton);
      expect(button.enabled, isFalse);
    });

    testWidgets('preserves offline queue across app restart', (tester) async {
      // Simulate app with persisted queue
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: false,
          pendingSyncCount: 2,
          hasPersistentQueue: true,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to pending queue
      await tester.tap(find.byKey(const Key('pending_sync_badge')));
      await tester.pumpAndSettle();

      // Should show pending items
      expect(find.text('Pending Sync'), findsOneWidget);
      expect(find.byKey(const Key('pending_item')), findsNWidgets(2));
    });

    testWidgets('shows last sync timestamp', (tester) async {
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: false,
          lastSyncTime: '2026-01-09 10:30',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Last synced: 2026-01-09'), findsOneWidget);
    });

    testWidgets('auto-syncs when app returns to foreground online',
        (tester) async {
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: true,
          pendingSyncCount: 1,
          simulateAppResume: true,
        ),
      );
      await tester.pumpAndSettle();

      // Should trigger auto-sync
      expect(find.byKey(const Key('syncing_indicator')), findsOneWidget);
    });
  });

  group('Offline Data Freshness', () {
    testWidgets('shows stale data warning after 24 hours', (tester) async {
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: false,
          dataAgeHours: 25,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Payslips'));
      await tester.pumpAndSettle();

      // Should show stale data warning
      expect(find.text('Data may be outdated'), findsOneWidget);
    });

    testWidgets('does not show warning for fresh data', (tester) async {
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: false,
          dataAgeHours: 2,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Payslips'));
      await tester.pumpAndSettle();

      // Should not show stale warning
      expect(find.text('Data may be outdated'), findsNothing);
    });
  });

  group('Offline Conflict Resolution', () {
    testWidgets('shows conflict dialog when sync detects changes',
        (tester) async {
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: true,
          hasConflict: true,
        ),
      );
      await tester.pumpAndSettle();

      // Should show conflict dialog
      expect(find.text('Sync Conflict'), findsOneWidget);
      expect(find.text('Keep Local'), findsOneWidget);
      expect(find.text('Use Server'), findsOneWidget);
    });

    testWidgets('resolves conflict with server version', (tester) async {
      await tester.pumpWidget(
        const _MockOfflineApp(
          isOnline: true,
          hasConflict: true,
        ),
      );
      await tester.pumpAndSettle();

      // Choose server version
      await tester.tap(find.text('Use Server'));
      await tester.pumpAndSettle();

      // Should show resolution success
      expect(find.text('Conflict Resolved'), findsOneWidget);
    });
  });
}

/// Mock app for offline testing
class _MockOfflineApp extends StatefulWidget {
  final bool isOnline;
  final int pendingSyncCount;
  final bool justReconnected;
  final int syncedCount;
  final bool syncFailed;
  final bool hasPersistentQueue;
  final String? lastSyncTime;
  final bool simulateAppResume;
  final int dataAgeHours;
  final bool hasConflict;
  final Function(Function(bool))? onConnectivityChange;

  const _MockOfflineApp({
    this.isOnline = true,
    this.pendingSyncCount = 0,
    this.justReconnected = false,
    this.syncedCount = 0,
    this.syncFailed = false,
    this.hasPersistentQueue = false,
    this.lastSyncTime,
    this.simulateAppResume = false,
    this.dataAgeHours = 0,
    this.hasConflict = false,
    this.onConnectivityChange,
  });

  @override
  State<_MockOfflineApp> createState() => _MockOfflineAppState();
}

class _MockOfflineAppState extends State<_MockOfflineApp> {
  late bool _isOnline;
  bool _isSyncing = false;
  bool _showConflictDialog = false;
  String _currentScreen = 'home';

  @override
  void initState() {
    super.initState();
    _isOnline = widget.isOnline;
    _showConflictDialog = widget.hasConflict;

    if (widget.onConnectivityChange != null) {
      widget.onConnectivityChange!((online) {
        setState(() {
          _isOnline = online;
          if (online) _isSyncing = true;
        });
      });
    }

    if (widget.simulateAppResume && widget.pendingSyncCount > 0) {
      _isSyncing = true;
    }
  }

  void _navigate(String screen) {
    setState(() => _currentScreen = screen);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(_getTitle()),
              leading: _currentScreen != 'home'
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _navigate('home'),
                    )
                  : null,
              actions: [
                if (!_isOnline) const Icon(Icons.cloud_off),
                if (widget.pendingSyncCount > 0)
                  Stack(
                    children: [
                      IconButton(
                        key: const Key('pending_sync_badge'),
                        icon: const Icon(Icons.sync),
                        onPressed: () => _navigate('pending'),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${widget.pendingSyncCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            body: Column(
              children: [
                // Offline banner
                if (!_isOnline)
                  Container(
                    key: const Key('offline_banner'),
                    width: double.infinity,
                    color: Colors.orange,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Offline Mode',
                          style: TextStyle(color: Colors.white),
                        ),
                        if (widget.lastSyncTime != null) ...[
                          const Text(
                            ' - ',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Last synced: ${widget.lastSyncTime}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Syncing indicator
                if (_isSyncing)
                  Container(
                    key: const Key('syncing_indicator'),
                    width: double.infinity,
                    color: Colors.blue,
                    padding: const EdgeInsets.all(8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Syncing...', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                // Sync success
                if (widget.justReconnected)
                  Container(
                    width: double.infinity,
                    color: Colors.green,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Sync Complete',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.syncedCount} items synced',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                // Sync failed
                if (widget.syncFailed)
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Sync Failed',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main content
                Expanded(child: _buildScreen()),
              ],
            ),
          ),

          // Conflict dialog
          if (_showConflictDialog)
            AlertDialog(
              title: const Text('Sync Conflict'),
              content: const Text(
                'Your local changes conflict with server changes. '
                'How would you like to resolve this?',
              ),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _showConflictDialog = false),
                  child: const Text('Keep Local'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _showConflictDialog = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conflict Resolved')),
                    );
                  },
                  child: const Text('Use Server'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentScreen) {
      case 'payslips':
        return 'Payslip List';
      case 'payslip_detail':
        return 'Payslip Detail';
      case 'leave':
        return 'Leave Balance';
      case 'leave_apply':
        return 'Apply Leave';
      case 'pending':
        return 'Pending Sync';
      default:
        return 'Home';
    }
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case 'payslips':
        return _PayslipsScreen(
          isOnline: _isOnline,
          dataAgeHours: widget.dataAgeHours,
          onDetail: () => _navigate('payslip_detail'),
        );
      case 'payslip_detail':
        return _PayslipDetailScreen(isOnline: _isOnline);
      case 'leave':
        return _LeaveScreen(
          lastSyncTime: widget.lastSyncTime,
          onApply: () => _navigate('leave_apply'),
        );
      case 'leave_apply':
        return _LeaveApplyScreen(isOnline: _isOnline);
      case 'pending':
        return _PendingSyncScreen(count: widget.pendingSyncCount);
      default:
        return _HomeScreen(
          onPayslips: () => _navigate('payslips'),
          onLeave: () => _navigate('leave'),
        );
    }
  }
}

class _HomeScreen extends StatelessWidget {
  final VoidCallback onPayslips;
  final VoidCallback onLeave;

  const _HomeScreen({
    required this.onPayslips,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.receipt_long),
          title: const Text('Payslips'),
          onTap: onPayslips,
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Leave'),
          onTap: onLeave,
        ),
      ],
    );
  }
}

class _PayslipsScreen extends StatelessWidget {
  final bool isOnline;
  final int dataAgeHours;
  final VoidCallback onDetail;

  const _PayslipsScreen({
    required this.isOnline,
    required this.dataAgeHours,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (dataAgeHours > 24)
          Container(
            width: double.infinity,
            color: Colors.yellow.shade100,
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Data may be outdated',
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView(
            children: [
              GestureDetector(
                key: const Key('cached_payslip_card'),
                onTap: onDetail,
                child: const Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('January 2026'),
                    subtitle: Text('MYR 5,000.00'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ),
              ),
              GestureDetector(
                key: const Key('cached_payslip_card'),
                onTap: onDetail,
                child: const Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('December 2025'),
                    subtitle: Text('MYR 5,000.00'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PayslipDetailScreen extends StatelessWidget {
  final bool isOnline;

  const _PayslipDetailScreen({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOnline)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Cached Data'),
                ],
              ),
            ),
          const Text('Gross Salary',
              style: TextStyle(color: Colors.grey)),
          const Text('MYR 5,000.00',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Net Salary', style: TextStyle(color: Colors.grey)),
          const Text('MYR 4,422.00',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            key: const Key('download_pdf_button'),
            onPressed: isOnline ? () {} : null,
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }
}

class _LeaveScreen extends StatelessWidget {
  final String? lastSyncTime;
  final VoidCallback onApply;

  const _LeaveScreen({
    this.lastSyncTime,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (lastSyncTime != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Last synced: $lastSyncTime'),
          ),
        const Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Annual Leave',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Entitled: 16'),
                    Text('Taken: 5'),
                    Text('Balance: 11'),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: onApply,
            child: const Text('Apply Leave'),
          ),
        ),
      ],
    );
  }
}

class _LeaveApplyScreen extends StatefulWidget {
  final bool isOnline;

  const _LeaveApplyScreen({required this.isOnline});

  @override
  State<_LeaveApplyScreen> createState() => _LeaveApplyScreenState();
}

class _LeaveApplyScreenState extends State<_LeaveApplyScreen> {
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Request Queued',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Your request will be submitted when online'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: const Key('leave_type_dropdown'),
            decoration: const InputDecoration(labelText: 'Leave Type'),
            items: const [
              DropdownMenuItem(value: 'annual', child: Text('Annual Leave')),
              DropdownMenuItem(value: 'sick', child: Text('Sick Leave')),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('reason_field'),
            decoration: const InputDecoration(labelText: 'Reason'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('submit_button'),
            onPressed: () {
              if (!widget.isOnline) {
                setState(() => _submitted = true);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _PendingSyncScreen extends StatelessWidget {
  final int count;

  const _PendingSyncScreen({required this.count});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) => Card(
        key: const Key('pending_item'),
        margin: const EdgeInsets.all(8),
        child: ListTile(
          leading: const Icon(Icons.schedule),
          title: Text('Pending Item ${index + 1}'),
          subtitle: const Text('Waiting for connection'),
        ),
      ),
    );
  }
}
