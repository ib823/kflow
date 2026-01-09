import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hms/hms_availability.dart';
import '../services/hms/push_service.dart';
import '../services/hms/analytics_service.dart';
import '../services/hms/analytics_observer.dart';

/// Provider for HMS availability service
final hmsAvailabilityProvider = Provider<HmsAvailability>((ref) {
  return HmsAvailability();
});

/// Provider for HMS availability check result
final isHmsAvailableProvider = FutureProvider<bool>((ref) async {
  final hmsAvailability = ref.read(hmsAvailabilityProvider);
  return await hmsAvailability.checkAvailability();
});

/// Provider for HMS Push service
final hmsPushServiceProvider = Provider<HmsPushService>((ref) {
  final pushService = HmsPushService();

  // Dispose on ref disposal
  ref.onDispose(() {
    pushService.dispose();
  });

  return pushService;
});

/// Provider for HMS Analytics service
final hmsAnalyticsServiceProvider = Provider<HmsAnalyticsService>((ref) {
  return HmsAnalyticsService();
});

/// Provider for analytics route observer
final analyticsRouteObserverProvider = Provider<AnalyticsRouteObserver>((ref) {
  final analytics = ref.read(hmsAnalyticsServiceProvider);
  return AnalyticsRouteObserver(analytics);
});

/// Provider for GoRouter analytics observer
final analyticsGoRouterObserverProvider =
    Provider<AnalyticsGoRouterObserver>((ref) {
  final analytics = ref.read(hmsAnalyticsServiceProvider);
  return AnalyticsGoRouterObserver(analytics);
});

/// Provider for push token
final pushTokenProvider = FutureProvider<String?>((ref) async {
  final isHmsAvailable = await ref.watch(isHmsAvailableProvider.future);

  if (!isHmsAvailable) {
    return null;
  }

  final pushService = ref.read(hmsPushServiceProvider);
  return await pushService.getToken();
});

/// Provider for notification enabled status
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final isHmsAvailable = await ref.watch(isHmsAvailableProvider.future);

  if (!isHmsAvailable) {
    return false;
  }

  final pushService = ref.read(hmsPushServiceProvider);
  return await pushService.areNotificationsEnabled();
});

/// HMS initialization state
class HmsInitializationState {
  final bool isAvailable;
  final bool pushInitialized;
  final bool analyticsInitialized;
  final String? pushToken;
  final String? errorMessage;

  const HmsInitializationState({
    this.isAvailable = false,
    this.pushInitialized = false,
    this.analyticsInitialized = false,
    this.pushToken,
    this.errorMessage,
  });

