import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable empty state widget for lists and screens
/// Follows WCAG accessibility guidelines with proper semantics
class EmptyState extends StatelessWidget {
  /// Icon to display (required)
  final IconData icon;

  /// Main title text
  final String title;

  /// Optional description text
  final String? description;

  /// Optional action button text
  final String? actionText;

  /// Optional action callback
  final VoidCallback? onAction;

  /// Custom icon color (defaults to textSecondary)
  final Color? iconColor;

  /// Whether to use a compact layout
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? AppColors.textSecondary;

    return Semantics(
      label: '$title${description != null ? '. $description' : ''}',
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with semantic exclusion (decorative)
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: compact ? 48 : 64,
                  color: color.withOpacity(0.5),
                ),
              ),
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              // Title
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              // Description
              if (description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              // Action button
              if (actionText != null && onAction != null) ...[
                SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state presets for common scenarios
class EmptyStates {
  EmptyStates._();

  /// No notifications
  static Widget notifications({VoidCallback? onRefresh}) => EmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'No notifications',
        description: 'You\'re all caught up!',
        actionText: onRefresh != null ? 'Refresh' : null,
        onAction: onRefresh,
      );

  /// No leave requests
  static Widget leaveRequests({VoidCallback? onApply}) => EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'No leave requests',
        description: 'You haven\'t submitted any leave requests yet.',
        actionText: onApply != null ? 'Apply Leave' : null,
        onAction: onApply,
      );

  /// No leave balance
  static Widget leaveBalance() => const EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No leave types available',
        description: 'Contact HR if you believe this is an error.',
      );

  /// No payslips
  static Widget payslips() => const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No payslips available',
        description: 'Your payslips will appear here once processed.',
      );

  /// Search results empty
  static Widget searchResults({String? query}) => EmptyState(
        icon: Icons.search_off_outlined,
        title: 'No results found',
        description: query != null
            ? 'No results for "$query"'
            : 'Try adjusting your search or filters.',
      );

  /// Network error
  static Widget networkError({VoidCallback? onRetry}) => EmptyState(
        icon: Icons.wifi_off_outlined,
        title: 'Connection error',
        description: 'Please check your internet connection and try again.',
        actionText: onRetry != null ? 'Retry' : null,
        onAction: onRetry,
        iconColor: AppColors.error,
      );

  /// Generic error
  static Widget error({String? message, VoidCallback? onRetry}) => EmptyState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        description: message ?? 'An unexpected error occurred.',
        actionText: onRetry != null ? 'Try Again' : null,
        onAction: onRetry,
        iconColor: AppColors.error,
      );
}
