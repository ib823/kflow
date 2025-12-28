import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.freezed.dart';
part 'employee.g.dart';

/// Employee model representing authenticated user data.
///
/// Contains essential profile information returned after successful login.
/// Country-specific statutory calculations use [countryCode].
@freezed
class Employee with _$Employee {
  const factory Employee({
    required int id,
    required String employeeNo,
    required String fullName,
    required String email,
    required String countryCode,
    required int companyId,
    required String companyName,
    String? departmentName,
    String? jobTitle,
    String? photoUrl,
    required bool pinConfigured,
    required bool biometricEnabled,
    @Default('en') String preferredLocale,
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);
}

/// Minimal employee info for display purposes.
@freezed
class EmployeeSummary with _$EmployeeSummary {
  const factory EmployeeSummary({
    required int id,
    required String fullName,
    String? photoUrl,
  }) = _EmployeeSummary;

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) =>
      _$EmployeeSummaryFromJson(json);
}
