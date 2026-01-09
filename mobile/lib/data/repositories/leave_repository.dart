import '../datasources/remote/api_config.dart';
import '../datasources/remote/odoo_client.dart';
import '../models/models.dart';
import 'base_repository.dart';

/// Leave repository
class LeaveRepository extends BaseRepository {
  LeaveRepository({
    required super.client,
    required super.storage,
    required super.syncManager,
  });

  /// Get leave balances
  Future<List<LeaveBalance>> getBalances({bool forceRefresh = false}) async {
    const cacheKey = 'leave_balances';

    // Return cached if fresh
    if (!forceRefresh && shouldUseCache(cacheKey)) {
      final cached = storage.getLeaveBalances();
      if (cached.isNotEmpty) return cached;
    }

    // Check if online
    if (!await syncManager.isOnline()) {
      final cached = storage.getLeaveBalances();
      if (cached.isNotEmpty) return cached;
      throw const ApiException(
        message: 'No internet connection and no cached data available.',
        code: 'offline_no_cache',
      );
    }

    // Fetch from API
    final response = await client.get(ApiEndpoints.leaveBalance);

    final list = response.data['data'] as List;
    final balances = list
        .map((e) => LeaveBalance.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache results
    await storage.saveLeaveBalances(balances);

    return balances;
  }

  /// Get leave requests
  Future<List<LeaveRequest>> getRequests({
    LeaveStatus? status,
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'leave_requests';

    // Return cached if fresh
    if (!forceRefresh && status == null && shouldUseCache(cacheKey)) {
      final cached = storage.getLeaveRequests();
      if (cached.isNotEmpty) return cached;
    }

    // Check if online
    if (!await syncManager.isOnline()) {
      final cached = storage.getLeaveRequests();
      if (cached.isNotEmpty) {
        // Filter locally if status specified
        if (status != null) {
          return cached.where((r) => r.status == status).toList();
        }
        return cached;
      }
      throw const ApiException(
        message: 'No internet connection and no cached data available.',
        code: 'offline_no_cache',
      );
    }

    // Fetch from API
    final response = await client.get(
      ApiEndpoints.leaveRequests,
      queryParameters: status != null ? {'status': status.name} : null,
    );

    final list = response.data['data'] as List;
    final requests = list
        .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache results (only if no filter)
    if (status == null) {
      await storage.saveLeaveRequests(requests);
    }

    return requests;
  }

  /// Get single leave request
  Future<LeaveRequest> getRequest(String id) async {
    final response = await client.get(ApiEndpoints.leaveRequestDetail(id));
    return LeaveRequest.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Apply for leave
  Future<LeaveRequest> applyLeave({
    required String leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    final data = {
      'leave_type_id': leaveTypeId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'reason': reason,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
    };

    // Check if online
    if (await syncManager.isOnline()) {
      final response = await client.post(
        ApiEndpoints.leaveRequests,
        data: data,
      );
      return LeaveRequest.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } else {
      // Queue for later sync
      await syncManager.queueOperation(
        type: 'leave_apply',
        endpoint: ApiEndpoints.leaveRequests,
        method: 'POST',
        data: data,
      );

      throw const ApiException(
        message: 'Request queued for sync when online.',
        code: 'offline_queued',
      );
    }
  }

  /// Cancel leave request
  Future<void> cancelRequest(String id) async {
    if (await syncManager.isOnline()) {
      await client.delete(ApiEndpoints.cancelLeaveRequest(id));
    } else {
      await syncManager.queueOperation(
        type: 'leave_cancel',
        endpoint: ApiEndpoints.cancelLeaveRequest(id),
        method: 'DELETE',
        data: {'id': id},
      );
      throw const ApiException(
        message: 'Cancellation queued for sync when online.',
        code: 'offline_queued',
      );
    }
  }
}
