import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Numeric PIN pad widget with haptic feedback.
///
/// Features:
/// - 3x4 numeric grid (1-9, 0)
/// - Biometric button (optional, bottom-left)
/// - Backspace button (bottom-right)
/// - Haptic feedback on tap
/// - Large touch targets (56dp minimum)
class PinPad extends StatelessWidget {
  /// Callback when a digit is pressed
  final void Function(String digit) onDigitPressed;

  /// Callback when backspace is pressed
  final VoidCallback onBackspacePressed;

  /// Callback when biometric button is pressed (optional)
  final VoidCallback? onBiometricPressed;

  /// Whether to show biometric button
  final bool showBiometric;

  /// Biometric type for icon selection
  final BiometricIconType biometricType;

  /// Whether the pad is disabled
  final bool disabled;

  const PinPad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
    this.biometricType = BiometricIconType.fingerprint,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildBottomRow(context),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => _buildDigitButton(digit)).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Biometric or empty space
        if (showBiometric && onBiometricPressed != null)
          _buildActionButton(
            icon: _getBiometricIcon(),
            onPressed: onBiometricPressed,
            semanticsLabel: 'Use biometric authentication',
          )
        else
          const SizedBox(width: 72, height: 72),

        // Zero digit
        _buildDigitButton('0'),

        // Backspace
        _buildActionButton(
          icon: Icons.backspace_outlined,
          onPressed: onBackspacePressed,
          semanticsLabel: 'Delete last digit',
        ),
      ],
    );
  }

  Widget _buildDigitButton(String digit) {
    return _PinButton(
      onPressed: disabled ? null : () => _onDigitTap(digit),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String semanticsLabel,
  }) {
    return _PinButton(
      onPressed: disabled ? null : onPressed,
      semanticsLabel: semanticsLabel,
      child: Icon(icon, size: 28),
    );
  }

  void _onDigitTap(String digit) {
    HapticFeedback.lightImpact();
    onDigitPressed(digit);
  }

  IconData _getBiometricIcon() {
    switch (biometricType) {
      case BiometricIconType.fingerprint:
        return Icons.fingerprint;
      case BiometricIconType.faceId:
        return Icons.face;
      case BiometricIconType.iris:
        return Icons.remove_red_eye_outlined;
    }
  }
}

/// PIN button with ripple effect and proper touch target
class _PinButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticsLabel;

  const _PinButton({
    required this.onPressed,
    required this.child,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: onPressed == null
                    ? theme.colorScheme.onSurface.withOpacity(0.38)
                    : theme.colorScheme.onSurface,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: onPressed == null
                      ? theme.colorScheme.onSurface.withOpacity(0.38)
                      : theme.colorScheme.onSurface,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Biometric icon types
enum BiometricIconType {
  fingerprint,
  faceId,
  iris,
}

/// PIN dots display showing entered digits
class PinDots extends StatelessWidget {
  /// Number of digits entered (0-6)
  final int enteredCount;

  /// Total number of dots (default 6)
  final int totalDots;

  /// Whether to show error state
  final bool hasError;

  /// Dot size
  final double dotSize;

  /// Spacing between dots
  final double spacing;

  const PinDots({
    super.key,
    required this.enteredCount,
    this.totalDots = 6,
    this.hasError = false,
    this.dotSize = 16,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (index) {
        final isFilled = index < enteredCount;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? theme.colorScheme.error
                : isFilled
                    ? theme.colorScheme.primary
                    : Colors.transparent,
            border: Border.all(
              color: hasError
                  ? theme.colorScheme.error
                  : isFilled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}
