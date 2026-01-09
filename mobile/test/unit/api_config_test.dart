import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/data/datasources/remote/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('has correct default base URL', () {
      expect(ApiConfig.baseUrl, contains('kerjaflow'));
    });

    test('has API version', () {
      expect(ApiConfig.apiVersion, 'v1');
    });

    test('apiUrl combines base and version', () {
      expect(ApiConfig.apiUrl, contains('/api/v1'));
    });

    test('has reasonable timeout values', () {
      expect(ApiConfig.connectTimeout.inSeconds, greaterThan(0));
      expect(ApiConfig.receiveTimeout.inSeconds, greaterThan(0));
      expect(ApiConfig.sendTimeout.inSeconds, greaterThan(0));
    });

    test('has retry configuration', () {
      expect(ApiConfig.maxRetries, greaterThan(0));
      expect(ApiConfig.retryDelay.inMilliseconds, greaterThan(0));
    });

    test('token refresh threshold is reasonable', () {
      // Should be at least 1 minute before expiry
      expect(ApiConfig.tokenRefreshThreshold, greaterThanOrEqualTo(60));
      // Should be at most 10 minutes before expiry
      expect(ApiConfig.tokenRefreshThreshold, lessThanOrEqualTo(600));
    });
  });

  group('ApiEndpoints', () {
    group('Auth endpoints', () {
      test('login endpoint', () {
        expect(ApiEndpoints.login, '/auth/login');
      });

      test('logout endpoint', () {
        expect(ApiEndpoints.logout, '/auth/logout');
      });

      test('refreshToken endpoint', () {
        expect(ApiEndpoints.refreshToken, '/auth/refresh');
      });

      test('verifyPin endpoint', () {
        expect(ApiEndpoints.verifyPin, '/auth/pin/verify');
      });

      test('setPin endpoint', () {
        expect(ApiEndpoints.setPin, '/auth/pin/set');
      });
    });

    group('User endpoints', () {
      test('userProfile endpoint', () {
        expect(ApiEndpoints.userProfile, '/user/profile');
      });

      test('userSettings endpoint', () {
        expect(ApiEndpoints.userSettings, '/user/settings');
      });
    });

    group('Payslip endpoints', () {
      test('payslips endpoint', () {
        expect(ApiEndpoints.payslips, '/payslips');
      });

      test('payslipDetail generates correct path', () {
        expect(ApiEndpoints.payslipDetail('123'), '/payslips/123');
      });

      test('payslipPdf generates correct path', () {
        expect(ApiEndpoints.payslipPdf('abc'), '/payslips/abc/pdf');
      });
    });

    group('Leave endpoints', () {
      test('leaveBalance endpoint', () {
        expect(ApiEndpoints.leaveBalance, '/leave/balance');
      });

      test('leaveTypes endpoint', () {
        expect(ApiEndpoints.leaveTypes, '/leave/types');
      });

      test('leaveRequests endpoint', () {
        expect(ApiEndpoints.leaveRequests, '/leave/requests');
      });

      test('leaveRequestDetail generates correct path', () {
        expect(ApiEndpoints.leaveRequestDetail('lr-001'), '/leave/requests/lr-001');
      });

      test('cancelLeaveRequest generates correct path', () {
        expect(ApiEndpoints.cancelLeaveRequest('lr-001'), '/leave/requests/lr-001/cancel');
      });
    });

    group('Approval endpoints', () {
      test('approvals endpoint', () {
        expect(ApiEndpoints.approvals, '/approvals');
      });

      test('approvalDetail generates correct path', () {
        expect(ApiEndpoints.approvalDetail('apr-001'), '/approvals/apr-001');
      });

      test('approveRequest generates correct path', () {
        expect(ApiEndpoints.approveRequest('apr-001'), '/approvals/apr-001/approve');
      });

      test('rejectRequest generates correct path', () {
        expect(ApiEndpoints.rejectRequest('apr-001'), '/approvals/apr-001/reject');
      });
    });

    group('Notification endpoints', () {
      test('notifications endpoint', () {
        expect(ApiEndpoints.notifications, '/notifications');
      });

      test('notificationDetail generates correct path', () {
        expect(ApiEndpoints.notificationDetail('n-001'), '/notifications/n-001');
      });

      test('markNotificationRead generates correct path', () {
        expect(ApiEndpoints.markNotificationRead('n-001'), '/notifications/n-001/read');
      });

      test('markAllNotificationsRead endpoint', () {
        expect(ApiEndpoints.markAllNotificationsRead, '/notifications/read-all');
      });
    });
  });
}
