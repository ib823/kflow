import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for handling deep links and universal links
class DeepLinkService {
  static const _channel = MethodChannel('my.kerjaflow.app/deep_link');

  static DeepLinkService? _instance;
  static DeepLinkService get instance {
    _instance ??= DeepLinkService._();
    return _instance!;
  }

  DeepLinkService._();

  final _linkController = StreamController<Uri>.broadcast();

  /// Stream of incoming deep links
  Stream<Uri> get onLink => _linkController.stream;

  Uri? _initialLink;

  /// The deep link that launched the app (if any)
  Uri? get initialLink => _initialLink;

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Set up method call handler for incoming links
    _channel.setMethodCallHandler(_handleMethodCall);

    // Get initial link if app was launched from a deep link
    try {
      final link = await _channel.invokeMethod<String>('getInitialLink');
      if (link != null) {
        _initialLink = Uri.tryParse(link);
        debugPrint('Initial deep link: $_initialLink');
      }
    } catch (e) {
      debugPrint('Failed to get initial deep link: $e');
    }
  }

  /// Handle method calls from native code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDeepLink':
        final link = call.arguments as String?;
        if (link != null) {
          final uri = Uri.tryParse(link);
          if (uri != null) {
            _linkController.add(uri);
          }
        }
        break;
    }
  }

  /// Parse a deep link and return the route and parameters
  DeepLinkResult? parseLink(Uri uri) {
    // Handle custom scheme: kerjaflow://
    if (uri.scheme == 'kerjaflow') {
      return _parseKerjaflowScheme(uri);
    }

    // Handle universal links: https://kerjaflow.my/...
    if (uri.host.endsWith('kerjaflow.my')) {
      return _parseUniversalLink(uri);
    }

    return null;
  }

  /// Parse kerjaflow:// scheme links
  DeepLinkResult? _parseKerjaflowScheme(Uri uri) {
    final path = uri.host + uri.path;
    final params = uri.queryParameters;

    switch (path) {
      case 'leave':
      case 'leave/':
        return DeepLinkResult(
          route: '/leave',
          params: params,
        );

      case 'leave/request':
        final requestId = params['id'];
        if (requestId != null) {
          return DeepLinkResult(
            route: '/leave/request/$requestId',
            params: params,
          );
        }
        return DeepLinkResult(route: '/leave');

      case 'payslip':
      case 'payslips':
        return DeepLinkResult(
          route: '/payslip',
          params: params,
        );

      case 'payslip/view':
        final payslipId = params['id'];
        if (payslipId != null) {
          return DeepLinkResult(
            route: '/payslip/$payslipId',
            params: params,
          );
        }
        return DeepLinkResult(route: '/payslip');

      case 'notifications':
        return DeepLinkResult(
          route: '/notifications',
          params: params,
        );

      case 'profile':
        return DeepLinkResult(
          route: '/profile',
          params: params,
        );

      case 'approval':
        final type = params['type'];
        final id = params['id'];
        if (type == 'leave' && id != null) {
          return DeepLinkResult(
            route: '/leave/request/$id',
            params: {...params, 'action': 'approve'},
          );
        }
        return DeepLinkResult(route: '/home');

      default:
        return DeepLinkResult(route: '/home');
    }
  }

  /// Parse universal links (https://kerjaflow.my/...)
  DeepLinkResult? _parseUniversalLink(Uri uri) {
    final segments = uri.pathSegments;
    final params = uri.queryParameters;

    if (segments.isEmpty) {
      return DeepLinkResult(route: '/home');
    }

    switch (segments[0]) {
      case 'app':
        // https://kerjaflow.my/app/leave/123
        if (segments.length > 1) {
          final subPath = segments.sublist(1).join('/');
          return DeepLinkResult(
            route: '/$subPath',
            params: params,
          );
        }
        return DeepLinkResult(route: '/home');

      case 'leave':
        if (segments.length > 1) {
          return DeepLinkResult(
            route: '/leave/request/${segments[1]}',
            params: params,
          );
        }
        return DeepLinkResult(route: '/leave');

      case 'payslip':
        if (segments.length > 1) {
          return DeepLinkResult(
            route: '/payslip/${segments[1]}',
            params: params,
          );
        }
        return DeepLinkResult(route: '/payslip');

      case 'reset-password':
        final token = params['token'];
        if (token != null) {
          return DeepLinkResult(
            route: '/reset-password',
            params: params,
          );
        }
        return DeepLinkResult(route: '/login');

      case 'verify-email':
        final token = params['token'];
        if (token != null) {
          return DeepLinkResult(
            route: '/verify-email',
            params: params,
          );
        }
        return DeepLinkResult(route: '/login');

      default:
        return DeepLinkResult(route: '/home');
    }
  }

  /// Dispose resources
  void dispose() {
    _linkController.close();
  }
}

/// Result of parsing a deep link
class DeepLinkResult {
  final String route;
  final Map<String, String> params;

  DeepLinkResult({
    required this.route,
    this.params = const {},
  });

  @override
  String toString() => 'DeepLinkResult(route: $route, params: $params)';
}
