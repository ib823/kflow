import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/biometric_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_pad.dart';

/// S-002: PIN Setup Screen
///
/// Features:
/// - 6-digit PIN entry with visual feedback
/// - PIN confirmation step
/// - Biometric enrollment option
/// - Animated transitions between steps
/// - Clear error messaging
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  @override
  void initState() {
    super.initState();
    // Reset PIN setup state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pinSetupProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final setupState = ref.watch(pinSetupProvider);
    final biometricAvailable = ref.watch(biometricAvailableProvider);

    // Listen for auth state changes
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next is AuthAuthenticated) {
        context.go('/dashboard');
      } else if (next is AuthError) {
        ref.read(pinSetupProvider.notifier).setError(next.message);
        ref.read(pinSetupProvider.notifier).setLoading(false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up PIN'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStep(theme, setupState, biometricAvailable),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(
    ThemeData theme,
    PinSetupState setupState,
    AsyncValue<bool> biometricAvailable,
  ) {
    switch (setupState.step) {
      case PinSetupStep.enterPin:
        return _buildEnterPinStep(theme, setupState);
      case PinSetupStep.confirmPin:
        return _buildConfirmPinStep(theme, setupState);
      case PinSetupStep.enableBiometric:
        return _buildBiometricStep(theme, setupState, biometricAvailable);
    }
  }

  Widget _buildEnterPinStep(ThemeData theme, PinSetupState setupState) {
    return Column(
      key: const ValueKey('enter_pin'),
      children: [
        const Spacer(),

        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          'Create Your PIN',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Enter a 6-digit PIN to secure your account',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 48),

        // PIN dots
        PinDots(
          enteredCount: setupState.pin.length,
          hasError: setupState.error != null,
        ),

        // Error message
        if (setupState.error != null) ...[
          const SizedBox(height: 16),
          Text(
            setupState.error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const Spacer(),

        // PIN pad
        PinPad(
          onDigitPressed: _onDigitPressed,
          onBackspacePressed: _onBackspacePressed,
          disabled: setupState.isLoading,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildConfirmPinStep(ThemeData theme, PinSetupState setupState) {
    return Column(
      key: const ValueKey('confirm_pin'),
      children: [
        const Spacer(),

        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          'Confirm Your PIN',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Enter your PIN again to confirm',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 48),

        // PIN dots
        PinDots(
          enteredCount: setupState.confirmPin.length,
          hasError: setupState.error != null,
        ),

        // Error message
        if (setupState.error != null) ...[
          const SizedBox(height: 16),
          Text(
            setupState.error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const Spacer(),

        // Back button
        TextButton.icon(
          onPressed: _onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Start Over'),
        ),

        const SizedBox(height: 16),

        // PIN pad
        PinPad(
          onDigitPressed: _onDigitPressed,
          onBackspacePressed: _onBackspacePressed,
          disabled: setupState.isLoading,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBiometricStep(
    ThemeData theme,
    PinSetupState setupState,
    AsyncValue<bool> biometricAvailable,
  ) {
    final available = biometricAvailable.valueOrNull ?? false;

    return Column(
      key: const ValueKey('biometric'),
      children: [
        const Spacer(),

        // Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.fingerprint,
            size: 56,
            color: theme.colorScheme.primary,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          'Enable Biometric Login',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          available
              ? 'Use your fingerprint or face to unlock the app quickly'
              : 'Biometric authentication is not available on this device',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const Spacer(),

        if (available) ...[
          // Enable biometric button
          FilledButton(
            onPressed: () => _onEnableBiometric(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: setupState.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Enable Biometric'),
          ),

          const SizedBox(height: 16),
        ],

        // Skip button
        OutlinedButton(
          onPressed: setupState.isLoading ? null : () => _onEnableBiometric(false),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(available ? 'Skip for Now' : 'Continue'),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  void _onDigitPressed(String digit) {
    final setupNotifier = ref.read(pinSetupProvider.notifier);
    final setupState = ref.read(pinSetupProvider);

    setupNotifier.addDigit(digit);
    setupNotifier.setError(null);

    // Check if PIN is complete
    if (setupState.step == PinSetupStep.enterPin && setupState.pin.length == 5) {
      // After this digit, PIN will be complete
      Future.delayed(const Duration(milliseconds: 200), () {
        setupNotifier.setStep(PinSetupStep.confirmPin);
      });
    } else if (setupState.step == PinSetupStep.confirmPin &&
        setupState.confirmPin.length == 5) {
      // After this digit, confirm PIN will be complete
      Future.delayed(const Duration(milliseconds: 200), () {
        _validatePins();
      });
    }
  }

  void _onBackspacePressed() {
    ref.read(pinSetupProvider.notifier).removeDigit();
    ref.read(pinSetupProvider.notifier).setError(null);
  }

  void _onBack() {
    ref.read(pinSetupProvider.notifier).clear();
  }

  void _validatePins() {
    final setupNotifier = ref.read(pinSetupProvider.notifier);
    final setupState = ref.read(pinSetupProvider);

    if (setupState.pin != setupState.confirmPin) {
      setupNotifier.setError('PINs do not match. Please try again.');
      setupNotifier.setStep(PinSetupStep.enterPin);
      setupNotifier.setPin('');
      setupNotifier.setConfirmPin('');
      return;
    }

    // Check for weak PINs
    if (_isWeakPin(setupState.pin)) {
      setupNotifier.setError('PIN is too simple. Avoid repeating or sequential digits.');
      setupNotifier.setStep(PinSetupStep.enterPin);
      setupNotifier.setPin('');
      setupNotifier.setConfirmPin('');
      return;
    }

    // Move to biometric step
    setupNotifier.setStep(PinSetupStep.enableBiometric);
  }

  bool _isWeakPin(String pin) {
    // Check for repeating digits (111111, 222222, etc.)
    if (pin.split('').toSet().length == 1) return true;

    // Check for sequential digits (123456, 654321)
    const ascending = '0123456789';
    const descending = '9876543210';
    if (ascending.contains(pin) || descending.contains(pin)) return true;

    // Check for common weak PINs
    const weakPins = ['000000', '123456', '654321', '111111', '123123'];
    if (weakPins.contains(pin)) return true;

    return false;
  }

  void _onEnableBiometric(bool enable) {
    final setupNotifier = ref.read(pinSetupProvider.notifier);
    final setupState = ref.read(pinSetupProvider);

    setupNotifier.setEnableBiometric(enable);
    setupNotifier.setLoading(true);

    ref.read(authNotifierProvider.notifier).setupPin(
          pin: setupState.pin,
          confirmPin: setupState.confirmPin,
          enableBiometric: enable,
        );
  }
}
