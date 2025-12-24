// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payslip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PayslipSummary _$PayslipSummaryFromJson(Map<String, dynamic> json) {
  return _PayslipSummary.fromJson(json);
}

/// @nodoc
mixin _$PayslipSummary {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'pay_period')
  String get payPeriod => throw _privateConstructorUsedError;
  @JsonKey(name: 'pay_date')
  String get payDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_salary')
  double get netSalary => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this PayslipSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayslipSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayslipSummaryCopyWith<PayslipSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayslipSummaryCopyWith<$Res> {
  factory $PayslipSummaryCopyWith(
          PayslipSummary value, $Res Function(PayslipSummary) then) =
      _$PayslipSummaryCopyWithImpl<$Res, PayslipSummary>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'pay_period') String payPeriod,
      @JsonKey(name: 'pay_date') String payDate,
      @JsonKey(name: 'net_salary') double netSalary,
      String status});
}

/// @nodoc
class _$PayslipSummaryCopyWithImpl<$Res, $Val extends PayslipSummary>
    implements $PayslipSummaryCopyWith<$Res> {
  _$PayslipSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayslipSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? payPeriod = null,
    Object? payDate = null,
    Object? netSalary = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      payPeriod: null == payPeriod
          ? _value.payPeriod
          : payPeriod // ignore: cast_nullable_to_non_nullable
              as String,
      payDate: null == payDate
          ? _value.payDate
          : payDate // ignore: cast_nullable_to_non_nullable
              as String,
      netSalary: null == netSalary
          ? _value.netSalary
          : netSalary // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PayslipSummaryImplCopyWith<$Res>
    implements $PayslipSummaryCopyWith<$Res> {
  factory _$$PayslipSummaryImplCopyWith(_$PayslipSummaryImpl value,
          $Res Function(_$PayslipSummaryImpl) then) =
      __$$PayslipSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'pay_period') String payPeriod,
      @JsonKey(name: 'pay_date') String payDate,
      @JsonKey(name: 'net_salary') double netSalary,
      String status});
}

/// @nodoc
class __$$PayslipSummaryImplCopyWithImpl<$Res>
    extends _$PayslipSummaryCopyWithImpl<$Res, _$PayslipSummaryImpl>
    implements _$$PayslipSummaryImplCopyWith<$Res> {
  __$$PayslipSummaryImplCopyWithImpl(
      _$PayslipSummaryImpl _value, $Res Function(_$PayslipSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PayslipSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? payPeriod = null,
    Object? payDate = null,
    Object? netSalary = null,
    Object? status = null,
  }) {
    return _then(_$PayslipSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      payPeriod: null == payPeriod
          ? _value.payPeriod
          : payPeriod // ignore: cast_nullable_to_non_nullable
              as String,
      payDate: null == payDate
          ? _value.payDate
          : payDate // ignore: cast_nullable_to_non_nullable
              as String,
      netSalary: null == netSalary
          ? _value.netSalary
          : netSalary // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PayslipSummaryImpl implements _PayslipSummary {
  const _$PayslipSummaryImpl(
      {required this.id,
      @JsonKey(name: 'pay_period') required this.payPeriod,
      @JsonKey(name: 'pay_date') required this.payDate,
      @JsonKey(name: 'net_salary') required this.netSalary,
      required this.status});

  factory _$PayslipSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayslipSummaryImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'pay_period')
  final String payPeriod;
  @override
  @JsonKey(name: 'pay_date')
  final String payDate;
  @override
  @JsonKey(name: 'net_salary')
  final double netSalary;
  @override
  final String status;

  @override
  String toString() {
    return 'PayslipSummary(id: $id, payPeriod: $payPeriod, payDate: $payDate, netSalary: $netSalary, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayslipSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.payPeriod, payPeriod) ||
                other.payPeriod == payPeriod) &&
            (identical(other.payDate, payDate) || other.payDate == payDate) &&
            (identical(other.netSalary, netSalary) ||
                other.netSalary == netSalary) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, payPeriod, payDate, netSalary, status);

  /// Create a copy of PayslipSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayslipSummaryImplCopyWith<_$PayslipSummaryImpl> get copyWith =>
      __$$PayslipSummaryImplCopyWithImpl<_$PayslipSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayslipSummaryImplToJson(
      this,
    );
  }
}

abstract class _PayslipSummary implements PayslipSummary {
  const factory _PayslipSummary(
      {required final int id,
      @JsonKey(name: 'pay_period') required final String payPeriod,
      @JsonKey(name: 'pay_date') required final String payDate,
      @JsonKey(name: 'net_salary') required final double netSalary,
      required final String status}) = _$PayslipSummaryImpl;

  factory _PayslipSummary.fromJson(Map<String, dynamic> json) =
      _$PayslipSummaryImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'pay_period')
  String get payPeriod;
  @override
  @JsonKey(name: 'pay_date')
  String get payDate;
  @override
  @JsonKey(name: 'net_salary')
  double get netSalary;
  @override
  String get status;

  /// Create a copy of PayslipSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayslipSummaryImplCopyWith<_$PayslipSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PayslipDetail _$PayslipDetailFromJson(Map<String, dynamic> json) {
  return _PayslipDetail.fromJson(json);
}

