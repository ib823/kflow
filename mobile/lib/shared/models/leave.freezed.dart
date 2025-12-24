// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LeaveType _$LeaveTypeFromJson(Map<String, dynamic> json) {
  return _LeaveType.fromJson(json);
}

/// @nodoc
mixin _$LeaveType {
  int get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_ms')
  String? get nameMs => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_entitlement')
  double get defaultEntitlement => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_half_day')
  bool get allowHalfDay => throw _privateConstructorUsedError;
  @JsonKey(name: 'requires_attachment')
  bool get requiresAttachment => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_days_notice')
  int get minDaysNotice => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_days_per_request')
  int? get maxDaysPerRequest => throw _privateConstructorUsedError;

  /// Serializes this LeaveType to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveTypeCopyWith<LeaveType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveTypeCopyWith<$Res> {
  factory $LeaveTypeCopyWith(LeaveType value, $Res Function(LeaveType) then) =
      _$LeaveTypeCopyWithImpl<$Res, LeaveType>;
  @useResult
  $Res call(
      {int id,
      String code,
      String name,
      @JsonKey(name: 'name_ms') String? nameMs,
      String? description,
      String? color,
      String? icon,
      @JsonKey(name: 'default_entitlement') double defaultEntitlement,
      @JsonKey(name: 'allow_half_day') bool allowHalfDay,
      @JsonKey(name: 'requires_attachment') bool requiresAttachment,
      @JsonKey(name: 'min_days_notice') int minDaysNotice,
      @JsonKey(name: 'max_days_per_request') int? maxDaysPerRequest});
}

/// @nodoc
class _$LeaveTypeCopyWithImpl<$Res, $Val extends LeaveType>
    implements $LeaveTypeCopyWith<$Res> {
  _$LeaveTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? nameMs = freezed,
    Object? description = freezed,
    Object? color = freezed,
    Object? icon = freezed,
    Object? defaultEntitlement = null,
    Object? allowHalfDay = null,
    Object? requiresAttachment = null,
    Object? minDaysNotice = null,
    Object? maxDaysPerRequest = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameMs: freezed == nameMs
          ? _value.nameMs
          : nameMs // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultEntitlement: null == defaultEntitlement
          ? _value.defaultEntitlement
          : defaultEntitlement // ignore: cast_nullable_to_non_nullable
              as double,
      allowHalfDay: null == allowHalfDay
          ? _value.allowHalfDay
          : allowHalfDay // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresAttachment: null == requiresAttachment
          ? _value.requiresAttachment
          : requiresAttachment // ignore: cast_nullable_to_non_nullable
              as bool,
      minDaysNotice: null == minDaysNotice
          ? _value.minDaysNotice
          : minDaysNotice // ignore: cast_nullable_to_non_nullable
              as int,
      maxDaysPerRequest: freezed == maxDaysPerRequest
          ? _value.maxDaysPerRequest
          : maxDaysPerRequest // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeaveTypeImplCopyWith<$Res>
    implements $LeaveTypeCopyWith<$Res> {
  factory _$$LeaveTypeImplCopyWith(
          _$LeaveTypeImpl value, $Res Function(_$LeaveTypeImpl) then) =
      __$$LeaveTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String code,
      String name,
      @JsonKey(name: 'name_ms') String? nameMs,
      String? description,
      String? color,
      String? icon,
      @JsonKey(name: 'default_entitlement') double defaultEntitlement,
      @JsonKey(name: 'allow_half_day') bool allowHalfDay,
      @JsonKey(name: 'requires_attachment') bool requiresAttachment,
      @JsonKey(name: 'min_days_notice') int minDaysNotice,
      @JsonKey(name: 'max_days_per_request') int? maxDaysPerRequest});
}

