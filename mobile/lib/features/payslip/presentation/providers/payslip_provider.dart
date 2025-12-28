import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/payslip_repository.dart';
import '../../domain/models/payslip.dart';

part 'payslip_provider.g.dart';

/// Provider for payslip list with year filter.
@riverpod
class PayslipListNotifier extends _$PayslipListNotifier {
  int _currentYear = DateTime.now().year;

  @override
  Future<PayslipListResponse> build() async {
    return ref.watch(payslipRepositoryProvider).getPayslips(year: _currentYear);
  }

  /// Change year filter and refresh.
  Future<void> setYear(int year) async {
    _currentYear = year;
    ref.invalidateSelf();
  }

  /// Get current year filter.
  int get currentYear => _currentYear;

  /// Refresh list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(payslipRepositoryProvider).getPayslips(year: _currentYear),
    );
  }
}

/// Provider for payslip detail (requires verification token).
@riverpod
Future<Payslip> payslipDetail(
  PayslipDetailRef ref, {
  required int id,
  required String verificationToken,
}) async {
  return ref.watch(payslipRepositoryProvider).getPayslipDetail(id, verificationToken);
}

/// Provider for payslip PDF bytes (requires verification token).
@riverpod
Future<Uint8List> payslipPdf(
  PayslipPdfRef ref, {
  required int id,
  required String verificationToken,
}) async {
  return ref.watch(payslipRepositoryProvider).getPayslipPdf(id, verificationToken);
}

/// Provider for available years (computed from payslips).
@riverpod
List<int> availablePayslipYears(AvailablePayslipYearsRef ref) {
  final currentYear = DateTime.now().year;
  // Show last 5 years
  return List.generate(5, (i) => currentYear - i);
}
