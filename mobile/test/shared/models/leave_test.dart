import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/shared/models/leave.dart';

void main() {
  group('LeaveType Model', () {
    test('creates LeaveType from JSON', () {
      final json = {
        'id': 1,
        'code': 'AL',
        'name': 'Annual Leave',
        'name_ms': 'Cuti Tahunan',
        'color': '#4CAF50',
        'default_entitlement': 14.0,
        'allow_half_day': true,
        'requires_attachment': false,
      };

      final leaveType = LeaveType.fromJson(json);

      expect(leaveType.id, 1);
      expect(leaveType.code, 'AL');
      expect(leaveType.name, 'Annual Leave');
      expect(leaveType.nameMs, 'Cuti Tahunan');
      expect(leaveType.allowHalfDay, isTrue);
      expect(leaveType.requiresAttachment, isFalse);
    });

    test('LeaveType equality works correctly', () {
      const type1 = LeaveType(
        id: 1,
        code: 'AL',
        name: 'Annual Leave',
        color: '#4CAF50',
        defaultEntitlement: 14,
        allowHalfDay: true,
        requiresAttachment: false,
      );

      const type2 = LeaveType(
        id: 1,
        code: 'AL',
        name: 'Annual Leave',
        color: '#4CAF50',
        defaultEntitlement: 14,
        allowHalfDay: true,
        requiresAttachment: false,
      );

      expect(type1, equals(type2));
    });
  });

  group('LeaveBalance Model', () {
    test('creates LeaveBalance from JSON', () {
      final json = {
        'leave_type': {
          'id': 1,
          'code': 'AL',
          'name': 'Annual Leave',
        },
        'year': 2025,
        'entitled': 14.0,
        'carried': 2.0,
        'taken': 5.0,
        'pending': 2.0,
        'balance': 11.0,
        'available': 9.0,
      };

      final balance = LeaveBalance.fromJson(json);

      expect(balance.leaveType.id, 1);
      expect(balance.leaveType.code, 'AL');
      expect(balance.entitled, 14.0);
      expect(balance.taken, 5.0);
      expect(balance.available, 9.0);
    });

    test('LeaveBalance has correct year', () {
      const balance = LeaveBalance(
        leaveType: LeaveType(id: 1, code: 'AL', name: 'Annual Leave'),
        year: 2025,
        entitled: 14.0,
        carried: 2.0,
        adjustment: 0.0,
        taken: 5.0,
        pending: 2.0,
        balance: 11.0,
        available: 9.0,
      );

      expect(balance.year, 2025);
      expect(balance.balance, 11.0);
      expect(balance.available, 9.0);
    });
  });

  group('LeaveRequest Model', () {
    test('creates LeaveRequest from JSON', () {
      final json = {
        'id': 1,
        'leave_type': {
          'id': 1,
          'code': 'AL',
          'name': 'Annual Leave',
        },
        'date_from': '2025-01-15',
        'date_to': '2025-01-17',
        'total_days': 3.0,
        'status': 'PENDING',
        'reason': 'Family vacation',
        'can_cancel': true,
      };

      final request = LeaveRequest.fromJson(json);

      expect(request.id, 1);
      expect(request.leaveType.code, 'AL');
      expect(request.totalDays, 3.0);
      expect(request.status, 'PENDING');
      expect(request.reason, 'Family vacation');
      expect(request.canCancel, isTrue);
    });

    test('LeaveRequest status parsing works', () {
      const request = LeaveRequest(
        id: 1,
        leaveType: LeaveType(id: 1, code: 'AL', name: 'Annual Leave'),
        dateFrom: '2025-01-15',
        dateTo: '2025-01-17',
        totalDays: 3.0,
        status: 'APPROVED',
      );

      expect(request.status, 'APPROVED');
    });

    test('LeaveRequest canCancel computed correctly', () {
      const pendingRequest = LeaveRequest(
        id: 1,
        leaveType: LeaveType(id: 1, code: 'AL', name: 'Annual Leave'),
        dateFrom: '2025-01-15',
        dateTo: '2025-01-17',
        totalDays: 3.0,
        status: 'PENDING',
        canCancel: true,
      );

      expect(pendingRequest.canCancel, isTrue);

      const rejectedRequest = LeaveRequest(
        id: 3,
        leaveType: LeaveType(id: 1, code: 'AL', name: 'Annual Leave'),
        dateFrom: '2025-01-15',
        dateTo: '2025-01-17',
        totalDays: 3.0,
        status: 'REJECTED',
        canCancel: false,
      );

      expect(rejectedRequest.canCancel, isFalse);
    });
  });

  group('PublicHoliday Model', () {
    test('creates PublicHoliday from JSON', () {
      final json = {
        'id': 1,
        'name': 'National Day',
        'name_ms': 'Hari Kebangsaan',
        'date': '2025-08-31',
        'holiday_type': 'FEDERAL',
      };

      final holiday = PublicHoliday.fromJson(json);

      expect(holiday.id, 1);
      expect(holiday.name, 'National Day');
      expect(holiday.nameMs, 'Hari Kebangsaan');
      expect(holiday.holidayType, 'FEDERAL');
    });
  });

  group('CreateLeaveRequest Model', () {
    test('creates CreateLeaveRequest correctly', () {
      const request = CreateLeaveRequest(
        leaveTypeId: 1,
        dateFrom: '2025-01-15',
        dateTo: '2025-01-17',
        reason: 'Family trip',
      );

      expect(request.leaveTypeId, 1);
      expect(request.dateFrom, '2025-01-15');
      expect(request.dateTo, '2025-01-17');
      expect(request.reason, 'Family trip');
      expect(request.halfDayType, isNull);
    });

    test('CreateLeaveRequest supports half day', () {
      const request = CreateLeaveRequest(
        leaveTypeId: 1,
        dateFrom: '2025-01-15',
        dateTo: '2025-01-15',
        halfDayType: 'AM',
      );

      expect(request.halfDayType, 'AM');
    });
  });
}
