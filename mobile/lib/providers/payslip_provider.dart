import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';

/// Payslip list state notifier
class PayslipListNotifier extends StateNotifier<AsyncValue<List<Payslip>>> {
  PayslipListNotifier() : super(const AsyncValue.loading());

  int _currentYear = DateTime.now().year;

  /// Get current filter year
  int get currentYear => _currentYear;

  /// Fetch payslips for a year
  Future<void> fetchPayslips({int? year}) async {
    if (year != null) _currentYear = year;

    state = const AsyncValue.loading();

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for development
      final payslips = List.generate(12, (index) {
        final month = 12 - index;
        return Payslip(
          id: 'payslip-$_currentYear-$month',
          month: month,
          year: _currentYear,
          basicSalary: 3500.0,
          grossSalary: 4550.0,
          totalDeductions: 300.0,
          netSalary: 4250.0 + (index * 50),
          earnings: [
            const PayslipItem(code: 'BASIC', name: 'Basic Salary', amount: 3500.0),
            const PayslipItem(code: 'ALLOW', name: 'Allowances', amount: 500.0),
            const PayslipItem(code: 'OT', name: 'Overtime', amount: 350.0),
            const PayslipItem(code: 'BONUS', name: 'Bonus', amount: 200.0),
          ],
          deductions: [
            const PayslipItem(code: 'EPF', name: 'EPF (Employee)', amount: 231.0),
            const PayslipItem(code: 'SOCSO', name: 'SOCSO', amount: 8.65),
            const PayslipItem(code: 'EIS', name: 'EIS', amount: 8.65),
            const PayslipItem(code: 'PCB', name: 'PCB (Tax)', amount: 51.70),
          ],
          employerContributions: [
            const PayslipItem(code: 'EPF_ER', name: 'EPF (Employer)', amount: 462.0),
            const PayslipItem(code: 'SOCSO_ER', name: 'SOCSO (Employer)', amount: 60.0),
            const PayslipItem(code: 'EIS_ER', name: 'EIS (Employer)', amount: 8.65),
          ],
          status: PaymentStatus.paid,
          paidDate: DateTime(_currentYear, month, 25),
          isNew: index == 0,
        );
      });

      state = AsyncValue.data(payslips);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Change filter year
  void setYear(int year) {
    if (year != _currentYear) {
      fetchPayslips(year: year);
    }
  }

  /// Refresh payslips
  Future<void> refresh() => fetchPayslips(year: _currentYear);
}

/// Payslip list provider
final payslipListProvider =
    StateNotifierProvider<PayslipListNotifier, AsyncValue<List<Payslip>>>((ref) {
  final notifier = PayslipListNotifier();
  notifier.fetchPayslips();
  return notifier;
});

/// Single payslip provider (by ID)
final payslipProvider =
    FutureProvider.family<Payslip?, String>((ref, id) async {
  final payslips = ref.watch(payslipListProvider);

  return payslips.whenOrNull(
    data: (list) {
      try {
        return list.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    },
  );
});

/// Available years provider for filter
final payslipYearsProvider = Provider<List<int>>((ref) {
  final currentYear = DateTime.now().year;
  return List.generate(5, (index) => currentYear - index);
});

/// Latest payslip provider
final latestPayslipProvider = Provider<Payslip?>((ref) {
  final payslips = ref.watch(payslipListProvider);
  return payslips.whenOrNull(
    data: (list) => list.isNotEmpty ? list.first : null,
  );
});