/// @nodoc
class __$$LeaveTypeImplCopyWithImpl<$Res>
    extends _$LeaveTypeCopyWithImpl<$Res, _$LeaveTypeImpl>
    implements _$$LeaveTypeImplCopyWith<$Res> {
  __$$LeaveTypeImplCopyWithImpl(
      _$LeaveTypeImpl _value, $Res Function(_$LeaveTypeImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeaveType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? nameMs = freezed,
    Object? description = freezed,
    Object? color = freezed,
    Object? icon = freezed,
    Object? defaultEntitlement = null,
    Object? allowHalfDay = null,
    Object? requiresAttachment = null,
    Object? minDaysNotice = null,
    Object? maxDaysPerRequest = freezed,
  }) {
    return _then(_$LeaveTypeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameMs: freezed == nameMs
          ? _value.nameMs
          : nameMs // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultEntitlement: null == defaultEntitlement
          ? _value.defaultEntitlement
          : defaultEntitlement // ignore: cast_nullable_to_non_nullable
              as double,
      allowHalfDay: null == allowHalfDay
          ? _value.allowHalfDay
          : allowHalfDay // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresAttachment: null == requiresAttachment
          ? _value.requiresAttachment
          : requiresAttachment // ignore: cast_nullable_to_non_nullable
              as bool,
      minDaysNotice: null == minDaysNotice
          ? _value.minDaysNotice
          : minDaysNotice // ignore: cast_nullable_to_non_nullable
              as int,
      maxDaysPerRequest: freezed == maxDaysPerRequest
          ? _value.maxDaysPerRequest
          : maxDaysPerRequest // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveTypeImpl implements _LeaveType {
  const _$LeaveTypeImpl(
      {required this.id,
      required this.code,
      required this.name,
      @JsonKey(name: 'name_ms') this.nameMs,
      this.description,
      this.color,
      this.icon,
      @JsonKey(name: 'default_entitlement') this.defaultEntitlement = 0,
      @JsonKey(name: 'allow_half_day') this.allowHalfDay = false,
      @JsonKey(name: 'requires_attachment') this.requiresAttachment = false,
      @JsonKey(name: 'min_days_notice') this.minDaysNotice = 0,
      @JsonKey(name: 'max_days_per_request') this.maxDaysPerRequest});

  factory _$LeaveTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveTypeImplFromJson(json);

  @override
  final int id;
  @override
  final String code;
  @override
  final String name;
  @override
  @JsonKey(name: 'name_ms')
  final String? nameMs;
  @override
  final String? description;
  @override
  final String? color;
  @override
  final String? icon;
  @override
  @JsonKey(name: 'default_entitlement')
  final double defaultEntitlement;
  @override
  @JsonKey(name: 'allow_half_day')
  final bool allowHalfDay;
  @override
  @JsonKey(name: 'requires_attachment')
  final bool requiresAttachment;
  @override
  @JsonKey(name: 'min_days_notice')
  final int minDaysNotice;
  @override
  @JsonKey(name: 'max_days_per_request')
  final int? maxDaysPerRequest;

  @override
  String toString() {
    return 'LeaveType(id: $id, code: $code, name: $name, nameMs: $nameMs, description: $description, color: $color, icon: $icon, defaultEntitlement: $defaultEntitlement, allowHalfDay: $allowHalfDay, requiresAttachment: $requiresAttachment, minDaysNotice: $minDaysNotice, maxDaysPerRequest: $maxDaysPerRequest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameMs, nameMs) || other.nameMs == nameMs) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.defaultEntitlement, defaultEntitlement) ||
                other.defaultEntitlement == defaultEntitlement) &&
            (identical(other.allowHalfDay, allowHalfDay) ||
                other.allowHalfDay == allowHalfDay) &&
            (identical(other.requiresAttachment, requiresAttachment) ||
                other.requiresAttachment == requiresAttachment) &&
            (identical(other.minDaysNotice, minDaysNotice) ||
                other.minDaysNotice == minDaysNotice) &&
            (identical(other.maxDaysPerRequest, maxDaysPerRequest) ||
                other.maxDaysPerRequest == maxDaysPerRequest));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      name,
      nameMs,
      description,
      color,
      icon,
      defaultEntitlement,
      allowHalfDay,
      requiresAttachment,
      minDaysNotice,
      maxDaysPerRequest);

  /// Create a copy of LeaveType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveTypeImplCopyWith<_$LeaveTypeImpl> get copyWith =>
      __$$LeaveTypeImplCopyWithImpl<_$LeaveTypeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveTypeImplToJson(
      this,
    );
  }
}

abstract class _LeaveType implements LeaveType {
  const factory _LeaveType(
      {required final int id,
      required final String code,
      required final String name,
      @JsonKey(name: 'name_ms') final String? nameMs,
      final String? description,
      final String? color,
      final String? icon,
      @JsonKey(name: 'default_entitlement') final double defaultEntitlement,
      @JsonKey(name: 'allow_half_day') final bool allowHalfDay,
      @JsonKey(name: 'requires_attachment') final bool requiresAttachment,
      @JsonKey(name: 'min_days_notice') final int minDaysNotice,
      @JsonKey(name: 'max_days_per_request')
      final int? maxDaysPerRequest}) = _$LeaveTypeImpl;

  factory _LeaveType.fromJson(Map<String, dynamic> json) =
      _$LeaveTypeImpl.fromJson;

  @override
  int get id;
  @override
  String get code;
  @override
  String get name;
  @override
  @JsonKey(name: 'name_ms')
  String? get nameMs;
  @override
  String? get description;
  @override
  String? get color;
  @override
  String? get icon;
  @override
  @JsonKey(name: 'default_entitlement')
  double get defaultEntitlement;
  @override
  @JsonKey(name: 'allow_half_day')
  bool get allowHalfDay;
  @override
  @JsonKey(name: 'requires_attachment')
  bool get requiresAttachment;
  @override
  @JsonKey(name: 'min_days_notice')
  int get minDaysNotice;
  @override
  @JsonKey(name: 'max_days_per_request')
  int? get maxDaysPerRequest;

  /// Create a copy of LeaveType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveTypeImplCopyWith<_$LeaveTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaveBalance _$LeaveBalanceFromJson(Map<String, dynamic> json) {
  return _LeaveBalance.fromJson(json);
}

