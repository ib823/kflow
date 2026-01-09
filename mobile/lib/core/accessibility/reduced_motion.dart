import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Check if user prefers reduced motion
/// Returns true if the user has enabled "Reduce Motion" in system settings
bool prefersReducedMotion(BuildContext context) {
  return MediaQuery.of(context).disableAnimations;
}

/// Get animation duration respecting reduced motion preference
/// Returns Duration.zero if user prefers reduced motion, otherwise returns normalDuration
Duration getAccessibleDuration(BuildContext context, Duration normalDuration) {
  if (prefersReducedMotion(context)) {
    return Duration.zero;
  }
  return normalDuration;
}

/// Get animation curve respecting reduced motion preference
/// Returns Curves.linear if user prefers reduced motion (for instant transitions)
Curve getAccessibleCurve(BuildContext context, Curve normalCurve) {
  if (prefersReducedMotion(context)) {
    return Curves.linear;
  }
  return normalCurve;
}

/// Animated container that respects reduced motion preference
class KFAccessibleAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double? width;
  final double? height;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;

  const KFAccessibleAnimatedContainer({
    super.key,
    required this.child,
    this.duration = KFAnimation.normal,
    this.curve = Curves.easeInOut,
    this.width,
    this.height,
    this.color,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
    this.constraints,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final accessibleDuration = getAccessibleDuration(context, duration);
    final accessibleCurve = getAccessibleCurve(context, curve);

    return AnimatedContainer(
      duration: accessibleDuration,
      curve: accessibleCurve,
      width: width,
      height: height,
      color: color,
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// Fade transition that respects reduced motion preference
class KFAccessibleFadeTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> opacity;
  final bool alwaysIncludeSemantics;

  const KFAccessibleFadeTransition({
    super.key,
    required this.child,
    required this.opacity,
    this.alwaysIncludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return child;
    }

    return FadeTransition(
      opacity: opacity,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      child: child,
    );
  }
}

/// Slide transition that respects reduced motion preference
class KFAccessibleSlideTransition extends StatelessWidget {
  final Widget child;
  final Animation<Offset> position;
  final bool transformHitTests;

  const KFAccessibleSlideTransition({
    super.key,
    required this.child,
    required this.position,
    this.transformHitTests = true,
  });

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return child;
    }

    return SlideTransition(
      position: position,
      transformHitTests: transformHitTests,
      child: child,
    );
  }
}

/// Scale transition that respects reduced motion preference
class KFAccessibleScaleTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> scale;
  final Alignment alignment;

  const KFAccessibleScaleTransition({
    super.key,
    required this.child,
    required this.scale,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return child;
    }

    return ScaleTransition(
      scale: scale,
      alignment: alignment,
      child: child,
    );
  }
}

/// Animated opacity that respects reduced motion preference
class KFAccessibleAnimatedOpacity extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onEnd;
  final bool alwaysIncludeSemantics;

  const KFAccessibleAnimatedOpacity({
    super.key,
    required this.child,
    required this.opacity,
    this.duration = KFAnimation.normal,
    this.curve = Curves.easeInOut,
    this.onEnd,
    this.alwaysIncludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    final accessibleDuration = getAccessibleDuration(context, duration);

    return AnimatedOpacity(
      opacity: opacity,
      duration: accessibleDuration,
      curve: curve,
      onEnd: onEnd,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      child: child,
    );
  }
}

/// Animated cross fade that respects reduced motion preference
class KFAccessibleCrossFade extends StatelessWidget {
  final Widget firstChild;
  final Widget secondChild;
  final CrossFadeState crossFadeState;
  final Duration duration;
  final Curve firstCurve;
  final Curve secondCurve;
  final Curve sizeCurve;
  final AlignmentGeometry alignment;

  const KFAccessibleCrossFade({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.crossFadeState,
    this.duration = KFAnimation.normal,
    this.firstCurve = Curves.easeOut,
    this.secondCurve = Curves.easeIn,
    this.sizeCurve = Curves.easeInOut,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final accessibleDuration = getAccessibleDuration(context, duration);

    // If reduced motion, just show the target child without animation
    if (accessibleDuration == Duration.zero) {
      return crossFadeState == CrossFadeState.showFirst
          ? firstChild
          : secondChild;
    }

    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState: crossFadeState,
      duration: accessibleDuration,
      firstCurve: firstCurve,
      secondCurve: secondCurve,
      sizeCurve: sizeCurve,
      alignment: alignment,
    );
  }
}

/// Animated switcher that respects reduced motion preference
class KFAccessibleSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;
  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  const KFAccessibleSwitcher({
    super.key,
    required this.child,
    this.duration = KFAnimation.normal,
    this.switchInCurve = Curves.easeIn,
    this.switchOutCurve = Curves.easeOut,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final accessibleDuration = getAccessibleDuration(context, duration);

    return AnimatedSwitcher(
      duration: accessibleDuration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder,
      layoutBuilder: layoutBuilder,
      child: child,
    );
  }
}

/// Animated positioned that respects reduced motion preference
class KFAccessibleAnimatedPositioned extends StatelessWidget {
  final Widget child;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onEnd;

  const KFAccessibleAnimatedPositioned({
    super.key,
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.duration = KFAnimation.normal,
    this.curve = Curves.easeInOut,
    this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final accessibleDuration = getAccessibleDuration(context, duration);

    return AnimatedPositioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      duration: accessibleDuration,
      curve: curve,
      onEnd: onEnd,
      child: child,
    );
  }
}

/// Animated scale that respects reduced motion preference
class KFAccessibleAnimatedScale extends StatelessWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;
  final FilterQuality? filterQuality;
  final VoidCallback? onEnd;

  const KFAccessibleAnimatedScale({
    super.key,
    required this.child,
    required this.scale,
    this.duration = KFAnimation.normal,
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
    this.filterQuality,
    this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final accessibleDuration = getAccessibleDuration(context, duration);

    return AnimatedScale(
      scale: scale,
      duration: accessibleDuration,
      curve: curve,
      alignment: alignment,
      filterQuality: filterQuality,
      onEnd: onEnd,
      child: child,
    );
  }
}
