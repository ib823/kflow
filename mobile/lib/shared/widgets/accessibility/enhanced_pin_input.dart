import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced PIN input widget for low-literacy users
/// Research-backed improvements (WCAG 2.2, Medhi et al. 2011):
/// - 24dp dots (vs 16dp standard) for calloused hands
/// - 72dp number pad buttons for touch accuracy
/// - Haptic feedback on each digit
/// - Full screen reader accessibility
/// - High contrast focus indicators
class EnhancedPinInput extends StatefulWidget {
  final int pinLength;
  final ValueChanged<String> onCompleted;
  final VoidCallback? onBiometricPressed;
  final bool enableHaptic;
  final bool showBiometricOption;
  final String? errorMessage;

  const EnhancedPinInput({
    super.key,
    this.pinLength = 6,
    required this.onCompleted,
    this.onBiometricPressed,
    this.enableHaptic = true,
    this.showBiometricOption = false,
    this.errorMessage,
  });

  @override
  State<EnhancedPinInput> createState() => _EnhancedPinInputState();
}

class _EnhancedPinInputState extends State<EnhancedPinInput>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // WCAG 2.2 minimum: 24x24 CSS pixels
  // For low-literacy/calloused hands: 24dp MINIMUM
  static const double _pinDotSize = 24.0;
  static const double _pinDotSpacing = 16.0;

  // Touch target: 72dp for industrial workers (above 48dp minimum)
  static const double _buttonSize = 72.0;
  static const double _buttonSpacing = 12.0;

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
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EnhancedPinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null && oldWidget.errorMessage == null) {
      _shakeController.forward().then((_) => _shakeController.reset());
      setState(() => _enteredPin = '');
    }
  }

  void _onDigitEntered(String digit) {
    if (_enteredPin.length >= widget.pinLength) return;

    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _enteredPin += digit;
    });

    // Announce to screen readers
    SemanticsService.announce(
      'Digit entered. ${_enteredPin.length} of ${widget.pinLength}',
      TextDirection.ltr,
    );

    if (_enteredPin.length == widget.pinLength) {
      widget.onCompleted(_enteredPin);
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;

    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });

    SemanticsService.announce(
      'Digit deleted. ${_enteredPin.length} of ${widget.pinLength}',
      TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // PIN Dots Row
          Semantics(
            label: 'PIN entry. ${_enteredPin.length} of ${widget.pinLength} digits entered.',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pinLength, (index) {
                final isFilled = index < _enteredPin.length;
                final isNext = index == _enteredPin.length;

                return Semantics(
                  label: 'PIN digit ${index + 1} of ${widget.pinLength}. ${isFilled ? "Entered" : "Empty"}',
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: _pinDotSpacing / 2),
                    width: _pinDotSize,
                    height: _pinDotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.errorMessage != null
                            ? theme.colorScheme.error
                            : isNext
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                        width: isNext ? 3.0 : 2.0,
                      ),
                      boxShadow: isFilled
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),

          // Error message
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 32),

          // Number Pad
          _buildNumberPad(theme),

          // Biometric option
          if (widget.showBiometricOption && widget.onBiometricPressed != null) ...[
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: widget.onBiometricPressed,
              icon: const Icon(Icons.fingerprint_rounded, size: 24),
              label: const Text('Use fingerprint instead'),
              style: TextButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNumberPad(ThemeData theme) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'DEL'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: _buttonSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((digit) {
              if (digit.isEmpty) {
                return SizedBox(width: _buttonSize, height: _buttonSize);
              }

              final isDelete = digit == 'DEL';

              return Semantics(
                button: true,
                label: isDelete ? 'Delete last digit' : 'Digit $digit',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _buttonSpacing / 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => isDelete ? _onBackspace() : _onDigitEntered(digit),
                      borderRadius: BorderRadius.circular(_buttonSize / 2),
                      child: Container(
                        width: _buttonSize,
                        height: _buttonSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: isDelete
                              ? Icon(
                                  Icons.backspace_outlined,
                                  size: 28,
                                  color: theme.colorScheme.onSurfaceVariant,
                                )
                              : Text(
                                  digit,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
