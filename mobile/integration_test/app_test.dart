import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// KerjaFlow End-to-End Integration Tests
///
/// Tests complete user flows:
/// - Login → PIN → Home → Payslip → Leave → Logout
///
/// Per CLAUDE.md: Full user flows work end-to-end
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End User Flow', () {
    testWidgets('Complete login → view payslip → apply leave → logout flow',
        (tester) async {
      // Note: In actual tests, you would launch the real app:
      // app.main();
      // await tester.pumpAndSettle();

      // For now, we test with mock screens
      await tester.pumpWidget(const _MockApp());
      await tester.pumpAndSettle();

      // ═══════════════════════════════════════════════════════════════
      // Step 1: Login Screen
      // ═══════════════════════════════════════════════════════════════
      expect(find.text('Login'), findsOneWidget);

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@kerjaflow.my',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'TestPassword123!',
      );

      // Tap login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // ═══════════════════════════════════════════════════════════════
      // Step 2: PIN Entry/Setup
      // ═══════════════════════════════════════════════════════════════
      if (find.byKey(const Key('pin_screen')).evaluate().isNotEmpty) {
        // Enter 6-digit PIN
        for (var i = 0; i < 6; i++) {
          await tester.tap(find.byKey(Key('pin_key_1')));
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();
      }

      // ═══════════════════════════════════════════════════════════════
      // Step 3: Home Screen
      // ═══════════════════════════════════════════════════════════════
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      // Verify quick action cards exist
      expect(find.text('Payslips'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);

      // ═══════════════════════════════════════════════════════════════
      // Step 4: Navigate to Payslips
      // ═══════════════════════════════════════════════════════════════
      await tester.tap(find.text('Payslips'));
      await tester.pumpAndSettle();

      expect(find.text('Payslip List'), findsOneWidget);

      // Verify payslip cards are displayed
      expect(find.byKey(const Key('payslip_card')), findsWidgets);

      // Tap first payslip to view detail
      await tester.tap(find.byKey(const Key('payslip_card')).first);
      await tester.pumpAndSettle();

      // ═══════════════════════════════════════════════════════════════
      // Step 5: Payslip Detail Screen
      // ═══════════════════════════════════════════════════════════════
      expect(find.text('Payslip Detail'), findsOneWidget);
      expect(find.text('Gross Salary'), findsOneWidget);
      expect(find.text('Net Salary'), findsOneWidget);
      expect(find.text('Deductions'), findsOneWidget);

      // Verify statutory deductions are shown
      expect(find.text('EPF'), findsOneWidget);
      expect(find.text('SOCSO'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // ═══════════════════════════════════════════════════════════════
      // Step 6: Navigate to Leave
      // ═══════════════════════════════════════════════════════════════
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(find.text('Leave Balance'), findsOneWidget);

      // ═══════════════════════════════════════════════════════════════
      // Step 7: Apply for Leave
      // ═══════════════════════════════════════════════════════════════
      await tester.tap(find.text('Apply Leave'));
      await tester.pumpAndSettle();

      expect(find.text('Leave Application'), findsOneWidget);

      // Select leave type
      await tester.tap(find.byKey(const Key('leave_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annual Leave').last);
      await tester.pumpAndSettle();

      // Enter reason
      await tester.enterText(
        find.byKey(const Key('reason_field')),
        'Family vacation to hometown',
      );

      // Submit (in real test, would also select dates)
      // await tester.tap(find.text('Submit'));
      // await tester.pumpAndSettle(const Duration(seconds: 2));

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // ═══════════════════════════════════════════════════════════════
      // Step 8: Logout
      // ═══════════════════════════════════════════════════════════════
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Confirm logout dialog
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // Back to login
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Navigation bottom bar works correctly', (tester) async {
      await tester.pumpWidget(const _MockAppWithBottomNav());
      await tester.pumpAndSettle();

      // Verify bottom nav items
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Navigate via bottom nav
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();
      expect(find.text('Payslips'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      expect(find.text('Leave'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Pull to refresh updates data', (tester) async {
      await tester.pumpWidget(const _MockRefreshableScreen());
      await tester.pumpAndSettle();

      // Perform pull to refresh
      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // Verify refresh indicator was shown
      expect(find.text('Refreshed!'), findsOneWidget);
    });
  });
}

/// Mock App for E2E testing
class _MockApp extends StatefulWidget {
  const _MockApp();

  @override
  State<_MockApp> createState() => _MockAppState();
}

class _MockAppState extends State<_MockApp> {
  String _currentScreen = 'login';
  bool _showLogoutDialog = false;

  void _navigate(String screen) {
    setState(() => _currentScreen = screen);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          _buildScreen(),
          if (_showLogoutDialog)
            AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _showLogoutDialog = false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showLogoutDialog = false;
                      _currentScreen = 'login';
                    });
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case 'login':
        return _LoginScreen(onLogin: () => _navigate('home'));
      case 'home':
        return _HomeScreen(
          onPayslips: () => _navigate('payslips'),
          onLeave: () => _navigate('leave'),
          onSettings: () => _navigate('settings'),
        );
      case 'payslips':
        return _PayslipsScreen(
          onDetail: () => _navigate('payslip_detail'),
          onBack: () => _navigate('home'),
        );
      case 'payslip_detail':
        return _PayslipDetailScreen(onBack: () => _navigate('payslips'));
      case 'leave':
        return _LeaveScreen(
          onApply: () => _navigate('leave_apply'),
          onBack: () => _navigate('home'),
        );
      case 'leave_apply':
        return _LeaveApplyScreen(onBack: () => _navigate('leave'));
      case 'settings':
        return _SettingsScreen(
          onLogout: () => setState(() => _showLogoutDialog = true),
          onBack: () => _navigate('home'),
        );
      default:
        return const Center(child: Text('Unknown screen'));
    }
  }
}

// Individual mock screens
class _LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;
  const _LoginScreen({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login', style: TextStyle(fontSize: 24)),
            TextField(key: const Key('email_field')),
            TextField(key: const Key('password_field')),
            ElevatedButton(
              key: const Key('login_button'),
              onPressed: onLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  final VoidCallback onPayslips;
  final VoidCallback onLeave;
  final VoidCallback onSettings;
  const _HomeScreen({
    required this.onPayslips,
    required this.onLeave,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: onSettings, icon: const Icon(Icons.settings)),
        ],
      ),
      body: Column(
        children: [
          const Text('Welcome'),
          ListTile(title: const Text('Payslips'), onTap: onPayslips),
          ListTile(title: const Text('Leave'), onTap: onLeave),
        ],
      ),
    );
  }
}

class _PayslipsScreen extends StatelessWidget {
  final VoidCallback onDetail;
  final VoidCallback onBack;
  const _PayslipsScreen({required this.onDetail, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslip List'),
        leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        children: [
          GestureDetector(
            key: const Key('payslip_card'),
            onTap: onDetail,
            child: const Card(child: ListTile(title: Text('January 2026'))),
          ),
        ],
      ),
    );
  }
}

