import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/leave_models.dart';

part 'leave_api.g.dart';

/// Leave management API client.
///
/// Covers 8 leave endpoints + 3 approval endpoints.
class LeaveApi {
  final Dio _dio;

  LeaveApi(this._dio);

  // ===========================================================================
  // Leave Types & Balances
  // ===========================================================================

  /// GET /api/v1/leave/types
  Future<List<LeaveType>> getLeaveTypes() async {
    final response = await _dio.get('/api/v1/leave/types');
    return (response.data['data'] as List)
        .map((e) => LeaveType.fromJson(e))
        .toList();
  }

  /// GET /api/v1/leave/balances
  Future<List<LeaveBalance>> getLeaveBalances() async {
    final response = await _dio.get('/api/v1/leave/balances');
    return (response.data['data'] as List)
        .map((e) => LeaveBalance.fromJson(e))
        .toList();
  }

  // ===========================================================================
  // Leave Requests
  // ===========================================================================

  /// GET /api/v1/leave/requests
  Future<List<LeaveRequest>> getLeaveRequests({String? status}) async {
    final response = await _dio.get('/api/v1/leave/requests', queryParameters: {
      if (status != null) 'status': status,
    });
    return (response.data['data'] as List)
        .map((e) => LeaveRequest.fromJson(e))
        .toList();
  }

  /// POST /api/v1/leave/requests
  Future<LeaveRequest> submitLeaveRequest(LeaveApplyRequest request) async {
    final response = await _dio.post('/api/v1/leave/requests', data: {
      'leave_type_id': request.leaveTypeId,
      'date_from': request.dateFrom.toIso8601String().split('T')[0],
      'date_to': request.dateTo.toIso8601String().split('T')[0],
      'is_half_day': request.isHalfDay,
      if (request.halfDayType != null) 'half_day_type': request.halfDayType,
      if (request.reason != null) 'reason': request.reason,
      if (request.attachmentId != null) 'attachment_id': request.attachmentId,
    });
    return LeaveRequest.fromJson(response.data['data']);
  }

  /// GET /api/v1/leave/requests/{id}
  Future<LeaveRequest> getLeaveRequestDetail(int id) async {
    final response = await _dio.get('/api/v1/leave/requests/$id');
    return LeaveRequest.fromJson(response.data['data']);
  }

  /// DELETE /api/v1/leave/requests/{id}
  Future<void> cancelLeaveRequest(int id) async {
    await _dio.delete('/api/v1/leave/requests/$id');
  }

  // ===========================================================================
  // Calendar & Holidays
  // ===========================================================================

  /// GET /api/v1/leave/calendar
  Future<Map<String, dynamic>> getLeaveCalendar({
    required int year,
    required int month,
  }) async {
    final response = await _dio.get('/api/v1/leave/calendar', queryParameters: {
      'year': year,
      'month': month,
    });
    return response.data['data'];
  }

  /// GET /api/v1/leave/holidays
  Future<List<PublicHoliday>> getPublicHolidays({
    required int year,
    String? countryCode,
  }) async {
    final response = await _dio.get('/api/v1/leave/holidays', queryParameters: {
      'year': year,
      if (countryCode != null) 'country_code': countryCode,
    });
    return (response.data['data'] as List)
        .map((e) => PublicHoliday.fromJson(e))
        .toList();
  }

  // ===========================================================================
  // Approvals (Supervisor)
  // ===========================================================================

  /// GET /api/v1/approvals
  Future<List<LeaveApprovalItem>> getPendingApprovals() async {
    final response = await _dio.get('/api/v1/approvals');
    return (response.data['data'] as List)
        .map((e) => LeaveApprovalItem.fromJson(e))
        .toList();
  }

  /// POST /api/v1/approvals/{id}/approve
  Future<void> approveLeaveRequest(int id, {String? comment}) async {
    await _dio.post('/api/v1/approvals/$id/approve', data: {
      if (comment != null) 'comment': comment,
    });
  }

  /// POST /api/v1/approvals/{id}/reject
  Future<void> rejectLeaveRequest(int id, {required String reason}) async {
    await _dio.post('/api/v1/approvals/$id/reject', data: {
      'reason': reason,
    });
  }
}

@riverpod
LeaveApi leaveApi(LeaveApiRef ref) {
  final dio = ref.watch(dioClientProvider);
  return LeaveApi(dio);
}
