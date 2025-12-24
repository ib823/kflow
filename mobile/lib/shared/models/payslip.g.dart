// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payslip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PayslipSummaryImpl _$$PayslipSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PayslipSummaryImpl(
      id: (json['id'] as num).toInt(),
      payPeriod: json['pay_period'] as String,
      payDate: json['pay_date'] as String,
      netSalary: (json['net_salary'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$$PayslipSummaryImplToJson(
        _$PayslipSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pay_period': instance.payPeriod,
      'pay_date': instance.payDate,
      'net_salary': instance.netSalary,
      'status': instance.status,
    };

_$PayslipDetailImpl _$$PayslipDetailImplFromJson(Map<String, dynamic> json) =>
    _$PayslipDetailImpl(
      id: (json['id'] as num).toInt(),
      payPeriod: json['pay_period'] as String,
      payDate: json['pay_date'] as String,
      employee:
          PayslipEmployee.fromJson(json['employee'] as Map<String, dynamic>),
      earnings: (json['earnings'] as List<dynamic>)
          .map((e) => PayslipLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      deductions: (json['deductions'] as List<dynamic>)
          .map((e) => PayslipLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary:
          PayslipSummaryData.fromJson(json['summary'] as Map<String, dynamic>),
      statutory:
          PayslipStatutory.fromJson(json['statutory'] as Map<String, dynamic>),
      hasPdf: json['has_pdf'] as bool? ?? false,
    );

Map<String, dynamic> _$$PayslipDetailImplToJson(_$PayslipDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pay_period': instance.payPeriod,
      'pay_date': instance.payDate,
      'employee': instance.employee,
      'earnings': instance.earnings,
      'deductions': instance.deductions,
      'summary': instance.summary,
      'statutory': instance.statutory,
      'has_pdf': instance.hasPdf,
    };

_$PayslipEmployeeImpl _$$PayslipEmployeeImplFromJson(
        Map<String, dynamic> json) =>
    _$PayslipEmployeeImpl(
      id: (json['id'] as num).toInt(),
      employeeNo: json['employee_no'] as String,
      fullName: json['full_name'] as String,
      icNo: json['ic_no'] as String?,
      epfNo: json['epf_no'] as String?,
      socsoNo: json['socso_no'] as String?,
      bankName: json['bank_name'] as String?,
      bankAccountNo: json['bank_account_no'] as String?,
    );

Map<String, dynamic> _$$PayslipEmployeeImplToJson(
        _$PayslipEmployeeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_no': instance.employeeNo,
      'full_name': instance.fullName,
      'ic_no': instance.icNo,
      'epf_no': instance.epfNo,
      'socso_no': instance.socsoNo,
      'bank_name': instance.bankName,
      'bank_account_no': instance.bankAccountNo,
    };

_$PayslipLineImpl _$$PayslipLineImplFromJson(Map<String, dynamic> json) =>
    _$PayslipLineImpl(
      code: json['code'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$PayslipLineImplToJson(_$PayslipLineImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'amount': instance.amount,
    };

_$PayslipSummaryDataImpl _$$PayslipSummaryDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PayslipSummaryDataImpl(
      basicSalary: (json['basic_salary'] as num).toDouble(),
      grossSalary: (json['gross_salary'] as num).toDouble(),
      totalDeductions: (json['total_deductions'] as num).toDouble(),
      netSalary: (json['net_salary'] as num).toDouble(),
    );

Map<String, dynamic> _$$PayslipSummaryDataImplToJson(
        _$PayslipSummaryDataImpl instance) =>
    <String, dynamic>{
      'basic_salary': instance.basicSalary,
      'gross_salary': instance.grossSalary,
      'total_deductions': instance.totalDeductions,
      'net_salary': instance.netSalary,
    };

_$PayslipStatutoryImpl _$$PayslipStatutoryImplFromJson(
        Map<String, dynamic> json) =>
    _$PayslipStatutoryImpl(
      epfEmployee: (json['epf_employee'] as num?)?.toDouble() ?? 0,
      epfEmployer: (json['epf_employer'] as num?)?.toDouble() ?? 0,
      socsoEmployee: (json['socso_employee'] as num?)?.toDouble() ?? 0,
      socsoEmployer: (json['socso_employer'] as num?)?.toDouble() ?? 0,
      eisEmployee: (json['eis_employee'] as num?)?.toDouble() ?? 0,
      eisEmployer: (json['eis_employer'] as num?)?.toDouble() ?? 0,
      pcb: (json['pcb'] as num?)?.toDouble() ?? 0,
      zakat: (json['zakat'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$PayslipStatutoryImplToJson(
        _$PayslipStatutoryImpl instance) =>
    <String, dynamic>{
      'epf_employee': instance.epfEmployee,
      'epf_employer': instance.epfEmployer,
      'socso_employee': instance.socsoEmployee,
      'socso_employer': instance.socsoEmployer,
      'eis_employee': instance.eisEmployee,
      'eis_employer': instance.eisEmployer,
      'pcb': instance.pcb,
      'zakat': instance.zakat,
    };
