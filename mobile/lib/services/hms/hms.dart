/// HMS (Huawei Mobile Services) integration for KerjaFlow
///
/// This module provides:
/// - HMS availability checking
/// - Push Kit integration for notifications
/// - Analytics Kit for screen and event tracking
///
/// Usage:
/// ```dart
/// // Check HMS availability
/// final isAvailable = await ref.read(isHmsAvailableProvider.future);
///
/// // Initialize HMS services
/// final hmsNotifier = ref.read(hmsInitializationProvider.notifier);
/// await hmsNotifier.initialize();
///
/// // Track analytics events
/// final tracker = ref.read(analyticsTrackerProvider);
/// await tracker.trackPayslipViewed(payslipId: 'xxx', month: 'Jan', year: '2026');
/// ```

export 'hms_availability.dart';
export 'push_service.dart';
export 'analytics_service.dart';
export 'analytics_observer.dart';
