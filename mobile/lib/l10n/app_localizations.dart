import 'package:flutter/material.dart';

/// Supported locales for KerjaFlow
/// 12 languages supporting ASEAN region + migrant workers
class KFLocalizations {
  /// All supported locales
  static const supportedLocales = [
    Locale('en'),      // English (default)
    Locale('ms'),      // Bahasa Melayu (Malaysian)
    Locale('id'),      // Bahasa Indonesia
    Locale('zh'),      // Chinese Simplified
    Locale('ta'),      // Tamil
    Locale('th'),      // Thai
    Locale('vi'),      // Vietnamese
    Locale('tl'),      // Tagalog/Filipino
    Locale('my'),      // Myanmar/Burmese (Unicode, NOT Zawgyi)
    Locale('km'),      // Khmer
    Locale('ne'),      // Nepali
    Locale('bn'),      // Bengali
  ];

  /// Default fallback locale
  static const fallbackLocale = Locale('en');

  /// Get locale from language code
  static Locale getLocale(String code) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => fallbackLocale,
    );
  }

  /// Get native language name for display
  static String getNativeName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'ms': return 'Bahasa Melayu';
      case 'id': return 'Bahasa Indonesia';
      case 'zh': return '简体中文';
      case 'ta': return 'தமிழ்';
      case 'th': return 'ภาษาไทย';
      case 'vi': return 'Tiếng Việt';
      case 'tl': return 'Filipino';
      case 'my': return 'မြန်မာဘာသာ';
      case 'km': return 'ភាសាខ្មែរ';
      case 'ne': return 'नेपाली';
      case 'bn': return 'বাংলা';
      default: return 'Unknown';
    }
  }

  /// Get English name for language code
  static String getEnglishName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'ms': return 'Malay';
      case 'id': return 'Indonesian';
      case 'zh': return 'Chinese (Simplified)';
      case 'ta': return 'Tamil';
      case 'th': return 'Thai';
      case 'vi': return 'Vietnamese';
      case 'tl': return 'Filipino';
      case 'my': return 'Myanmar (Burmese)';
      case 'km': return 'Khmer';
      case 'ne': return 'Nepali';
      case 'bn': return 'Bengali';
      default: return 'Unknown';
    }
  }

  /// Check if locale is RTL (right-to-left)
  /// Note: None of our supported languages are RTL
  /// Jawi (Arabic script Malay) would require 'ms-Arab' locale
  static bool isRTL(String code) {
    return false;
  }

  /// Get flag emoji for language (for visual display)
  static String getFlag(String code) {
    switch (code) {
      case 'en': return '🇬🇧'; // UK flag for English
      case 'ms': return '🇲🇾'; // Malaysia
      case 'id': return '🇮🇩'; // Indonesia
      case 'zh': return '🇨🇳'; // China
      case 'ta': return '🇮🇳'; // India (Tamil)
      case 'th': return '🇹🇭'; // Thailand
      case 'vi': return '🇻🇳'; // Vietnam
      case 'tl': return '🇵🇭'; // Philippines
      case 'my': return '🇲🇲'; // Myanmar
      case 'km': return '🇰🇭'; // Cambodia
      case 'ne': return '🇳🇵'; // Nepal
      case 'bn': return '🇧🇩'; // Bangladesh
      default: return '🏳️';
    }
  }

  /// Get target user description for language
  static String getTargetUsers(String code) {
    switch (code) {
      case 'en': return 'Default, professionals';
      case 'ms': return 'Malaysian workers';
      case 'id': return 'Indonesian workers';
      case 'zh': return 'Chinese speakers';
      case 'ta': return 'Malaysian Indians, Tamil speakers';
      case 'th': return 'Thai workers';
      case 'vi': return 'Vietnamese workers';
      case 'tl': return 'Filipino workers';
      case 'my': return 'Myanmar workers';
      case 'km': return 'Cambodian workers';
      case 'ne': return 'Nepali workers';
      case 'bn': return 'Bangladeshi workers';
      default: return 'Unknown';
    }
  }
}

/// Localization delegate for KerjaFlow
/// TODO: Generate actual translations using flutter_localizations or intl package
class KFLocalizationsDelegate extends LocalizationsDelegate<KFStrings> {
  const KFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return KFLocalizations.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<KFStrings> load(Locale locale) async {
    return KFStrings(locale);
  }

