import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/models.dart';

/// Local storage using Hive
class LocalStorage {
  static const String _userBox = 'user';
  static const String _payslipsBox = 'payslips';
  static const String _leaveBox = 'leave';
  static const String _notificationsBox = 'notifications';
  static const String _syncQueueBox = 'sync_queue';
  static const String _cacheMetaBox = 'cache_meta';

  /// Initialize Hive boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox(_userBox),
      Hive.openBox(_payslipsBox),
      Hive.openBox(_leaveBox),
      Hive.openBox(_notificationsBox),
      Hive.openBox(_syncQueueBox),
      Hive.openBox(_cacheMetaBox),
    ]);
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await Future.wait([
      Hive.box(_userBox).clear(),
      Hive.box(_payslipsBox).clear(),
      Hive.box(_leaveBox).clear(),
      Hive.box(_notificationsBox).clear(),
      Hive.box(_syncQueueBox).clear(),
      Hive.box(_cacheMetaBox).clear(),
    ]);
  }

  // User storage
  Box get _user => Hive.box(_userBox);

  Future<void> saveUser(User user) async {
    await _user.put('current_user', jsonEncode(user.toJson()));
    await _updateCacheMeta('user');
  }

  User? getUser() {
    final data = _user.get('current_user');
    if (data == null) return null;
    return User.fromJson(jsonDecode(data as String) as Map<String, dynamic>);
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    await _user.put('settings', jsonEncode(settings.toJson()));
  }

  UserSettings? getUserSettings() {
    final data = _user.get('settings');
    if (data == null) return null;
    return UserSettings.fromJson(jsonDecode(data as String) as Map<String, dynamic>);
  }

  // Payslip storage
  Box get _payslips => Hive.box(_payslipsBox);

  Future<void> savePayslips(List<Payslip> payslips, int year) async {
    await _payslips.put(
      'payslips_$year',
      jsonEncode(payslips.map((p) => p.toJson()).toList()),
    );
    await _updateCacheMeta('payslips_$year');
  }

  List<Payslip> getPayslips(int year) {
    final data = _payslips.get('payslips_$year');
    if (data == null) return [];

    final list = jsonDecode(data as String) as List;
    return list
        .map((e) => Payslip.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Leave storage
  Box get _leave => Hive.box(_leaveBox);

  Future<void> saveLeaveBalances(List<LeaveBalance> balances) async {
    await _leave.put(
      'balances',
      jsonEncode(balances.map((b) => b.toJson()).toList()),
    );
    await _updateCacheMeta('leave_balances');
  }

  List<LeaveBalance> getLeaveBalances() {
    final data = _leave.get('balances');
    if (data == null) return [];

    final list = jsonDecode(data as String) as List;
    return list
        .map((e) => LeaveBalance.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLeaveRequests(List<LeaveRequest> requests) async {
    await _leave.put(
      'requests',
      jsonEncode(requests.map((r) => r.toJson()).toList()),
    );
    await _updateCacheMeta('leave_requests');
  }

  List<LeaveRequest> getLeaveRequests() {
    final data = _leave.get('requests');
    if (data == null) return [];

    final list = jsonDecode(data as String) as List;
    return list
        .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Notification storage
  Box get _notifications => Hive.box(_notificationsBox);

  Future<void> saveNotifications(List<AppNotification> notifications) async {
    await _notifications.put(
      'all',
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
    await _updateCacheMeta('notifications');
  }

  List<AppNotification> getNotifications() {
    final data = _notifications.get('all');
    if (data == null) return [];

    final list = jsonDecode(data as String) as List;
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Cache metadata
  Box get _cacheMeta => Hive.box(_cacheMetaBox);

  Future<void> _updateCacheMeta(String key) async {
    await _cacheMeta.put(key, DateTime.now().toIso8601String());
  }

  DateTime? getCacheTime(String key) {
    final data = _cacheMeta.get(key);
    if (data == null) return null;
    return DateTime.parse(data as String);
  }

  bool isCacheStale(String key, Duration maxAge) {
    final cacheTime = getCacheTime(key);
    if (cacheTime == null) return true;
    return DateTime.now().difference(cacheTime) > maxAge;
  }

  // Sync queue
  Box get _syncQueue => Hive.box(_syncQueueBox);

  Future<void> addToSyncQueue(SyncItem item) async {
    final items = getSyncQueue();
    items.add(item);
    await _syncQueue.put(
      'queue',
      jsonEncode(items.map((i) => i.toJson()).toList()),
    );
  }

  List<SyncItem> getSyncQueue() {
    final data = _syncQueue.get('queue');
    if (data == null) return [];

    final list = jsonDecode(data as String) as List;
    return list
        .map((e) => SyncItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> removeSyncItem(String id) async {
    final items = getSyncQueue();
    items.removeWhere((i) => i.id == id);
    await _syncQueue.put(
      'queue',
      jsonEncode(items.map((i) => i.toJson()).toList()),
    );
  }

  Future<void> clearSyncQueue() async {
    await _syncQueue.delete('queue');
  }
}

/// Sync queue item
class SyncItem {
  final String id;
  final String type;
  final String endpoint;
  final String method;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  int retryCount;

  SyncItem({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.method,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      id: json['id'] as String,
      type: json['type'] as String,
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'endpoint': endpoint,
      'method': method,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'retry_count': retryCount,
    };
  }
}
