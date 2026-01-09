import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';

/// Button size enum
enum ButtonSize { small, medium, large }

/// Primary action button - main CTA
class KFPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final ButtonSize size;

  const KFPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final height = _getHeight();
    final padding = _getPadding();
    final fontSize = _getFontSize();

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: KFColors.primary600,
          foregroundColor: KFColors.white,
          disabledBackgroundColor: KFColors.gray200,
          disabledForegroundColor: KFColors.gray400,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
          textStyle: TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: fontSize,
            fontWeight: KFTypography.semibold,
          ),
        ),
        child: _buildContent(fontSize),
      ),
    );
  }

  Widget _buildContent(double fontSize) {
    if (isLoading) {
      return SizedBox(
        width: fontSize + 4,
        height: fontSize + 4,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(KFColors.white),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: fontSize + 2),
          const SizedBox(width: KFSpacing.space2),
        ],
        Text(label),
        if (trailingIcon != null) ...[
          const SizedBox(width: KFSpacing.space2),
          Icon(trailingIcon, size: fontSize + 2),
        ],
      ],
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return KFTouchTargets.comfortable;
      case ButtonSize.large:
        return KFTouchTargets.large;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: KFSpacing.space4);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: KFSpacing.space6);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: KFSpacing.space8);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return KFTypography.fontSizeSm;
      case ButtonSize.medium:
        return KFTypography.fontSizeBase;
      case ButtonSize.large:
        return KFTypography.fontSizeMd;
    }
  }
}

/// Secondary action button - outlined style
class KFSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final ButtonSize size;

  const KFSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final height = size == ButtonSize.small
        ? 36.0
        : size == ButtonSize.large
            ? KFTouchTargets.large
            : KFTouchTargets.comfortable;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: KFColors.primary600,
          side: BorderSide(
            color: onPressed != null ? KFColors.primary600 : KFColors.gray300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
          textStyle: TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: size == ButtonSize.small
                ? KFTypography.fontSizeSm
                : KFTypography.fontSizeBase,
            fontWeight: KFTypography.semibold,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(KFColors.primary600),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: KFIconSizes.md),
                    const SizedBox(width: KFSpacing.space2),
                  ],
                  Text(label),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: KFSpacing.space2),
                    Icon(trailingIcon, size: KFIconSizes.md),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Text button - minimal style
class KFTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final Color? color;

  const KFTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? KFColors.primary600;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: buttonColor,
        minimumSize: const Size(KFTouchTargets.minimum, KFTouchTargets.minimum),
        padding: const EdgeInsets.symmetric(horizontal: KFSpacing.space4),
        textStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.medium,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: KFIconSizes.md),
            const SizedBox(width: KFSpacing.space1),
          ],
          Text(label),
        ],
      ),
    );
  }
}

/// Danger button - for destructive actions
class KFDangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final bool isOutlined;

  const KFDangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: KFTouchTargets.comfortable,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: KFColors.error600,
            side: const BorderSide(color: KFColors.error600),
            shape: RoundedRectangleBorder(
              borderRadius: KFRadius.radiusLg,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: KFTouchTargets.comfortable,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: KFColors.error600,
          foregroundColor: KFColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(KFColors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Icon button with tooltip
class KFIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const KFIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = KFTouchTargets.comfortable,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: KFRadius.radiusFull,
      child: InkWell(
        onTap: onPressed,
        borderRadius: KFRadius.radiusFull,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              icon,
              size: size * 0.5,
              color: color ??
                  (onPressed != null ? KFColors.gray700 : KFColors.gray400),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Floating action button
class KFFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final String? tooltip;
  final bool extended;
  final bool mini;

  const KFFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.tooltip,
    this.extended = false,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: KFColors.secondary500,
        foregroundColor: KFColors.white,
        tooltip: tooltip,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      mini: mini,
      backgroundColor: KFColors.secondary500,
      foregroundColor: KFColors.white,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}

/// Success button variant
class KFSuccessButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;

  const KFSuccessButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: KFTouchTargets.comfortable,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: KFColors.success600,
          foregroundColor: KFColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(KFColors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: KFIconSizes.md),
                    const SizedBox(width: KFSpacing.space2),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
