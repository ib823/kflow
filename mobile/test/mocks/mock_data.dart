/// Mock data for testing
class MockData {
  // User data
  static const String userId = 'user-001';
  static const String userName = 'Ahmad Razak';
  static const String userEmail = 'ahmad.razak@company.com';
  static const String employeeId = 'EMP-0001';
  static const String department = 'Production';
  static const String position = 'Senior Operator';

  // Auth data
  static const String accessToken = 'mock_access_token_12345';
  static const String refreshToken = 'mock_refresh_token_67890';
  static const String validPin = '123456';
  static const String invalidPin = '000000';
  static const String password = 'Test@123';

  // Payslip data
  static Map<String, dynamic> get mockPayslip => {
        'id': 'payslip-2026-01',
        'month': 1,
        'year': 2026,
        'basic_salary': 3500.00,
        'gross_salary': 4550.00,
        'total_deductions': 300.00,
        'net_salary': 4250.00,
        'status': 'paid',
        'paid_date': '2026-01-25',
        'is_new': true,
        'earnings': [
          {'code': 'BASIC', 'name': 'Basic Salary', 'amount': 3500.00},
          {'code': 'ALLOW', 'name': 'Allowances', 'amount': 500.00},
          {'code': 'OT', 'name': 'Overtime', 'amount': 350.00},
          {'code': 'BONUS', 'name': 'Bonus', 'amount': 200.00},
        ],
        'deductions': [
          {'code': 'EPF', 'name': 'EPF (Employee)', 'amount': 231.00},
          {'code': 'SOCSO', 'name': 'SOCSO', 'amount': 8.65},
          {'code': 'EIS', 'name': 'EIS', 'amount': 8.65},
          {'code': 'PCB', 'name': 'PCB (Tax)', 'amount': 51.70},
        ],
      };

  static List<Map<String, dynamic>> get mockPayslipList => [
        mockPayslip,
        {...mockPayslip, 'id': 'payslip-2025-12', 'month': 12, 'year': 2025, 'is_new': false},
        {...mockPayslip, 'id': 'payslip-2025-11', 'month': 11, 'year': 2025, 'is_new': false},
      ];

  // Leave data
  static Map<String, dynamic> get mockLeaveBalance => {
        'leave_type_id': 'annual',
        'leave_type_name': 'Annual Leave',
        'color_value': 0xFF4CAF50,
        'icon_name': 'beach_access',
        'entitled': 16,
        'taken': 4,
        'pending': 0,
        'balance': 12,
      };

  static List<Map<String, dynamic>> get mockLeaveBalances => [
        mockLeaveBalance,
        {
          'leave_type_id': 'medical',
          'leave_type_name': 'Medical Leave',
          'color_value': 0xFFE91E63,
          'icon_name': 'local_hospital',
          'entitled': 14,
          'taken': 4,
          'pending': 0,
          'balance': 10,
        },
        {
          'leave_type_id': 'emergency',
          'leave_type_name': 'Emergency Leave',
          'color_value': 0xFFFF9800,
          'icon_name': 'warning_amber',
          'entitled': 3,
          'taken': 1,
          'pending': 0,
          'balance': 2,
        },
      ];

  static Map<String, dynamic> get mockLeaveRequest => {
        'id': 'leave-001',
        'leave_type_id': 'annual',
        'leave_type_name': 'Annual Leave',
        'leave_type_color': 0xFF4CAF50,
        'start_date': '2026-01-15',
        'end_date': '2026-01-17',
        'days': 3,
        'reason': 'Family vacation',
        'status': 'pending',
        'created_at': '2026-01-05T10:00:00Z',
      };

  // Approval data
  static Map<String, dynamic> get mockApproval => {
        'id': 'apr-001',
        'employee_id': 'EMP-0042',
        'employee_name': 'Sarah Abdullah',
        'employee_department': 'Production',
        'type': 'leave',
        'title': 'Annual Leave',
        'description': '15 Jan - 17 Jan 2026 (3 days)',
        'status': 'pending',
        'submitted_at': '2026-01-05T10:00:00Z',
      };

  static List<Map<String, dynamic>> get mockApprovals => [
        mockApproval,
        {...mockApproval, 'id': 'apr-002', 'employee_name': 'Mohammad Ali', 'title': 'Medical Leave'},
        {...mockApproval, 'id': 'apr-003', 'employee_name': 'Siti Aminah', 'status': 'approved'},
      ];

  // Notification data
  static Map<String, dynamic> get mockNotification => {
        'id': 'notif-001',
        'type': 'leave_approved',
        'title': 'Leave Approved',
        'message': 'Your annual leave request for 15-17 Jan has been approved.',
        'is_read': false,
        'action_url': '/leave/leave-1',
        'created_at': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
      };

  static List<Map<String, dynamic>> get mockNotifications => [
        mockNotification,
        {
          'id': 'notif-002',
          'type': 'payslip_available',
          'title': 'New Payslip Available',
          'message': 'Your December 2025 payslip is now available.',
          'is_read': false,
          'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        },
        {
          'id': 'notif-003',
          'type': 'announcement',
          'title': 'Company Announcement',
          'message': 'Upcoming maintenance scheduled for this weekend.',
          'is_read': true,
          'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
      ];

  // User profile
  static Map<String, dynamic> get mockUser => {
        'id': userId,
        'employee_id': employeeId,
        'name': userName,
        'email': userEmail,
        'department': department,
        'position': position,
        'join_date': '2020-01-15',
        'role': 'employee',
        'is_supervisor': false,
      };

  // API responses
  static Map<String, dynamic> successResponse(dynamic data) => {
        'success': true,
        'data': data,
        'message': null,
      };

  static Map<String, dynamic> errorResponse(String message, {String? code}) => {
        'success': false,
        'data': null,
        'message': message,
        'code': code,
      };

  static Map<String, dynamic> paginatedResponse(
    List<dynamic> data, {
    int page = 1,
    int perPage = 10,
    int total = 100,
  }) =>
      {
        'success': true,
        'data': data,
        'meta': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'total_pages': (total / perPage).ceil(),
        },
      };
}
