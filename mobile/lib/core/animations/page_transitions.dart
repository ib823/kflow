import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Slide up transition for modals and bottom sheets
class SlideUpTransition extends PageRouteBuilder {
  final Widget page;

  SlideUpTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: KFAnimation.normal,
          reverseTransitionDuration: KFAnimation.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
                .chain(CurveTween(curve: KFAnimation.emphasizedDecelerate));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// Fade through transition for tab switches
class FadeThroughTransition extends PageRouteBuilder {
  final Widget page;

  FadeThroughTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: KFAnimation.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween(begin: 0.0, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: child,
            );
          },
        );
}

/// Shared axis transition for forward/backward navigation
class SharedAxisTransition extends PageRouteBuilder {
  final Widget page;
  final bool forward;

  SharedAxisTransition({required this.page, this.forward = true})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: KFAnimation.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetTween = Tween(
              begin: Offset(forward ? 0.3 : -0.3, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: KFAnimation.emphasizedDecelerate));

            final fadeTween = Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(offsetTween),
                child: child,
              ),
            );
          },
        );
}

/// Container transform transition for hero-like transformations
class ContainerTransformTransition extends PageRouteBuilder {
  final Widget page;
  final Color scrimColor;

  ContainerTransformTransition({
    required this.page,
    this.scrimColor = Colors.black54,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: KFAnimation.slow,
          reverseTransitionDuration: KFAnimation.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween(begin: 0.92, end: 1.0)
                .chain(CurveTween(curve: KFAnimation.emphasized));

            final fadeTween = Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
        );
}

/// No transition for instant navigation
class NoTransition extends PageRouteBuilder {
  final Widget page;

  NoTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}

/// Hero dialog transition for full-screen dialogs
class HeroDialogTransition extends PageRouteBuilder {
  final Widget page;
  final String heroTag;

  HeroDialogTransition({
    required this.page,
    required this.heroTag,
  }) : super(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black54,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: KFAnimation.normal,
          reverseTransitionDuration: KFAnimation.fast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween(begin: 0.8, end: 1.0)
                .chain(CurveTween(curve: KFAnimation.emphasizedDecelerate));

            final fadeTween = Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
        );
}