/// @nodoc
mixin _$PayslipDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'pay_period')
  String get payPeriod => throw _privateConstructorUsedError;
  @JsonKey(name: 'pay_date')
  String get payDate => throw _privateConstructorUsedError;
  PayslipEmployee get employee => throw _privateConstructorUsedError;
  List<PayslipLine> get earnings => throw _privateConstructorUsedError;
  List<PayslipLine> get deductions => throw _privateConstructorUsedError;
  PayslipSummaryData get summary => throw _privateConstructorUsedError;
  PayslipStatutory get statutory => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_pdf')
  bool get hasPdf => throw _privateConstructorUsedError;

  /// Serializes this PayslipDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayslipDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayslipDetailCopyWith<PayslipDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayslipDetailCopyWith<$Res> {
  factory $PayslipDetailCopyWith(
          PayslipDetail value, $Res Function(PayslipDetail) then) =
      _$PayslipDetailCopyWithImpl<$Res, PayslipDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'pay_period') String payPeriod,
      @JsonKey(name: 'pay_date') String payDate,
      PayslipEmployee employee,
      List<PayslipLine> earnings,
      List<PayslipLine> deductions,
      PayslipSummaryData summary,
      PayslipStatutory statutory,
      @JsonKey(name: 'has_pdf') bool hasPdf});

  $PayslipEmployeeCopyWith<$Res> get employee;
  $PayslipSummaryDataCopyWith<$Res> get summary;
  $PayslipStatutoryCopyWith<$Res> get statutory;
}

/// @nodoc
class _$PayslipDetailCopyWithImpl<$Res, $Val extends PayslipDetail>
    implements $PayslipDetailCopyWith<$Res> {
  _$PayslipDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayslipDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? payPeriod = null,
    Object? payDate = null,
    Object? employee = null,
    Object? earnings = null,
    Object? deductions = null,
    Object? summary = null,
    Object? statutory = null,
    Object? hasPdf = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      payPeriod: null == payPeriod
          ? _value.payPeriod
          : payPeriod // ignore: cast_nullable_to_non_nullable
              as String,
      payDate: null == payDate
          ? _value.payDate
          : payDate // ignore: cast_nullable_to_non_nullable
              as String,
      employee: null == employee
          ? _value.employee
          : employee // ignore: cast_nullable_to_non_nullable
              as PayslipEmployee,
      earnings: null == earnings
          ? _value.earnings
          : earnings // ignore: cast_nullable_to_non_nullable
              as List<PayslipLine>,
      deductions: null == deductions
          ? _value.deductions
          : deductions // ignore: cast_nullable_to_non_nullable
              as List<PayslipLine>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as PayslipSummaryData,
      statutory: null == statutory
          ? _value.statutory
          : statutory // ignore: cast_nullable_to_non_nullable
              as PayslipStatutory,
      hasPdf: null == hasPdf
          ? _value.hasPdf
          : hasPdf // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of PayslipDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PayslipEmployeeCopyWith<$Res> get employee {
    return $PayslipEmployeeCopyWith<$Res>(_value.employee, (value) {
      return _then(_value.copyWith(employee: value) as $Val);
    });
  }

  /// Create a copy of PayslipDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PayslipSummaryDataCopyWith<$Res> get summary {
    return $PayslipSummaryDataCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  /// Create a copy of PayslipDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PayslipStatutoryCopyWith<$Res> get statutory {
    return $PayslipStatutoryCopyWith<$Res>(_value.statutory, (value) {
      return _then(_value.copyWith(statutory: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PayslipDetailImplCopyWith<$Res>
    implements $PayslipDetailCopyWith<$Res> {
  factory _$$PayslipDetailImplCopyWith(
          _$PayslipDetailImpl value, $Res Function(_$PayslipDetailImpl) then) =
      __$$PayslipDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'pay_period') String payPeriod,
      @JsonKey(name: 'pay_date') String payDate,
      PayslipEmployee employee,
      List<PayslipLine> earnings,
      List<PayslipLine> deductions,
      PayslipSummaryData summary,
      PayslipStatutory statutory,
      @JsonKey(name: 'has_pdf') bool hasPdf});

  @override
  $PayslipEmployeeCopyWith<$Res> get employee;
  @override
  $PayslipSummaryDataCopyWith<$Res> get summary;
  @override
  $PayslipStatutoryCopyWith<$Res> get statutory;
}

/// @nodoc
class __$$PayslipDetailImplCopyWithImpl<$Res>
    extends _$PayslipDetailCopyWithImpl<$Res, _$PayslipDetailImpl>
    implements _$$PayslipDetailImplCopyWith<$Res> {
  __$$PayslipDetailImplCopyWithImpl(
      _$PayslipDetailImpl _value, $Res Function(_$PayslipDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of PayslipDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? payPeriod = null,
    Object? payDate = null,
    Object? employee = null,
    Object? earnings = null,
    Object? deductions = null,
    Object? summary = null,
    Object? statutory = null,
    Object? hasPdf = null,
  }) {
    return _then(_$PayslipDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      payPeriod: null == payPeriod
          ? _value.payPeriod
          : payPeriod // ignore: cast_nullable_to_non_nullable
              as String,
      payDate: null == payDate
          ? _value.payDate
          : payDate // ignore: cast_nullable_to_non_nullable
              as String,
      employee: null == employee
          ? _value.employee
          : employee // ignore: cast_nullable_to_non_nullable
              as PayslipEmployee,
      earnings: null == earnings
          ? _value._earnings
          : earnings // ignore: cast_nullable_to_non_nullable
              as List<PayslipLine>,
      deductions: null == deductions
          ? _value._deductions
          : deductions // ignore: cast_nullable_to_non_nullable
              as List<PayslipLine>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as PayslipSummaryData,
      statutory: null == statutory
          ? _value.statutory
          : statutory // ignore: cast_nullable_to_non_nullable
              as PayslipStatutory,
      hasPdf: null == hasPdf
          ? _value.hasPdf
          : hasPdf // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PayslipDetailImpl implements _PayslipDetail {
  const _$PayslipDetailImpl(
      {required this.id,
      @JsonKey(name: 'pay_period') required this.payPeriod,
      @JsonKey(name: 'pay_date') required this.payDate,
      required this.employee,
      required final List<PayslipLine> earnings,
      required final List<PayslipLine> deductions,
      required this.summary,
      required this.statutory,
      @JsonKey(name: 'has_pdf') this.hasPdf = false})
      : _earnings = earnings,
        _deductions = deductions;

  factory _$PayslipDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayslipDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'pay_period')
  final String payPeriod;
  @override
  @JsonKey(name: 'pay_date')
  final String payDate;
  @override
  final PayslipEmployee employee;
  final List<PayslipLine> _earnings;
  @override
  List<PayslipLine> get earnings {
    if (_earnings is EqualUnmodifiableListView) return _earnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_earnings);
  }

  final List<PayslipLine> _deductions;
  @override
  List<PayslipLine> get deductions {
    if (_deductions is EqualUnmodifiableListView) return _deductions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deductions);
  }

  @override
  final PayslipSummaryData summary;
  @override
  final PayslipStatutory statutory;
  @override
  @JsonKey(name: 'has_pdf')
  final bool hasPdf;

  @override
  String toString() {
    return 'PayslipDetail(id: $id, payPeriod: $payPeriod, payDate: $payDate, employee: $employee, earnings: $earnings, deductions: $deductions, summary: $summary, statutory: $statutory, hasPdf: $hasPdf)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayslipDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.payPeriod, payPeriod) ||
                other.payPeriod == payPeriod) &&
            (identical(other.payDate, payDate) || other.payDate == payDate) &&
            (identical(other.employee, employee) ||
                other.employee == employee) &&
            const DeepCollectionEquality().equals(other._earnings, _earnings) &&
            const DeepCollectionEquality()
                .equals(other._deductions, _deductions) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.statutory, statutory) ||
                other.statutory == statutory) &&
            (identical(other.hasPdf, hasPdf) || other.hasPdf == hasPdf));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      payPeriod,
      payDate,
      employee,
      const DeepCollectionEquality().hash(_earnings),
      const DeepCollectionEquality().hash(_deductions),
      summary,
      statutory,
      hasPdf);

  /// Create a copy of PayslipDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayslipDetailImplCopyWith<_$PayslipDetailImpl> get copyWith =>
      __$$PayslipDetailImplCopyWithImpl<_$PayslipDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayslipDetailImplToJson(
      this,
    );
  }
}

