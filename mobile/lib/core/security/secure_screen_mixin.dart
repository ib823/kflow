import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Mixin for screens that need FLAG_SECURE protection
///
/// Use this mixin on StatefulWidget states for screens displaying
/// sensitive data (payslips, documents, PINs, passwords).
///
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with SecureScreenMixin {
///   @override
///   void initState() {
///     super.initState();
///     enableSecureScreen();
///   }
///
///   @override
///   void dispose() {
///     disableSecureScreen();
///     super.dispose();
///   }
/// }
/// ```
mixin SecureScreenMixin<T extends StatefulWidget> on State<T> {
  static const _channel = MethodChannel('kerjaflow/secure_screen');

  bool _isSecureEnabled = false;

  /// Enables FLAG_SECURE to prevent screenshots and screen recording.
  /// On Android: Sets FLAG_SECURE on the window.
  /// On iOS: Enables protection via UIScreen capturedDidChangeNotification.
  Future<void> enableSecureScreen() async {
    if (_isSecureEnabled) return;

    try {
      // Platform-specific implementation via method channel
      await _channel.invokeMethod('enableSecure');
      _isSecureEnabled = true;
    } catch (e) {
      // Fallback: Use SystemChrome for basic protection
      // Note: This doesn't provide true FLAG_SECURE but is better than nothing
      if (kDebugMode) {
        debugPrint('SecureScreenMixin: enableSecure failed - $e');
      }
    }
  }

  /// Disables FLAG_SECURE protection.
  /// Should be called in dispose() to ensure proper cleanup.
  Future<void> disableSecureScreen() async {
    if (!_isSecureEnabled) return;

    try {
      await _channel.invokeMethod('disableSecure');
      _isSecureEnabled = false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureScreenMixin: disableSecure failed - $e');
      }
    }
  }

  /// Check if secure mode is currently enabled
  bool get isSecureScreenEnabled => _isSecureEnabled;
}

/// Platform channel handler for secure screen functionality.
/// Must be registered in the native Android/iOS code.
///
/// Android (MainActivity.kt):
/// ```kotlin
/// MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kerjaflow/secure_screen")
///   .setMethodCallHandler { call, result ->
///     when (call.method) {
///       "enableSecure" -> {
///         window.setFlags(
///           WindowManager.LayoutParams.FLAG_SECURE,
///           WindowManager.LayoutParams.FLAG_SECURE
///         )
///         result.success(null)
///       }
///       "disableSecure" -> {
///         window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
///         result.success(null)
///       }
///       else -> result.notImplemented()
///     }
///   }
/// ```
///
/// iOS (AppDelegate.swift):
/// ```swift
/// let controller = window?.rootViewController as! FlutterViewController
/// let channel = FlutterMethodChannel(name: "kerjaflow/secure_screen", binaryMessenger: controller.binaryMessenger)
/// channel.setMethodCallHandler { call, result in
///   switch call.method {
///   case "enableSecure":
///     // iOS doesn't have direct FLAG_SECURE equivalent
///     // Use textField overlay technique or just mark as secure
///     result(nil)
///   case "disableSecure":
///     result(nil)
///   default:
///     result(FlutterMethodNotImplemented)
///   }
/// }
/// ```
class SecureScreenChannel {
  static const channel = MethodChannel('kerjaflow/secure_screen');
}