  @override
  bool shouldReload(KFLocalizationsDelegate old) => false;
}

/// String resources for KerjaFlow
/// This is a placeholder for actual translations
/// In production, these would be loaded from ARB files
class KFStrings {
  final Locale locale;

  KFStrings(this.locale);

  /// Get strings for current context
  static KFStrings of(BuildContext context) {
    return Localizations.of<KFStrings>(context, KFStrings) ??
        KFStrings(const Locale('en'));
  }

  // ============================================================================
  // COMMON
  // ============================================================================

  String get appName => 'KerjaFlow';
  String get loading => 'Loading...';
  String get error => 'Error';
  String get retry => 'Retry';
  String get cancel => 'Cancel';
  String get save => 'Save';
  String get delete => 'Delete';
  String get edit => 'Edit';
  String get done => 'Done';
  String get next => 'Next';
  String get back => 'Back';
  String get close => 'Close';
  String get search => 'Search';
  String get noResults => 'No results found';
  String get ok => 'OK';
  String get yes => 'Yes';
  String get no => 'No';
  String get confirm => 'Confirm';
  String get submit => 'Submit';
  String get refresh => 'Refresh';
  String get pullToRefresh => 'Pull to refresh';

  // ============================================================================
  // AUTH
  // ============================================================================

  String get welcome => 'Welcome';
  String get welcomeBack => 'Welcome Back';
  String get signIn => 'Sign In';
  String get signOut => 'Sign Out';
  String get employeeId => 'Employee ID';
  String get password => 'Password';
  String get forgotPassword => 'Forgot Password?';
  String get createPin => 'Create PIN';
  String get enterPin => 'Enter PIN';
  String get confirmPin => 'Confirm PIN';
  String get pinMismatch => 'PINs do not match';
  String get wrongPin => 'Wrong PIN';
  String get biometricLogin => 'Biometric Login';
  String get useBiometrics => 'Use fingerprint or face to login';
  String get loginFailed => 'Login failed';
  String get invalidCredentials => 'Invalid credentials';

  // ============================================================================
  // DASHBOARD
  // ============================================================================

  String get home => 'Home';
  String get goodMorning => 'Good Morning';
  String get goodAfternoon => 'Good Afternoon';
  String get goodEvening => 'Good Evening';
  String get quickActions => 'Quick Actions';
  String get recentActivity => 'Recent Activity';
  String get viewAll => 'View All';

  // ============================================================================
  // PAYSLIP
  // ============================================================================

  String get payslips => 'Payslips';
  String get payslip => 'Payslip';
  String get payslipDetails => 'Payslip Details';
  String get netPay => 'Net Pay';
  String get grossPay => 'Gross Pay';
  String get earnings => 'Earnings';
  String get deductions => 'Deductions';
  String get downloadPdf => 'Download PDF';
  String get basicSalary => 'Basic Salary';
  String get allowances => 'Allowances';
  String get overtime => 'Overtime';
  String get bonus => 'Bonus';
  String get epf => 'EPF';
  String get socso => 'SOCSO';
  String get eis => 'EIS';
  String get pcb => 'PCB (Tax)';
  String get payPeriod => 'Pay Period';

  // ============================================================================
  // LEAVE
  // ============================================================================

  String get leave => 'Leave';
  String get leaveBalance => 'Leave Balance';
  String get applyLeave => 'Apply Leave';
  String get leaveHistory => 'Leave History';
  String get annualLeave => 'Annual Leave';
  String get medicalLeave => 'Medical Leave';
  String get emergencyLeave => 'Emergency Leave';
  String get unpaidLeave => 'Unpaid Leave';
  String get maternityLeave => 'Maternity Leave';
  String get paternityLeave => 'Paternity Leave';
  String get compassionateLeave => 'Compassionate Leave';
  String get replacementLeave => 'Replacement Leave';
  String get hajjLeave => 'Hajj Leave';
  String get leaveType => 'Leave Type';
  String get startDate => 'Start Date';
  String get endDate => 'End Date';
  String get reason => 'Reason';
  String get attachment => 'Attachment';
  String get attachments => 'Attachments';
  String get cancelLeave => 'Cancel Leave';
  String get leaveApplied => 'Leave applied successfully';
  String get leaveCancelled => 'Leave cancelled';

