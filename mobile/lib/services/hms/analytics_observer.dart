import 'package:flutter/material.dart';
import 'analytics_service.dart';

/// Navigation observer that automatically tracks screen views
/// Used with GoRouter or Navigator to track screen transitions
class AnalyticsRouteObserver extends NavigatorObserver {
  final HmsAnalyticsService _analytics;
  String? _currentScreen;

  AnalyticsRouteObserver(this._analytics);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreen(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackScreen(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackScreen(newRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute != null) {
      _trackScreen(previousRoute);
    }
  }

  void _trackScreen(Route<dynamic> route) {
    final screenName = _getScreenName(route);
    if (screenName != null && screenName != _currentScreen) {
      // End previous screen tracking
      if (_currentScreen != null) {
        _analytics.endScreen(_currentScreen!);
      }

      // Track new screen
      _currentScreen = screenName;
      _analytics.trackScreen(screenName, screenClass: _getScreenClass(route));
    }
  }

  String? _getScreenName(Route<dynamic> route) {
    // First check route settings name
    final routeName = route.settings.name;
    if (routeName != null && routeName.isNotEmpty && routeName != '/') {
      return _formatRouteName(routeName);
    }

    // Fallback to arguments if they contain screen name
    final args = route.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('screenName')) {
      return args['screenName'] as String;
    }

    // For MaterialPageRoute, try to get the widget name
    if (route is MaterialPageRoute) {
      return null; // Cannot determine screen name
    }

    return null;
  }

  String? _getScreenClass(Route<dynamic> route) {
    // Get the screen class from arguments if available
    final args = route.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('screenClass')) {
      return args['screenClass'] as String;
    }
    return null;
  }

  String _formatRouteName(String routeName) {
    // Convert route paths to readable screen names
    // e.g., '/payslips/detail' -> 'PayslipsDetailScreen'

    // Remove leading slash
    var name = routeName.startsWith('/') ? routeName.substring(1) : routeName;

    // Handle empty route
    if (name.isEmpty) {
      return 'HomeScreen';
    }

    // Remove query parameters
    final queryIndex = name.indexOf('?');
    if (queryIndex != -1) {
      name = name.substring(0, queryIndex);
    }

    // Remove dynamic segments (e.g., :id, [id])
    name = name.replaceAll(RegExp(r':\w+|\[\w+\]'), '');

    // Clean up double slashes
    name = name.replaceAll('//', '/');

    // Convert to PascalCase
    final parts = name.split('/').where((p) => p.isNotEmpty);
    final pascalCase = parts.map((part) {
      return part[0].toUpperCase() + part.substring(1);
    }).join('');

    return '${pascalCase}Screen';
  }
}

/// GoRouter observer adapter for HMS Analytics
/// Use this with GoRouter for automatic screen tracking
class AnalyticsGoRouterObserver extends NavigatorObserver {
  final HmsAnalyticsService _analytics;
  String? _currentScreen;

  AnalyticsGoRouterObserver(this._analytics);

  /// Called when navigation happens in GoRouter
  void onNavigation(String location, String? previousLocation) {
    final screenName = _formatLocationToScreenName(location);

    // End previous screen tracking
    if (_currentScreen != null) {
      _analytics.endScreen(_currentScreen!);
    }

    // Track new screen
    _currentScreen = screenName;
    _analytics.trackScreen(screenName);
  }

  String _formatLocationToScreenName(String location) {
    // Remove leading slash
    var name = location.startsWith('/') ? location.substring(1) : location;

    // Handle empty route (home)
    if (name.isEmpty) {
      return 'DashboardScreen';
    }

    // Remove query parameters
    final queryIndex = name.indexOf('?');
    if (queryIndex != -1) {
      name = name.substring(0, queryIndex);
    }

    // Remove UUID-like segments (common for detail screens)
    name = name.replaceAll(
      RegExp(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'),
      'detail',
    );

    // Remove numeric IDs
    name = name.replaceAll(RegExp(r'/\d+(/|$)'), '/detail\$1');

    // Convert to PascalCase screen name
    final parts = name.split('/').where((p) => p.isNotEmpty);
    final pascalCase = parts.map((part) {
      // Handle hyphenated names
      if (part.contains('-')) {
        return part.split('-').map((p) {
          return p[0].toUpperCase() + p.substring(1);
        }).join('');
      }
      return part[0].toUpperCase() + part.substring(1);
    }).join('');

    return '${pascalCase}Screen';
  }

  /// Manually track screen (for screens not using navigation)
  void trackScreen(String screenName) {
    if (_currentScreen != null) {
      _analytics.endScreen(_currentScreen!);
    }
    _currentScreen = screenName;
    _analytics.trackScreen(screenName);
  }
}

/// Route name constants for consistent tracking
class Routes {
  // Auth
  static const String login = '/login';
  static const String pinEntry = '/pin';
  static const String pinSetup = '/pin/setup';

  // Main
  static const String dashboard = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Payslips
  static const String payslips = '/payslips';
  static const String payslipDetail = '/payslips/:id';
  static const String payslipPdf = '/payslips/:id/pdf';

  // Leave
  static const String leaveBalance = '/leave';
  static const String leaveHistory = '/leave/history';
  static const String leaveRequest = '/leave/request';
  static const String leaveDetail = '/leave/:id';

  // Approvals
  static const String approvals = '/approvals';
  static const String approvalDetail = '/approvals/:id';

  // Documents
  static const String documents = '/documents';
  static const String documentUpload = '/documents/upload';
  static const String documentView = '/documents/:id';

  // Attendance
  static const String attendance = '/attendance';
  static const String attendanceHistory = '/attendance/history';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationDetail = '/notifications/:id';
}