/// @nodoc
mixin _$LeaveBalance {
  @JsonKey(name: 'leave_type')
  LeaveType get leaveType => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  double get entitled => throw _privateConstructorUsedError;
  double get carried => throw _privateConstructorUsedError;
  double get adjustment => throw _privateConstructorUsedError;
  double get taken => throw _privateConstructorUsedError;
  double get pending => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  double get available => throw _privateConstructorUsedError;

  /// Serializes this LeaveBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveBalanceCopyWith<LeaveBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveBalanceCopyWith<$Res> {
  factory $LeaveBalanceCopyWith(
          LeaveBalance value, $Res Function(LeaveBalance) then) =
      _$LeaveBalanceCopyWithImpl<$Res, LeaveBalance>;
  @useResult
  $Res call(
      {@JsonKey(name: 'leave_type') LeaveType leaveType,
      int year,
      double entitled,
      double carried,
      double adjustment,
      double taken,
      double pending,
      double balance,
      double available});

  $LeaveTypeCopyWith<$Res> get leaveType;
}

/// @nodoc
class _$LeaveBalanceCopyWithImpl<$Res, $Val extends LeaveBalance>
    implements $LeaveBalanceCopyWith<$Res> {
  _$LeaveBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leaveType = null,
    Object? year = null,
    Object? entitled = null,
    Object? carried = null,
    Object? adjustment = null,
    Object? taken = null,
    Object? pending = null,
    Object? balance = null,
    Object? available = null,
  }) {
    return _then(_value.copyWith(
      leaveType: null == leaveType
          ? _value.leaveType
          : leaveType // ignore: cast_nullable_to_non_nullable
              as LeaveType,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      entitled: null == entitled
          ? _value.entitled
          : entitled // ignore: cast_nullable_to_non_nullable
              as double,
      carried: null == carried
          ? _value.carried
          : carried // ignore: cast_nullable_to_non_nullable
              as double,
      adjustment: null == adjustment
          ? _value.adjustment
          : adjustment // ignore: cast_nullable_to_non_nullable
              as double,
      taken: null == taken
          ? _value.taken
          : taken // ignore: cast_nullable_to_non_nullable
              as double,
      pending: null == pending
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as double,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeaveTypeCopyWith<$Res> get leaveType {
    return $LeaveTypeCopyWith<$Res>(_value.leaveType, (value) {
      return _then(_value.copyWith(leaveType: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LeaveBalanceImplCopyWith<$Res>
    implements $LeaveBalanceCopyWith<$Res> {
  factory _$$LeaveBalanceImplCopyWith(
          _$LeaveBalanceImpl value, $Res Function(_$LeaveBalanceImpl) then) =
      __$$LeaveBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'leave_type') LeaveType leaveType,
      int year,
      double entitled,
      double carried,
      double adjustment,
      double taken,
      double pending,
      double balance,
      double available});

  @override
  $LeaveTypeCopyWith<$Res> get leaveType;
}

/// @nodoc
class __$$LeaveBalanceImplCopyWithImpl<$Res>
    extends _$LeaveBalanceCopyWithImpl<$Res, _$LeaveBalanceImpl>
    implements _$$LeaveBalanceImplCopyWith<$Res> {
  __$$LeaveBalanceImplCopyWithImpl(
      _$LeaveBalanceImpl _value, $Res Function(_$LeaveBalanceImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leaveType = null,
    Object? year = null,
    Object? entitled = null,
    Object? carried = null,
    Object? adjustment = null,
    Object? taken = null,
    Object? pending = null,
    Object? balance = null,
    Object? available = null,
  }) {
    return _then(_$LeaveBalanceImpl(
      leaveType: null == leaveType
          ? _value.leaveType
          : leaveType // ignore: cast_nullable_to_non_nullable
              as LeaveType,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      entitled: null == entitled
          ? _value.entitled
          : entitled // ignore: cast_nullable_to_non_nullable
              as double,
      carried: null == carried
          ? _value.carried
          : carried // ignore: cast_nullable_to_non_nullable
              as double,
      adjustment: null == adjustment
          ? _value.adjustment
          : adjustment // ignore: cast_nullable_to_non_nullable
              as double,
      taken: null == taken
          ? _value.taken
          : taken // ignore: cast_nullable_to_non_nullable
              as double,
      pending: null == pending
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as double,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveBalanceImpl implements _LeaveBalance {
  const _$LeaveBalanceImpl(
      {@JsonKey(name: 'leave_type') required this.leaveType,
      required this.year,
      this.entitled = 0,
      this.carried = 0,
      this.adjustment = 0,
      this.taken = 0,
      this.pending = 0,
      this.balance = 0,
      this.available = 0});

  factory _$LeaveBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveBalanceImplFromJson(json);

  @override
  @JsonKey(name: 'leave_type')
  final LeaveType leaveType;
  @override
  final int year;
  @override
  @JsonKey()
  final double entitled;
  @override
  @JsonKey()
  final double carried;
  @override
  @JsonKey()
  final double adjustment;
  @override
  @JsonKey()
  final double taken;
  @override
  @JsonKey()
  final double pending;
  @override
  @JsonKey()
  final double balance;
  @override
  @JsonKey()
  final double available;

  @override
  String toString() {
    return 'LeaveBalance(leaveType: $leaveType, year: $year, entitled: $entitled, carried: $carried, adjustment: $adjustment, taken: $taken, pending: $pending, balance: $balance, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveBalanceImpl &&
            (identical(other.leaveType, leaveType) ||
                other.leaveType == leaveType) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.entitled, entitled) ||
                other.entitled == entitled) &&
            (identical(other.carried, carried) || other.carried == carried) &&
            (identical(other.adjustment, adjustment) ||
                other.adjustment == adjustment) &&
            (identical(other.taken, taken) || other.taken == taken) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.available, available) ||
                other.available == available));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, leaveType, year, entitled,
      carried, adjustment, taken, pending, balance, available);

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveBalanceImplCopyWith<_$LeaveBalanceImpl> get copyWith =>
      __$$LeaveBalanceImplCopyWithImpl<_$LeaveBalanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveBalanceImplToJson(
      this,
    );
  }
}

abstract class _LeaveBalance implements LeaveBalance {
  const factory _LeaveBalance(
      {@JsonKey(name: 'leave_type') required final LeaveType leaveType,
      required final int year,
      final double entitled,
      final double carried,
      final double adjustment,
      final double taken,
      final double pending,
      final double balance,
      final double available}) = _$LeaveBalanceImpl;

  factory _LeaveBalance.fromJson(Map<String, dynamic> json) =
      _$LeaveBalanceImpl.fromJson;

  @override
  @JsonKey(name: 'leave_type')
  LeaveType get leaveType;
  @override
  int get year;
  @override
  double get entitled;
  @override
  double get carried;
  @override
  double get adjustment;
  @override
  double get taken;
  @override
  double get pending;
  @override
  double get balance;
  @override
  double get available;

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveBalanceImplCopyWith<_$LeaveBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) {
  return _LeaveRequest.fromJson(json);
}

/// @nodoc
mixin _$LeaveRequest {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'leave_type')
  LeaveType get leaveType => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_from')
  String get dateFrom => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_to')
  String get dateTo => throw _privateConstructorUsedError;
  @JsonKey(name: 'half_day_type')
  String? get halfDayType => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_days')
  double get totalDays => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'can_cancel')
  bool get canCancel => throw _privateConstructorUsedError;
  LeaveApprover? get approver => throw _privateConstructorUsedError;
  @JsonKey(name: 'approved_at')
  String? get approvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LeaveRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveRequestCopyWith<LeaveRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveRequestCopyWith<$Res> {
  factory $LeaveRequestCopyWith(
          LeaveRequest value, $Res Function(LeaveRequest) then) =
      _$LeaveRequestCopyWithImpl<$Res, LeaveRequest>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'leave_type') LeaveType leaveType,
      @JsonKey(name: 'date_from') String dateFrom,
      @JsonKey(name: 'date_to') String dateTo,
      @JsonKey(name: 'half_day_type') String? halfDayType,
      @JsonKey(name: 'total_days') double totalDays,
      String? reason,
      String status,
      @JsonKey(name: 'can_cancel') bool canCancel,
      LeaveApprover? approver,
      @JsonKey(name: 'approved_at') String? approvedAt,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'created_at') String? createdAt});

  $LeaveTypeCopyWith<$Res> get leaveType;
  $LeaveApproverCopyWith<$Res>? get approver;
}

