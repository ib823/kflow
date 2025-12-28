import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/dashboard_data.dart';
import 'dashboard_api.dart';

part 'dashboard_repository.g.dart';

/// Repository for dashboard data with caching support.
class DashboardRepository {
  final DashboardApi _api;

  DashboardRepository(this._api);

  /// Fetch dashboard data from API.
  Future<DashboardData> getDashboard() => _api.getDashboard();
}

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  return DashboardRepository(ref.watch(dashboardApiProvider));
}
