import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/secure_screen_mixin.dart';
import '../../../../shared/theme/app_theme.dart';

/// PIN entry steps
enum PinEntryStep {
  current,
  newPin,
  confirm,
}

/// S-082: Change PIN Screen
///
/// Secure PIN change with:
/// - FLAG_SECURE enabled
/// - Current PIN verification
/// - New PIN with weak PIN detection
/// - PIN pad UI
class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen>
    with SecureScreenMixin {
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  PinEntryStep _step = PinEntryStep.current;
  String? _error;
  bool _isSubmitting = false;

  // Weak PINs to reject
  static const List<String> _weakPins = [
    '123456', '654321', '012345', '543210',
    '000000', '111111', '222222', '333333',
    '444444', '555555', '666666', '777777',
    '888888', '999999', '123123', '121212',
    '112233', '332211', '101010', '010101',
    '123321', '456654', '789987',
  ];

  @override
  void initState() {
    super.initState();
    enableSecureScreen(); // FLAG_SECURE - prevent screenshots
  }

  @override
  void dispose() {
    disableSecureScreen();
    super.dispose();
  }

  String get _currentEnteredPin {
    switch (_step) {
      case PinEntryStep.current:
        return _currentPin;
      case PinEntryStep.newPin:
        return _newPin;
      case PinEntryStep.confirm:
        return _confirmPin;
    }
  }

  bool _isWeakPin(String pin) {
    // Check known weak patterns
    if (_weakPins.contains(pin)) return true;

    // Check for year patterns (19XX, 20XX)
    if (RegExp(r'^(19|20)\d{4}$').hasMatch(pin)) return true;

    // Check if all digits are the same
    if (pin.split('').toSet().length == 1) return true;

    // Check for sequential patterns
    final digits = pin.split('').map(int.parse).toList();
    bool isAscending = true;
    bool isDescending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) isAscending = false;
      if (digits[i] != digits[i - 1] - 1) isDescending = false;
    }
    if (isAscending || isDescending) return true;

    return false;
  }

  void _onDigitPressed(String digit) {
    setState(() {
      _error = null;
      switch (_step) {
        case PinEntryStep.current:
          if (_currentPin.length < 6) {
            _currentPin += digit;
            if (_currentPin.length == 6) {
              _validateCurrentPin();
            }
          }
          break;
        case PinEntryStep.newPin:
          if (_newPin.length < 6) {
            _newPin += digit;
            if (_newPin.length == 6) {
              _validateNewPin();
            }
          }
          break;
        case PinEntryStep.confirm:
          if (_confirmPin.length < 6) {
            _confirmPin += digit;
            if (_confirmPin.length == 6) {
              _validateConfirmPin();
            }
          }
          break;
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      _error = null;
      switch (_step) {
        case PinEntryStep.current:
          if (_currentPin.isNotEmpty) {
            _currentPin = _currentPin.substring(0, _currentPin.length - 1);
          }
          break;
        case PinEntryStep.newPin:
          if (_newPin.isNotEmpty) {
            _newPin = _newPin.substring(0, _newPin.length - 1);
          }
          break;
        case PinEntryStep.confirm:
          if (_confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
          break;
      }
    });
  }

  void _validateCurrentPin() {
    // In a real app, verify current PIN with API
    // For demo, accept any 6-digit PIN
    setState(() {
      _step = PinEntryStep.newPin;
    });
  }

  void _validateNewPin() {
    if (_isWeakPin(_newPin)) {
      setState(() {
        _error = 'This PIN is too weak. Please choose a stronger PIN.';
        _newPin = '';
      });
    } else if (_newPin == _currentPin) {
      setState(() {
        _error = 'New PIN cannot be the same as current PIN';
        _newPin = '';
      });
    } else {
      setState(() {
        _step = PinEntryStep.confirm;
      });
    }
  }

  void _validateConfirmPin() {
    if (_confirmPin != _newPin) {
      setState(() {
        _error = 'PINs do not match. Please try again.';
        _confirmPin = '';
      });
    } else {
      _submitPinChange();
    }
  }

  Future<void> _submitPinChange() async {
    setState(() => _isSubmitting = true);

    try {
      // Simulate API call: POST /api/v1/auth/change-pin
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Show biometric re-enrollment prompt
        await _showBiometricPrompt();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN changed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to change PIN: ${e.toString()}';
        _confirmPin = '';
        _isSubmitting = false;
      });
    }
  }

  Future<void> _showBiometricPrompt() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.fingerprint, size: 48, color: AppColors.primary),
        title: const Text('Re-enroll Biometrics'),
        content: const Text(
          'Since you changed your PIN, you may need to re-enable biometric authentication for app unlock.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to biometric setup
            },
            child: const Text('Enable Now'),
          ),
        ],
      ),
    );
  }

  void _goBack() {
    setState(() {
      _error = null;
      switch (_step) {
        case PinEntryStep.current:
          context.pop();
          break;
        case PinEntryStep.newPin:
          _newPin = '';
          _step = PinEntryStep.current;
          break;
        case PinEntryStep.confirm:
          _confirmPin = '';
          _step = PinEntryStep.newPin;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change PIN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Security notice
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: AppColors.info, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Screen capture is disabled for your security',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Step indicator
            _buildStepIndicator(),

            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              _getStepTitle(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              _getStepSubtitle(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // PIN dots
            _buildPinDots(),

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // PIN pad
            if (!_isSubmitting) _buildPinPad(),

            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: CircularProgressIndicator(),
              ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot(0, _step.index >= 0),
        Container(
          width: 40,
          height: 2,
          color: _step.index >= 1 ? AppColors.primary : AppColors.divider,
        ),
        _buildStepDot(1, _step.index >= 1),
        Container(
          width: 40,
          height: 2,
          color: _step.index >= 2 ? AppColors.primary : AppColors.divider,
        ),
        _buildStepDot(2, _step.index >= 2),
      ],
    );
  }

  Widget _buildStepDot(int index, bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.divider,
        shape: BoxShape.circle,
      ),
    );
  }

  String _getStepTitle() {
    switch (_step) {
      case PinEntryStep.current:
        return 'Enter Current PIN';
      case PinEntryStep.newPin:
        return 'Enter New PIN';
      case PinEntryStep.confirm:
        return 'Confirm New PIN';
    }
  }

  String _getStepSubtitle() {
    switch (_step) {
      case PinEntryStep.current:
        return 'Enter your current 6-digit PIN';
      case PinEntryStep.newPin:
        return 'Choose a new 6-digit PIN';
      case PinEntryStep.confirm:
        return 'Enter your new PIN again';
    }
  }

  Widget _buildPinDots() {
    final pin = _currentEnteredPin;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < pin.length;
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isFilled ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isFilled ? AppColors.primary : AppColors.textSecondary,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildPinPad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3'].map(_buildPinButton).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6'].map(_buildPinButton).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9'].map(_buildPinButton).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72, height: 72), // Empty space
              _buildPinButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinButton(String digit) {
    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            digit,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: _onBackspacePressed,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined, size: 28),
        ),
      ),
    );
  }
}