/// @nodoc
class _$LeaveRequestCopyWithImpl<$Res, $Val extends LeaveRequest>
    implements $LeaveRequestCopyWith<$Res> {
  _$LeaveRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? leaveType = null,
    Object? dateFrom = null,
    Object? dateTo = null,
    Object? halfDayType = freezed,
    Object? totalDays = null,
    Object? reason = freezed,
    Object? status = null,
    Object? canCancel = null,
    Object? approver = freezed,
    Object? approvedAt = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      leaveType: null == leaveType
          ? _value.leaveType
          : leaveType // ignore: cast_nullable_to_non_nullable
              as LeaveType,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as String,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as String,
      halfDayType: freezed == halfDayType
          ? _value.halfDayType
          : halfDayType // ignore: cast_nullable_to_non_nullable
              as String?,
      totalDays: null == totalDays
          ? _value.totalDays
          : totalDays // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      canCancel: null == canCancel
          ? _value.canCancel
          : canCancel // ignore: cast_nullable_to_non_nullable
              as bool,
      approver: freezed == approver
          ? _value.approver
          : approver // ignore: cast_nullable_to_non_nullable
              as LeaveApprover?,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeaveTypeCopyWith<$Res> get leaveType {
    return $LeaveTypeCopyWith<$Res>(_value.leaveType, (value) {
      return _then(_value.copyWith(leaveType: value) as $Val);
    });
  }

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeaveApproverCopyWith<$Res>? get approver {
    if (_value.approver == null) {
      return null;
    }

    return $LeaveApproverCopyWith<$Res>(_value.approver!, (value) {
      return _then(_value.copyWith(approver: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LeaveRequestImplCopyWith<$Res>
    implements $LeaveRequestCopyWith<$Res> {
  factory _$$LeaveRequestImplCopyWith(
          _$LeaveRequestImpl value, $Res Function(_$LeaveRequestImpl) then) =
      __$$LeaveRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'leave_type') LeaveType leaveType,
      @JsonKey(name: 'date_from') String dateFrom,
      @JsonKey(name: 'date_to') String dateTo,
      @JsonKey(name: 'half_day_type') String? halfDayType,
      @JsonKey(name: 'total_days') double totalDays,
      String? reason,
      String status,
      @JsonKey(name: 'can_cancel') bool canCancel,
      LeaveApprover? approver,
      @JsonKey(name: 'approved_at') String? approvedAt,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'created_at') String? createdAt});

  @override
  $LeaveTypeCopyWith<$Res> get leaveType;
  @override
  $LeaveApproverCopyWith<$Res>? get approver;
}

/// @nodoc
class __$$LeaveRequestImplCopyWithImpl<$Res>
    extends _$LeaveRequestCopyWithImpl<$Res, _$LeaveRequestImpl>
    implements _$$LeaveRequestImplCopyWith<$Res> {
  __$$LeaveRequestImplCopyWithImpl(
      _$LeaveRequestImpl _value, $Res Function(_$LeaveRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? leaveType = null,
    Object? dateFrom = null,
    Object? dateTo = null,
    Object? halfDayType = freezed,
    Object? totalDays = null,
    Object? reason = freezed,
    Object? status = null,
    Object? canCancel = null,
    Object? approver = freezed,
    Object? approvedAt = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$LeaveRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      leaveType: null == leaveType
          ? _value.leaveType
          : leaveType // ignore: cast_nullable_to_non_nullable
              as LeaveType,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as String,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as String,
      halfDayType: freezed == halfDayType
          ? _value.halfDayType
          : halfDayType // ignore: cast_nullable_to_non_nullable
              as String?,
      totalDays: null == totalDays
          ? _value.totalDays
          : totalDays // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      canCancel: null == canCancel
          ? _value.canCancel
          : canCancel // ignore: cast_nullable_to_non_nullable
              as bool,
      approver: freezed == approver
          ? _value.approver
          : approver // ignore: cast_nullable_to_non_nullable
              as LeaveApprover?,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveRequestImpl implements _LeaveRequest {
  const _$LeaveRequestImpl(
      {required this.id,
      @JsonKey(name: 'leave_type') required this.leaveType,
      @JsonKey(name: 'date_from') required this.dateFrom,
      @JsonKey(name: 'date_to') required this.dateTo,
      @JsonKey(name: 'half_day_type') this.halfDayType,
      @JsonKey(name: 'total_days') required this.totalDays,
      this.reason,
      required this.status,
      @JsonKey(name: 'can_cancel') this.canCancel = false,
      this.approver,
      @JsonKey(name: 'approved_at') this.approvedAt,
      @JsonKey(name: 'rejection_reason') this.rejectionReason,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$LeaveRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveRequestImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'leave_type')
  final LeaveType leaveType;
  @override
  @JsonKey(name: 'date_from')
  final String dateFrom;
  @override
  @JsonKey(name: 'date_to')
  final String dateTo;
  @override
  @JsonKey(name: 'half_day_type')
  final String? halfDayType;
  @override
  @JsonKey(name: 'total_days')
  final double totalDays;
  @override
  final String? reason;
  @override
  final String status;
  @override
  @JsonKey(name: 'can_cancel')
  final bool canCancel;
  @override
  final LeaveApprover? approver;
  @override
  @JsonKey(name: 'approved_at')
  final String? approvedAt;
  @override
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'LeaveRequest(id: $id, leaveType: $leaveType, dateFrom: $dateFrom, dateTo: $dateTo, halfDayType: $halfDayType, totalDays: $totalDays, reason: $reason, status: $status, canCancel: $canCancel, approver: $approver, approvedAt: $approvedAt, rejectionReason: $rejectionReason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.leaveType, leaveType) ||
                other.leaveType == leaveType) &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo) &&
            (identical(other.halfDayType, halfDayType) ||
                other.halfDayType == halfDayType) &&
            (identical(other.totalDays, totalDays) ||
                other.totalDays == totalDays) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.canCancel, canCancel) ||
                other.canCancel == canCancel) &&
            (identical(other.approver, approver) ||
                other.approver == approver) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      leaveType,
      dateFrom,
      dateTo,
      halfDayType,
      totalDays,
      reason,
      status,
      canCancel,
      approver,
      approvedAt,
      rejectionReason,
      createdAt);

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveRequestImplCopyWith<_$LeaveRequestImpl> get copyWith =>
      __$$LeaveRequestImplCopyWithImpl<_$LeaveRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveRequestImplToJson(
      this,
    );
  }
}

