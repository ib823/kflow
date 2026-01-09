import '../datasources/remote/odoo_client.dart';
import '../datasources/local/local_storage.dart';
import '../sync/sync_manager.dart';

/// Base repository with common functionality
abstract class BaseRepository {
  final OdooClient client;
  final LocalStorage storage;
  final SyncManager syncManager;

  BaseRepository({
    required this.client,
    required this.storage,
    required this.syncManager,
  });

  /// Default cache duration
  Duration get defaultCacheDuration => const Duration(minutes: 15);

  /// Check if should use cache
  bool shouldUseCache(String cacheKey) {
    return !storage.isCacheStale(cacheKey, defaultCacheDuration);
  }
}
