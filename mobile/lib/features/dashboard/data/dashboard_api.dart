import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/dashboard_data.dart';

part 'dashboard_api.g.dart';

/// Dashboard API client for aggregated home screen data.
class DashboardApi {
  final Dio _dio;

  DashboardApi(this._dio);

  /// GET /api/v1/dashboard
  ///
  /// Returns aggregated data for home screen:
  /// - Employee summary
  /// - Leave balance (default type)
  /// - Latest payslip
  /// - Pending approvals count (if supervisor)
  /// - Unread notifications count
  Future<DashboardData> getDashboard() async {
    final response = await _dio.get('/api/v1/dashboard');
    return DashboardData.fromJson(response.data['data']);
  }
}

@riverpod
DashboardApi dashboardApi(DashboardApiRef ref) {
  final dio = ref.watch(dioClientProvider);
  return DashboardApi(dio);
}
