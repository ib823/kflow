import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/payslip.dart';
import 'payslip_api.dart';

part 'payslip_repository.g.dart';

/// Repository for payslip data with caching.
class PayslipRepository {
  final PayslipApi _api;

  PayslipRepository(this._api);

  /// Get paginated payslip list.
  Future<PayslipListResponse> getPayslips({int page = 1, int? year}) =>
      _api.getPayslips(page: page, year: year);

  /// Get payslip detail (requires verification token).
  Future<Payslip> getPayslipDetail(int id, String verificationToken) =>
      _api.getPayslipDetail(id, verificationToken);

  /// Get payslip PDF bytes (requires verification token).
  Future<Uint8List> getPayslipPdf(int id, String verificationToken) =>
      _api.getPayslipPdf(id, verificationToken);
}

@riverpod
PayslipRepository payslipRepository(PayslipRepositoryRef ref) {
  return PayslipRepository(ref.watch(payslipApiProvider));
}
