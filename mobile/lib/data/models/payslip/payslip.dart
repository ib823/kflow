import 'package:freezed_annotation/freezed_annotation.dart';

part 'payslip.freezed.dart';
part 'payslip.g.dart';

/// Payment status
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('paid')
  paid,
}

/// Payslip item (earning or deduction)
@freezed
class PayslipItem with _$PayslipItem {
  const factory PayslipItem({
    required String code,
    required String name,
    required double amount,
    String? description,
  }) = _PayslipItem;

  factory PayslipItem.fromJson(Map<String, dynamic> json) =>
      _$PayslipItemFromJson(json);
}

/// Payslip model
@freezed
class Payslip with _$Payslip {
  const Payslip._();

  const factory Payslip({
    required String id,
    required int month,
    required int year,
    required double basicSalary,
    required double grossSalary,
    required double totalDeductions,
    required double netSalary,
    required List<PayslipItem> earnings,
    required List<PayslipItem> deductions,
    required List<PayslipItem> employerContributions,
    required PaymentStatus status,
    DateTime? paidDate,
    String? pdfUrl,
    @Default(false) bool isNew,
  }) = _Payslip;

  factory Payslip.fromJson(Map<String, dynamic> json) =>
      _$PayslipFromJson(json);

  /// Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  /// Get display date (e.g., "December 2025")
  String get displayDate => '$monthName $year';
}
