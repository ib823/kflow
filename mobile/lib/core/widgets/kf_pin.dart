import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';

/// PIN display dots
class KFPinDisplay extends StatelessWidget {
  final int length;
  final int filled;
  final bool hasError;
  final bool obscured;

  const KFPinDisplay({
    super.key,
    this.length = 6,
    this.filled = 0,
    this.hasError = false,
    this.obscured = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filled;
        return AnimatedContainer(
          duration: KFAnimation.fast,
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? KFColors.error500
                : isFilled
                    ? KFColors.primary600
                    : Colors.transparent,
            border: Border.all(
              color: hasError
                  ? KFColors.error500
                  : isFilled
                      ? KFColors.primary600
                      : KFColors.gray300,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

/// PIN keypad
class KFPinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;
  final bool showBiometric;
  final bool enabled;

  const KFPinKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onBiometric,
    this.showBiometric = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: KFSpacing.space4),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: KFSpacing.space4),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: KFSpacing.space4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (showBiometric && onBiometric != null)
              _buildKey(
                child: const Icon(Icons.fingerprint, size: 28),
                onTap: enabled ? onBiometric : null,
              )
            else
              const SizedBox(width: 72),
            _buildDigitKey('0'),
            _buildKey(
              child: const Icon(Icons.backspace_outlined, size: 24),
              onTap: enabled ? onDelete : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitKey(d)).toList(),
    );
  }

  Widget _buildDigitKey(String digit) {
    return _buildKey(
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: KFTypography.medium,
        ),
      ),
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onDigit(digit);
            }
          : null,
    );
  }

  Widget _buildKey({required Widget child, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: KFRadius.radiusFull,
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

/// Complete PIN entry screen component
class KFPinEntry extends StatefulWidget {
  final int length;
  final String title;
  final String? subtitle;
  final ValueChanged<String> onComplete;
  final bool showBiometric;
  final VoidCallback? onBiometric;
  final String? error;

  const KFPinEntry({
    super.key,
    this.length = 6,
    required this.title,
    this.subtitle,
    required this.onComplete,
    this.showBiometric = false,
    this.onBiometric,
    this.error,
  });

  @override
  State<KFPinEntry> createState() => KFPinEntryState();
}

class KFPinEntryState extends State<KFPinEntry> {
  String _pin = '';

  void _onDigit(String digit) {
    if (_pin.length < widget.length) {
      setState(() => _pin += digit);
      if (_pin.length == widget.length) {
        widget.onComplete(_pin);
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void reset() {
    setState(() => _pin = '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: KFTypography.fontSize2xl,
            fontWeight: KFTypography.semibold,
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: KFSpacing.space2),
          Text(
            widget.subtitle!,
            style: const TextStyle(
              fontSize: KFTypography.fontSizeBase,
              color: KFColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: KFSpacing.space8),
        KFPinDisplay(
          length: widget.length,
          filled: _pin.length,
          hasError: widget.error != null,
        ),
        if (widget.error != null) ...[
          const SizedBox(height: KFSpacing.space4),
          Text(
            widget.error!,
            style: const TextStyle(
              fontSize: KFTypography.fontSizeSm,
              color: KFColors.error600,
            ),
          ),
        ],
        const SizedBox(height: KFSpacing.space10),
        KFPinKeypad(
          onDigit: _onDigit,
          onDelete: _onDelete,
          onBiometric: widget.onBiometric,
          showBiometric: widget.showBiometric,
        ),
      ],
    );
  }
}

/// PIN setup with confirmation
class KFPinSetup extends StatefulWidget {
  final String title;
  final String confirmTitle;
  final int length;
  final ValueChanged<String> onComplete;
  final String? Function(String)? validator;

  const KFPinSetup({
    super.key,
    this.title = 'Create PIN',
    this.confirmTitle = 'Confirm PIN',
    this.length = 6,
    required this.onComplete,
    this.validator,
  });

  @override
  State<KFPinSetup> createState() => _KFPinSetupState();
}

class _KFPinSetupState extends State<KFPinSetup> {
  String? _firstPin;
  String? _error;
  final _pinKey = GlobalKey<KFPinEntryState>();

  void _onPinComplete(String pin) {
    if (_firstPin == null) {
      // First PIN entry
      final validationError = widget.validator?.call(pin);
      if (validationError != null) {
        setState(() => _error = validationError);
        _pinKey.currentState?.reset();
        return;
      }

      setState(() {
        _firstPin = pin;
        _error = null;
      });
      _pinKey.currentState?.reset();
    } else {
      // Confirmation
      if (pin == _firstPin) {
        widget.onComplete(pin);
      } else {
        setState(() {
          _error = 'PINs do not match';
          _firstPin = null;
        });
        _pinKey.currentState?.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KFPinEntry(
      key: _pinKey,
      length: widget.length,
      title: _firstPin == null ? widget.title : widget.confirmTitle,
      subtitle: _firstPin == null
          ? 'Enter a ${widget.length}-digit PIN'
          : 'Re-enter your PIN to confirm',
      onComplete: _onPinComplete,
      error: _error,
    );
  }
}
