import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Test wrapper for widgets
/// Provides MaterialApp with all necessary configurations
Widget testableWidget({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  List<Override>? overrides,
  Locale locale = const Locale('en'),
}) {
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: themeMode,
    theme: _buildLightTheme(),
    darkTheme: _buildDarkTheme(),
    locale: locale,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('ms'),
      Locale('id'),
    ],
    home: Scaffold(body: child),
  );

  if (overrides != null && overrides.isNotEmpty) {
    return ProviderScope(
      overrides: overrides,
      child: app,
    );
  }

  return ProviderScope(child: app);
}

/// Light theme for testing
ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.light,
    ),
    fontFamily: 'Roboto',
  );
}

/// Dark theme for testing
ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.dark,
    ),
    fontFamily: 'Roboto',
  );
}

/// Extension to pump widget with testable wrapper
extension WidgetTesterExtension on WidgetTester {
  /// Pumps a widget wrapped in testableWidget
  Future<void> pumpTestableWidget(
    Widget widget, {
    ThemeMode themeMode = ThemeMode.light,
    List<Override>? overrides,
    Duration? duration,
  }) async {
    await pumpWidget(
      testableWidget(
        child: widget,
        themeMode: themeMode,
        overrides: overrides,
      ),
    );
    if (duration != null) {
      await pump(duration);
    }
  }

  /// Pumps and settles the widget
  Future<void> pumpAndSettleTestable(
    Widget widget, {
    ThemeMode themeMode = ThemeMode.light,
    List<Override>? overrides,
  }) async {
    await pumpTestableWidget(
      widget,
      themeMode: themeMode,
      overrides: overrides,
    );
    await pumpAndSettle();
  }
}

/// Golden test helper
class GoldenHelper {
  /// Generates goldens for both light and dark themes
  static Future<void> testBothThemes(
    WidgetTester tester, {
    required String name,
    required Widget widget,
  }) async {
    // Light theme
    await tester.pumpTestableWidget(widget, themeMode: ThemeMode.light);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/${name}_light.png'),
    );

    // Dark theme
    await tester.pumpTestableWidget(widget, themeMode: ThemeMode.dark);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/${name}_dark.png'),
    );
  }
}

/// Test constants
class TestConstants {
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortDelay = Duration(milliseconds: 100);
  static const Duration networkDelay = Duration(seconds: 1);
}
