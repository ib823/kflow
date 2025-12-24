// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaveTypeImpl _$$LeaveTypeImplFromJson(Map<String, dynamic> json) =>
    _$LeaveTypeImpl(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      nameMs: json['name_ms'] as String?,
      description: json['description'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      defaultEntitlement:
          (json['default_entitlement'] as num?)?.toDouble() ?? 0,
      allowHalfDay: json['allow_half_day'] as bool? ?? false,
      requiresAttachment: json['requires_attachment'] as bool? ?? false,
      minDaysNotice: (json['min_days_notice'] as num?)?.toInt() ?? 0,
      maxDaysPerRequest: (json['max_days_per_request'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$LeaveTypeImplToJson(_$LeaveTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'name_ms': instance.nameMs,
      'description': instance.description,
      'color': instance.color,
      'icon': instance.icon,
      'default_entitlement': instance.defaultEntitlement,
      'allow_half_day': instance.allowHalfDay,
      'requires_attachment': instance.requiresAttachment,
      'min_days_notice': instance.minDaysNotice,
      'max_days_per_request': instance.maxDaysPerRequest,
    };

_$LeaveBalanceImpl _$$LeaveBalanceImplFromJson(Map<String, dynamic> json) =>
    _$LeaveBalanceImpl(
      leaveType: LeaveType.fromJson(json['leave_type'] as Map<String, dynamic>),
      year: (json['year'] as num).toInt(),
      entitled: (json['entitled'] as num?)?.toDouble() ?? 0,
      carried: (json['carried'] as num?)?.toDouble() ?? 0,
      adjustment: (json['adjustment'] as num?)?.toDouble() ?? 0,
      taken: (json['taken'] as num?)?.toDouble() ?? 0,
      pending: (json['pending'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      available: (json['available'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$LeaveBalanceImplToJson(_$LeaveBalanceImpl instance) =>
    <String, dynamic>{
      'leave_type': instance.leaveType,
      'year': instance.year,
      'entitled': instance.entitled,
      'carried': instance.carried,
      'adjustment': instance.adjustment,
      'taken': instance.taken,
      'pending': instance.pending,
      'balance': instance.balance,
      'available': instance.available,
    };

_$LeaveRequestImpl _$$LeaveRequestImplFromJson(Map<String, dynamic> json) =>
    _$LeaveRequestImpl(
      id: (json['id'] as num).toInt(),
      leaveType: LeaveType.fromJson(json['leave_type'] as Map<String, dynamic>),
      dateFrom: json['date_from'] as String,
      dateTo: json['date_to'] as String,
      halfDayType: json['half_day_type'] as String?,
      totalDays: (json['total_days'] as num).toDouble(),
      reason: json['reason'] as String?,
      status: json['status'] as String,
      canCancel: json['can_cancel'] as bool? ?? false,
      approver: json['approver'] == null
          ? null
          : LeaveApprover.fromJson(json['approver'] as Map<String, dynamic>),
      approvedAt: json['approved_at'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$LeaveRequestImplToJson(_$LeaveRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'leave_type': instance.leaveType,
      'date_from': instance.dateFrom,
      'date_to': instance.dateTo,
      'half_day_type': instance.halfDayType,
      'total_days': instance.totalDays,
      'reason': instance.reason,
      'status': instance.status,
      'can_cancel': instance.canCancel,
      'approver': instance.approver,
      'approved_at': instance.approvedAt,
      'rejection_reason': instance.rejectionReason,
      'created_at': instance.createdAt,
    };

_$LeaveApproverImpl _$$LeaveApproverImplFromJson(Map<String, dynamic> json) =>
    _$LeaveApproverImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$LeaveApproverImplToJson(_$LeaveApproverImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$PublicHolidayImpl _$$PublicHolidayImplFromJson(Map<String, dynamic> json) =>
    _$PublicHolidayImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      nameMs: json['name_ms'] as String?,
      date: json['date'] as String,
      state: json['state'] as String?,
      holidayType: json['holiday_type'] as String,
    );

Map<String, dynamic> _$$PublicHolidayImplToJson(_$PublicHolidayImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ms': instance.nameMs,
      'date': instance.date,
      'state': instance.state,
      'holiday_type': instance.holidayType,
    };

_$CreateLeaveRequestImpl _$$CreateLeaveRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateLeaveRequestImpl(
      leaveTypeId: (json['leave_type_id'] as num).toInt(),
      dateFrom: json['date_from'] as String,
      dateTo: json['date_to'] as String,
      halfDayType: json['half_day_type'] as String?,
      reason: json['reason'] as String?,
      attachmentId: (json['attachment_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CreateLeaveRequestImplToJson(
        _$CreateLeaveRequestImpl instance) =>
    <String, dynamic>{
      'leave_type_id': instance.leaveTypeId,
      'date_from': instance.dateFrom,
      'date_to': instance.dateTo,
      'half_day_type': instance.halfDayType,
      'reason': instance.reason,
      'attachment_id': instance.attachmentId,
    };
