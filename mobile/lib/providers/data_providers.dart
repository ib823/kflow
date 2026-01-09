import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/data.dart';

/// Odoo client provider
final odooClientProvider = Provider<OdooClient>((ref) {
  return OdooClient();
});

/// Local storage provider
final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

/// Sync manager provider
final syncManagerProvider = Provider<SyncManager>((ref) {
  final manager = SyncManager(
    client: ref.watch(odooClientProvider),
    storage: ref.watch(localStorageProvider),
  );
  // Start listening for connectivity changes
  manager.startListening();
  ref.onDispose(() => manager.stopListening());
  return manager;
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    client: ref.watch(odooClientProvider),
    storage: ref.watch(localStorageProvider),
    syncManager: ref.watch(syncManagerProvider),
  );
});

/// Payslip repository provider
final payslipRepositoryProvider = Provider<PayslipRepository>((ref) {
  return PayslipRepository(
    client: ref.watch(odooClientProvider),
    storage: ref.watch(localStorageProvider),
    syncManager: ref.watch(syncManagerProvider),
  );
});

/// Leave repository provider
final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository(
    client: ref.watch(odooClientProvider),
    storage: ref.watch(localStorageProvider),
    syncManager: ref.watch(syncManagerProvider),
  );
});

/// Connectivity status provider
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Initial check
  final results = await connectivity.checkConnectivity();
  yield results.isNotEmpty && results.first != ConnectivityResult.none;

  // Stream connectivity changes
  await for (final results in connectivity.onConnectivityChanged) {
    yield results.isNotEmpty && results.first != ConnectivityResult.none;
  }
});

/// Is online provider
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
    data: (isOnline) => isOnline,
    orElse: () => true, // Assume online if unknown
  );
});

/// Pending sync count provider
final pendingSyncCountProvider = Provider<int>((ref) {
  return ref.watch(syncManagerProvider).pendingSyncCount;
});

/// Has pending syncs provider
final hasPendingSyncsProvider = Provider<bool>((ref) {
  return ref.watch(pendingSyncCountProvider) > 0;
});
