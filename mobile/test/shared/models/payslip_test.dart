import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/shared/models/payslip.dart';

void main() {
  group('PayslipSummary Model', () {
    test('creates PayslipSummary from JSON', () {
      final json = {
        'id': 1,
        'pay_period': '2025-01',
        'pay_date': '2025-01-31',
        'net_salary': 4800.0,
        'status': 'PUBLISHED',
      };

      final payslip = PayslipSummary.fromJson(json);

      expect(payslip.id, 1);
      expect(payslip.payPeriod, '2025-01');
      expect(payslip.payDate, '2025-01-31');
      expect(payslip.netSalary, 4800.0);
      expect(payslip.status, 'PUBLISHED');
    });

    test('PayslipSummary equality works correctly', () {
      const payslip1 = PayslipSummary(
        id: 1,
        payPeriod: '2025-01',
        payDate: '2025-01-31',
        netSalary: 4800.0,
        status: 'PUBLISHED',
      );

      const payslip2 = PayslipSummary(
        id: 1,
        payPeriod: '2025-01',
        payDate: '2025-01-31',
        netSalary: 4800.0,
        status: 'PUBLISHED',
      );

      expect(payslip1, equals(payslip2));
    });
  });

  group('PayslipLine Model', () {
    test('creates PayslipLine from JSON', () {
      final json = {
        'code': 'BASIC',
        'name': 'Basic Salary',
        'amount': 5500.0,
      };

      final line = PayslipLine.fromJson(json);

      expect(line.code, 'BASIC');
      expect(line.name, 'Basic Salary');
      expect(line.amount, 5500.0);
    });

    test('PayslipLine equality works', () {
      const line1 = PayslipLine(
        code: 'BASIC',
        name: 'Basic Salary',
        amount: 5500.0,
      );

      const line2 = PayslipLine(
        code: 'BASIC',
        name: 'Basic Salary',
        amount: 5500.0,
      );

      expect(line1, equals(line2));
    });
  });

  group('PayslipDetail Model', () {
    test('creates PayslipDetail from JSON', () {
      final json = {
        'id': 1,
        'pay_period': '2025-01',
        'pay_date': '2025-01-31',
        'employee': {
          'id': 1,
          'employee_no': 'EMP001',
          'full_name': 'John Doe',
        },
        'earnings': [
          {'code': 'BASIC', 'name': 'Basic Salary', 'amount': 5500.0},
          {'code': 'ALLOWANCE', 'name': 'Transport Allowance', 'amount': 500.0},
        ],
        'deductions': [
          {'code': 'EPF', 'name': 'EPF Employee', 'amount': 660.0},
        ],
        'summary': {
          'basic_salary': 5500.0,
          'gross_salary': 6000.0,
          'total_deductions': 1200.0,
          'net_salary': 4800.0,
        },
        'statutory': {
          'epf_employee': 660.0,
          'epf_employer': 780.0,
          'socso_employee': 23.65,
          'socso_employer': 82.95,
          'eis_employee': 12.0,
          'eis_employer': 12.0,
          'pcb': 250.0,
        },
        'has_pdf': true,
      };

      final detail = PayslipDetail.fromJson(json);

      expect(detail.id, 1);
      expect(detail.employee.fullName, 'John Doe');
      expect(detail.earnings.length, 2);
      expect(detail.deductions.length, 1);
      expect(detail.summary.netSalary, 4800.0);
      expect(detail.statutory.epfEmployee, 660.0);
      expect(detail.hasPdf, isTrue);
    });

    test('PayslipDetail separates earnings and deductions', () {
      const detail = PayslipDetail(
        id: 1,
        payPeriod: '2025-01',
        payDate: '2025-01-31',
        employee: PayslipEmployee(
          id: 1,
          employeeNo: 'EMP001',
          fullName: 'John Doe',
        ),
        earnings: [
          PayslipLine(code: 'BASIC', name: 'Basic', amount: 5500.0),
          PayslipLine(code: 'ALLOWANCE', name: 'Allowance', amount: 500.0),
        ],
        deductions: [
          PayslipLine(code: 'EPF', name: 'EPF', amount: 660.0),
        ],
        summary: PayslipSummaryData(
          basicSalary: 5500.0,
          grossSalary: 6000.0,
          totalDeductions: 660.0,
          netSalary: 5340.0,
        ),
        statutory: PayslipStatutory(
          epfEmployee: 660.0,
          epfEmployer: 780.0,
        ),
      );

      expect(detail.earnings.length, 2);
      expect(detail.deductions.length, 1);
      expect(detail.summary.grossSalary, 6000.0);
      expect(detail.summary.totalDeductions, 660.0);
    });
  });

  group('PayslipEmployee Model', () {
    test('creates PayslipEmployee from JSON', () {
      final json = {
        'id': 1,
        'employee_no': 'EMP001',
        'full_name': 'John Doe',
        'ic_no': '850101-01-1234',
        'epf_no': 'EPF123456',
        'bank_name': 'Maybank',
        'bank_account_no': '1234567890',
      };

      final employee = PayslipEmployee.fromJson(json);

      expect(employee.id, 1);
      expect(employee.employeeNo, 'EMP001');
      expect(employee.fullName, 'John Doe');
      expect(employee.icNo, '850101-01-1234');
      expect(employee.epfNo, 'EPF123456');
      expect(employee.bankName, 'Maybank');
    });
  });

  group('PayslipStatutory Model', () {
    test('creates PayslipStatutory from JSON', () {
      final json = {
        'epf_employee': 660.0,
        'epf_employer': 780.0,
        'socso_employee': 23.65,
        'socso_employer': 82.95,
        'eis_employee': 12.0,
        'eis_employer': 12.0,
        'pcb': 250.0,
        'zakat': 0.0,
      };

      final statutory = PayslipStatutory.fromJson(json);

      expect(statutory.epfEmployee, 660.0);
      expect(statutory.epfEmployer, 780.0);
      expect(statutory.socsoEmployee, 23.65);
      expect(statutory.pcb, 250.0);
    });

    test('PayslipStatutory has default values', () {
      const statutory = PayslipStatutory();

      expect(statutory.epfEmployee, 0);
      expect(statutory.epfEmployer, 0);
      expect(statutory.pcb, 0);
      expect(statutory.zakat, 0);
    });
  });

  group('PayslipSummaryData Model', () {
    test('creates PayslipSummaryData from JSON', () {
      final json = {
        'basic_salary': 5500.0,
        'gross_salary': 6000.0,
        'total_deductions': 1200.0,
        'net_salary': 4800.0,
      };

      final summary = PayslipSummaryData.fromJson(json);

      expect(summary.basicSalary, 5500.0);
      expect(summary.grossSalary, 6000.0);
      expect(summary.totalDeductions, 1200.0);
      expect(summary.netSalary, 4800.0);
    });
  });
}
