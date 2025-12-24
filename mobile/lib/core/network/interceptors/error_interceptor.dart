import 'package:dio/dio.dart';

import '../../error/api_exception.dart';

/// Interceptor for handling API errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapDioException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
      ),
    );
  }

  ApiException _mapDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          code: 'TIMEOUT',
          message: 'Request timed out. Please try again.',
          isNetworkError: true,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          code: 'NETWORK_ERROR',
          message: 'No internet connection. Please check your network.',
          isNetworkError: true,
        );

      case DioExceptionType.badResponse:
        return _parseErrorResponse(err.response);

      case DioExceptionType.cancel:
        return const ApiException(
          code: 'REQUEST_CANCELLED',
          message: 'Request was cancelled.',
        );

      default:
        return const ApiException(
          code: 'UNKNOWN_ERROR',
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  ApiException _parseErrorResponse(Response? response) {
    if (response == null) {
      return const ApiException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error occurred.',
      );
    }

    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ApiException(
        code: (data['code'] as String?) ?? 'ERROR',
        message: (data['message'] as String?) ?? _getDefaultMessage(statusCode),
        details: data['details'] as Map<String, dynamic>?,
        fieldErrors: _parseFieldErrors(data['field_errors']),
        statusCode: statusCode,
      );
    }

    return ApiException(
      code: 'HTTP_$statusCode',
      message: _getDefaultMessage(statusCode),
      statusCode: statusCode,
    );
  }

  String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You don\'t have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 413:
        return 'File is too large.';
      case 423:
        return 'Account is locked. Please try again later.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong.';
    }
  }

  List<FieldError>? _parseFieldErrors(dynamic fieldErrors) {
    if (fieldErrors == null || fieldErrors is! List) return null;

    return fieldErrors
        .cast<Map<String, dynamic>>()
        .map<FieldError>(
          (e) => FieldError(
            field: (e['field'] as String?) ?? '',
            message: (e['message'] as String?) ?? '',
          ),
        )
        .toList();
  }
}
