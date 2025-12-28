import 'package:flutter/material.dart';

/// Font configuration for KerjaFlow supporting multiple ASEAN scripts.
///
/// Provides font family mappings for complex scripts that require special
/// rendering (Khmer, Myanmar, Thai, Tamil, Bengali, Devanagari, Lao).
///
/// All fonts use the Noto Sans family from Google Fonts for consistent
/// rendering across all platforms.
class KerjaFlowFonts {
  KerjaFlowFonts._();

  /// Primary font for Latin scripts (English, Malay, Indonesian, Vietnamese, Filipino)
  static const String primaryLatin = 'Roboto';

  /// Fallback system font
  static const String systemFallback = '.SF Pro Text';

  /// Script-specific font families mapped by locale code
  ///
  /// These fonts are required for proper rendering of complex scripts:
  /// - Khmer: Requires special vowel/consonant clustering
  /// - Myanmar: Complex stacking and reordering rules
  /// - Thai: Tone marks and vowel positioning
  /// - Tamil: Ligatures and conjunct formations
  /// - Bengali: Similar complexity to Tamil
  /// - Devanagari: Used for Nepali, complex ligatures
  /// - Lao: Similar to Thai with tone marks
  static const Map<String, String> scriptFonts = {
    'km': 'NotoSansKhmer',       // Khmer (Cambodia)
    'my': 'NotoSansMyanmar',     // Burmese (Myanmar)
    'th': 'NotoSansThai',        // Thai (Thailand)
    'ta': 'NotoSansTamil',       // Tamil (Malaysia, Singapore)
    'bn': 'NotoSansBengali',     // Bengali (Bangladesh migrants)
    'ne': 'NotoSansDevanagari',  // Nepali (Nepal migrants)
    'lo': 'NotoSansLao',         // Lao (Laos)
  };

  /// Languages that use the primary Latin font
  static const List<String> latinLocales = [
    'en',    // English
    'ms',    // Bahasa Malaysia
    'id',    // Bahasa Indonesia
    'vi',    // Vietnamese (Latin + diacritics)
    'tl',    // Filipino/Tagalog
  ];

  /// Languages that use Han script (Chinese)
  static const List<String> hanLocales = [
    'zh',    // Chinese (Simplified/Traditional)
  ];

  /// Get the appropriate font family for a given locale
  ///
  /// Returns the script-specific font if available, otherwise falls back
  /// to the primary Latin font.
  ///
  /// Example:
  /// ```dart
  /// final font = KerjaFlowFonts.getFontFamily('km'); // Returns 'NotoSansKhmer'
  /// final font = KerjaFlowFonts.getFontFamily('en'); // Returns 'Roboto'
  /// ```
  static String getFontFamily(String localeCode) {
    // Extract language code from full locale (e.g., 'zh_Hans' -> 'zh')
    final languageCode = localeCode.split('_').first;

    return scriptFonts[languageCode] ?? primaryLatin;
  }

  /// Get a list of font families for fallback rendering
  ///
  /// Returns a list starting with the locale-specific font (if any),
  /// followed by the primary Latin font and system fallback.
  static List<String> getFontFallbackChain(String localeCode) {
    final languageCode = localeCode.split('_').first;
    final specificFont = scriptFonts[languageCode];

    if (specificFont != null) {
      return [specificFont, primaryLatin, systemFallback];
    }
    return [primaryLatin, systemFallback];
  }

  /// Check if a locale requires a special script font
  static bool requiresSpecialFont(String localeCode) {
    final languageCode = localeCode.split('_').first;
    return scriptFonts.containsKey(languageCode);
  }

  /// Get TextTheme configured for a specific locale
  ///
  /// This ensures proper font rendering for complex scripts throughout
  /// the application.
  static TextTheme getTextTheme(String localeCode, {required TextTheme baseTheme}) {
    final fontFamily = getFontFamily(localeCode);
    final fallbacks = getFontFallbackChain(localeCode);

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
      ),
    );
  }

  /// Line height adjustments for different scripts
  ///
  /// Some scripts require more vertical space for proper rendering
  /// of diacritics, tone marks, and stacked characters.
  static double getLineHeightMultiplier(String localeCode) {
    final languageCode = localeCode.split('_').first;

    switch (languageCode) {
      case 'th':
        return 1.5;  // Thai needs extra space for tone marks
      case 'my':
        return 1.6;  // Myanmar has tall stacked consonants
      case 'km':
        return 1.5;  // Khmer has subscript consonants
      case 'lo':
        return 1.5;  // Lao similar to Thai
      case 'ta':
      case 'bn':
      case 'ne':
        return 1.4;  // South Asian scripts with complex ligatures
      default:
        return 1.2;  // Standard for Latin scripts
    }
  }

  /// Get minimum font size for readability
  ///
  /// Complex scripts may need larger minimum sizes for legibility,
  /// especially on mobile devices.
  static double getMinimumFontSize(String localeCode) {
    final languageCode = localeCode.split('_').first;

    switch (languageCode) {
      case 'km':
      case 'my':
      case 'th':
      case 'lo':
        return 14.0;  // Complex scripts need larger minimum
      case 'ta':
      case 'bn':
      case 'ne':
        return 13.0;  // South Asian scripts
      case 'zh':
        return 14.0;  // Chinese characters
      default:
        return 12.0;  // Standard Latin minimum
    }
  }
}

/// Extension on BuildContext for easy font access
extension FontContextExtension on BuildContext {
  /// Get the appropriate font family for the current locale
  String get currentFontFamily {
    final locale = Localizations.localeOf(this);
    return KerjaFlowFonts.getFontFamily(locale.languageCode);
  }

  /// Check if current locale requires a special script font
  bool get requiresSpecialFont {
    final locale = Localizations.localeOf(this);
    return KerjaFlowFonts.requiresSpecialFont(locale.languageCode);
  }

  /// Get line height multiplier for current locale
  double get lineHeightMultiplier {
    final locale = Localizations.localeOf(this);
    return KerjaFlowFonts.getLineHeightMultiplier(locale.languageCode);
  }

  /// Get minimum font size for current locale
  double get minimumFontSize {
    final locale = Localizations.localeOf(this);
    return KerjaFlowFonts.getMinimumFontSize(locale.languageCode);
  }
}
