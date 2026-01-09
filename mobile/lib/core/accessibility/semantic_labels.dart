import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Semantic wrapper for screen reader support
/// Provides accessibility information for assistive technologies
class KFSemantics extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool? button;
  final bool? header;
  final bool? link;
  final bool? image;
  final bool? liveRegion;
  final bool? slider;
  final bool? textField;
  final bool? readOnly;
  final bool? focused;
  final bool excludeFromSemantics;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onScrollLeft;
  final VoidCallback? onScrollRight;
  final VoidCallback? onScrollUp;
  final VoidCallback? onScrollDown;

  const KFSemantics({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.button,
    this.header,
    this.link,
    this.image,
    this.liveRegion,
    this.slider,
    this.textField,
    this.readOnly,
    this.focused,
    this.excludeFromSemantics = false,
    this.onTap,
    this.onLongPress,
    this.onScrollLeft,
    this.onScrollRight,
    this.onScrollUp,
    this.onScrollDown,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeFromSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      link: link,
      image: image,
      liveRegion: liveRegion,
      slider: slider,
      textField: textField,
      readOnly: readOnly,
      focused: focused,
      onTap: onTap,
      onLongPress: onLongPress,
      onScrollLeft: onScrollLeft,
      onScrollRight: onScrollRight,
      onScrollUp: onScrollUp,
      onScrollDown: onScrollDown,
      child: child,
    );
  }
}

/// Semantic button wrapper
class KFSemanticButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final bool enabled;

  const KFSemanticButton({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: enabled ? onTap : null,
      child: child,
    );
  }
}

/// Semantic header wrapper
class KFSemanticHeader extends StatelessWidget {
  final Widget child;
  final String? label;

  const KFSemanticHeader({
    super.key,
    required this.child,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: label,
      child: child,
    );
  }
}

/// Semantic image wrapper
class KFSemanticImage extends StatelessWidget {
  final Widget child;
  final String description;
  final bool isDecorative;

  const KFSemanticImage({
    super.key,
    required this.child,
    required this.description,
    this.isDecorative = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDecorative) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      image: true,
      label: description,
      child: child,
    );
  }
}

/// Announce changes to screen readers
class KFAnnounce {
  /// Polite announcement - waits for current speech to finish
  static void polite(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Assertive announcement - interrupts current speech
  static void assertive(BuildContext context, String message) {
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: Assertiveness.assertive,
    );
  }

  /// Announce with custom text direction
  static void withDirection(
    BuildContext context,
    String message,
    TextDirection direction, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    SemanticsService.announce(
      message,
      direction,
      assertiveness: assertiveness,
    );
  }
}

/// Focus management utilities
class KFFocusManager {
  /// Request focus on a specific node
  static void requestFocus(FocusNode node) {
    node.requestFocus();
  }

  /// Move focus to next focusable node
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous focusable node
  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Remove focus from current node
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Request focus on the primary focus node of the scope
  static void requestScopeFocus(BuildContext context) {
    FocusScope.of(context).requestFocus();
  }

  /// Check if any descendant has focus
  static bool hasFocus(BuildContext context) {
    return FocusScope.of(context).hasFocus;
  }

  /// Check if the primary focus is within this scope
  static bool hasPrimaryFocus(BuildContext context) {
    return FocusScope.of(context).hasPrimaryFocus;
  }
}

/// Accessibility-aware text scaling
/// Respects user's text size preferences while preventing overflow
class KFAccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double minScale;
  final double maxScale;
  final bool softWrap;

  const KFAccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.minScale = 0.8,
    this.maxScale = 2.0,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;

    // Clamp the scale factor
    final clampedScaler = textScaler.clamp(
      minScaleFactor: minScale,
      maxScaleFactor: maxScale,
    );

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: clampedScaler),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        softWrap: softWrap,
      ),
    );
  }
}

/// Semantic group for related items
class KFSemanticGroup extends StatelessWidget {
  final List<Widget> children;
  final String? label;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const KFSemanticGroup({
    super.key,
    required this.children,
    this.label,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    final content = direction == Axis.vertical
        ? Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: children,
          )
        : Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: children,
          );

    if (label != null) {
      return Semantics(
        label: label,
        container: true,
        child: content,
      );
    }

    return MergeSemantics(child: content);
  }
}

/// Live region for dynamic content updates
class KFLiveRegion extends StatelessWidget {
  final Widget child;
  final String? label;

  const KFLiveRegion({
    super.key,
    required this.child,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: child,
    );
  }
}
