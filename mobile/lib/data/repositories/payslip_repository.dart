import '../datasources/remote/api_config.dart';
import '../datasources/remote/odoo_client.dart';
import '../models/models.dart';
import 'base_repository.dart';

/// Payslip repository
class PayslipRepository extends BaseRepository {
  PayslipRepository({
    required super.client,
    required super.storage,
    required super.syncManager,
  });

  /// Get payslips for a year
  Future<List<Payslip>> getPayslips({
    required int year,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'payslips_$year';

    // Return cached if fresh
    if (!forceRefresh && shouldUseCache(cacheKey)) {
      final cached = storage.getPayslips(year);
      if (cached.isNotEmpty) return cached;
    }

    // Check if online
    if (!await syncManager.isOnline()) {
      // Return cached data even if stale when offline
      final cached = storage.getPayslips(year);
      if (cached.isNotEmpty) return cached;
      throw const ApiException(
        message: 'No internet connection and no cached data available.',
        code: 'offline_no_cache',
      );
    }

    // Fetch from API
    final response = await client.get(
      ApiEndpoints.payslips,
      queryParameters: {'year': year},
    );

    final list = response.data['data'] as List;
    final payslips = list
        .map((e) => Payslip.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache results
    await storage.savePayslips(payslips, year);

    return payslips;
  }

  /// Get single payslip
  Future<Payslip> getPayslip(String id) async {
    final response = await client.get(ApiEndpoints.payslipDetail(id));
    return Payslip.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Download payslip PDF
  Future<String> downloadPdf(String id, String savePath) async {
    await client.download(
      ApiEndpoints.payslipPdf(id),
      savePath,
    );
    return savePath;
  }

  /// Get available years
  List<int> getAvailableYears() {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - index);
  }
}
