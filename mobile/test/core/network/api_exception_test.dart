import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/core/error/api_exception.dart';

void main() {
  group('ApiException', () {
    test('creates exception with code and message', () {
      const exception = ApiException(
        code: 'TEST_ERROR',
        message: 'Something went wrong',
      );

      expect(exception.code, 'TEST_ERROR');
      expect(exception.message, 'Something went wrong');
      expect(exception.statusCode, isNull);
      expect(exception.isNetworkError, isFalse);
    });

    test('creates exception with status code', () {
      const exception = ApiException(
        code: 'UNAUTHORIZED',
        message: 'Unauthorized',
        statusCode: 401,
      );

      expect(exception.message, 'Unauthorized');
      expect(exception.statusCode, 401);
    });

    test('creates exception with field errors', () {
      const exception = ApiException(
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
        statusCode: 400,
        fieldErrors: [
          FieldError(field: 'email', message: 'Email is required'),
        ],
      );

      expect(exception.message, 'Validation failed');
      expect(exception.statusCode, 400);
      expect(exception.fieldErrors, hasLength(1));
      expect(exception.fieldErrors!.first.field, 'email');
    });

    test('toString returns formatted string', () {
      const exception = ApiException(
        code: 'TEST',
        message: 'Test error',
        statusCode: 500,
      );

      expect(exception.toString(), contains('TEST'));
      expect(exception.toString(), contains('Test error'));
    });

    group('fromDioException', () {
      test('handles connection timeout', () {
        final dioError = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final exception = ApiException.fromDioException(dioError);

        expect(exception.code, ErrorCodes.timeout);
        expect(exception.isNetworkError, isTrue);
      });

      test('handles send timeout', () {
        final dioError = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final exception = ApiException.fromDioException(dioError);

        expect(exception.code, ErrorCodes.timeout);
        expect(exception.isNetworkError, isTrue);
      });

      test('handles receive timeout', () {
        final dioError = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final exception = ApiException.fromDioException(dioError);

        expect(exception.code, ErrorCodes.timeout);
        expect(exception.isNetworkError, isTrue);
      });

      test('handles connection error', () {
        final dioError = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );

        final exception = ApiException.fromDioException(dioError);

        expect(exception.code, ErrorCodes.networkError);
        expect(exception.isNetworkError, isTrue);
      });

      test('handles server response with error structure', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'error': {
                'code': 'INVALID_INPUT',
                'message': 'Invalid input provided',
              }
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final exception = ApiException.fromDioException(dioError);

        expect(exception.code, 'INVALID_INPUT');
        expect(exception.message, 'Invalid input provided');
        expect(exception.statusCode, 400);
      });

      test('handles server response with field errors', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 422,
            data: {
              'error': {
                'code': 'VALIDATION_ERROR',
                'message': 'Validation failed',
                'fields': {
                  'email': 'Email is required',
                  'password': 'Password too short',
                },
              }
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final exception = ApiException.fromDioException(dioError);

        expect(exception.code, 'VALIDATION_ERROR');
        expect(exception.statusCode, 422);
        expect(exception.fieldErrors, hasLength(2));
      });

      test('handles fallback error format', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: {
              'message': 'Internal server error',
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final exception = ApiException.fromDioException(dioError);

        expect(exception.message, 'Internal server error');
        expect(exception.statusCode, 500);
      });

      test('handles non-JSON response', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: 'Plain text error',
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final exception = ApiException.fromDioException(dioError);

        expect(exception.code, 'SERVER_ERROR');
        expect(exception.statusCode, 500);
      });

      test('handles unknown error without response', () {
        final dioError = DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/test'),
          message: 'Unknown error occurred',
        );

        final exception = ApiException.fromDioException(dioError);

        expect(exception.code, ErrorCodes.networkError);
        expect(exception.isNetworkError, isTrue);
      });
    });
  });

  group('ApiException properties', () {
    test('isAuthError returns true for auth-related codes', () {
      const exception = ApiException(
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      );

      expect(exception.isAuthError, isTrue);
    });

    test('isAuthError returns true for 401 status', () {
      const exception = ApiException(
        code: 'ERROR',
        message: 'Unauthorized',
        statusCode: 401,
      );

      expect(exception.isAuthError, isTrue);
    });

    test('isPinError returns true for PIN-related codes', () {
      const exceptionInvalid = ApiException(
        code: 'INVALID_PIN',
        message: 'Invalid PIN',
      );
      const exceptionRequired = ApiException(
        code: 'PIN_REQUIRED',
        message: 'PIN required',
      );

      expect(exceptionInvalid.isPinError, isTrue);
      expect(exceptionRequired.isPinError, isTrue);
    });

    test('isValidationError returns true for validation codes', () {
      const exception = ApiException(
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
      );

      expect(exception.isValidationError, isTrue);
    });

    test('isValidationError returns true for 400 status', () {
      const exception = ApiException(
        code: 'ERROR',
        message: 'Bad request',
        statusCode: 400,
      );

      expect(exception.isValidationError, isTrue);
    });

    test('isRateLimitError returns true for rate limit', () {
      const exception = ApiException(
        code: 'RATE_LIMITED',
        message: 'Too many requests',
        statusCode: 429,
      );

      expect(exception.isRateLimitError, isTrue);
    });

    test('isServerError returns true for 5xx status', () {
      const exception500 = ApiException(
        code: 'ERROR',
        message: 'Error',
        statusCode: 500,
      );
      const exception503 = ApiException(
        code: 'ERROR',
        message: 'Error',
        statusCode: 503,
      );

      expect(exception500.isServerError, isTrue);
      expect(exception503.isServerError, isTrue);
    });

    test('isServerError returns false for 4xx status', () {
      const exception = ApiException(
        code: 'ERROR',
        message: 'Error',
        statusCode: 400,
      );

      expect(exception.isServerError, isFalse);
    });
  });

  group('FieldError', () {
    test('creates field error correctly', () {
      const fieldError = FieldError(
        field: 'email',
        message: 'Email is required',
      );

      expect(fieldError.field, 'email');
      expect(fieldError.message, 'Email is required');
    });
  });

  group('getFieldError', () {
    test('returns field error message', () {
      const exception = ApiException(
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
        fieldErrors: [
          FieldError(field: 'email', message: 'Email is required'),
          FieldError(field: 'password', message: 'Password too short'),
        ],
      );

      expect(exception.getFieldError('email'), 'Email is required');
      expect(exception.getFieldError('password'), 'Password too short');
    });

    test('returns empty string for non-existent field', () {
      const exception = ApiException(
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
        fieldErrors: [
          FieldError(field: 'email', message: 'Email is required'),
        ],
      );

      expect(exception.getFieldError('name'), '');
    });

    test('returns null when no field errors', () {
      const exception = ApiException(
        code: 'ERROR',
        message: 'Error',
      );

      expect(exception.getFieldError('email'), isNull);
    });
  });

  group('ErrorCodes', () {
    test('authentication codes are defined', () {
      expect(ErrorCodes.invalidCredentials, 'INVALID_CREDENTIALS');
      expect(ErrorCodes.accountLocked, 'ACCOUNT_LOCKED');
      expect(ErrorCodes.tokenExpired, 'TOKEN_EXPIRED');
      expect(ErrorCodes.invalidPin, 'INVALID_PIN');
    });

    test('leave codes are defined', () {
      expect(ErrorCodes.insufficientBalance, 'INSUFFICIENT_BALANCE');
      expect(ErrorCodes.leaveOverlap, 'LEAVE_OVERLAP');
      expect(ErrorCodes.invalidDateRange, 'INVALID_DATE_RANGE');
    });

    test('payslip codes are defined', () {
      expect(ErrorCodes.payslipNotFound, 'PAYSLIP_NOT_FOUND');
      expect(ErrorCodes.pdfNotAvailable, 'PDF_NOT_AVAILABLE');
    });

    test('network codes are defined', () {
      expect(ErrorCodes.networkError, 'NETWORK_ERROR');
      expect(ErrorCodes.timeout, 'TIMEOUT');
    });
  });
}
