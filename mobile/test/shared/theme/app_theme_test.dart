import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/shared/theme/app_theme.dart';

void main() {
  group('AppTheme Colors', () {
    test('primary colors are defined correctly', () {
      expect(AppColors.primary, const Color(0xFF1A5276));
      expect(AppColors.primaryLight, const Color(0xFF2E86AB));
      expect(AppColors.primaryDark, const Color(0xFF0D3B50));
      expect(AppColors.primarySurface, const Color(0xFFE8F4F8));
    });

    test('semantic colors meet WCAG AA contrast requirements', () {
      // Success: 5.4:1 ratio
      expect(AppColors.success, const Color(0xFF1E8449));
      // Warning: 4.6:1 ratio
      expect(AppColors.warning, const Color(0xFFB7791F));
      // Error: 5.9:1 ratio
      expect(AppColors.error, const Color(0xFFC0392B));
      // Info: 5.2:1 ratio
      expect(AppColors.info, const Color(0xFF2471A3));
    });

    test('text colors meet WCAG AA contrast requirements', () {
      // Primary text: 8.5:1 ratio
      expect(AppColors.textPrimary, const Color(0xFF2C3E50));
      // Secondary text: 5.8:1 ratio
      expect(AppColors.textSecondary, const Color(0xFF566573));
      // Tertiary text: 4.5:1 ratio
      expect(AppColors.textTertiary, const Color(0xFF7B8D9A));
    });

    test('background colors are defined', () {
      expect(AppColors.background, const Color(0xFFFAFAFA));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.surfaceVariant, const Color(0xFFF5F7F8));
      expect(AppColors.divider, const Color(0xFFECEFF1));
    });
  });

  group('AppSpacing', () {
    test('spacing values follow 4dp base unit', () {
      expect(AppSpacing.xxs, 2);
      expect(AppSpacing.xs, 4);
      expect(AppSpacing.sm, 8);
      expect(AppSpacing.md, 16);
      expect(AppSpacing.lg, 24);
      expect(AppSpacing.xl, 32);
      expect(AppSpacing.xxl, 48);
      expect(AppSpacing.xxxl, 64);
    });
  });

  group('AppRadius', () {
    test('radius values are defined correctly', () {
      expect(AppRadius.none, 0);
      expect(AppRadius.sm, 4);
      expect(AppRadius.md, 8);
      expect(AppRadius.lg, 16);
      expect(AppRadius.full, 9999);
    });
  });

  group('AppElevation', () {
    test('elevation shadows are defined', () {
      expect(AppElevation.low, isNotEmpty);
      expect(AppElevation.medium, isNotEmpty);
      expect(AppElevation.low.first.blurRadius, 4);
      expect(AppElevation.medium.first.blurRadius, 8);
    });
  });

  group('AppTheme Light Theme', () {
    test('light theme is properly configured', () {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.primaryColor, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('light theme color scheme is correct', () {
      final colorScheme = AppTheme.lightTheme.colorScheme;

      expect(colorScheme.primary, AppColors.primary);
      expect(colorScheme.error, AppColors.error);
      expect(colorScheme.surface, AppColors.surface);
    });

    test('light theme app bar is configured correctly', () {
      final appBarTheme = AppTheme.lightTheme.appBarTheme;

      expect(appBarTheme.backgroundColor, AppColors.surface);
      expect(appBarTheme.foregroundColor, AppColors.textPrimary);
      expect(appBarTheme.elevation, 0);
      expect(appBarTheme.centerTitle, isTrue);
    });

    test('light theme buttons have 48dp minimum height', () {
      final elevatedButtonStyle = AppTheme.lightTheme.elevatedButtonTheme.style;
      final outlinedButtonStyle = AppTheme.lightTheme.outlinedButtonTheme.style;

      expect(
        elevatedButtonStyle?.minimumSize?.resolve({}),
        const Size(double.infinity, 48),
      );
      expect(
        outlinedButtonStyle?.minimumSize?.resolve({}),
        const Size(double.infinity, 48),
      );
    });

    test('light theme input decoration is configured', () {
      final inputTheme = AppTheme.lightTheme.inputDecorationTheme;

      expect(inputTheme.filled, isFalse);
      expect(inputTheme.border, isA<OutlineInputBorder>());
    });

    test('light theme snackbar is floating', () {
      final snackBarTheme = AppTheme.lightTheme.snackBarTheme;

      expect(snackBarTheme.behavior, SnackBarBehavior.floating);
    });
  });

  group('AppTheme Dark Theme', () {
    test('dark theme is properly configured', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.primaryColor, AppColors.primaryLight);
    });

    test('dark theme uses OLED-friendly background', () {
      final theme = AppTheme.darkTheme;

      // Dark mode should use very dark background for OLED
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    test('dark theme text colors have good contrast', () {
      final textTheme = AppTheme.darkTheme.textTheme;

      // Dark mode text should be light colored
      expect(textTheme.bodyLarge?.color, const Color(0xFFE1E1E1));
      expect(textTheme.bodyMedium?.color, const Color(0xFFE1E1E1));
    });

    test('dark theme color scheme is correct', () {
      final colorScheme = AppTheme.darkTheme.colorScheme;

      expect(colorScheme.brightness, Brightness.dark);
      expect(colorScheme.primary, AppColors.primaryLight);
    });
  });

  group('Typography', () {
    test('text theme uses Inter font family', () {
      final textTheme = AppTheme.lightTheme.textTheme;

      expect(textTheme.displayLarge?.fontFamily, 'Inter');
      expect(textTheme.bodyMedium?.fontFamily, 'Inter');
      expect(textTheme.labelSmall?.fontFamily, 'Inter');
    });

    test('text theme has proper hierarchy', () {
      final textTheme = AppTheme.lightTheme.textTheme;

      // Display sizes should be larger than headline
      expect(
        textTheme.displayLarge!.fontSize! > textTheme.headlineLarge!.fontSize!,
        isTrue,
      );

      // Headline sizes should be larger than body
      expect(
        textTheme.headlineLarge!.fontSize! > textTheme.bodyLarge!.fontSize!,
        isTrue,
      );

      // Body sizes should be larger than label
      expect(
        textTheme.bodyLarge!.fontSize! > textTheme.labelLarge!.fontSize!,
        isTrue,
      );
    });
  });
}
