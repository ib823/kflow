import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:logger/logger.dart';

/// HMS Push notification service
/// Handles push token registration, topic subscription, and message handling
class HmsPushService {
  final Logger _logger = Logger();

  String? _pushToken;
  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();

  /// Current push token
  String? get pushToken => _pushToken;

  /// Stream of incoming push messages
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  /// Stream of token updates
  Stream<String> get onTokenRefresh => _tokenController.stream;

  /// Initialize HMS Push Kit
  Future<void> initialize() async {
    try {
      // Turn on push auto-init
      await Push.setAutoInitEnabled(true);

      // Setup listeners
      Push.getTokenStream.listen(_onTokenReceived);
      Push.getIntentStream.listen(_onNotificationOpened);
      Push.onNotificationOpenedApp.listen(_onNotificationOpened);
      Push.onMessageReceivedStream.listen(_onMessageReceived);

      // Get initial token
      await getToken();

      _logger.i('HMS Push service initialized');
    } catch (e) {
      _logger.e('Error initializing HMS Push: $e');
    }
  }

  /// Get push notification token
  Future<String?> getToken() async {
    try {
      final token = await Push.getToken('');
      if (token.isNotEmpty) {
        _pushToken = token;
        _logger.i('HMS push token received: ${token.substring(0, 20)}...');
      }
      return _pushToken;
    } catch (e) {
      _logger.e('Error getting push token: $e');
      return null;
    }
  }

  /// Handle token received callback
  void _onTokenReceived(String token) {
    _pushToken = token;
    _tokenController.add(token);
    _logger.i('HMS push token updated');
  }

  /// Handle notification opened callback
  void _onNotificationOpened(dynamic message) {
    _logger.i('Notification opened: $message');
    // Handle notification tap - navigate to specific screen
  }

  /// Handle message received callback
  void _onMessageReceived(RemoteMessage message) {
    _logger.i('Message received: ${message.data}');
    _messageController.add(message);
  }

  /// Subscribe to a topic for targeted notifications
  Future<bool> subscribeToTopic(String topic) async {
    try {
      await Push.subscribe(topic);
      _logger.i('Subscribed to topic: $topic');
      return true;
    } catch (e) {
      _logger.e('Error subscribing to topic $topic: $e');
      return false;
    }
  }

  /// Unsubscribe from a topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      await Push.unsubscribe(topic);
      _logger.i('Unsubscribed from topic: $topic');
      return true;
    } catch (e) {
      _logger.e('Error unsubscribing from topic $topic: $e');
      return false;
    }
  }

  /// Subscribe to KerjaFlow specific topics
  Future<void> subscribeToKerjaFlowTopics({
    required String companyId,
    required String employeeId,
    String? departmentId,
    bool isManager = false,
  }) async {
    // All employees topic
    await subscribeToTopic('kerjaflow_all');

    // Company-specific topic
    await subscribeToTopic('company_$companyId');

    // Employee-specific topic
    await subscribeToTopic('employee_$employeeId');

    // Department topic if provided
    if (departmentId != null) {
      await subscribeToTopic('department_$departmentId');
    }

    // Manager-specific topic
    if (isManager) {
      await subscribeToTopic('managers_$companyId');
      await subscribeToTopic('approvals_$companyId');
    }

    // Feature-specific topics
    await subscribeToTopic('payslips_$companyId');
    await subscribeToTopic('leave_$companyId');
    await subscribeToTopic('announcements_$companyId');
  }

  /// Unsubscribe from all KerjaFlow topics (on logout)
  Future<void> unsubscribeFromAllTopics({
    required String companyId,
    required String employeeId,
    String? departmentId,
    bool isManager = false,
  }) async {
    await unsubscribeFromTopic('kerjaflow_all');
    await unsubscribeFromTopic('company_$companyId');
    await unsubscribeFromTopic('employee_$employeeId');

    if (departmentId != null) {
      await unsubscribeFromTopic('department_$departmentId');
    }

    if (isManager) {
      await unsubscribeFromTopic('managers_$companyId');
      await unsubscribeFromTopic('approvals_$companyId');
    }

    await unsubscribeFromTopic('payslips_$companyId');
    await unsubscribeFromTopic('leave_$companyId');
    await unsubscribeFromTopic('announcements_$companyId');
  }

  /// Delete push token (for logout)
  Future<void> deleteToken() async {
    try {
      await Push.deleteToken('');
      _pushToken = null;
      _logger.i('Push token deleted');
    } catch (e) {
      _logger.e('Error deleting push token: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final enabled = await Push.isNotificationEnabled();
      return enabled ?? false;
    } catch (e) {
      _logger.e('Error checking notification status: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _messageController.close();
    _tokenController.close();
  }
}

/// Push notification topics for KerjaFlow
class PushTopics {
  static const String all = 'kerjaflow_all';

  static String company(String id) => 'company_$id';
  static String employee(String id) => 'employee_$id';
  static String department(String id) => 'department_$id';
  static String managers(String companyId) => 'managers_$companyId';
  static String approvals(String companyId) => 'approvals_$companyId';
  static String payslips(String companyId) => 'payslips_$companyId';
  static String leave(String companyId) => 'leave_$companyId';
  static String announcements(String companyId) => 'announcements_$companyId';
}
