import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// PIN setup screen for first-time PIN creation
class PinSetupScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const PinSetupScreen({
    super.key,
    this.onComplete,
    this.onSkip,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;
  bool _isLoading = false;

  // Weak PINs that should be blocked
  static const List<String> _weakPins = [
    '000000',
    '111111',
    '222222',
    '333333',
    '444444',
    '555555',
    '666666',
    '777777',
    '888888',
    '999999',
    '123456',
    '654321',
    '012345',
    '123123',
  ];

  void _onPinEntered(String pin) {
    if (!_isConfirming) {
      // First entry - validate PIN strength
      if (_weakPins.contains(pin)) {
        setState(() {
          _errorMessage = 'PIN is too weak. Please choose a stronger PIN.';
          _pin = '';
        });
        return;
      }

      setState(() {
        _pin = pin;
        _isConfirming = true;
        _errorMessage = null;
      });
    } else {
      // Confirmation entry
      if (pin != _pin) {
        setState(() {
          _errorMessage = 'PINs do not match. Please try again.';
          _confirmPin = '';
          _isConfirming = false;
          _pin = '';
        });
        return;
      }

      _savePin(pin);
    }
  }

  Future<void> _savePin(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate API call to save PIN
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    // Success - navigate to next screen
    widget.onComplete?.call();
  }

  void _onReset() {
    setState(() {
      _pin = '';
      _confirmPin = '';
      _isConfirming = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup PIN'),
        actions: [
          if (widget.onSkip != null)
            TextButton(
              onPressed: widget.onSkip,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: SafeArea(
        child: KFLoadingOverlay(
          isLoading: _isLoading,
          message: 'Setting up your PIN...',
          child: Padding(
            padding: KFSpacing.screenPadding,
            child: Column(
              children: [
                const Spacer(),
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: KFColors.primary100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: KFColors.primary600,
                  ),
                ),
                const SizedBox(height: KFSpacing.space6),
                // Title
                Text(
                  _isConfirming ? 'Confirm Your PIN' : 'Create Your PIN',
                  style: const TextStyle(
                    fontSize: KFTypography.fontSize2xl,
                    fontWeight: KFTypography.bold,
                  ),
                ),
                const SizedBox(height: KFSpacing.space2),
                // Subtitle
                Text(
                  _isConfirming
                      ? 'Enter your PIN again to confirm'
                      : 'Choose a 6-digit PIN for quick access',
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeBase,
                    color: KFColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: KFSpacing.space8),
                // Error message
                if (_errorMessage != null) ...[
                  KFInfoBanner(
                    message: _errorMessage!,
                    backgroundColor: KFColors.error100,
                    textColor: KFColors.error700,
                    icon: Icons.error_outline,
                    onDismiss: () => setState(() => _errorMessage = null),
                  ),
                  const SizedBox(height: KFSpacing.space4),
                ],
                // PIN Entry
                KFPinEntry(
                  length: 6,
                  onCompleted: _onPinEntered,
                  onChanged: (pin) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
                const SizedBox(height: KFSpacing.space4),
                // Reset button (only in confirm mode)
                if (_isConfirming)
                  KFTextButton(
                    label: 'Start Over',
                    onPressed: _onReset,
                  ),
                const Spacer(flex: 2),
                // Security note
                Container(
                  padding: const EdgeInsets.all(KFSpacing.space4),
                  decoration: BoxDecoration(
                    color: KFColors.gray100,
                    borderRadius: KFRadius.radiusMd,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security,
                        size: KFIconSizes.md,
                        color: KFColors.gray600,
                      ),
                      const SizedBox(width: KFSpacing.space3),
                      Expanded(
                        child: Text(
                          'Your PIN is encrypted and stored securely on your device.',
                          style: TextStyle(
                            fontSize: KFTypography.fontSizeSm,
                            color: KFColors.gray600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
