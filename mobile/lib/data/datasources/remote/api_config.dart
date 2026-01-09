/// API configuration for Odoo backend
class ApiConfig {
  /// Base URL for API
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.kerjaflow.com',
  );

  /// API version
  static const String apiVersion = 'v1';

  /// Full API URL
  static String get apiUrl => '$baseUrl/api/$apiVersion';

  /// Request timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  /// Token refresh threshold (seconds before expiry)
  static const int tokenRefreshThreshold = 300; // 5 minutes
}

/// API endpoints
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String verifyPin = '/auth/pin/verify';
  static const String setPin = '/auth/pin/set';
  static const String registerBiometric = '/auth/biometric/register';

  // User
  static const String userProfile = '/user/profile';
  static const String userSettings = '/user/settings';
  static const String updateProfile = '/user/profile';
  static const String updateSettings = '/user/settings';

  // Payslips
  static const String payslips = '/payslips';
  static String payslipDetail(String id) => '/payslips/$id';
  static String payslipPdf(String id) => '/payslips/$id/pdf';

  // Leave
  static const String leaveBalance = '/leave/balance';
  static const String leaveTypes = '/leave/types';
  static const String leaveRequests = '/leave/requests';
  static String leaveRequestDetail(String id) => '/leave/requests/$id';
  static String cancelLeaveRequest(String id) => '/leave/requests/$id/cancel';

  // Approvals
  static const String approvals = '/approvals';
  static String approvalDetail(String id) => '/approvals/$id';
  static String approveRequest(String id) => '/approvals/$id/approve';
  static String rejectRequest(String id) => '/approvals/$id/reject';

  // Notifications
  static const String notifications = '/notifications';
  static String notificationDetail(String id) => '/notifications/$id';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
}
