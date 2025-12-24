import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// An accessible tappable widget that provides:
/// - Semantic labels for screen readers
/// - Keyboard navigation support
/// - Proper touch targets (min 48x48dp)
/// - Visual feedback (InkWell ripple)
/// - Optional haptic feedback
///
/// Use this instead of raw GestureDetector for accessibility compliance.
class AccessibleTap extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  /// Semantic label for screen readers (required for accessibility)
  final String semanticLabel;

  /// Optional semantic hint (describes what happens on tap)
  final String? semanticHint;

  /// Whether this is a button (affects semantic role)
  final bool isButton;

  /// Whether to enable haptic feedback on tap
  final bool hapticFeedback;

  /// Border radius for InkWell splash
  final BorderRadius? borderRadius;

  /// Custom splash color
  final Color? splashColor;

  /// Custom highlight color
  final Color? highlightColor;

  /// Whether to exclude child semantics (useful when child has its own semantics)
  final bool excludeChildSemantics;

  /// Tooltip text (shown on long press/hover)
  final String? tooltip;

  /// Minimum touch target size (defaults to 48x48 for Material guidelines)
  final Size minTouchTarget;

  const AccessibleTap({
    super.key,
    required this.child,
    required this.onTap,
    required this.semanticLabel,
    this.onLongPress,
    this.semanticHint,
    this.isButton = true,
    this.hapticFeedback = false,
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
    this.excludeChildSemantics = false,
    this.tooltip,
    this.minTouchTarget = const Size(48, 48),
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: isButton,
      enabled: onTap != null,
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: excludeChildSemantics,
      child: InkWell(
        onTap: onTap != null
            ? () {
                if (hapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onTap!();
              }
            : null,
        onLongPress: onLongPress != null
            ? () {
                if (hapticFeedback) {
                  HapticFeedback.mediumImpact();
                }
                onLongPress!();
              }
            : null,
        borderRadius: borderRadius,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minTouchTarget.width,
            minHeight: minTouchTarget.height,
          ),
          child: child,
        ),
      ),
    );

    // Wrap with tooltip if provided
    if (tooltip != null) {
      content = Tooltip(
        message: tooltip!,
        child: content,
      );
    }

    return content;
  }
}

/// An accessible icon button with proper semantics
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final Color? color;
  final double? size;
  final bool hapticFeedback;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.color,
    this.size,
    this.hapticFeedback = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: IconButton(
          icon: Icon(icon, color: color, size: size),
          onPressed: onPressed != null
              ? () {
                  if (hapticFeedback) {
                    HapticFeedback.lightImpact();
                  }
                  onPressed!();
                }
              : null,
        ),
      ),
    );
  }
}

/// An accessible card that can be tapped
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String semanticLabel;
  final String? semanticHint;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;

  const AccessibleCard({
    super.key,
    required this.child,
    required this.onTap,
    required this.semanticLabel,
    this.semanticHint,
    this.padding,
    this.color,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.md);

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      enabled: onTap != null,
      child: Card(
        color: color,
        elevation: elevation ?? 0,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }
}
