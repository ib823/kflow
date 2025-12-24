/// API exception with structured error information
class ApiException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final List<FieldError>? fieldErrors;
  final int? statusCode;
  final bool isNetworkError;

  const ApiException({
    required this.code,
    required this.message,
    this.details,
    this.fieldErrors,
    this.statusCode,
    this.isNetworkError = false,
  });

  /// Check if error is authentication related
  bool get isAuthError =>
      code == 'INVALID_CREDENTIALS' ||
      code == 'ACCOUNT_LOCKED' ||
      code == 'TOKEN_EXPIRED' ||
      code == 'SESSION_REVOKED' ||
      statusCode == 401;

  /// Check if error is PIN related
  bool get isPinError =>
      code == 'INVALID_PIN' ||
      code == 'PIN_REQUIRED' ||
      code == 'PIN_NOT_SET' ||
      code == 'VERIFICATION_EXPIRED';

  /// Check if error is validation related
  bool get isValidationError =>
      code == 'VALIDATION_ERROR' || statusCode == 400;

  /// Check if error is rate limit related
  bool get isRateLimitError => code == 'RATE_LIMITED' || statusCode == 429;

  /// Check if error is server error
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Get field-specific error message
  String? getFieldError(String fieldName) {
    return fieldErrors
        ?.firstWhere(
          (e) => e.field == fieldName,
          orElse: () => const FieldError(field: '', message: ''),
        )
        .message;
  }

  @override
  String toString() {
    return 'ApiException(code: $code, message: $message, statusCode: $statusCode)';
  }
}

/// Field-level validation error
class FieldError {
  final String field;
  final String message;

  const FieldError({
    required this.field,
    required this.message,
  });
}

/// Error codes from API specification
class ErrorCodes {
  // Authentication
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String accountLocked = 'ACCOUNT_LOCKED';
  static const String accountInactive = 'ACCOUNT_INACTIVE';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String tokenInvalid = 'TOKEN_INVALID';
  static const String refreshTokenExpired = 'REFRESH_TOKEN_EXPIRED';
  static const String sessionRevoked = 'SESSION_REVOKED';
  static const String invalidPin = 'INVALID_PIN';
  static const String pinRequired = 'PIN_REQUIRED';
  static const String pinNotSet = 'PIN_NOT_SET';
  static const String verificationExpired = 'VERIFICATION_EXPIRED';
  static const String passwordTooWeak = 'PASSWORD_TOO_WEAK';
  static const String passwordSame = 'PASSWORD_SAME';

  // Leave
  static const String insufficientBalance = 'INSUFFICIENT_BALANCE';
  static const String leaveOverlap = 'LEAVE_OVERLAP';
  static const String insufficientNotice = 'INSUFFICIENT_NOTICE';
  static const String attachmentRequired = 'ATTACHMENT_REQUIRED';
  static const String maxDaysExceeded = 'MAX_DAYS_EXCEEDED';
  static const String noWorkingDays = 'NO_WORKING_DAYS';
  static const String invalidDateRange = 'INVALID_DATE_RANGE';
  static const String dateInPast = 'DATE_IN_PAST';
  static const String halfDayMultiDay = 'HALF_DAY_MULTI_DAY';
  static const String cannotCancel = 'CANNOT_CANCEL';
  static const String cannotApprove = 'CANNOT_APPROVE';
  static const String alreadyProcessed = 'ALREADY_PROCESSED';

  // Payslip
  static const String payslipNotFound = 'PAYSLIP_NOT_FOUND';
  static const String payslipNotPublished = 'PAYSLIP_NOT_PUBLISHED';
  static const String pdfNotAvailable = 'PDF_NOT_AVAILABLE';

  // File
  static const String fileTooLarge = 'FILE_TOO_LARGE';
  static const String invalidFileType = 'INVALID_FILE_TYPE';
  static const String uploadFailed = 'UPLOAD_FAILED';
  static const String documentNotFound = 'DOCUMENT_NOT_FOUND';

  // Network
  static const String networkError = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String serverUnavailable = 'SERVER_UNAVAILABLE';
  static const String rateLimited = 'RATE_LIMITED';

  // General
  static const String validationError = 'VALIDATION_ERROR';
  static const String notFound = 'NOT_FOUND';
  static const String forbidden = 'FORBIDDEN';
}
