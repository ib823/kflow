import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/error/api_exception.dart';
import '../models/payslip.dart';

part 'payslip_provider.g.dart';

/// State for payslip data with PIN verification status
class PayslipState {
  final List<PayslipSummary> payslips;
  final bool isPinVerified;
  final DateTime? pinVerifiedAt;
  final bool isLoading;
  final String? error;

  const PayslipState({
    this.payslips = const [],
    this.isPinVerified = false,
    this.pinVerifiedAt,
    this.isLoading = false,
    this.error,
  });

  PayslipState copyWith({
    List<PayslipSummary>? payslips,
    bool? isPinVerified,
    DateTime? pinVerifiedAt,
    bool? isLoading,
    String? error,
  }) {
    return PayslipState(
      payslips: payslips ?? this.payslips,
      isPinVerified: isPinVerified ?? this.isPinVerified,
      pinVerifiedAt: pinVerifiedAt ?? this.pinVerifiedAt,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Check if PIN verification is still valid (5 minute window)
  bool get isPinVerificationValid {
    if (!isPinVerified || pinVerifiedAt == null) return false;
    return DateTime.now().difference(pinVerifiedAt!).inMinutes < 5;
  }
}

@riverpod
class PayslipNotifier extends _$PayslipNotifier {
  @override
  Future<PayslipState> build() async {
    // Check existing PIN verification status
    final storage = ref.read(secureStorageProvider);
    final isVerified = await storage.isPinVerificationValid();

    if (isVerified) {
      return _fetchPayslips();
    }

    return PayslipState(isPinVerified: isVerified);
  }

  Future<PayslipState> _fetchPayslips() async {
    try {
      final dio = ref.read(dioClientProvider);
      final storage = ref.read(secureStorageProvider);

      // Get verification token for sensitive data
      final verificationToken = await storage.getPinVerificationToken();

      final response = await dio.get(
        '/payslips',
        options: Options(
          headers: {
            if (verificationToken != null) 'X-Verification-Token': verificationToken,
          },
        ),
      );

      final payslips = (response.data as List)
          .map((e) => PayslipSummary.fromJson(e as Map<String, dynamic>))
          .toList();

      return PayslipState(
        payslips: payslips,
        isPinVerified: true,
        pinVerifiedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);

      // Check if PIN verification is required
      if (error.isPinError) {
        return const PayslipState(isPinVerified: false);
      }

      return PayslipState(error: error.message);
    } catch (e) {
      return PayslipState(error: e.toString());
    }
  }

  /// Mark PIN as verified and fetch payslips
  Future<void> onPinVerified() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchPayslips());
  }

  /// Refresh payslip list
  Future<void> refresh() async {
    final current = state.valueOrNull;
    if (current == null || !current.isPinVerificationValid) {
      // Need to verify PIN again
      state = AsyncValue.data(const PayslipState(isPinVerified: false));
      return;
    }

    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchPayslips());
  }

  /// Fetch payslips with optional year filter
  Future<List<PayslipSummary>> fetchPayslips({int? year}) async {
    try {
      final dio = ref.read(dioClientProvider);
      final storage = ref.read(secureStorageProvider);
      final verificationToken = await storage.getPinVerificationToken();

      final response = await dio.get(
        '/payslips',
        queryParameters: {
          if (year != null) 'year': year,
        },
        options: Options(
          headers: {
            if (verificationToken != null) 'X-Verification-Token': verificationToken,
          },
        ),
      );

      final payslips = (response.data as List)
          .map((e) => PayslipSummary.fromJson(e as Map<String, dynamic>))
          .toList();

      // Update state
      final current = state.valueOrNull ?? const PayslipState();
      state = AsyncValue.data(current.copyWith(payslips: payslips));

      return payslips;
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }

  /// Clear PIN verification (e.g., when leaving payslip screens)
  void clearVerification() {
    final current = state.valueOrNull ?? const PayslipState();
    state = AsyncValue.data(current.copyWith(
      isPinVerified: false,
      pinVerifiedAt: null,
    ));
  }
}

/// Provider for fetching a single payslip detail
@riverpod
class PayslipDetailNotifier extends _$PayslipDetailNotifier {
  @override
  Future<PayslipDetail?> build(int payslipId) async {
    return _fetchDetail(payslipId);
  }

  Future<PayslipDetail?> _fetchDetail(int id) async {
    try {
      final dio = ref.read(dioClientProvider);
      final storage = ref.read(secureStorageProvider);
      final verificationToken = await storage.getPinVerificationToken();

      final response = await dio.get(
        '/payslips/$id',
        options: Options(
          headers: {
            if (verificationToken != null) 'X-Verification-Token': verificationToken,
          },
        ),
      );

      return PayslipDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }

  /// Download payslip as PDF
  Future<String?> downloadPdf(int id) async {
    try {
      final dio = ref.read(dioClientProvider);
      final storage = ref.read(secureStorageProvider);
      final verificationToken = await storage.getPinVerificationToken();

      final response = await dio.get(
        '/payslips/$id/pdf',
        options: Options(
          headers: {
            if (verificationToken != null) 'X-Verification-Token': verificationToken,
          },
          responseType: ResponseType.bytes,
        ),
      );

      // In a real app, save to file and return path
      // For now, return a mock path
      return '/downloads/payslip_$id.pdf';
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      throw error;
    }
  }
}

/// Provider for checking PIN verification status
@riverpod
Future<bool> isPinVerified(IsPinVerifiedRef ref) async {
  final payslipState = await ref.watch(payslipNotifierProvider.future);
  return payslipState.isPinVerificationValid;
}