  // ============================================================================
  // APPROVALS
  // ============================================================================

  String get approvals => 'Approvals';
  String get pending => 'Pending';
  String get approved => 'Approved';
  String get rejected => 'Rejected';
  String get approve => 'Approve';
  String get reject => 'Reject';
  String get comment => 'Comment';
  String get commentRequired => 'Comment required for rejection';
  String get approvedBy => 'Approved by';
  String get rejectedBy => 'Rejected by';
  String get submittedOn => 'Submitted on';
  String get noApprovals => 'No pending approvals';

  // ============================================================================
  // NOTIFICATIONS
  // ============================================================================

  String get notifications => 'Notifications';
  String get markAllRead => 'Mark all as read';
  String get noNotifications => 'No notifications';
  String get newNotification => 'New notification';

  // ============================================================================
  // PROFILE
  // ============================================================================

  String get profile => 'Profile';
  String get myProfile => 'My Profile';
  String get editProfile => 'Edit Profile';
  String get personalInfo => 'Personal Information';
  String get contactInfo => 'Contact Information';
  String get employmentInfo => 'Employment Information';
  String get emergencyContact => 'Emergency Contact';
  String get fullName => 'Full Name';
  String get email => 'Email';
  String get phoneNumber => 'Phone Number';
  String get dateOfBirth => 'Date of Birth';
  String get gender => 'Gender';
  String get nationality => 'Nationality';
  String get address => 'Address';
  String get department => 'Department';
  String get position => 'Position';
  String get joinDate => 'Join Date';
  String get reportingTo => 'Reporting To';
  String get profileUpdated => 'Profile updated successfully';
  String get changePhoto => 'Change Photo';

  // ============================================================================
  // SETTINGS
  // ============================================================================

  String get settings => 'Settings';
  String get language => 'Language';
  String get theme => 'Theme';
  String get themeSystem => 'System Default';
  String get themeLight => 'Light';
  String get themeDark => 'Dark';
  String get security => 'Security';
  String get changePin => 'Change PIN';
  String get changePassword => 'Change Password';
  String get autoLock => 'Auto-lock';
  String get about => 'About';
  String get help => 'Help & FAQ';
  String get logout => 'Logout';
  String get logoutConfirm => 'Are you sure you want to logout?';
  String get version => 'Version';
  String get termsOfService => 'Terms of Service';
  String get privacyPolicy => 'Privacy Policy';
  String get licenses => 'Open Source Licenses';

  // ============================================================================
  // DOCUMENTS
  // ============================================================================

  String get documents => 'Documents';
  String get uploadDocument => 'Upload Document';
  String get documentUploaded => 'Document uploaded successfully';
  String get documentType => 'Document Type';
  String get selectFile => 'Select File';
  String get noDocuments => 'No documents';

  // ============================================================================
  // STATUS & UNITS
  // ============================================================================

  String get days => 'days';
  String get day => 'day';
  String get hours => 'hours';
  String get hour => 'hour';
  String get remaining => 'remaining';
  String get used => 'used';
  String get available => 'available';
  String get total => 'Total';

  // ============================================================================
  // ERRORS
  // ============================================================================

  String get errorGeneric => 'Something went wrong';
  String get errorNetwork => 'Network error. Please check your connection.';
  String get errorServer => 'Server error. Please try again later.';
  String get errorTimeout => 'Request timed out. Please try again.';
  String get errorUnauthorized => 'Session expired. Please login again.';
  String get errorNotFound => 'Not found';
  String get errorValidation => 'Please check your input';

  // ============================================================================
  // EMPTY STATES
  // ============================================================================

  String get emptyPayslips => 'No payslips available';
  String get emptyLeave => 'No leave records';
  String get emptyApprovals => 'No pending approvals';
  String get emptyNotifications => 'No notifications';
  String get emptyDocuments => 'No documents uploaded';

  // ============================================================================
  // ACCESSIBILITY
  // ============================================================================

  String get tapToSelect => 'Tap to select';
  String get tapToOpen => 'Tap to open';
  String get tapToClose => 'Tap to close';
  String get swipeToRefresh => 'Swipe down to refresh';
  String get loadingContent => 'Loading content';
  String get contentLoaded => 'Content loaded';
}
