import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../models/leave.dart';

part 'leave_provider.g.dart';

/// State class for leave data
class LeaveState {
  final List<LeaveBalance> balances;
  final List<LeaveRequest> requests;
  final List<LeaveType> leaveTypes;
  final List<PublicHoliday> holidays;
  final bool isLoading;
  final String? error;

  const LeaveState({
    this.balances = const [],
    this.requests = const [],
    this.leaveTypes = const [],
    this.holidays = const [],
    this.isLoading = false,
    this.error,
  });

  LeaveState copyWith({
    List<LeaveBalance>? balances,
    List<LeaveRequest>? requests,
    List<LeaveType>? leaveTypes,
    List<PublicHoliday>? holidays,
    bool? isLoading,
    String? error,
  }) {
    return LeaveState(
      balances: balances ?? this.balances,
      requests: requests ?? this.requests,
      leaveTypes: leaveTypes ?? this.leaveTypes,
      holidays: holidays ?? this.holidays,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get available balance for a specific leave type
  double getAvailableBalance(int leaveTypeId) {
    final balance = balances.firstWhere(
      (b) => b.leaveType.id == leaveTypeId,
      orElse: () => const LeaveBalance(
        leaveType: LeaveType(id: 0, code: '', name: ''),
        year: 0,
      ),
    );
    return balance.available;
  }
}

@riverpod
class LeaveNotifier extends _$LeaveNotifier {
  @override
  Future<LeaveState> build() async {
    // Auto-fetch on initialization
    return _fetchAll();
  }

  Future<LeaveState> _fetchAll() async {
    try {
      final dio = ref.read(dioClientProvider);

      // Fetch all data in parallel for efficiency
      final results = await Future.wait([
        dio.get('/leave/balances'),
        dio.get('/leave/types'),
        dio.get('/leave/requests'),
        dio.get('/leave/holidays', queryParameters: {'year': DateTime.now().year}),
      ]);

      final balances = (results[0].data as List)
          .map((e) => LeaveBalance.fromJson(e as Map<String, dynamic>))
          .toList();

      final leaveTypes = (results[1].data as List)
          .map((e) => LeaveType.fromJson(e as Map<String, dynamic>))
          .toList();

      final requests = (results[2].data as List)
          .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList();

      final holidays = (results[3].data as List)
          .map((e) => PublicHoliday.fromJson(e as Map<String, dynamic>))
          .toList();

      return LeaveState(
        balances: balances,
        leaveTypes: leaveTypes,
        requests: requests,
        holidays: holidays,
      );
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      return LeaveState(error: error.message);
    } catch (e) {
      return LeaveState(error: e.toString());
    }
  }

  /// Refresh all leave data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchAll());
  }

  /// Fetch leave balances only
  Future<List<LeaveBalance>> fetchBalances() async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get('/leave/balances');

      final balances = (response.data as List)
          .map((e) => LeaveBalance.fromJson(e as Map<String, dynamic>))
          .toList();

      // Update state
      final current = state.valueOrNull ?? const LeaveState();
      state = AsyncValue.data(current.copyWith(balances: balances));

      return balances;
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }

  /// Fetch leave request history with optional status filter
  Future<List<LeaveRequest>> fetchRequests({
    String? status,
    int? year,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get('/leave/requests', queryParameters: {
        if (status != null) 'status': status,
        if (year != null) 'year': year,
        'limit': limit,
        'offset': offset,
      });

      final requests = (response.data as List)
          .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList();

      // Update state
      final current = state.valueOrNull ?? const LeaveState();
      state = AsyncValue.data(current.copyWith(requests: requests));

      return requests;
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }

  /// Fetch single leave request by ID
  Future<LeaveRequest> fetchRequest(int id) async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get('/leave/requests/$id');
      return LeaveRequest.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }

  /// Submit a new leave request
  Future<LeaveRequest> submitRequest(CreateLeaveRequest request) async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.post('/leave/requests', data: request.toJson());

      final newRequest = LeaveRequest.fromJson(response.data as Map<String, dynamic>);

      // Update state with new request
      final current = state.valueOrNull ?? const LeaveState();
      state = AsyncValue.data(current.copyWith(
        requests: [newRequest, ...current.requests],
      ));

      // Refresh balances as they may have changed
      await fetchBalances();

      return newRequest;
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }

  /// Cancel a leave request
  Future<void> cancelRequest(int id) async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.post('/leave/requests/$id/cancel');

      // Update state - remove or update the cancelled request
      final current = state.valueOrNull ?? const LeaveState();
      final updatedRequests = current.requests.map((r) {
        if (r.id == id) {
          return LeaveRequest(
            id: r.id,
            leaveType: r.leaveType,
            dateFrom: r.dateFrom,
            dateTo: r.dateTo,
            halfDayType: r.halfDayType,
            totalDays: r.totalDays,
            reason: r.reason,
            status: 'cancelled',
            canCancel: false,
            approver: r.approver,
            approvedAt: r.approvedAt,
            createdAt: r.createdAt,
          );
        }
        return r;
      }).toList();

      state = AsyncValue.data(current.copyWith(requests: updatedRequests));

      // Refresh balances
      await fetchBalances();
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }

  /// Calculate working days between two dates (excluding weekends and holidays)
  double calculateWorkingDays(DateTime from, DateTime to, {bool isHalfDay = false}) {
    if (to.isBefore(from)) return 0;

    final holidays = state.valueOrNull?.holidays ?? [];
    final holidayDates = holidays.map((h) => DateTime.parse(h.date)).toSet();

    double days = 0;
    DateTime current = from;

    while (!current.isAfter(to)) {
      // Skip weekends (Saturday = 6, Sunday = 7)
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday &&
          !holidayDates.contains(DateTime(current.year, current.month, current.day))) {
        days += 1;
      }
      current = current.add(const Duration(days: 1));
    }

    if (isHalfDay && days > 0) {
      days = 0.5;
    }

    return days;
  }
}

/// Provider for leave balances only (lighter weight)
@riverpod
Future<List<LeaveBalance>> leaveBalances(LeaveBalancesRef ref) async {
  final leaveState = await ref.watch(leaveNotifierProvider.future);
  return leaveState.balances;
}

/// Provider for leave requests only
@riverpod
Future<List<LeaveRequest>> leaveRequests(LeaveRequestsRef ref) async {
  final leaveState = await ref.watch(leaveNotifierProvider.future);
  return leaveState.requests;
}

/// Provider for leave types only
@riverpod
Future<List<LeaveType>> leaveTypes(LeaveTypesRef ref) async {
  final leaveState = await ref.watch(leaveNotifierProvider.future);
  return leaveState.leaveTypes;
}
