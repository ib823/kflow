import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_data.freezed.dart';
part 'dashboard_data.g.dart';

/// Dashboard aggregated data from GET /api/v1/dashboard
@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    required EmployeeSummary employee,
    required LeaveBalanceSummary leaveBalance,
    LatestPayslip? latestPayslip,
    required int pendingApprovals,
    required int unreadNotifications,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}

/// Employee summary for dashboard display
@freezed
class EmployeeSummary with _$EmployeeSummary {
  const factory EmployeeSummary({
    required String fullName,
    String? photoUrl,
    required String jobTitle,
    required String department,
    required String countryCode,
  }) = _EmployeeSummary;

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) =>
      _$EmployeeSummaryFromJson(json);
}

/// Leave balance summary for dashboard card
@freezed
class LeaveBalanceSummary with _$LeaveBalanceSummary {
  const factory LeaveBalanceSummary({
    required String typeName,
    required double entitled,
    required double taken,
    required double pending,
    required double balance,
  }) = _LeaveBalanceSummary;

  factory LeaveBalanceSummary.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceSummaryFromJson(json);
}

/// Latest payslip summary for dashboard card
@freezed
class LatestPayslip with _$LatestPayslip {
  const factory LatestPayslip({
    required int id,
    required String period,
    required String netSalary,
    required String currencyCode,
  }) = _LatestPayslip;

  factory LatestPayslip.fromJson(Map<String, dynamic> json) =>
      _$LatestPayslipFromJson(json);
}