abstract class _PayslipDetail implements PayslipDetail {
  const factory _PayslipDetail(
      {required final int id,
      @JsonKey(name: 'pay_period') required final String payPeriod,
      @JsonKey(name: 'pay_date') required final String payDate,
      required final PayslipEmployee employee,
      required final List<PayslipLine> earnings,
      required final List<PayslipLine> deductions,
      required final PayslipSummaryData summary,
      required final PayslipStatutory statutory,
      @JsonKey(name: 'has_pdf') final bool hasPdf}) = _$PayslipDetailImpl;

  factory _PayslipDetail.fromJson(Map<String, dynamic> json) =
      _$PayslipDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'pay_period')
  String get payPeriod;
  @override
  @JsonKey(name: 'pay_date')
  String get payDate;
  @override
  PayslipEmployee get employee;
  @override
  List<PayslipLine> get earnings;
  @override
  List<PayslipLine> get deductions;
  @override
  PayslipSummaryData get summary;
  @override
  PayslipStatutory get statutory;
  @override
  @JsonKey(name: 'has_pdf')
  bool get hasPdf;

  /// Create a copy of PayslipDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayslipDetailImplCopyWith<_$PayslipDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PayslipEmployee _$PayslipEmployeeFromJson(Map<String, dynamic> json) {
  return _PayslipEmployee.fromJson(json);
}

/// @nodoc
mixin _$PayslipEmployee {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'employee_no')
  String get employeeNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'ic_no')
  String? get icNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'epf_no')
  String? get epfNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'socso_no')
  String? get socsoNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'bank_name')
  String? get bankName => throw _privateConstructorUsedError;
  @JsonKey(name: 'bank_account_no')
  String? get bankAccountNo => throw _privateConstructorUsedError;

  /// Serializes this PayslipEmployee to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayslipEmployee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayslipEmployeeCopyWith<PayslipEmployee> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayslipEmployeeCopyWith<$Res> {
  factory $PayslipEmployeeCopyWith(
          PayslipEmployee value, $Res Function(PayslipEmployee) then) =
      _$PayslipEmployeeCopyWithImpl<$Res, PayslipEmployee>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'employee_no') String employeeNo,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'ic_no') String? icNo,
      @JsonKey(name: 'epf_no') String? epfNo,
      @JsonKey(name: 'socso_no') String? socsoNo,
      @JsonKey(name: 'bank_name') String? bankName,
      @JsonKey(name: 'bank_account_no') String? bankAccountNo});
}

