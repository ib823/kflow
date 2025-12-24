/// Application configuration and environment settings
class AppConfig {
  static late AppConfig _instance;

  final String apiBaseUrl;
  final String environment;
  final bool debugMode;
  final String appVersion;
  final int buildNumber;

  AppConfig._({
    required this.apiBaseUrl,
    required this.environment,
    required this.debugMode,
    required this.appVersion,
    required this.buildNumber,
  });

  static AppConfig get instance => _instance;

  static Future<void> initialize() async {
    // In production, these would come from environment variables or secure storage
    _instance = AppConfig._(
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8069/api/v1',
      ),
      environment: const String.fromEnvironment(
        'ENVIRONMENT',
        defaultValue: 'development',
      ),
      debugMode: const bool.fromEnvironment(
        'DEBUG',
        defaultValue: true,
      ),
      appVersion: '1.0.0',
      buildNumber: 1,
    );
  }

  bool get isProduction => environment == 'production';
  bool get isStaging => environment == 'staging';
  bool get isDevelopment => environment == 'development';
}

/// API configuration constants
class ApiConfig {
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 60000; // 60 seconds for uploads

  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 second

  // API versioning
  static const String apiVersion = 'v1';

  // Rate limit headers
  static const String rateLimitHeader = 'X-RateLimit-Limit';
  static const String rateLimitRemainingHeader = 'X-RateLimit-Remaining';
  static const String rateLimitResetHeader = 'X-RateLimit-Reset';

  // PIN verification header
  static const String verificationTokenHeader = 'X-Verification-Token';
}

/// Storage keys for secure storage
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
  static const String userId = 'user_id';
  static const String employeeId = 'employee_id';
  static const String companyId = 'company_id';
  static const String userRole = 'user_role';
  static const String hasPin = 'has_pin';
  static const String preferredLanguage = 'preferred_language';
  static const String fcmToken = 'fcm_token';
  static const String deviceId = 'device_id';
}

/// Notification channel IDs for Android
class NotificationChannels {
  static const String leave = 'kf_leave';
  static const String payslip = 'kf_payslip';
  static const String approvals = 'kf_approvals';
  static const String reminders = 'kf_reminders';
  static const String system = 'kf_system';
}
