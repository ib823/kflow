import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor for logging HTTP requests and responses in debug mode
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '┌──────────────────────────────────────────────────────────────────\n'
      '│ REQUEST: ${options.method} ${options.path}\n'
      '│ Headers: ${_formatHeaders(options.headers)}\n'
      '│ Query: ${options.queryParameters}\n'
      '│ Body: ${_formatBody(options.data)}\n'
      '└──────────────────────────────────────────────────────────────────',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      '┌──────────────────────────────────────────────────────────────────\n'
      '│ RESPONSE: ${response.statusCode} ${response.requestOptions.path}\n'
      '│ Body: ${_formatBody(response.data)}\n'
      '└──────────────────────────────────────────────────────────────────',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '┌──────────────────────────────────────────────────────────────────\n'
      '│ ERROR: ${err.type} ${err.requestOptions.path}\n'
      '│ Status: ${err.response?.statusCode}\n'
      '│ Message: ${err.message}\n'
      '│ Response: ${_formatBody(err.response?.data)}\n'
      '└──────────────────────────────────────────────────────────────────',
    );
    handler.next(err);
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    // Hide sensitive headers
    final safeHeaders = Map<String, dynamic>.from(headers);
    if (safeHeaders.containsKey('Authorization')) {
      safeHeaders['Authorization'] = 'Bearer ***';
    }
    if (safeHeaders.containsKey('X-Verification-Token')) {
      safeHeaders['X-Verification-Token'] = '***';
    }
    return safeHeaders.toString();
  }

  String _formatBody(dynamic body) {
    if (body == null) return 'null';

    try {
      if (body is Map || body is List) {
        // Truncate long bodies
        final jsonStr = const JsonEncoder.withIndent('  ').convert(body);
        if (jsonStr.length > 500) {
          return '${jsonStr.substring(0, 500)}... [truncated]';
        }
        return jsonStr;
      }
      return body.toString();
    } catch (e) {
      return body.toString();
    }
  }
}