/// @nodoc
class _$PayslipEmployeeCopyWithImpl<$Res, $Val extends PayslipEmployee>
    implements $PayslipEmployeeCopyWith<$Res> {
  _$PayslipEmployeeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayslipEmployee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeNo = null,
    Object? fullName = null,
    Object? icNo = freezed,
    Object? epfNo = freezed,
    Object? socsoNo = freezed,
    Object? bankName = freezed,
    Object? bankAccountNo = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      employeeNo: null == employeeNo
          ? _value.employeeNo
          : employeeNo // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      icNo: freezed == icNo
          ? _value.icNo
          : icNo // ignore: cast_nullable_to_non_nullable
              as String?,
      epfNo: freezed == epfNo
          ? _value.epfNo
          : epfNo // ignore: cast_nullable_to_non_nullable
              as String?,
      socsoNo: freezed == socsoNo
          ? _value.socsoNo
          : socsoNo // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      bankAccountNo: freezed == bankAccountNo
          ? _value.bankAccountNo
          : bankAccountNo // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PayslipEmployeeImplCopyWith<$Res>
    implements $PayslipEmployeeCopyWith<$Res> {
  factory _$$PayslipEmployeeImplCopyWith(_$PayslipEmployeeImpl value,
          $Res Function(_$PayslipEmployeeImpl) then) =
      __$$PayslipEmployeeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'employee_no') String employeeNo,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'ic_no') String? icNo,
      @JsonKey(name: 'epf_no') String? epfNo,
      @JsonKey(name: 'socso_no') String? socsoNo,
      @JsonKey(name: 'bank_name') String? bankName,
      @JsonKey(name: 'bank_account_no') String? bankAccountNo});
}

/// @nodoc
class __$$PayslipEmployeeImplCopyWithImpl<$Res>
    extends _$PayslipEmployeeCopyWithImpl<$Res, _$PayslipEmployeeImpl>
    implements _$$PayslipEmployeeImplCopyWith<$Res> {
  __$$PayslipEmployeeImplCopyWithImpl(
      _$PayslipEmployeeImpl _value, $Res Function(_$PayslipEmployeeImpl) _then)
      : super(_value, _then);

  /// Create a copy of PayslipEmployee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeNo = null,
    Object? fullName = null,
    Object? icNo = freezed,
    Object? epfNo = freezed,
    Object? socsoNo = freezed,
    Object? bankName = freezed,
    Object? bankAccountNo = freezed,
  }) {
    return _then(_$PayslipEmployeeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      employeeNo: null == employeeNo
          ? _value.employeeNo
          : employeeNo // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      icNo: freezed == icNo
          ? _value.icNo
          : icNo // ignore: cast_nullable_to_non_nullable
              as String?,
      epfNo: freezed == epfNo
          ? _value.epfNo
          : epfNo // ignore: cast_nullable_to_non_nullable
              as String?,
      socsoNo: freezed == socsoNo
          ? _value.socsoNo
          : socsoNo // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      bankAccountNo: freezed == bankAccountNo
          ? _value.bankAccountNo
          : bankAccountNo // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PayslipEmployeeImpl implements _PayslipEmployee {
  const _$PayslipEmployeeImpl(
      {required this.id,
      @JsonKey(name: 'employee_no') required this.employeeNo,
      @JsonKey(name: 'full_name') required this.fullName,
      @JsonKey(name: 'ic_no') this.icNo,
      @JsonKey(name: 'epf_no') this.epfNo,
      @JsonKey(name: 'socso_no') this.socsoNo,
      @JsonKey(name: 'bank_name') this.bankName,
      @JsonKey(name: 'bank_account_no') this.bankAccountNo});

  factory _$PayslipEmployeeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayslipEmployeeImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'employee_no')
  final String employeeNo;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'ic_no')
  final String? icNo;
  @override
  @JsonKey(name: 'epf_no')
  final String? epfNo;
  @override
  @JsonKey(name: 'socso_no')
  final String? socsoNo;
  @override
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @override
  @JsonKey(name: 'bank_account_no')
  final String? bankAccountNo;

  @override
  String toString() {
    return 'PayslipEmployee(id: $id, employeeNo: $employeeNo, fullName: $fullName, icNo: $icNo, epfNo: $epfNo, socsoNo: $socsoNo, bankName: $bankName, bankAccountNo: $bankAccountNo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayslipEmployeeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeNo, employeeNo) ||
                other.employeeNo == employeeNo) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.icNo, icNo) || other.icNo == icNo) &&
            (identical(other.epfNo, epfNo) || other.epfNo == epfNo) &&
            (identical(other.socsoNo, socsoNo) || other.socsoNo == socsoNo) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.bankAccountNo, bankAccountNo) ||
                other.bankAccountNo == bankAccountNo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, employeeNo, fullName, icNo,
      epfNo, socsoNo, bankName, bankAccountNo);

  /// Create a copy of PayslipEmployee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayslipEmployeeImplCopyWith<_$PayslipEmployeeImpl> get copyWith =>
      __$$PayslipEmployeeImplCopyWithImpl<_$PayslipEmployeeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayslipEmployeeImplToJson(
      this,
    );
  }
}

