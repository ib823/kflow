import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/biometric_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/biometric_prompt.dart';
import '../widgets/pin_pad.dart';

/// S-003: PIN Entry Screen
///
/// Features:
/// - 6-digit PIN entry with dots visualization
/// - Biometric authentication option
/// - Lockout after 5 failed attempts (15 min)
/// - Shake animation on error
/// - Logout option
class PinEntryScreen extends ConsumerStatefulWidget {
  /// Purpose of PIN verification
  final String purpose;

  /// Whether to show logout option
  final bool showLogout;

  const PinEntryScreen({
    super.key,
    this.purpose = 'app_unlock',
    this.showLogout = true,
  });

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // Reset PIN entry state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pinEntryProvider.notifier).clear();
      _checkBiometric();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final biometricEnabled = await ref.read(isBiometricEnabledProvider.future);
    if (biometricEnabled && mounted) {
      setState(() => _showBiometric = true);
      // Auto-trigger biometric
      _onBiometricPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pinState = ref.watch(pinEntryProvider);
    final biometricAvailable = ref.watch(biometricAvailableProvider);

    // Listen for auth state changes
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next is AuthAuthenticated) {
        context.go('/dashboard');
      }
    });

    // Get biometric type for icon
    final biometricType = biometricAvailable.valueOrNull == true
        ? ref.watch(primaryBiometricTypeProvider).valueOrNull
        : null;

    BiometricIconType iconType = BiometricIconType.fingerprint;
    if (biometricType == BiometricType.faceId) {
      iconType = BiometricIconType.faceId;
    } else if (biometricType == BiometricType.iris) {
      iconType = BiometricIconType.iris;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Logout option
              if (widget.showLogout)
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _onLogout,
                    child: const Text('Sign Out'),
                  ),
                ),

              const Spacer(),

              // User avatar and name
              _buildUserInfo(theme),

              const SizedBox(height: 32),

              // Title
              Text(
                'Enter Your PIN',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                _getSubtitle(pinState),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: pinState.error != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // PIN dots with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: PinDots(
                  enteredCount: pinState.pin.length,
                  hasError: pinState.error != null,
                ),
              ),

              const Spacer(),

              // Lockout message
              if (pinState.isLockedOut) ...[
                _buildLockoutMessage(theme),
                const SizedBox(height: 32),
              ],

              // PIN pad
              PinPad(
                onDigitPressed: _onDigitPressed,
                onBackspacePressed: _onBackspacePressed,
                onBiometricPressed: _showBiometric ? _onBiometricPressed : null,
                showBiometric: _showBiometric,
                biometricType: iconType,
                disabled: pinState.isLoading || pinState.isLockedOut,
              ),

              const SizedBox(height: 24),

              // Forgot PIN
              TextButton(
                onPressed: _onForgotPin,
                child: const Text('Forgot PIN?'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    final authState = ref.watch(authNotifierProvider);
    String name = 'User';

    if (authState is AuthPinRequired) {
      name = authState.employee.fullName;
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getSubtitle(PinEntryState state) {
    if (state.error != null) {
      return state.error!;
    }
    if (state.isLockedOut) {
      return 'Too many failed attempts';
    }
    if (state.attempts > 0) {
      return '${state.remainingAttempts} attempts remaining';
    }
    return 'Enter your 6-digit PIN';
  }

  Widget _buildLockoutMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_clock,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Locked',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Please wait 15 minutes or contact HR',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onDigitPressed(String digit) {
    final pinNotifier = ref.read(pinEntryProvider.notifier);
    final pinState = ref.read(pinEntryProvider);

    if (pinState.isLockedOut) return;

    pinNotifier.addDigit(digit);
    pinNotifier.setError(null);

    // Check if PIN is complete
    if (pinState.pin.length == 5) {
      // After this digit, PIN will be complete
      Future.delayed(const Duration(milliseconds: 200), () {
        _verifyPin();
      });
    }
  }

  void _onBackspacePressed() {
    ref.read(pinEntryProvider.notifier).removeDigit();
    ref.read(pinEntryProvider.notifier).setError(null);
  }

  Future<void> _verifyPin() async {
    final pinNotifier = ref.read(pinEntryProvider.notifier);
    final pinState = ref.read(pinEntryProvider);

    pinNotifier.setLoading(true);

    final success = await ref.read(authNotifierProvider.notifier).verifyPin(
          pinState.pin,
          purpose: widget.purpose,
        );

    if (!mounted) return;

    pinNotifier.setLoading(false);

    if (!success) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      pinNotifier.incrementAttempts();
      pinNotifier.setError('Incorrect PIN');
    }
  }

  Future<void> _onBiometricPressed() async {
    final success =
        await ref.read(authNotifierProvider.notifier).authenticateWithBiometric();

    if (!success && mounted) {
      // Biometric failed, user can still use PIN
    }
  }

  void _onForgotPin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text(
          'To reset your PIN, please sign out and log in again with your email and password. '
          'You will be prompted to set up a new PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _onLogout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _onLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }
}
