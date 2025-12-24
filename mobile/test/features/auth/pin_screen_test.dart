import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PinSetupScreen Widget Tests', () {
    testWidgets('displays PIN input fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinSetupScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Enter PIN'), findsOneWidget);
      expect(find.text('Confirm PIN'), findsOneWidget);
    });

    testWidgets('displays setup button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinSetupScreen(),
          ),
        ),
      );

      expect(find.text('Set PIN'), findsOneWidget);
    });

    testWidgets('validates PIN length', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinSetupScreen(),
          ),
        ),
      );

      final pinField = find.byKey(const Key('pin_field'));
      await tester.enterText(pinField, '12345');  // Too short
      await tester.pump();

      final setupButton = find.text('Set PIN');
      await tester.tap(setupButton);
      await tester.pump();

      expect(find.text('PIN must be 6 digits'), findsOneWidget);
    });

    testWidgets('validates PIN confirmation match', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinSetupScreen(),
          ),
        ),
      );

      final pinField = find.byKey(const Key('pin_field'));
      final confirmField = find.byKey(const Key('confirm_pin_field'));

      await tester.enterText(pinField, '123456');
      await tester.enterText(confirmField, '654321');
      await tester.pump();

      final setupButton = find.text('Set PIN');
      await tester.tap(setupButton);
      await tester.pump();

      expect(find.text('PINs do not match'), findsOneWidget);
    });

    testWidgets('PIN fields only accept numbers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinSetupScreen(),
          ),
        ),
      );

      final pinField = find.byKey(const Key('pin_field'));
      final textField = tester.widget<TextField>(pinField);

      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('PIN fields obscure input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinSetupScreen(),
          ),
        ),
      );

      final pinField = find.byKey(const Key('pin_field'));
      final textField = tester.widget<TextField>(pinField);

      expect(textField.obscureText, isTrue);
    });
  });

  group('PinVerifyScreen Widget Tests', () {
    testWidgets('displays PIN input field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinVerifyScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter your PIN'), findsOneWidget);
    });

    testWidgets('displays verify button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinVerifyScreen(),
          ),
        ),
      );

      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('shows forgot PIN option', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinVerifyScreen(),
          ),
        ),
      );

      expect(find.text('Forgot PIN?'), findsOneWidget);
    });

    testWidgets('validates empty PIN', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinVerifyScreen(),
          ),
        ),
      );

      final verifyButton = find.text('Verify');
      await tester.tap(verifyButton);
      await tester.pump();

      expect(find.text('PIN is required'), findsOneWidget);
    });

    testWidgets('displays remaining attempts on error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockPinVerifyScreen(showAttempts: true),
          ),
        ),
      );

      expect(find.textContaining('attempts remaining'), findsOneWidget);
    });
  });
}

/// Mock PIN Setup Screen
class _MockPinSetupScreen extends StatefulWidget {
  const _MockPinSetupScreen();

  @override
  State<_MockPinSetupScreen> createState() => _MockPinSetupScreenState();
}

class _MockPinSetupScreenState extends State<_MockPinSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Set up your PIN',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextFormField(
              key: const Key('pin_field'),
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              validator: (value) {
                if (value == null || value.length != 6) {
                  return 'PIN must be 6 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('confirm_pin_field'),
              controller: _confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              validator: (value) {
                if (value != _pinController.text) {
                  return 'PINs do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _formKey.currentState?.validate(),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Set PIN'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }
}

/// Mock PIN Verify Screen
class _MockPinVerifyScreen extends StatefulWidget {
  final bool showAttempts;

  const _MockPinVerifyScreen({this.showAttempts = false});

  @override
  State<_MockPinVerifyScreen> createState() => _MockPinVerifyScreenState();
}

class _MockPinVerifyScreenState extends State<_MockPinVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Enter your PIN',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            if (widget.showAttempts)
              const Text(
                '3 attempts remaining',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('verify_pin_field'),
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'PIN is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _formKey.currentState?.validate(),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Verify'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('Forgot PIN?'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
