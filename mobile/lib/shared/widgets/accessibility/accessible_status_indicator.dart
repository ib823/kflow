import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Request status enum
enum RequestStatus { pending, approved, rejected, cancelled }

/// Accessible status indicator combining:
/// - Color (for sighted users)
/// - Icon (universal recognition)
/// - Pattern/shape (color-blind accessibility)
/// - Text label (screen readers + low-literacy)
/// - Optional haptic feedback
///
/// Research: WCAG 1.4.1 - Never use color alone
class AccessibleStatusIndicator extends StatelessWidget {
  final RequestStatus status;
  final bool showLabel;
  final bool compact;
  final bool enableHaptic;

  const AccessibleStatusIndicator({
    super.key,
    required this.status,
    this.showLabel = true,
    this.compact = false,
    this.enableHaptic = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(context);
    final theme = Theme.of(context);

    if (enableHaptic) {
      _triggerHaptic();
    }

    return Semantics(
      label: '${config.label}. ${config.accessibilityHint}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          border: Border.all(
            color: config.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              config.icon,
              size: compact ? 14 : 18,
              color: config.iconColor,
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                config.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: config.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(BuildContext context) {
    switch (status) {
      case RequestStatus.pending:
        return const _StatusConfig(
          icon: Icons.schedule_rounded,
          label: 'Pending',
          accessibilityHint: 'Waiting for approval. Yellow clock icon.',
          backgroundColor: Color(0xFFFEF9E7),
          borderColor: Color(0xFFF39C12),
          iconColor: Color(0xFFB9770E),
          textColor: Color(0xFF7D5A00),
        );

      case RequestStatus.approved:
        return const _StatusConfig(
          icon: Icons.check_circle_rounded,
          label: 'Approved',
          accessibilityHint: 'Request approved. Green checkmark icon.',
          backgroundColor: Color(0xFFEAFAF1),
          borderColor: Color(0xFF27AE60),
          iconColor: Color(0xFF1E8449),
          textColor: Color(0xFF145A32),
        );

      case RequestStatus.rejected:
        return const _StatusConfig(
          icon: Icons.cancel_rounded,
          label: 'Rejected',
          accessibilityHint: 'Request rejected. Red X icon.',
          backgroundColor: Color(0xFFFDEDEC),
          borderColor: Color(0xFFC0392B),
          iconColor: Color(0xFF922B21),
          textColor: Color(0xFF641E16),
        );

      case RequestStatus.cancelled:
        return const _StatusConfig(
          icon: Icons.block_rounded,
          label: 'Cancelled',
          accessibilityHint: 'Request cancelled. Grey block icon.',
          backgroundColor: Color(0xFFF0F0F3),
          borderColor: Color(0xFF8E8E9A),
          iconColor: Color(0xFF6B6B7B),
          textColor: Color(0xFF4A4A5A),
        );
    }
  }

  void _triggerHaptic() {
    switch (status) {
      case RequestStatus.approved:
        HapticFeedback.mediumImpact();
        break;
      case RequestStatus.rejected:
        HapticFeedback.heavyImpact();
        break;
      case RequestStatus.pending:
        HapticFeedback.lightImpact();
        break;
      case RequestStatus.cancelled:
        HapticFeedback.selectionClick();
        break;
    }
  }
}

class _StatusConfig {
  final IconData icon;
  final String label;
  final String accessibilityHint;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  const _StatusConfig({
    required this.icon,
    required this.label,
    required this.accessibilityHint,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}
