import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/biometric_service.dart';
import 'pin_pad.dart';

/// Biometric authentication prompt widget (S-006).
///
/// Features:
/// - Animated biometric icon based on device capability
/// - Fallback to PIN button
/// - Lockout indication
/// - Haptic feedback
class BiometricPrompt extends ConsumerStatefulWidget {
  /// Callback when biometric authentication succeeds
  final VoidCallback onSuccess;

  /// Callback when user chooses PIN fallback
  final VoidCallback onUsePinPressed;

  /// Custom message to display
  final String? message;

  /// Whether to auto-trigger biometric on mount
  final bool autoTrigger;

  const BiometricPrompt({
    super.key,
    required this.onSuccess,
    required this.onUsePinPressed,
    this.message,
    this.autoTrigger = true,
  });

  @override
  ConsumerState<BiometricPrompt> createState() => _BiometricPromptState();
}

class _BiometricPromptState extends ConsumerState<BiometricPrompt>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  bool _isAuthenticating = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);

    if (widget.autoTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authenticate();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    final biometricService = ref.read(biometricServiceProvider);
    final result = await biometricService.authenticate(
      localizedReason: widget.message ?? 'Authenticate to access KerjaFlow',
    );

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
    });

    switch (result) {
      case BiometricSuccess():
        widget.onSuccess();
      case BiometricCancelled():
        // User cancelled, do nothing
        break;
      case BiometricFailure(reason: final reason):
        setState(() => _error = reason);
      case BiometricLockout(isPermanent: final isPermanent):
        setState(() {
          _error = isPermanent
              ? 'Biometric locked. Please use PIN.'
              : 'Too many attempts. Try again later.';
        });
      case BiometricNotAvailable():
        widget.onUsePinPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Biometric icon with pulse animation
        ScaleTransition(
          scale: _pulseAnimation,
          child: _BiometricIcon(
            isAuthenticating: _isAuthenticating,
            hasError: _error != null,
          ),
        ),

        const SizedBox(height: 32),

        // Message
        Text(
          widget.message ?? 'Touch the sensor to unlock',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),

        // Error message
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 48),

        // Retry button
        if (!_isAuthenticating && _error != null)
          OutlinedButton.icon(
            onPressed: _authenticate,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),

        const SizedBox(height: 16),

        // PIN fallback
        TextButton(
          onPressed: widget.onUsePinPressed,
          child: const Text('Use PIN instead'),
        ),
      ],
    );
  }
}

/// Animated biometric icon based on device capability
class _BiometricIcon extends ConsumerWidget {
  final bool isAuthenticating;
  final bool hasError;

  const _BiometricIcon({
    required this.isAuthenticating,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final biometricType = ref.watch(primaryBiometricTypeProvider);

    return biometricType.when(
      data: (type) {
        IconData icon;
        switch (type) {
          case BiometricType.faceId:
            icon = Icons.face;
          case BiometricType.fingerprint:
            icon = Icons.fingerprint;
          case BiometricType.iris:
            icon = Icons.remove_red_eye_outlined;
          case BiometricType.none:
            icon = Icons.lock;
        }

        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? theme.colorScheme.errorContainer
                : isAuthenticating
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: hasError
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              width: 3,
            ),
          ),
          child: Icon(
            icon,
            size: 56,
            color: hasError
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
        );
      },
      loading: () => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.errorContainer,
        ),
        child: Icon(
          Icons.error_outline,
          size: 56,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

/// Small biometric button for inline use
class BiometricButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final double size;

  const BiometricButton({
    super.key,
    required this.onPressed,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final biometricType = ref.watch(primaryBiometricTypeProvider);

    return biometricType.when(
      data: (type) {
        if (type == BiometricType.none) {
          return const SizedBox.shrink();
        }

        BiometricIconType iconType;
        switch (type) {
          case BiometricType.faceId:
            iconType = BiometricIconType.faceId;
          case BiometricType.fingerprint:
            iconType = BiometricIconType.fingerprint;
          case BiometricType.iris:
            iconType = BiometricIconType.iris;
          case BiometricType.none:
            return const SizedBox.shrink();
        }

        return IconButton(
          onPressed: onPressed,
          iconSize: size * 0.6,
          style: IconButton.styleFrom(
            minimumSize: Size(size, size),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          icon: Icon(
            iconType == BiometricIconType.faceId
                ? Icons.face
                : iconType == BiometricIconType.fingerprint
                    ? Icons.fingerprint
                    : Icons.remove_red_eye_outlined,
          ),
        );
      },
      loading: () => SizedBox(width: size, height: size),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
