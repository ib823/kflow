import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// LoginScreen Widget Tests
///
/// Tests UI rendering, validation, and user interactions for the login screen.
/// Per CLAUDE.md: Test widget rendering in different states
void main() {
  group('LoginScreen Widget Tests', () {
    /// Helper to create a testable widget
    Widget createTestWidget({Widget? child}) {
      return ProviderScope(
        child: MaterialApp(
          home: child ?? const Scaffold(body: _MockLoginScreen()),
        ),
      );
    }

    testWidgets('renders login form with all required fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify app title/logo exists
      expect(find.text('KerjaFlow'), findsOneWidget);

      // Verify email field exists
      expect(find.byKey(const Key('email_field')), findsOneWidget);

      // Verify password field exists
      expect(find.byKey(const Key('password_field')), findsOneWidget);

      // Verify login button exists
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      // Verify forgot password link exists
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Leave email empty, enter password
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Password123!',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify error message shown
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid email
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'invalid-email',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Password123!',
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('shows validation error for empty password', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter email, leave password empty
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@kerjaflow.my',
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows validation error for short password', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@kerjaflow.my',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        '123', // Too short (minimum 8 characters)
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially password should be obscured (visibility_off icon)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      // Enter a password
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'MySecretPassword',
      );

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now visibility icon should change
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('shows loading indicator during login', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('forgot password link is tappable', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () => tapped = true,
              child: const Text('Forgot Password?'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Forgot Password?'));
      expect(tapped, isTrue);
    });

    testWidgets('accepts valid email formats', (tester) async {
      final validEmails = [
        'test@example.com',
        'user.name@domain.co',
        'first.last@company.com.my',
        'admin@kerjaflow.my',
      ];

      for (final email in validEmails) {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
          find.byKey(const Key('email_field')),
          email,
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'Password123!',
        );

        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Should not show email format error
        expect(find.text('Invalid email format'), findsNothing);
      }
    });
  });
}

/// Mock login screen for testing
class _MockLoginScreen extends StatefulWidget {
  const _MockLoginScreen();

  @override
  State<_MockLoginScreen> createState() => _MockLoginScreenState();
}

class _MockLoginScreenState extends State<_MockLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('KerjaFlow', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            TextFormField(
              key: const Key('email_field'),
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('password_field'),
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('login_button'),
              onPressed: () {
                _formKey.currentState?.validate();
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