abstract class _LeaveRequest implements LeaveRequest {
  const factory _LeaveRequest(
          {required final int id,
          @JsonKey(name: 'leave_type') required final LeaveType leaveType,
          @JsonKey(name: 'date_from') required final String dateFrom,
          @JsonKey(name: 'date_to') required final String dateTo,
          @JsonKey(name: 'half_day_type') final String? halfDayType,
          @JsonKey(name: 'total_days') required final double totalDays,
          final String? reason,
          required final String status,
          @JsonKey(name: 'can_cancel') final bool canCancel,
          final LeaveApprover? approver,
          @JsonKey(name: 'approved_at') final String? approvedAt,
          @JsonKey(name: 'rejection_reason') final String? rejectionReason,
          @JsonKey(name: 'created_at') final String? createdAt}) =
      _$LeaveRequestImpl;

  factory _LeaveRequest.fromJson(Map<String, dynamic> json) =
      _$LeaveRequestImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'leave_type')
  LeaveType get leaveType;
  @override
  @JsonKey(name: 'date_from')
  String get dateFrom;
  @override
  @JsonKey(name: 'date_to')
  String get dateTo;
  @override
  @JsonKey(name: 'half_day_type')
  String? get halfDayType;
  @override
  @JsonKey(name: 'total_days')
  double get totalDays;
  @override
  String? get reason;
  @override
  String get status;
  @override
  @JsonKey(name: 'can_cancel')
  bool get canCancel;
  @override
  LeaveApprover? get approver;
  @override
  @JsonKey(name: 'approved_at')
  String? get approvedAt;
  @override
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveRequestImplCopyWith<_$LeaveRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaveApprover _$LeaveApproverFromJson(Map<String, dynamic> json) {
  return _LeaveApprover.fromJson(json);
}

