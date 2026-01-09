import 'package:huawei_analytics/huawei_analytics.dart';
import 'package:logger/logger.dart';

/// HMS Analytics service
/// Tracks screens, events, and user properties for analytics
class HmsAnalyticsService {
  final Logger _logger = Logger();
  final HMSAnalytics _analytics = HMSAnalytics();

  bool _isInitialized = false;

  /// Whether analytics is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize HMS Analytics
  Future<void> initialize() async {
    try {
      await _analytics.enableLog();
      await _analytics.setAnalyticsEnabled(true);
      await _analytics.setReportPolicies(
        scheduledTime: 120, // Report every 2 hours
        onMoveBackgroundPolicy: true,
      );

      _isInitialized = true;
      _logger.i('HMS Analytics initialized');
    } catch (e) {
      _logger.e('Error initializing HMS Analytics: $e');
      _isInitialized = false;
    }
  }

  /// Set user ID for analytics tracking
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(userId);
      _logger.d('Analytics user ID set');
    } catch (e) {
      _logger.e('Error setting user ID: $e');
    }
  }

  /// Clear user ID on logout
  Future<void> clearUserId() async {
    try {
      await _analytics.setUserId(null);
      _logger.d('Analytics user ID cleared');
    } catch (e) {
      _logger.e('Error clearing user ID: $e');
    }
  }

  /// Set user profile properties
  Future<void> setUserProfile({
    required String companyId,
    required String countryCode,
    String? departmentId,
    bool isManager = false,
  }) async {
    try {
      await _analytics.setUserProfile('company_id', companyId);
      await _analytics.setUserProfile('country_code', countryCode);
      await _analytics.setUserProfile('is_manager', isManager.toString());

      if (departmentId != null) {
        await _analytics.setUserProfile('department_id', departmentId);
      }

      _logger.d('User profile set');
    } catch (e) {
      _logger.e('Error setting user profile: $e');
    }
  }

  /// Track screen view
  Future<void> trackScreen(String screenName, {String? screenClass}) async {
    try {
      await _analytics.pageStart(screenName, screenClass ?? screenName);
      _logger.d('Screen tracked: $screenName');
    } catch (e) {
      _logger.e('Error tracking screen: $e');
    }
  }

  /// End screen tracking
  Future<void> endScreen(String screenName) async {
    try {
      await _analytics.pageEnd(screenName);
    } catch (e) {
      _logger.e('Error ending screen tracking: $e');
    }
  }

  /// Track custom event
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final bundle = parameters != null
          ? HAEventType.toBundle(eventName, parameters)
          : null;

      await _analytics.onEvent(eventName, bundle ?? {});
      _logger.d('Event tracked: $eventName');
    } catch (e) {
      _logger.e('Error tracking event $eventName: $e');
    }
  }

  // ============================================
  // KerjaFlow-specific analytics events
  // ============================================

  /// Track login event
  Future<void> trackLogin({required String method}) async {
    await trackEvent(HAEventType.SIGNIN, parameters: {
      HAParamType.METHOD: method,
    });
  }

  /// Track logout event
  Future<void> trackLogout() async {
    await trackEvent(HAEventType.SIGNOUT);
  }

  /// Track payslip viewed
  Future<void> trackPayslipViewed({
    required String payslipId,
    required String month,
    required String year,
  }) async {
    await trackEvent('payslip_viewed', parameters: {
      'payslip_id': payslipId,
      'month': month,
      'year': year,
    });
  }

  /// Track payslip downloaded
  Future<void> trackPayslipDownloaded({
    required String payslipId,
    required String format,
  }) async {
    await trackEvent('payslip_downloaded', parameters: {
      'payslip_id': payslipId,
      'format': format,
    });
  }

  /// Track leave request submitted
  Future<void> trackLeaveRequestSubmitted({
    required String leaveType,
    required int daysRequested,
  }) async {
    await trackEvent('leave_request_submitted', parameters: {
      'leave_type': leaveType,
      'days_requested': daysRequested,
    });
  }

  /// Track leave request cancelled
  Future<void> trackLeaveRequestCancelled({
    required String requestId,
  }) async {
    await trackEvent('leave_request_cancelled', parameters: {
      'request_id': requestId,
    });
  }

  /// Track approval action
  Future<void> trackApprovalAction({
    required String requestId,
    required String action,
    required String requestType,
  }) async {
    await trackEvent('approval_action', parameters: {
      'request_id': requestId,
      'action': action,
      'request_type': requestType,
    });
  }

  /// Track document uploaded
  Future<void> trackDocumentUploaded({
    required String documentType,
    required int fileSizeKb,
  }) async {
    await trackEvent('document_uploaded', parameters: {
      'document_type': documentType,
      'file_size_kb': fileSizeKb,
    });
  }

  /// Track language changed
  Future<void> trackLanguageChanged({
    required String fromLanguage,
    required String toLanguage,
  }) async {
    await trackEvent('language_changed', parameters: {
      'from_language': fromLanguage,
      'to_language': toLanguage,
    });
  }

  /// Track attendance action
  Future<void> trackAttendanceAction({
    required String action,
    String? location,
  }) async {
    await trackEvent('attendance_action', parameters: {
      'action': action,
      if (location != null) 'location': location,
    });
  }

  /// Track search performed
  Future<void> trackSearch({
    required String searchTerm,
    required String searchType,
    required int resultsCount,
  }) async {
    await trackEvent(HAEventType.SEARCH, parameters: {
      HAParamType.SEARCHKEYWORDS: searchTerm,
      'search_type': searchType,
      'results_count': resultsCount,
    });
  }

  /// Track error occurred
  Future<void> trackError({
    required String errorCode,
    required String errorMessage,
    String? screenName,
  }) async {
    await trackEvent('error_occurred', parameters: {
      'error_code': errorCode,
      'error_message': errorMessage,
      if (screenName != null) 'screen_name': screenName,
    });
  }

  /// Track feature usage
  Future<void> trackFeatureUsage({
    required String feature,
    String? action,
  }) async {
    await trackEvent('feature_usage', parameters: {
      'feature': feature,
      if (action != null) 'action': action,
    });
  }

  /// Track offline mode activation
  Future<void> trackOfflineMode({required bool isOffline}) async {
    await trackEvent('offline_mode', parameters: {
      'is_offline': isOffline,
    });
  }

  /// Clear all analytics data (for privacy)
  Future<void> clearCachedData() async {
    try {
      await _analytics.clearCachedData();
      _logger.i('Analytics cache cleared');
    } catch (e) {
      _logger.e('Error clearing analytics cache: $e');
    }
  }

  /// Disable analytics collection
  Future<void> disableAnalytics() async {
    try {
      await _analytics.setAnalyticsEnabled(false);
      _logger.i('Analytics disabled');
    } catch (e) {
      _logger.e('Error disabling analytics: $e');
    }
  }

  /// Enable analytics collection
  Future<void> enableAnalytics() async {
    try {
      await _analytics.setAnalyticsEnabled(true);
      _logger.i('Analytics enabled');
    } catch (e) {
      _logger.e('Error enabling analytics: $e');
    }
  }
}

