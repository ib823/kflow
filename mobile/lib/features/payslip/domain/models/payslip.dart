import 'package:freezed_annotation/freezed_annotation.dart';

part 'payslip.freezed.dart';
part 'payslip.g.dart';

/// Full payslip detail from GET /api/v1/payslips/{id}
/// Requires PIN verification token.
@freezed
class Payslip with _$Payslip {
  const factory Payslip({
    required int id,
    required String period,
    required DateTime payDate,
    required String currencyCode,
    required String basicSalary,
    required String grossSalary,
    required String netSalary,
    required String totalEarnings,
    required String totalDeductions,
    required List<PayslipLine> earnings,
    required List<PayslipLine> deductions,
    required Map<String, String> statutoryContributions,
  }) = _Payslip;

  factory Payslip.fromJson(Map<String, dynamic> json) =>
      _$PayslipFromJson(json);
}

/// Individual payslip line item (earning or deduction).
@freezed
class PayslipLine with _$PayslipLine {
  const factory PayslipLine({
    required String code,
    required String name,
    required String category,
    required String amount,
    required bool isStatutory,
  }) = _PayslipLine;

  factory PayslipLine.fromJson(Map<String, dynamic> json) =>
      _$PayslipLineFromJson(json);
}

/// Payslip list item for grid view from GET /api/v1/payslips
@freezed
class PayslipListItem with _$PayslipListItem {
  const factory PayslipListItem({
    required int id,
    required String period,
    required DateTime payDate,
    required String netSalary,
    required String currencyCode,
  }) = _PayslipListItem;

  factory PayslipListItem.fromJson(Map<String, dynamic> json) =>
      _$PayslipListItemFromJson(json);
}

/// Paginated payslip list response
@freezed
class PayslipListResponse with _$PayslipListResponse {
  const factory PayslipListResponse({
    required List<PayslipListItem> items,
    required int total,
    required int page,
    required int perPage,
    required int totalPages,
  }) = _PayslipListResponse;

  factory PayslipListResponse.fromJson(Map<String, dynamic> json) =>
      _$PayslipListResponseFromJson(json);
}
