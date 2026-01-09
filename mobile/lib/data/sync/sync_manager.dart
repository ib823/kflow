import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../datasources/remote/odoo_client.dart';
import '../datasources/local/local_storage.dart';

/// Sync manager for offline-first operations
class SyncManager {
  final OdooClient _client;
  final LocalStorage _storage;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Callback when sync completes
  Function()? onSyncComplete;

  /// Callback when sync fails
  Function(String error)? onSyncError;

  SyncManager({
    required OdooClient client,
    required LocalStorage storage,
    Connectivity? connectivity,
  })  : _client = client,
        _storage = storage,
        _connectivity = connectivity ?? Connectivity();

  /// Start listening for connectivity changes
  void startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        if (results.isNotEmpty && results.first != ConnectivityResult.none) {
          syncPendingItems();
        }
      },
    );
  }

  /// Stop listening
  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Check if online
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  /// Queue an operation for sync
  Future<void> queueOperation({
    required String type,
    required String endpoint,
    required String method,
    required Map<String, dynamic> data,
  }) async {
    final item = SyncItem(
      id: const Uuid().v4(),
      type: type,
      endpoint: endpoint,
      method: method,
      data: data,
      createdAt: DateTime.now(),
    );

    await _storage.addToSyncQueue(item);

    // Try to sync immediately if online
    if (await isOnline()) {
      syncPendingItems();
    }
  }

  /// Sync all pending items
  Future<void> syncPendingItems() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final items = _storage.getSyncQueue();

      for (final item in items) {
        try {
          await _processItem(item);
          await _storage.removeSyncItem(item.id);
        } catch (e) {
          // Increment retry count
          item.retryCount++;

          // Remove if too many retries
          if (item.retryCount > 3) {
            await _storage.removeSyncItem(item.id);
            onSyncError?.call('Failed to sync ${item.type}: $e');
          }
        }
      }

      onSyncComplete?.call();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processItem(SyncItem item) async {
    switch (item.method.toUpperCase()) {
      case 'POST':
        await _client.post(item.endpoint, data: item.data);
        break;
      case 'PUT':
        await _client.put(item.endpoint, data: item.data);
        break;
      case 'DELETE':
        await _client.delete(item.endpoint, data: item.data);
        break;
    }
  }

  /// Get pending sync count
  int get pendingSyncCount => _storage.getSyncQueue().length;

  /// Check if has pending syncs
  bool get hasPendingSyncs => pendingSyncCount > 0;
}