/// Analytics event names for KerjaFlow
class AnalyticsEvents {
  // Authentication
  static const String login = 'login';
  static const String logout = 'logout';
  static const String pinSetup = 'pin_setup';
  static const String biometricEnabled = 'biometric_enabled';

  // Payslip
  static const String payslipViewed = 'payslip_viewed';
  static const String payslipDownloaded = 'payslip_downloaded';
  static const String payslipShared = 'payslip_shared';

  // Leave
  static const String leaveRequestSubmitted = 'leave_request_submitted';
  static const String leaveRequestCancelled = 'leave_request_cancelled';
  static const String leaveBalanceViewed = 'leave_balance_viewed';

  // Approvals
  static const String approvalAction = 'approval_action';
  static const String approvalListViewed = 'approval_list_viewed';

  // Documents
  static const String documentUploaded = 'document_uploaded';
  static const String documentViewed = 'document_viewed';
  static const String documentDownloaded = 'document_downloaded';

  // Attendance
  static const String clockIn = 'clock_in';
  static const String clockOut = 'clock_out';
  static const String attendanceViewed = 'attendance_viewed';

  // Settings
  static const String languageChanged = 'language_changed';
  static const String themeChanged = 'theme_changed';
  static const String notificationSettingsChanged =
      'notification_settings_changed';

  // General
  static const String appOpened = 'app_opened';
  static const String search = 'search';
  static const String errorOccurred = 'error_occurred';
  static const String offlineMode = 'offline_mode';
}

/// Screen names for analytics tracking
class AnalyticsScreens {
  // Auth screens
  static const String login = 'LoginScreen';
  static const String pinEntry = 'PinEntryScreen';
  static const String pinSetup = 'PinSetupScreen';

  // Main screens
  static const String dashboard = 'DashboardScreen';
  static const String profile = 'ProfileScreen';
  static const String settings = 'SettingsScreen';

  // Payslip screens
  static const String payslipList = 'PayslipListScreen';
  static const String payslipDetail = 'PayslipDetailScreen';
  static const String payslipPdf = 'PayslipPdfScreen';

  // Leave screens
  static const String leaveBalance = 'LeaveBalanceScreen';
  static const String leaveHistory = 'LeaveHistoryScreen';
  static const String leaveRequest = 'LeaveRequestScreen';
  static const String leaveDetail = 'LeaveDetailScreen';

  // Approval screens
  static const String approvalList = 'ApprovalListScreen';
  static const String approvalDetail = 'ApprovalDetailScreen';

  // Document screens
  static const String documentList = 'DocumentListScreen';
  static const String documentUpload = 'DocumentUploadScreen';
  static const String documentViewer = 'DocumentViewerScreen';

  // Attendance screens
  static const String attendance = 'AttendanceScreen';
  static const String attendanceHistory = 'AttendanceHistoryScreen';

  // Notification screens
  static const String notifications = 'NotificationsScreen';
  static const String notificationDetail = 'NotificationDetailScreen';
}
