import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'kf_button.dart';

/// Status types
enum StatusType { approved, pending, rejected, cancelled, processing, draft }

/// Status chip
class KFStatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool showIcon;

  const KFStatusChip({
    super.key,
    required this.label,
    required this.type,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: KFRadius.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, size: 14, color: config.textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: KFTypography.fontSizeSm,
              fontWeight: KFTypography.medium,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig() {
    switch (type) {
      case StatusType.approved:
        return _StatusConfig(
          backgroundColor: KFColors.success100,
          textColor: KFColors.success700,
          icon: Icons.check_circle,
        );
      case StatusType.pending:
        return _StatusConfig(
          backgroundColor: KFColors.warning100,
          textColor: KFColors.warning700,
          icon: Icons.schedule,
        );
      case StatusType.rejected:
        return _StatusConfig(
          backgroundColor: KFColors.error100,
          textColor: KFColors.error700,
          icon: Icons.cancel,
        );
      case StatusType.cancelled:
        return _StatusConfig(
          backgroundColor: KFColors.gray100,
          textColor: KFColors.gray600,
          icon: Icons.block,
        );
      case StatusType.processing:
        return _StatusConfig(
          backgroundColor: KFColors.info100,
          textColor: KFColors.info600,
          icon: Icons.sync,
        );
      case StatusType.draft:
        return _StatusConfig(
          backgroundColor: KFColors.gray100,
          textColor: KFColors.gray600,
          icon: Icons.edit_note,
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

/// Badge for notifications
class KFBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final bool showZero;
  final Color? color;

  const KFBadge({
    super.key,
    required this.child,
    required this.count,
    this.showZero = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showZero) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: count > 9 ? 4 : 0,
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            decoration: BoxDecoration(
              color: color ?? KFColors.error500,
              shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: count > 9 ? KFRadius.radiusFull : null,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: KFColors.white,
                  fontSize: 10,
                  fontWeight: KFTypography.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty state placeholder
class KFEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const KFEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: KFColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: KFColors.gray400,
              ),
            ),
            const SizedBox(height: KFSpacing.space6),
            Text(
              title,
              style: const TextStyle(
                fontSize: KFTypography.fontSizeLg,
                fontWeight: KFTypography.semibold,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: KFSpacing.space2),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: KFTypography.fontSizeBase,
                  color: KFColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: KFSpacing.space6),
              KFSecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state
class KFErrorState extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  const KFErrorState({
    super.key,
    this.title,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: KFColors.error100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: KFColors.error600,
              ),
            ),
            const SizedBox(height: KFSpacing.space6),
            Text(
              title ?? 'Something went wrong',
              style: const TextStyle(
                fontSize: KFTypography.fontSizeLg,
                fontWeight: KFTypography.semibold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: KFSpacing.space2),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: KFTypography.fontSizeBase,
                  color: KFColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: KFSpacing.space6),
              KFPrimaryButton(
                label: 'Try Again',
                onPressed: onRetry,
                isFullWidth: false,
                leadingIcon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Info banner
class KFInfoBanner extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onDismiss;

  const KFInfoBanner({
    super.key,
    required this.message,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KFSpacing.space3),
      decoration: BoxDecoration(
        color: backgroundColor ?? KFColors.info100,
        borderRadius: KFRadius.radiusMd,
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.info_outline,
            color: textColor ?? KFColors.info600,
            size: KFIconSizes.md,
          ),
          const SizedBox(width: KFSpacing.space2),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: KFTypography.fontSizeSm,
                color: textColor ?? KFColors.info700,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: textColor ?? KFColors.info600,
                size: KFIconSizes.sm,
              ),
            ),
        ],
      ),
    );
  }
}