/// @nodoc
mixin _$LeaveApprover {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this LeaveApprover to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveApprover
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveApproverCopyWith<LeaveApprover> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveApproverCopyWith<$Res> {
  factory $LeaveApproverCopyWith(
          LeaveApprover value, $Res Function(LeaveApprover) then) =
      _$LeaveApproverCopyWithImpl<$Res, LeaveApprover>;
  @useResult
  $Res call({int? id, String? name});
}

/// @nodoc
class _$LeaveApproverCopyWithImpl<$Res, $Val extends LeaveApprover>
    implements $LeaveApproverCopyWith<$Res> {
  _$LeaveApproverCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveApprover
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeaveApproverImplCopyWith<$Res>
    implements $LeaveApproverCopyWith<$Res> {
  factory _$$LeaveApproverImplCopyWith(
          _$LeaveApproverImpl value, $Res Function(_$LeaveApproverImpl) then) =
      __$$LeaveApproverImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name});
}

/// @nodoc
class __$$LeaveApproverImplCopyWithImpl<$Res>
    extends _$LeaveApproverCopyWithImpl<$Res, _$LeaveApproverImpl>
    implements _$$LeaveApproverImplCopyWith<$Res> {
  __$$LeaveApproverImplCopyWithImpl(
      _$LeaveApproverImpl _value, $Res Function(_$LeaveApproverImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeaveApprover
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_$LeaveApproverImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveApproverImpl implements _LeaveApprover {
  const _$LeaveApproverImpl({this.id, this.name});

  factory _$LeaveApproverImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveApproverImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;

  @override
  String toString() {
    return 'LeaveApprover(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveApproverImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of LeaveApprover
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveApproverImplCopyWith<_$LeaveApproverImpl> get copyWith =>
      __$$LeaveApproverImplCopyWithImpl<_$LeaveApproverImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveApproverImplToJson(
      this,
    );
  }
}

abstract class _LeaveApprover implements LeaveApprover {
  const factory _LeaveApprover({final int? id, final String? name}) =
      _$LeaveApproverImpl;

  factory _LeaveApprover.fromJson(Map<String, dynamic> json) =
      _$LeaveApproverImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;

  /// Create a copy of LeaveApprover
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveApproverImplCopyWith<_$LeaveApproverImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PublicHoliday _$PublicHolidayFromJson(Map<String, dynamic> json) {
  return _PublicHoliday.fromJson(json);
}

/// @nodoc
mixin _$PublicHoliday {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_ms')
  String? get nameMs => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'holiday_type')
  String get holidayType => throw _privateConstructorUsedError;

  /// Serializes this PublicHoliday to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicHoliday
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicHolidayCopyWith<PublicHoliday> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicHolidayCopyWith<$Res> {
  factory $PublicHolidayCopyWith(
          PublicHoliday value, $Res Function(PublicHoliday) then) =
      _$PublicHolidayCopyWithImpl<$Res, PublicHoliday>;
  @useResult
  $Res call(
      {int id,
      String name,
      @JsonKey(name: 'name_ms') String? nameMs,
      String date,
      String? state,
      @JsonKey(name: 'holiday_type') String holidayType});
}

/// @nodoc
class _$PublicHolidayCopyWithImpl<$Res, $Val extends PublicHoliday>
    implements $PublicHolidayCopyWith<$Res> {
  _$PublicHolidayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicHoliday
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameMs = freezed,
    Object? date = null,
    Object? state = freezed,
    Object? holidayType = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameMs: freezed == nameMs
          ? _value.nameMs
          : nameMs // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      holidayType: null == holidayType
          ? _value.holidayType
          : holidayType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PublicHolidayImplCopyWith<$Res>
    implements $PublicHolidayCopyWith<$Res> {
  factory _$$PublicHolidayImplCopyWith(
          _$PublicHolidayImpl value, $Res Function(_$PublicHolidayImpl) then) =
      __$$PublicHolidayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      @JsonKey(name: 'name_ms') String? nameMs,
      String date,
      String? state,
      @JsonKey(name: 'holiday_type') String holidayType});
}

/// @nodoc
class __$$PublicHolidayImplCopyWithImpl<$Res>
    extends _$PublicHolidayCopyWithImpl<$Res, _$PublicHolidayImpl>
    implements _$$PublicHolidayImplCopyWith<$Res> {
  __$$PublicHolidayImplCopyWithImpl(
      _$PublicHolidayImpl _value, $Res Function(_$PublicHolidayImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicHoliday
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameMs = freezed,
    Object? date = null,
    Object? state = freezed,
    Object? holidayType = null,
  }) {
    return _then(_$PublicHolidayImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameMs: freezed == nameMs
          ? _value.nameMs
          : nameMs // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      holidayType: null == holidayType
          ? _value.holidayType
          : holidayType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicHolidayImpl implements _PublicHoliday {
  const _$PublicHolidayImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'name_ms') this.nameMs,
      required this.date,
      this.state,
      @JsonKey(name: 'holiday_type') required this.holidayType});

  factory _$PublicHolidayImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicHolidayImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'name_ms')
  final String? nameMs;
  @override
  final String date;
  @override
  final String? state;
  @override
  @JsonKey(name: 'holiday_type')
  final String holidayType;

  @override
  String toString() {
    return 'PublicHoliday(id: $id, name: $name, nameMs: $nameMs, date: $date, state: $state, holidayType: $holidayType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicHolidayImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameMs, nameMs) || other.nameMs == nameMs) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.holidayType, holidayType) ||
                other.holidayType == holidayType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, nameMs, date, state, holidayType);

  /// Create a copy of PublicHoliday
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicHolidayImplCopyWith<_$PublicHolidayImpl> get copyWith =>
      __$$PublicHolidayImplCopyWithImpl<_$PublicHolidayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicHolidayImplToJson(
      this,
    );
  }
}

abstract class _PublicHoliday implements PublicHoliday {
  const factory _PublicHoliday(
          {required final int id,
          required final String name,
          @JsonKey(name: 'name_ms') final String? nameMs,
          required final String date,
          final String? state,
          @JsonKey(name: 'holiday_type') required final String holidayType}) =
      _$PublicHolidayImpl;

  factory _PublicHoliday.fromJson(Map<String, dynamic> json) =
      _$PublicHolidayImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'name_ms')
  String? get nameMs;
  @override
  String get date;
  @override
  String? get state;
  @override
  @JsonKey(name: 'holiday_type')
  String get holidayType;

  /// Create a copy of PublicHoliday
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicHolidayImplCopyWith<_$PublicHolidayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateLeaveRequest _$CreateLeaveRequestFromJson(Map<String, dynamic> json) {
  return _CreateLeaveRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateLeaveRequest {
  @JsonKey(name: 'leave_type_id')
  int get leaveTypeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_from')
  String get dateFrom => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_to')
  String get dateTo => throw _privateConstructorUsedError;
  @JsonKey(name: 'half_day_type')
  String? get halfDayType => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  @JsonKey(name: 'attachment_id')
  int? get attachmentId => throw _privateConstructorUsedError;

  /// Serializes this CreateLeaveRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateLeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateLeaveRequestCopyWith<CreateLeaveRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateLeaveRequestCopyWith<$Res> {
  factory $CreateLeaveRequestCopyWith(
          CreateLeaveRequest value, $Res Function(CreateLeaveRequest) then) =
      _$CreateLeaveRequestCopyWithImpl<$Res, CreateLeaveRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'leave_type_id') int leaveTypeId,
      @JsonKey(name: 'date_from') String dateFrom,
      @JsonKey(name: 'date_to') String dateTo,
      @JsonKey(name: 'half_day_type') String? halfDayType,
      String? reason,
      @JsonKey(name: 'attachment_id') int? attachmentId});
}

