import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/providers/notification_provider.dart';
import '../../../shared/models/notification.dart';
import '../../../shared/widgets/widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          notificationState.maybeWhen(
            data: (state) => state.unreadCount > 0
                ? Semantics(
                    label: 'Mark all ${state.unreadCount} notifications as read',
                    button: true,
                    child: TextButton(
                      onPressed: () async {
                        await ref
                            .read(notificationNotifierProvider.notifier)
                            .markAllAsRead();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All notifications marked as read'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      child: const Text('Mark all read'),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationState.when(
        loading: () => const LoadingState(message: 'Loading notifications...'),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.read(notificationNotifierProvider.notifier).refresh(),
        ),
        data: (state) {
          if (state.notifications.isEmpty) {
            return EmptyStates.notifications(
              onRefresh: () =>
                  ref.read(notificationNotifierProvider.notifier).refresh(),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationNotifierProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                // Load more trigger
                if (index >= state.notifications.length) {
                  // Trigger loading more
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(notificationNotifierProvider.notifier).loadMore();
                  });
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notification = state.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, ref, notification),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    // Mark as read if unread
    if (!notification.isRead) {
      await ref
          .read(notificationNotifierProvider.notifier)
          .markAsRead(notification.id);
    }

    // Navigate based on deep link
    if (notification.deepLink != null && context.mounted) {
      // Parse deep link and navigate
      // Example: kerjaflow://leave/request/123
      // For now, just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening: ${notification.title}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'LEAVE_APPROVED':
        return Icons.check_circle;
      case 'LEAVE_REJECTED':
        return Icons.cancel;
      case 'LEAVE_PENDING':
        return Icons.schedule;
      case 'PAYSLIP_READY':
        return Icons.receipt_long;
      case 'DOCUMENT_EXPIRING':
        return Icons.warning_amber;
      case 'ANNOUNCEMENT':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  Color get _color {
    switch (notification.type) {
      case 'LEAVE_APPROVED':
        return AppColors.success;
      case 'LEAVE_REJECTED':
        return AppColors.error;
      case 'LEAVE_PENDING':
        return AppColors.warning;
      case 'PAYSLIP_READY':
        return AppColors.info;
      case 'DOCUMENT_EXPIRING':
        return AppColors.warning;
      case 'ANNOUNCEMENT':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${notification.isRead ? "" : "Unread. "}${notification.title}. ${notification.body}. ${notification.createdAt ?? ""}',
      button: true,
      child: Container(
        color: notification.isRead ? null : AppColors.primary.withOpacity(0.05),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          leading: ExcludeSemantics(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                color: _color,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight:
                        notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),
              // FIXED: Increased touch target from 8x8 to proper indicator
              // Using text badge instead of tiny dot for accessibility
              if (!notification.isRead)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'NEW',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xs),
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              // FIXED: Removed hardcoded fontSize, using theme
              Text(
                notification.createdAt ?? '',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