abstract class _PayslipEmployee implements PayslipEmployee {
  const factory _PayslipEmployee(
          {required final int id,
          @JsonKey(name: 'employee_no') required final String employeeNo,
          @JsonKey(name: 'full_name') required final String fullName,
          @JsonKey(name: 'ic_no') final String? icNo,
          @JsonKey(name: 'epf_no') final String? epfNo,
          @JsonKey(name: 'socso_no') final String? socsoNo,
          @JsonKey(name: 'bank_name') final String? bankName,
          @JsonKey(name: 'bank_account_no') final String? bankAccountNo}) =
      _$PayslipEmployeeImpl;

  factory _PayslipEmployee.fromJson(Map<String, dynamic> json) =
      _$PayslipEmployeeImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'employee_no')
  String get employeeNo;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'ic_no')
  String? get icNo;
  @override
  @JsonKey(name: 'epf_no')
  String? get epfNo;
  @override
  @JsonKey(name: 'socso_no')
  String? get socsoNo;
  @override
  @JsonKey(name: 'bank_name')
  String? get bankName;
  @override
  @JsonKey(name: 'bank_account_no')
  String? get bankAccountNo;

  /// Create a copy of PayslipEmployee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayslipEmployeeImplCopyWith<_$PayslipEmployeeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PayslipLine _$PayslipLineFromJson(Map<String, dynamic> json) {
  return _PayslipLine.fromJson(json);
}

/// @nodoc
mixin _$PayslipLine {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this PayslipLine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayslipLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayslipLineCopyWith<PayslipLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayslipLineCopyWith<$Res> {
  factory $PayslipLineCopyWith(
          PayslipLine value, $Res Function(PayslipLine) then) =
      _$PayslipLineCopyWithImpl<$Res, PayslipLine>;
  @useResult
  $Res call({String code, String name, double amount});
}

/// @nodoc
class _$PayslipLineCopyWithImpl<$Res, $Val extends PayslipLine>
    implements $PayslipLineCopyWith<$Res> {
  _$PayslipLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayslipLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? amount = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PayslipLineImplCopyWith<$Res>
    implements $PayslipLineCopyWith<$Res> {
  factory _$$PayslipLineImplCopyWith(
          _$PayslipLineImpl value, $Res Function(_$PayslipLineImpl) then) =
      __$$PayslipLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, double amount});
}

/// @nodoc
class __$$PayslipLineImplCopyWithImpl<$Res>
    extends _$PayslipLineCopyWithImpl<$Res, _$PayslipLineImpl>
    implements _$$PayslipLineImplCopyWith<$Res> {
  __$$PayslipLineImplCopyWithImpl(
      _$PayslipLineImpl _value, $Res Function(_$PayslipLineImpl) _then)
      : super(_value, _then);

  /// Create a copy of PayslipLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? amount = null,
  }) {
    return _then(_$PayslipLineImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PayslipLineImpl implements _PayslipLine {
  const _$PayslipLineImpl(
      {required this.code, required this.name, required this.amount});

  factory _$PayslipLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayslipLineImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final double amount;

  @override
  String toString() {
    return 'PayslipLine(code: $code, name: $name, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayslipLineImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, name, amount);

  /// Create a copy of PayslipLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayslipLineImplCopyWith<_$PayslipLineImpl> get copyWith =>
      __$$PayslipLineImplCopyWithImpl<_$PayslipLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayslipLineImplToJson(
      this,
    );
  }
}

abstract class _PayslipLine implements PayslipLine {
  const factory _PayslipLine(
      {required final String code,
      required final String name,
      required final double amount}) = _$PayslipLineImpl;

  factory _PayslipLine.fromJson(Map<String, dynamic> json) =
      _$PayslipLineImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  double get amount;

  /// Create a copy of PayslipLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayslipLineImplCopyWith<_$PayslipLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PayslipSummaryData _$PayslipSummaryDataFromJson(Map<String, dynamic> json) {
  return _PayslipSummaryData.fromJson(json);
}

/// @nodoc
mixin _$PayslipSummaryData {
  @JsonKey(name: 'basic_salary')
  double get basicSalary => throw _privateConstructorUsedError;
  @JsonKey(name: 'gross_salary')
  double get grossSalary => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_deductions')
  double get totalDeductions => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_salary')
  double get netSalary => throw _privateConstructorUsedError;

  /// Serializes this PayslipSummaryData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayslipSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayslipSummaryDataCopyWith<PayslipSummaryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayslipSummaryDataCopyWith<$Res> {
  factory $PayslipSummaryDataCopyWith(
          PayslipSummaryData value, $Res Function(PayslipSummaryData) then) =
      _$PayslipSummaryDataCopyWithImpl<$Res, PayslipSummaryData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'basic_salary') double basicSalary,
      @JsonKey(name: 'gross_salary') double grossSalary,
      @JsonKey(name: 'total_deductions') double totalDeductions,
      @JsonKey(name: 'net_salary') double netSalary});
}