/// @nodoc
class _$CreateLeaveRequestCopyWithImpl<$Res, $Val extends CreateLeaveRequest>
    implements $CreateLeaveRequestCopyWith<$Res> {
  _$CreateLeaveRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateLeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leaveTypeId = null,
    Object? dateFrom = null,
    Object? dateTo = null,
    Object? halfDayType = freezed,
    Object? reason = freezed,
    Object? attachmentId = freezed,
  }) {
    return _then(_value.copyWith(
      leaveTypeId: null == leaveTypeId
          ? _value.leaveTypeId
          : leaveTypeId // ignore: cast_nullable_to_non_nullable
              as int,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as String,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as String,
      halfDayType: freezed == halfDayType
          ? _value.halfDayType
          : halfDayType // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentId: freezed == attachmentId
          ? _value.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateLeaveRequestImplCopyWith<$Res>
    implements $CreateLeaveRequestCopyWith<$Res> {
  factory _$$CreateLeaveRequestImplCopyWith(_$CreateLeaveRequestImpl value,
          $Res Function(_$CreateLeaveRequestImpl) then) =
      __$$CreateLeaveRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'leave_type_id') int leaveTypeId,
      @JsonKey(name: 'date_from') String dateFrom,
      @JsonKey(name: 'date_to') String dateTo,
      @JsonKey(name: 'half_day_type') String? halfDayType,
      String? reason,
      @JsonKey(name: 'attachment_id') int? attachmentId});
}

