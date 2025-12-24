import 'package:freezed_annotation/freezed_annotation.dart';

part 'payslip.freezed.dart';
part 'payslip.g.dart';

@freezed
class PayslipSummary with _$PayslipSummary {
  const factory PayslipSummary({
    required int id,
    @JsonKey(name: 'pay_period') required String payPeriod,
    @JsonKey(name: 'pay_date') required String payDate,
    @JsonKey(name: 'net_salary') required double netSalary,
    required String status,
  }) = _PayslipSummary;

  factory PayslipSummary.fromJson(Map<String, dynamic> json) =>
      _$PayslipSummaryFromJson(json);
}

@freezed
class PayslipDetail with _$PayslipDetail {
  const factory PayslipDetail({
    required int id,
    @JsonKey(name: 'pay_period') required String payPeriod,
    @JsonKey(name: 'pay_date') required String payDate,
    required PayslipEmployee employee,
    required List<PayslipLine> earnings,
    required List<PayslipLine> deductions,
    required PayslipSummaryData summary,
    required PayslipStatutory statutory,
    @JsonKey(name: 'has_pdf') @Default(false) bool hasPdf,
  }) = _PayslipDetail;

  factory PayslipDetail.fromJson(Map<String, dynamic> json) =>
      _$PayslipDetailFromJson(json);
}

@freezed
class PayslipEmployee with _$PayslipEmployee {
  const factory PayslipEmployee({
    required int id,
    @JsonKey(name: 'employee_no') required String employeeNo,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'ic_no') String? icNo,
    @JsonKey(name: 'epf_no') String? epfNo,
    @JsonKey(name: 'socso_no') String? socsoNo,
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'bank_account_no') String? bankAccountNo,
  }) = _PayslipEmployee;

  factory PayslipEmployee.fromJson(Map<String, dynamic> json) =>
      _$PayslipEmployeeFromJson(json);
}

@freezed
class PayslipLine with _$PayslipLine {
  const factory PayslipLine({
    required String code,
    required String name,
    required double amount,
  }) = _PayslipLine;

  factory PayslipLine.fromJson(Map<String, dynamic> json) =>
      _$PayslipLineFromJson(json);
}

@freezed
class PayslipSummaryData with _$PayslipSummaryData {
  const factory PayslipSummaryData({
    @JsonKey(name: 'basic_salary') required double basicSalary,
    @JsonKey(name: 'gross_salary') required double grossSalary,
    @JsonKey(name: 'total_deductions') required double totalDeductions,
    @JsonKey(name: 'net_salary') required double netSalary,
  }) = _PayslipSummaryData;

  factory PayslipSummaryData.fromJson(Map<String, dynamic> json) =>
      _$PayslipSummaryDataFromJson(json);
}

@freezed
class PayslipStatutory with _$PayslipStatutory {
  const factory PayslipStatutory({
    @JsonKey(name: 'epf_employee') @Default(0) double epfEmployee,
    @JsonKey(name: 'epf_employer') @Default(0) double epfEmployer,
    @JsonKey(name: 'socso_employee') @Default(0) double socsoEmployee,
    @JsonKey(name: 'socso_employer') @Default(0) double socsoEmployer,
    @JsonKey(name: 'eis_employee') @Default(0) double eisEmployee,
    @JsonKey(name: 'eis_employer') @Default(0) double eisEmployer,
    @Default(0) double pcb,
    @Default(0) double zakat,
  }) = _PayslipStatutory;

  factory PayslipStatutory.fromJson(Map<String, dynamic> json) =>
      _$PayslipStatutoryFromJson(json);
}
