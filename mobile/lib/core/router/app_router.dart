import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/pin_setup_screen.dart';
import '../../features/auth/presentation/screens/pin_entry_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/leave/presentation/leave_balance_screen.dart';
import '../../features/leave/presentation/leave_request_screen.dart';
import '../../features/leave/presentation/leave_history_screen.dart';
import '../../features/leave/presentation/leave_apply_screen.dart';
import '../../features/leave/presentation/screens/leave_calendar_screen.dart';
import '../../features/leave/presentation/screens/approval_detail_screen.dart';
import '../../features/payslip/presentation/payslip_list_screen.dart';
import '../../features/payslip/presentation/payslip_detail_screen.dart';
import '../../features/payslip/presentation/screens/payslip_pdf_screen.dart';
import '../../features/documents/presentation/screens/document_list_screen.dart';
import '../../features/documents/presentation/screens/document_upload_screen.dart';
import '../../features/documents/presentation/screens/document_viewer_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/legal_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/notifications/presentation/screens/notification_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/change_password_screen.dart';
import '../../features/settings/presentation/screens/change_pin_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../shared/providers/auth_provider.dart';

part 'app_router.g.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const pinSetup = '/pin-setup';
  static const pinEntry = '/pin-entry';
  static const dashboard = '/dashboard';
  static const home = '/home';
  static const leaveBalance = '/leave/balance';
  static const leaveHistory = '/leave/history';
  static const leaveApply = '/leave/apply';
  static const leaveRequest = '/leave/request/:id';
  static const leaveCalendar = '/leave/calendar';
  static const approval = '/approval/:id';
  static const payslipList = '/payslips';
  static const payslipDetail = '/payslips/:id';
  static const payslipPdf = '/payslips/:id/pdf';
  static const documents = '/documents';
  static const documentUpload = '/documents/upload';
  static const documentView = '/documents/:id';
  static const profile = '/profile';
  static const notifications = '/notifications';
  static const notificationDetail = '/notifications/:id';
  static const settings = '/settings';
  static const settingsPassword = '/settings/password';
  static const settingsPin = '/settings/pin';
  static const settingsAbout = '/settings/about';
  static const privacyPolicy = '/privacy-policy';
  static const termsOfService = '/terms-of-service';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.isLoggedIn ?? false;
      final isLoading = authState.isLoading;
      final currentPath = state.matchedLocation;

      // Don't redirect while loading
      if (isLoading) return null;

      // Public routes that don't require auth
      final publicRoutes = [AppRoutes.login, AppRoutes.splash];
      final isPublicRoute = publicRoutes.contains(currentPath);

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isPublicRoute) {
        return AppRoutes.login;
      }

      // If logged in and on login page, go to home
      if (isLoggedIn && currentPath == AppRoutes.login) {
        return AppRoutes.home;
      }

      // If on splash and auth state resolved
      if (currentPath == AppRoutes.splash && !isLoading) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.pinSetup,
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.pinEntry,
        builder: (context, state) {
          final purpose = state.uri.queryParameters['purpose'] ?? 'app_unlock';
          return PinEntryScreen(purpose: purpose);
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.leaveBalance,
        builder: (context, state) => const LeaveBalanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.leaveHistory,
        builder: (context, state) => const LeaveHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.leaveApply,
        builder: (context, state) => const LeaveApplyScreen(),
      ),
      GoRoute(
        path: AppRoutes.leaveRequest,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return LeaveRequestScreen(requestId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.payslipList,
        builder: (context, state) => const PayslipListScreen(),
      ),
      GoRoute(
        path: AppRoutes.payslipDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PayslipDetailScreen(payslipId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationDetail,
        builder: (context, state) => NotificationDetailScreen(
          notificationId: state.pathParameters['id']!,
        ),
      ),
      // Leave calendar and approval
      GoRoute(
        path: AppRoutes.leaveCalendar,
        builder: (context, state) => const LeaveCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.approval,
        builder: (context, state) => ApprovalDetailScreen(
          leaveRequestId: state.pathParameters['id']!,
        ),
      ),
      // Payslip PDF
      GoRoute(
        path: AppRoutes.payslipPdf,
        builder: (context, state) => PayslipPdfScreen(
          payslipId: state.pathParameters['id']!,
        ),
      ),
      // Documents
      GoRoute(
        path: AppRoutes.documents,
        builder: (context, state) => const DocumentListScreen(),
      ),
      GoRoute(
        path: AppRoutes.documentUpload,
        builder: (context, state) => const DocumentUploadScreen(),
      ),
      GoRoute(
        path: AppRoutes.documentView,
        builder: (context, state) => DocumentViewerScreen(
          documentId: state.pathParameters['id']!,
        ),
      ),
      // Settings
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPin,
        builder: (context, state) => const ChangePinScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsAbout,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const LegalScreen(docType: LegalDocType.privacyPolicy),
      ),
      GoRoute(
        path: AppRoutes.termsOfService,
        builder: (context, state) => const LegalScreen(docType: LegalDocType.termsOfService),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 24),
            Text(
              'KerjaFlow',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
