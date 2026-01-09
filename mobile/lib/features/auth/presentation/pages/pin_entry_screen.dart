import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// PIN entry screen for authentication
class PinEntryScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onForgotPin;
  final VoidCallback? onLogout;
  final String? userName;
  final String? userAvatar;

  const PinEntryScreen({
    super.key,
    this.onSuccess,
    this.onForgotPin,
    this.onLogout,
    this.userName,
    this.userAvatar,
  });

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _errorMessage;
  bool _isLoading = false;
  int _attempts = 0;
  bool _isLocked = false;
  int _lockoutSeconds = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const int _maxAttempts = 5;
  static const int _pinLength = 6;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    if (_isLocked || _isLoading) return;

    if (key == 'delete') {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
          _errorMessage = null;
        });
      }
    } else if (key == 'biometric') {
      _handleBiometric();
    } else if (_pin.length < _pinLength) {
      setState(() {
        _pin += key;
        _errorMessage = null;
      });

      if (_pin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    // Simulate API verification
    await Future.delayed(const Duration(milliseconds: 800));

    // For demo, accept "123456" as valid PIN
    if (_pin == '123456') {
      setState(() => _isLoading = false);
      widget.onSuccess?.call();
    } else {
      _attempts++;

      if (_attempts >= _maxAttempts) {
        _startLockout();
      } else {
        _shakeController.forward(from: 0);
        setState(() {
          _isLoading = false;
          _pin = '';
          _errorMessage =
              'Incorrect PIN. ${_maxAttempts - _attempts} attempts remaining.';
        });
      }
    }
  }

  void _startLockout() {
    setState(() {
      _isLocked = true;
      _lockoutSeconds = 30;
      _isLoading = false;
      _pin = '';
      _errorMessage = null;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() => _lockoutSeconds--);

      if (_lockoutSeconds <= 0) {
        setState(() {
          _isLocked = false;
          _attempts = 0;
        });
        return false;
      }
      return true;
    });
  }

  Future<void> _handleBiometric() async {
    // Simulate biometric authentication
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);

    // For demo, always succeed
    widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: KFLoadingOverlay(
          isLoading: _isLoading,
          child: Padding(
            padding: KFSpacing.screenPadding,
            child: Column(
              children: [
                const SizedBox(height: KFSpacing.space8),
                // User avatar
                _buildAvatar(),
                const SizedBox(height: KFSpacing.space4),
                // Welcome text
                Text(
                  'Welcome back${widget.userName != null ? ', ${widget.userName}' : ''}',
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeXl,
                    fontWeight: KFTypography.semiBold,
                  ),
                ),
                const SizedBox(height: KFSpacing.space2),
                Text(
                  _isLocked
                      ? 'Too many attempts. Try again in $_lockoutSeconds seconds.'
                      : 'Enter your PIN to continue',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeBase,
                    color: _isLocked ? KFColors.error600 : KFColors.gray600,
                  ),
                ),
                const SizedBox(height: KFSpacing.space8),
                // PIN dots with shake animation
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _shakeAnimation.value *
                            ((_shakeController.value * 10).toInt().isEven
                                ? 1
                                : -1),
                        0,
                      ),
                      child: child,
                    );
                  },
                  child: KFPinDisplay(
                    length: _pinLength,
                    filledCount: _pin.length,
                    hasError: _errorMessage != null,
                  ),
                ),
                const SizedBox(height: KFSpacing.space4),
                // Error message
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: KFTypography.fontSizeSm,
                      color: KFColors.error600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const Spacer(),
                // PIN keypad
                KFPinKeypad(
                  onKeyPressed: _onKeyPressed,
                  showBiometric: true,
                  disabled: _isLocked,
                ),
                const SizedBox(height: KFSpacing.space6),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    KFTextButton(
                      label: 'Forgot PIN?',
                      onPressed: _isLocked ? null : widget.onForgotPin,
                    ),
                    KFTextButton(
                      label: 'Logout',
                      onPressed: widget.onLogout,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.userAvatar != null) {
      return CircleAvatar(
        radius: KFAvatarSizes.xl / 2,
        backgroundImage: NetworkImage(widget.userAvatar!),
      );
    }

    return Container(
      width: KFAvatarSizes.xl,
      height: KFAvatarSizes.xl,
      decoration: const BoxDecoration(
        color: KFColors.primary100,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 40,
        color: KFColors.primary600,
      ),
    );
  }
}
