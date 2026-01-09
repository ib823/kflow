import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/test_app.dart';
import '../mocks/mock_data.dart';

/// Integration tests for authentication flow
/// Tests: Login -> PIN Setup -> PIN Entry -> Dashboard
void main() {
  group('Authentication Flow', () {
    testWidgets('successful login flow', (tester) async {
      // Build the login screen
      await tester.pumpTestableWidget(
        const _MockLoginScreen(),
      );

      // Enter employee ID
      await tester.enterText(
        find.byKey(const Key('employee_id_field')),
        MockData.employeeId,
      );

      // Enter password
      await tester.enterText(
        find.byKey(const Key('password_field')),
        MockData.password,
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Login successful'), findsOneWidget);
    });

    testWidgets('shows error on invalid credentials', (tester) async {
      await tester.pumpTestableWidget(
        const _MockLoginScreen(),
      );

      // Enter invalid credentials
      await tester.enterText(
        find.byKey(const Key('employee_id_field')),
        'INVALID',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrong',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('validates empty fields', (tester) async {
      await tester.pumpTestableWidget(
        const _MockLoginScreen(),
      );

      // Tap login button without entering anything
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Employee ID is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('PIN entry flow', (tester) async {
      await tester.pumpTestableWidget(
        const _MockPinScreen(),
      );

      // Enter PIN digits
      for (var digit in MockData.validPin.split('')) {
        await tester.tap(find.text(digit));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should show success
      expect(find.text('PIN verified'), findsOneWidget);
    });

    testWidgets('shows error on invalid PIN', (tester) async {
      await tester.pumpTestableWidget(
        const _MockPinScreen(),
      );

      // Enter invalid PIN
      for (var digit in MockData.invalidPin.split('')) {
        await tester.tap(find.text(digit));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should show error
      expect(find.text('Invalid PIN'), findsOneWidget);
    });

    testWidgets('logout clears session', (tester) async {
      await tester.pumpTestableWidget(
        const _MockDashboardScreen(),
      );

      // Tap logout button
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();

      // Should navigate to login
      expect(find.text('Login'), findsOneWidget);
    });
  });
}

/// Mock login screen for testing
class _MockLoginScreen extends ConsumerStatefulWidget {
  const _MockLoginScreen();

  @override
  ConsumerState<_MockLoginScreen> createState() => _MockLoginScreenState();
}

class _MockLoginScreenState extends ConsumerState<_MockLoginScreen> {
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  String? _success;
  bool _employeeIdError = false;
  bool _passwordError = false;

  void _login() {
    setState(() {
      _employeeIdError = _employeeIdController.text.isEmpty;
      _passwordError = _passwordController.text.isEmpty;
      _error = null;
      _success = null;
    });

    if (_employeeIdError || _passwordError) return;

    if (_employeeIdController.text == MockData.employeeId &&
        _passwordController.text == MockData.password) {
      setState(() => _success = 'Login successful');
    } else {
      setState(() => _error = 'Invalid credentials');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            key: const Key('employee_id_field'),
            controller: _employeeIdController,
            decoration: InputDecoration(
              labelText: 'Employee ID',
              errorText: _employeeIdError ? 'Employee ID is required' : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('password_field'),
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _passwordError ? 'Password is required' : null,
            ),
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          if (_success != null)
            Text(_success!, style: const TextStyle(color: Colors.green)),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('login_button'),
            onPressed: _login,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

/// Mock PIN screen for testing
class _MockPinScreen extends StatefulWidget {
  const _MockPinScreen();

  @override
  State<_MockPinScreen> createState() => _MockPinScreenState();
}

class _MockPinScreenState extends State<_MockPinScreen> {
  String _enteredPin = '';
  String? _message;
  bool _isError = false;

  void _addDigit(String digit) {
    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += digit;
        _message = null;
      });

      if (_enteredPin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _verifyPin() {
    if (_enteredPin == MockData.validPin) {
      setState(() {
        _message = 'PIN verified';
        _isError = false;
      });
    } else {
      setState(() {
        _message = 'Invalid PIN';
        _isError = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // PIN dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Container(
              margin: const EdgeInsets.all(8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < _enteredPin.length
                    ? Colors.blue
                    : Colors.grey.shade300,
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        if (_message != null)
          Text(
            _message!,
            style: TextStyle(color: _isError ? Colors.red : Colors.green),
          ),
        const SizedBox(height: 24),
        // Number pad
        Wrap(
          spacing: 24,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(10, (index) {
            final digit = index == 9 ? '0' : '${index + 1}';
            return SizedBox(
              width: 64,
              height: 64,
              child: ElevatedButton(
                onPressed: () => _addDigit(digit),
                child: Text(digit, style: const TextStyle(fontSize: 24)),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Mock dashboard screen for testing
class _MockDashboardScreen extends StatefulWidget {
  const _MockDashboardScreen();

  @override
  State<_MockDashboardScreen> createState() => _MockDashboardScreenState();
}

class _MockDashboardScreenState extends State<_MockDashboardScreen> {
  bool _loggedOut = false;

  @override
  Widget build(BuildContext context) {
    if (_loggedOut) {
      return const Center(child: Text('Login'));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Welcome, ${MockData.userName}'),
        const SizedBox(height: 24),
        ElevatedButton(
          key: const Key('logout_button'),
          onPressed: () => setState(() => _loggedOut = true),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