/// @nodoc
class _$PayslipSummaryDataCopyWithImpl<$Res, $Val extends PayslipSummaryData>
    implements $PayslipSummaryDataCopyWith<$Res> {
  _$PayslipSummaryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayslipSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? basicSalary = null,
    Object? grossSalary = null,
    Object? totalDeductions = null,
    Object? netSalary = null,
  }) {
    return _then(_value.copyWith(
      basicSalary: null == basicSalary
          ? _value.basicSalary
          : basicSalary // ignore: cast_nullable_to_non_nullable
              as double,
      grossSalary: null == grossSalary
          ? _value.grossSalary
          : grossSalary // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeductions: null == totalDeductions
          ? _value.totalDeductions
          : totalDeductions // ignore: cast_nullable_to_non_nullable
              as double,
      netSalary: null == netSalary
          ? _value.netSalary
          : netSalary // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PayslipSummaryDataImplCopyWith<$Res>
    implements $PayslipSummaryDataCopyWith<$Res> {
  factory _$$PayslipSummaryDataImplCopyWith(_$PayslipSummaryDataImpl value,
          $Res Function(_$PayslipSummaryDataImpl) then) =
      __$$PayslipSummaryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'basic_salary') double basicSalary,
      @JsonKey(name: 'gross_salary') double grossSalary,
      @JsonKey(name: 'total_deductions') double totalDeductions,
      @JsonKey(name: 'net_salary') double netSalary});
}

