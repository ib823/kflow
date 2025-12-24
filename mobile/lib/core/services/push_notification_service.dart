import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Unified push notification service that handles both FCM (Google) and HMS (Huawei)
class PushNotificationService {
  static const _hmsChannel = MethodChannel('my.kerjaflow.app/hms');

  static PushNotificationService? _instance;
  static PushNotificationService get instance {
    _instance ??= PushNotificationService._();
    return _instance!;
  }

  PushNotificationService._();

  final _tokenController = StreamController<String>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of push tokens (FCM or HMS)
  Stream<String> get onTokenRefresh => _tokenController.stream;

  /// Stream of received notifications
  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;

  String? _currentToken;
  String? get currentToken => _currentToken;

  PushProvider? _provider;
  PushProvider? get provider => _provider;

  /// Initialize push notifications based on available services
  Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('Push notifications not supported on this platform');
      return;
    }

    if (Platform.isIOS) {
      // iOS always uses FCM/APNs
      await _initializeFcm();
      _provider = PushProvider.fcm;
    } else if (Platform.isAndroid) {
      // Check if HMS is available
      final hmsAvailable = await _isHmsAvailable();

      if (hmsAvailable) {
        await _initializeHms();
        _provider = PushProvider.hms;
      } else {
        await _initializeFcm();
        _provider = PushProvider.fcm;
      }
    }

    debugPrint('Push notification initialized with provider: $_provider');
  }

  /// Check if HMS Core is available on this device
  Future<bool> _isHmsAvailable() async {
    try {
      final result = await _hmsChannel.invokeMethod<bool>('isHmsAvailable');
      return result ?? false;
    } catch (e) {
      debugPrint('HMS availability check failed: $e');
      return false;
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFcm() async {
    try {
      // FCM initialization handled by firebase_messaging package
      // This is a placeholder - actual implementation uses the package
      debugPrint('FCM initialization - implement with firebase_messaging package');
    } catch (e) {
      debugPrint('FCM initialization failed: $e');
    }
  }

  /// Initialize Huawei Push Kit
  Future<void> _initializeHms() async {
    try {
      // Get initial token
      final token = await _hmsChannel.invokeMethod<String>('getHmsToken');
      if (token != null) {
        _currentToken = token;
        _tokenController.add(token);
      }

      // Check for pending notifications
      await _checkPendingHmsNotification();

      // Set up method call handler for incoming notifications
      _hmsChannel.setMethodCallHandler(_handleHmsMethodCall);

      debugPrint('HMS Push initialized with token: ${token?.substring(0, 20)}...');
    } catch (e) {
      debugPrint('HMS initialization failed: $e');
    }
  }

  /// Handle method calls from native HMS code
  Future<dynamic> _handleHmsMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTokenRefresh':
        final token = call.arguments as String;
        _currentToken = token;
        _tokenController.add(token);
        break;
      case 'onNotification':
        final data = call.arguments as Map<dynamic, dynamic>;
        _notificationController.add(Map<String, dynamic>.from(data));
        break;
    }
  }

  /// Check for pending HMS notifications
  Future<void> _checkPendingHmsNotification() async {
    try {
      final notification = await _hmsChannel.invokeMethod<String>(
        'getPendingNotification',
      );

      if (notification != null) {
        final data = jsonDecode(notification) as Map<String, dynamic>;
        _notificationController.add(data);

        // Clear the pending notification
        await _hmsChannel.invokeMethod('clearPendingNotification');
      }
    } catch (e) {
      debugPrint('Failed to check pending HMS notification: $e');
    }
  }

  /// Get the current push token
  Future<String?> getToken() async {
    if (_currentToken != null) return _currentToken;

    if (_provider == PushProvider.hms) {
      try {
        _currentToken = await _hmsChannel.invokeMethod<String>('getHmsToken');
      } catch (e) {
        debugPrint('Failed to get HMS token: $e');
      }
    }
    // FCM token retrieval handled by firebase_messaging package

    return _currentToken;
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      // Implement using firebase_messaging or local_notifications package
      return true;
    }
    // Android 13+ notification permission handled separately
    return true;
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    if (_provider == PushProvider.fcm) {
      // Implement using firebase_messaging package
      debugPrint('Subscribing to FCM topic: $topic');
    } else if (_provider == PushProvider.hms) {
      // HMS topic subscription requires server-side implementation
      debugPrint('HMS topic subscription: $topic (server-side)');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_provider == PushProvider.fcm) {
      // Implement using firebase_messaging package
      debugPrint('Unsubscribing from FCM topic: $topic');
    } else if (_provider == PushProvider.hms) {
      // HMS topic unsubscription requires server-side implementation
      debugPrint('HMS topic unsubscription: $topic (server-side)');
    }
  }

  /// Dispose resources
  void dispose() {
    _tokenController.close();
    _notificationController.close();
  }
}

/// Push notification provider types
enum PushProvider {
  fcm,  // Firebase Cloud Messaging (Google)
  hms,  // Huawei Mobile Services
}
