import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Generic API response wrapper
@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse.success({
    required T data,
    String? message,
  }) = ApiResponseSuccess<T>;

  const factory ApiResponse.error({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) = ApiResponseError<T>;

  const factory ApiResponse.loading() = ApiResponseLoading<T>;
}

/// Pagination metadata
@freezed
class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    required int page,
    required int pageSize,
    required int totalItems,
    required int totalPages,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}

/// Paginated response
@freezed
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> items,
    required PaginationMeta meta,
  }) = _PaginatedResponse<T>;
}