/// @nodoc
class __$$PayslipSummaryDataImplCopyWithImpl<$Res>
    extends _$PayslipSummaryDataCopyWithImpl<$Res, _$PayslipSummaryDataImpl>
    implements _$$PayslipSummaryDataImplCopyWith<$Res> {
  __$$PayslipSummaryDataImplCopyWithImpl(_$PayslipSummaryDataImpl _value,
      $Res Function(_$PayslipSummaryDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of PayslipSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? basicSalary = null,
    Object? grossSalary = null,
    Object? totalDeductions = null,
    Object? netSalary = null,
  }) {
    return _then(_$PayslipSummaryDataImpl(
      basicSalary: null == basicSalary
          ? _value.basicSalary
          : basicSalary // ignore: cast_nullable_to_non_nullable
              as double,
      grossSalary: null == grossSalary
          ? _value.grossSalary
          : grossSalary // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeductions: null == totalDeductions
          ? _value.totalDeductions
          : totalDeductions // ignore: cast_nullable_to_non_nullable
              as double,
      netSalary: null == netSalary
          ? _value.netSalary
          : netSalary // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PayslipSummaryDataImpl implements _PayslipSummaryData {
  const _$PayslipSummaryDataImpl(
      {@JsonKey(name: 'basic_salary') required this.basicSalary,
      @JsonKey(name: 'gross_salary') required this.grossSalary,
      @JsonKey(name: 'total_deductions') required this.totalDeductions,
      @JsonKey(name: 'net_salary') required this.netSalary});

  factory _$PayslipSummaryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayslipSummaryDataImplFromJson(json);

  @override
  @JsonKey(name: 'basic_salary')
  final double basicSalary;
  @override
  @JsonKey(name: 'gross_salary')
  final double grossSalary;
  @override
  @JsonKey(name: 'total_deductions')
  final double totalDeductions;
  @override
  @JsonKey(name: 'net_salary')
  final double netSalary;

  @override
  String toString() {
    return 'PayslipSummaryData(basicSalary: $basicSalary, grossSalary: $grossSalary, totalDeductions: $totalDeductions, netSalary: $netSalary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayslipSummaryDataImpl &&
            (identical(other.basicSalary, basicSalary) ||
                other.basicSalary == basicSalary) &&
            (identical(other.grossSalary, grossSalary) ||
                other.grossSalary == grossSalary) &&
            (identical(other.totalDeductions, totalDeductions) ||
                other.totalDeductions == totalDeductions) &&
            (identical(other.netSalary, netSalary) ||
                other.netSalary == netSalary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, basicSalary, grossSalary, totalDeductions, netSalary);

  /// Create a copy of PayslipSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayslipSummaryDataImplCopyWith<_$PayslipSummaryDataImpl> get copyWith =>
      __$$PayslipSummaryDataImplCopyWithImpl<_$PayslipSummaryDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayslipSummaryDataImplToJson(
      this,
    );
  }
}

abstract class _PayslipSummaryData implements PayslipSummaryData {
  const factory _PayslipSummaryData(
      {@JsonKey(name: 'basic_salary') required final double basicSalary,
      @JsonKey(name: 'gross_salary') required final double grossSalary,
      @JsonKey(name: 'total_deductions') required final double totalDeductions,
      @JsonKey(name: 'net_salary')
      required final double netSalary}) = _$PayslipSummaryDataImpl;

  factory _PayslipSummaryData.fromJson(Map<String, dynamic> json) =
      _$PayslipSummaryDataImpl.fromJson;

  @override
  @JsonKey(name: 'basic_salary')
  double get basicSalary;
  @override
  @JsonKey(name: 'gross_salary')
  double get grossSalary;
  @override
  @JsonKey(name: 'total_deductions')
  double get totalDeductions;
  @override
  @JsonKey(name: 'net_salary')
  double get netSalary;

  /// Create a copy of PayslipSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayslipSummaryDataImplCopyWith<_$PayslipSummaryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PayslipStatutory _$PayslipStatutoryFromJson(Map<String, dynamic> json) {
  return _PayslipStatutory.fromJson(json);
}

/// @nodoc
mixin _$PayslipStatutory {
  @JsonKey(name: 'epf_employee')
  double get epfEmployee => throw _privateConstructorUsedError;
  @JsonKey(name: 'epf_employer')
  double get epfEmployer => throw _privateConstructorUsedError;
  @JsonKey(name: 'socso_employee')
  double get socsoEmployee => throw _privateConstructorUsedError;
  @JsonKey(name: 'socso_employer')
  double get socsoEmployer => throw _privateConstructorUsedError;
  @JsonKey(name: 'eis_employee')
  double get eisEmployee => throw _privateConstructorUsedError;
  @JsonKey(name: 'eis_employer')
  double get eisEmployer => throw _privateConstructorUsedError;
  double get pcb => throw _privateConstructorUsedError;
  double get zakat => throw _privateConstructorUsedError;

  /// Serializes this PayslipStatutory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayslipStatutory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayslipStatutoryCopyWith<PayslipStatutory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayslipStatutoryCopyWith<$Res> {
  factory $PayslipStatutoryCopyWith(
          PayslipStatutory value, $Res Function(PayslipStatutory) then) =
      _$PayslipStatutoryCopyWithImpl<$Res, PayslipStatutory>;
  @useResult
  $Res call(
      {@JsonKey(name: 'epf_employee') double epfEmployee,
      @JsonKey(name: 'epf_employer') double epfEmployer,
      @JsonKey(name: 'socso_employee') double socsoEmployee,
      @JsonKey(name: 'socso_employer') double socsoEmployer,
      @JsonKey(name: 'eis_employee') double eisEmployee,
      @JsonKey(name: 'eis_employer') double eisEmployer,
      double pcb,
      double zakat});
}

/// @nodoc
class _$PayslipStatutoryCopyWithImpl<$Res, $Val extends PayslipStatutory>
    implements $PayslipStatutoryCopyWith<$Res> {
  _$PayslipStatutoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayslipStatutory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? epfEmployee = null,
    Object? epfEmployer = null,
    Object? socsoEmployee = null,
    Object? socsoEmployer = null,
    Object? eisEmployee = null,
    Object? eisEmployer = null,
    Object? pcb = null,
    Object? zakat = null,
  }) {
    return _then(_value.copyWith(
      epfEmployee: null == epfEmployee
          ? _value.epfEmployee
          : epfEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      epfEmployer: null == epfEmployer
          ? _value.epfEmployer
          : epfEmployer // ignore: cast_nullable_to_non_nullable
              as double,
      socsoEmployee: null == socsoEmployee
          ? _value.socsoEmployee
          : socsoEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      socsoEmployer: null == socsoEmployer
          ? _value.socsoEmployer
          : socsoEmployer // ignore: cast_nullable_to_non_nullable
              as double,
      eisEmployee: null == eisEmployee
          ? _value.eisEmployee
          : eisEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      eisEmployer: null == eisEmployer
          ? _value.eisEmployer
          : eisEmployer // ignore: cast_nullable_to_non_nullable
              as double,
      pcb: null == pcb
          ? _value.pcb
          : pcb // ignore: cast_nullable_to_non_nullable
              as double,
      zakat: null == zakat
          ? _value.zakat
          : zakat // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PayslipStatutoryImplCopyWith<$Res>
    implements $PayslipStatutoryCopyWith<$Res> {
  factory _$$PayslipStatutoryImplCopyWith(_$PayslipStatutoryImpl value,
          $Res Function(_$PayslipStatutoryImpl) then) =
      __$$PayslipStatutoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'epf_employee') double epfEmployee,
      @JsonKey(name: 'epf_employer') double epfEmployer,
      @JsonKey(name: 'socso_employee') double socsoEmployee,
      @JsonKey(name: 'socso_employer') double socsoEmployer,
      @JsonKey(name: 'eis_employee') double eisEmployee,
      @JsonKey(name: 'eis_employer') double eisEmployer,
      double pcb,
      double zakat});
}

/// @nodoc
class __$$PayslipStatutoryImplCopyWithImpl<$Res>
    extends _$PayslipStatutoryCopyWithImpl<$Res, _$PayslipStatutoryImpl>
    implements _$$PayslipStatutoryImplCopyWith<$Res> {
  __$$PayslipStatutoryImplCopyWithImpl(_$PayslipStatutoryImpl _value,
      $Res Function(_$PayslipStatutoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PayslipStatutory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? epfEmployee = null,
    Object? epfEmployer = null,
    Object? socsoEmployee = null,
    Object? socsoEmployer = null,
    Object? eisEmployee = null,
    Object? eisEmployer = null,
    Object? pcb = null,
    Object? zakat = null,
  }) {
    return _then(_$PayslipStatutoryImpl(
      epfEmployee: null == epfEmployee
          ? _value.epfEmployee
          : epfEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      epfEmployer: null == epfEmployer
          ? _value.epfEmployer
          : epfEmployer // ignore: cast_nullable_to_non_nullable
              as double,
      socsoEmployee: null == socsoEmployee
          ? _value.socsoEmployee
          : socsoEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      socsoEmployer: null == socsoEmployer
          ? _value.socsoEmployer
          : socsoEmployer // ignore: cast_nullable_to_non_nullable
              as double,
      eisEmployee: null == eisEmployee
          ? _value.eisEmployee
          : eisEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      eisEmployer: null == eisEmployer
          ? _value.eisEmployer
          : eisEmployer // ignore: cast_nullable_to_non_nullable
              as double,
      pcb: null == pcb
          ? _value.pcb
          : pcb // ignore: cast_nullable_to_non_nullable
              as double,
      zakat: null == zakat
          ? _value.zakat
          : zakat // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PayslipStatutoryImpl implements _PayslipStatutory {
  const _$PayslipStatutoryImpl(
      {@JsonKey(name: 'epf_employee') this.epfEmployee = 0,
      @JsonKey(name: 'epf_employer') this.epfEmployer = 0,
      @JsonKey(name: 'socso_employee') this.socsoEmployee = 0,
      @JsonKey(name: 'socso_employer') this.socsoEmployer = 0,
      @JsonKey(name: 'eis_employee') this.eisEmployee = 0,
      @JsonKey(name: 'eis_employer') this.eisEmployer = 0,
      this.pcb = 0,
      this.zakat = 0});

  factory _$PayslipStatutoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayslipStatutoryImplFromJson(json);

  @override
  @JsonKey(name: 'epf_employee')
  final double epfEmployee;
  @override
  @JsonKey(name: 'epf_employer')
  final double epfEmployer;
  @override
  @JsonKey(name: 'socso_employee')
  final double socsoEmployee;
  @override
  @JsonKey(name: 'socso_employer')
  final double socsoEmployer;
  @override
  @JsonKey(name: 'eis_employee')
  final double eisEmployee;
  @override
  @JsonKey(name: 'eis_employer')
  final double eisEmployer;
  @override
  @JsonKey()
  final double pcb;
  @override
  @JsonKey()
  final double zakat;

  @override
  String toString() {
    return 'PayslipStatutory(epfEmployee: $epfEmployee, epfEmployer: $epfEmployer, socsoEmployee: $socsoEmployee, socsoEmployer: $socsoEmployer, eisEmployee: $eisEmployee, eisEmployer: $eisEmployer, pcb: $pcb, zakat: $zakat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayslipStatutoryImpl &&
            (identical(other.epfEmployee, epfEmployee) ||
                other.epfEmployee == epfEmployee) &&
            (identical(other.epfEmployer, epfEmployer) ||
                other.epfEmployer == epfEmployer) &&
            (identical(other.socsoEmployee, socsoEmployee) ||
                other.socsoEmployee == socsoEmployee) &&
            (identical(other.socsoEmployer, socsoEmployer) ||
                other.socsoEmployer == socsoEmployer) &&
            (identical(other.eisEmployee, eisEmployee) ||
                other.eisEmployee == eisEmployee) &&
            (identical(other.eisEmployer, eisEmployer) ||
                other.eisEmployer == eisEmployer) &&
            (identical(other.pcb, pcb) || other.pcb == pcb) &&
            (identical(other.zakat, zakat) || other.zakat == zakat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, epfEmployee, epfEmployer,
      socsoEmployee, socsoEmployer, eisEmployee, eisEmployer, pcb, zakat);

  /// Create a copy of PayslipStatutory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayslipStatutoryImplCopyWith<_$PayslipStatutoryImpl> get copyWith =>
      __$$PayslipStatutoryImplCopyWithImpl<_$PayslipStatutoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayslipStatutoryImplToJson(
      this,
    );
  }
}

abstract class _PayslipStatutory implements PayslipStatutory {
  const factory _PayslipStatutory(
      {@JsonKey(name: 'epf_employee') final double epfEmployee,
      @JsonKey(name: 'epf_employer') final double epfEmployer,
      @JsonKey(name: 'socso_employee') final double socsoEmployee,
      @JsonKey(name: 'socso_employer') final double socsoEmployer,
      @JsonKey(name: 'eis_employee') final double eisEmployee,
      @JsonKey(name: 'eis_employer') final double eisEmployer,
      final double pcb,
      final double zakat}) = _$PayslipStatutoryImpl;

  factory _PayslipStatutory.fromJson(Map<String, dynamic> json) =
      _$PayslipStatutoryImpl.fromJson;

  @override
  @JsonKey(name: 'epf_employee')
  double get epfEmployee;
  @override
  @JsonKey(name: 'epf_employer')
  double get epfEmployer;
  @override
  @JsonKey(name: 'socso_employee')
  double get socsoEmployee;
  @override
  @JsonKey(name: 'socso_employer')
  double get socsoEmployer;
  @override
  @JsonKey(name: 'eis_employee')
  double get eisEmployee;
  @override
  @JsonKey(name: 'eis_employer')
  double get eisEmployer;
  @override
  double get pcb;
  @override
  double get zakat;

  /// Create a copy of PayslipStatutory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayslipStatutoryImplCopyWith<_$PayslipStatutoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