/// @nodoc
class __$$CreateLeaveRequestImplCopyWithImpl<$Res>
    extends _$CreateLeaveRequestCopyWithImpl<$Res, _$CreateLeaveRequestImpl>
    implements _$$CreateLeaveRequestImplCopyWith<$Res> {
  __$$CreateLeaveRequestImplCopyWithImpl(_$CreateLeaveRequestImpl _value,
      $Res Function(_$CreateLeaveRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateLeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leaveTypeId = null,
    Object? dateFrom = null,
    Object? dateTo = null,
    Object? halfDayType = freezed,
    Object? reason = freezed,
    Object? attachmentId = freezed,
  }) {
    return _then(_$CreateLeaveRequestImpl(
      leaveTypeId: null == leaveTypeId
          ? _value.leaveTypeId
          : leaveTypeId // ignore: cast_nullable_to_non_nullable
              as int,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as String,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as String,
      halfDayType: freezed == halfDayType
          ? _value.halfDayType
          : halfDayType // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentId: freezed == attachmentId
          ? _value.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateLeaveRequestImpl implements _CreateLeaveRequest {
  const _$CreateLeaveRequestImpl(
      {@JsonKey(name: 'leave_type_id') required this.leaveTypeId,
      @JsonKey(name: 'date_from') required this.dateFrom,
      @JsonKey(name: 'date_to') required this.dateTo,
      @JsonKey(name: 'half_day_type') this.halfDayType,
      this.reason,
      @JsonKey(name: 'attachment_id') this.attachmentId});

  factory _$CreateLeaveRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateLeaveRequestImplFromJson(json);

  @override
  @JsonKey(name: 'leave_type_id')
  final int leaveTypeId;
  @override
  @JsonKey(name: 'date_from')
  final String dateFrom;
  @override
  @JsonKey(name: 'date_to')
  final String dateTo;
  @override
  @JsonKey(name: 'half_day_type')
  final String? halfDayType;
  @override
  final String? reason;
  @override
  @JsonKey(name: 'attachment_id')
  final int? attachmentId;

  @override
  String toString() {
    return 'CreateLeaveRequest(leaveTypeId: $leaveTypeId, dateFrom: $dateFrom, dateTo: $dateTo, halfDayType: $halfDayType, reason: $reason, attachmentId: $attachmentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateLeaveRequestImpl &&
            (identical(other.leaveTypeId, leaveTypeId) ||
                other.leaveTypeId == leaveTypeId) &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo) &&
            (identical(other.halfDayType, halfDayType) ||
                other.halfDayType == halfDayType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.attachmentId, attachmentId) ||
                other.attachmentId == attachmentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, leaveTypeId, dateFrom, dateTo,
      halfDayType, reason, attachmentId);

  /// Create a copy of CreateLeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateLeaveRequestImplCopyWith<_$CreateLeaveRequestImpl> get copyWith =>
      __$$CreateLeaveRequestImplCopyWithImpl<_$CreateLeaveRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateLeaveRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateLeaveRequest implements CreateLeaveRequest {
  const factory _CreateLeaveRequest(
          {@JsonKey(name: 'leave_type_id') required final int leaveTypeId,
          @JsonKey(name: 'date_from') required final String dateFrom,
          @JsonKey(name: 'date_to') required final String dateTo,
          @JsonKey(name: 'half_day_type') final String? halfDayType,
          final String? reason,
          @JsonKey(name: 'attachment_id') final int? attachmentId}) =
      _$CreateLeaveRequestImpl;

  factory _CreateLeaveRequest.fromJson(Map<String, dynamic> json) =
      _$CreateLeaveRequestImpl.fromJson;

  @override
  @JsonKey(name: 'leave_type_id')
  int get leaveTypeId;
  @override
  @JsonKey(name: 'date_from')
  String get dateFrom;
  @override
  @JsonKey(name: 'date_to')
  String get dateTo;
  @override
  @JsonKey(name: 'half_day_type')
  String? get halfDayType;
  @override
  String? get reason;
  @override
  @JsonKey(name: 'attachment_id')
  int? get attachmentId;

  /// Create a copy of CreateLeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateLeaveRequestImplCopyWith<_$CreateLeaveRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