  HmsInitializationState copyWith({
    bool? isAvailable,
    bool? pushInitialized,
    bool? analyticsInitialized,
    String? pushToken,
    String? errorMessage,
  }) {
    return HmsInitializationState(
      isAvailable: isAvailable ?? this.isAvailable,
      pushInitialized: pushInitialized ?? this.pushInitialized,
      analyticsInitialized: analyticsInitialized ?? this.analyticsInitialized,
      pushToken: pushToken ?? this.pushToken,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isFullyInitialized =>
      isAvailable && pushInitialized && analyticsInitialized;
}

/// HMS initialization notifier
class HmsInitializationNotifier extends StateNotifier<HmsInitializationState> {
  final HmsAvailability _availability;
  final HmsPushService _pushService;
  final HmsAnalyticsService _analyticsService;

  HmsInitializationNotifier(
    this._availability,
    this._pushService,
    this._analyticsService,
  ) : super(const HmsInitializationState());

  /// Initialize all HMS services
  Future<void> initialize() async {
    try {
      // Check HMS availability
      final isAvailable = await _availability.checkAvailability();
      state = state.copyWith(isAvailable: isAvailable);

      if (!isAvailable) {
        state = state.copyWith(
          errorMessage: _availability.getErrorMessage(),
        );
        return;
      }

      // Initialize Push Kit
      await _pushService.initialize();
      final token = await _pushService.getToken();
      state = state.copyWith(
        pushInitialized: true,
        pushToken: token,
      );

      // Initialize Analytics
      await _analyticsService.initialize();
      state = state.copyWith(analyticsInitialized: true);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'HMS initialization failed: $e',
      );
    }
  }

  /// Subscribe user to push topics
  Future<void> subscribeUserTopics({
    required String companyId,
    required String employeeId,
    String? departmentId,
    bool isManager = false,
  }) async {
    if (!state.isAvailable) return;

    await _pushService.subscribeToKerjaFlowTopics(
      companyId: companyId,
      employeeId: employeeId,
      departmentId: departmentId,
      isManager: isManager,
    );
  }

  /// Unsubscribe user from push topics (on logout)
  Future<void> unsubscribeUserTopics({
    required String companyId,
    required String employeeId,
    String? departmentId,
    bool isManager = false,
  }) async {
    if (!state.isAvailable) return;

    await _pushService.unsubscribeFromAllTopics(
      companyId: companyId,
      employeeId: employeeId,
      departmentId: departmentId,
      isManager: isManager,
    );
  }

  /// Set analytics user
  Future<void> setAnalyticsUser({
    required String userId,
    required String companyId,
    required String countryCode,
    String? departmentId,
    bool isManager = false,
  }) async {
    if (!state.analyticsInitialized) return;

    await _analyticsService.setUserId(userId);
    await _analyticsService.setUserProfile(
      companyId: companyId,
      countryCode: countryCode,
      departmentId: departmentId,
      isManager: isManager,
    );
  }

  /// Clear user data on logout
  Future<void> clearUserData() async {
    if (state.analyticsInitialized) {
      await _analyticsService.clearUserId();
    }

    if (state.pushInitialized) {
      await _pushService.deleteToken();
    }
  }
}

/// Provider for HMS initialization notifier
final hmsInitializationProvider =
    StateNotifierProvider<HmsInitializationNotifier, HmsInitializationState>(
        (ref) {
  final availability = ref.read(hmsAvailabilityProvider);
  final pushService = ref.read(hmsPushServiceProvider);
  final analyticsService = ref.read(hmsAnalyticsServiceProvider);

  return HmsInitializationNotifier(
    availability,
    pushService,
    analyticsService,
  );
});

/// Provider for tracking analytics events
final analyticsTrackerProvider = Provider<AnalyticsTracker>((ref) {
  final analytics = ref.read(hmsAnalyticsServiceProvider);
  final isInitialized = ref.watch(hmsInitializationProvider).analyticsInitialized;

  return AnalyticsTracker(analytics, isInitialized);
});

/// Helper class for tracking analytics events
class AnalyticsTracker {
  final HmsAnalyticsService _analytics;
  final bool _isInitialized;

  AnalyticsTracker(this._analytics, this._isInitialized);

  /// Track login event
  Future<void> trackLogin({required String method}) async {
    if (!_isInitialized) return;
    await _analytics.trackLogin(method: method);
  }

  /// Track logout event
  Future<void> trackLogout() async {
    if (!_isInitialized) return;
    await _analytics.trackLogout();
  }

  /// Track payslip viewed
  Future<void> trackPayslipViewed({
    required String payslipId,
    required String month,
    required String year,
  }) async {
    if (!_isInitialized) return;
    await _analytics.trackPayslipViewed(
      payslipId: payslipId,
      month: month,
      year: year,
    );
  }

  /// Track leave request
  Future<void> trackLeaveRequest({
    required String leaveType,
    required int days,
  }) async {
    if (!_isInitialized) return;
    await _analytics.trackLeaveRequestSubmitted(
      leaveType: leaveType,
      daysRequested: days,
    );
  }

  /// Track approval action
  Future<void> trackApproval({
    required String requestId,
    required String action,
    required String type,
  }) async {
    if (!_isInitialized) return;
    await _analytics.trackApprovalAction(
      requestId: requestId,
      action: action,
      requestType: type,
    );
  }

  /// Track screen view
  Future<void> trackScreen(String screenName) async {
    if (!_isInitialized) return;
    await _analytics.trackScreen(screenName);
  }

  /// Track custom event
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    if (!_isInitialized) return;
    await _analytics.trackEvent(name, parameters: params);
  }

  /// Track error
  Future<void> trackError({
    required String code,
    required String message,
    String? screen,
  }) async {
    if (!_isInitialized) return;
    await _analytics.trackError(
      errorCode: code,
      errorMessage: message,
      screenName: screen,
    );
  }
}