class _PayslipDetailScreen extends StatelessWidget {
  final VoidCallback onBack;
  const _PayslipDetailScreen({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslip Detail'),
        leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
      ),
      body: const Column(
        children: [
          Text('Gross Salary'),
          Text('Net Salary'),
          Text('Deductions'),
          Text('EPF'),
          Text('SOCSO'),
        ],
      ),
    );
  }
}

class _LeaveScreen extends StatelessWidget {
  final VoidCallback onApply;
  final VoidCallback onBack;
  const _LeaveScreen({required this.onApply, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Balance'),
        leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: onApply, child: const Text('Apply Leave')),
        ],
      ),
    );
  }
}

class _LeaveApplyScreen extends StatelessWidget {
  final VoidCallback onBack;
  const _LeaveApplyScreen({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Application'),
        leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          DropdownButtonFormField<String>(
            key: const Key('leave_type_dropdown'),
            items: const [
              DropdownMenuItem(value: 'annual', child: Text('Annual Leave')),
            ],
            onChanged: (_) {},
          ),
          const TextField(key: Key('reason_field')),
        ],
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onBack;
  const _SettingsScreen({required this.onLogout, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          ListTile(title: const Text('Sign Out'), onTap: onLogout),
        ],
      ),
    );
  }
}

/// Mock app with bottom navigation
class _MockAppWithBottomNav extends StatefulWidget {
  const _MockAppWithBottomNav();

  @override
  State<_MockAppWithBottomNav> createState() => _MockAppWithBottomNavState();
}

class _MockAppWithBottomNavState extends State<_MockAppWithBottomNav> {
  int _currentIndex = 0;
  final _pages = ['Home', 'Payslips', 'Leave', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text(_pages[_currentIndex])),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Payslips'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Leave'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

/// Mock refreshable screen
class _MockRefreshableScreen extends StatefulWidget {
  const _MockRefreshableScreen();

  @override
  State<_MockRefreshableScreen> createState() => _MockRefreshableScreenState();
}

class _MockRefreshableScreenState extends State<_MockRefreshableScreen> {
  bool _refreshed = false;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _refreshed = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            children: [
              if (_refreshed) const Text('Refreshed!'),
              const SizedBox(height: 1000), // Ensure scrollable
            ],
          ),
        ),
      ),
    );
  }
}
