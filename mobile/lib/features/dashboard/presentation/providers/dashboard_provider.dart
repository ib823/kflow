import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/dashboard_repository.dart';
import '../../domain/models/dashboard_data.dart';

part 'dashboard_provider.g.dart';

/// Provider for dashboard data with auto-refresh capability.
@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  Future<DashboardData> build() async {
    return ref.watch(dashboardRepositoryProvider).getDashboard();
  }

  /// Refresh dashboard data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).getDashboard(),
    );
  }
}

/// Provider for pending approvals count (supervisor badge).
@riverpod
int pendingApprovalsCount(PendingApprovalsCountRef ref) {
  final dashboard = ref.watch(dashboardNotifierProvider);
  return dashboard.maybeWhen(
    data: (data) => data.pendingApprovals,
    orElse: () => 0,
  );
}

/// Provider for unread notifications count (bell badge).
@riverpod
int unreadNotificationsCount(UnreadNotificationsCountRef ref) {
  final dashboard = ref.watch(dashboardNotifierProvider);
  return dashboard.maybeWhen(
    data: (data) => data.unreadNotifications,
    orElse: () => 0,
  );
}
