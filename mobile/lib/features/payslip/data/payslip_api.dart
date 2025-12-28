import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/payslip.dart';

part 'payslip_api.g.dart';

/// Payslip API client.
///
/// Rate limit: 30 requests/minute for payslip endpoints.
class PayslipApi {
  final Dio _dio;

  PayslipApi(this._dio);

  /// GET /api/v1/payslips
  ///
  /// List payslips with pagination.
  /// Optional year filter.
  Future<PayslipListResponse> getPayslips({
    int page = 1,
    int limit = 12,
    int? year,
  }) async {
    final response = await _dio.get('/api/v1/payslips', queryParameters: {
      'page': page,
      'limit': limit,
      if (year != null) 'year': year,
    });
    return PayslipListResponse.fromJson(response.data['data']);
  }

  /// GET /api/v1/payslips/{id}
  ///
  /// Get payslip detail. Requires PIN verification token.
  Future<Payslip> getPayslipDetail(int id, String verificationToken) async {
    final response = await _dio.get(
      '/api/v1/payslips/$id',
      options: Options(headers: {'X-Verification-Token': verificationToken}),
    );
    return Payslip.fromJson(response.data['data']);
  }

  /// GET /api/v1/payslips/{id}/pdf
  ///
  /// Download payslip PDF. Requires PIN verification token.
  Future<Uint8List> getPayslipPdf(int id, String verificationToken) async {
    final response = await _dio.get<List<int>>(
      '/api/v1/payslips/$id/pdf',
      options: Options(
        headers: {'X-Verification-Token': verificationToken},
        responseType: ResponseType.bytes,
      ),
    );
    return Uint8List.fromList(response.data!);
  }
}

@riverpod
PayslipApi payslipApi(PayslipApiRef ref) {
  final dio = ref.watch(dioClientProvider);
  return PayslipApi(dio);
}
