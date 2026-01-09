import 'package:flutter/material.dart';

/// Font configuration for multi-script ASEAN language support
///
/// KerjaFlow supports 12 languages with various scripts:
/// - Latin: English, Malay, Indonesian, Vietnamese, Filipino
/// - Han: Chinese Simplified
/// - Thai: Thai
/// - Tamil: Tamil
/// - Khmer: Khmer
/// - Myanmar: Myanmar/Burmese (Unicode only, NOT Zawgyi)
/// - Devanagari: Nepali
/// - Bengali: Bengali
class KFFontConfig {
  KFFontConfig._();

  /// Base font family for Latin scripts
  static const String baseFontFamily = 'Plus Jakarta Sans';

  /// Fallback system font
  static const String systemFallback = 'Roboto';

  /// Script-specific font families with fallbacks
  /// Order: Primary -> System fallback -> Generic
  static const Map<String, List<String>> scriptFonts = {
    // Chinese Simplified - Han script
    'zh': ['Noto Sans SC', 'PingFang SC', 'Microsoft YaHei', 'sans-serif'],

    // Tamil - Brahmic script
    'ta': ['NotoSansTamil', 'Noto Sans Tamil', 'Latha', 'sans-serif'],

    // Thai - Thai script
    'th': ['NotoSansThai', 'Noto Sans Thai', 'Tahoma', 'sans-serif'],

    // Myanmar/Burmese - Myanmar script (Unicode only)
    'my': ['NotoSansMyanmar', 'Noto Sans Myanmar', 'Myanmar Text', 'Padauk', 'sans-serif'],

    // Khmer - Khmer script
    'km': ['NotoSansKhmer', 'Noto Sans Khmer', 'Khmer OS', 'sans-serif'],

    // Nepali - Devanagari script
    'ne': ['NotoSansDevanagari', 'Noto Sans Devanagari', 'Mangal', 'sans-serif'],

    // Bengali - Bengali script
    'bn': ['NotoSansBengali', 'Noto Sans Bengali', 'Vrinda', 'sans-serif'],
  };

  /// Languages using Latin script (no special font needed)
  static const Set<String> latinScriptLanguages = {
    'en', // English
    'ms', // Malay
    'id', // Indonesian
    'vi', // Vietnamese
    'tl', // Filipino/Tagalog
  };

  /// Get font family fallback list for a locale
  static List<String> getFontFamilyFallback(String localeCode) {
    // Check if it's a complex script language
    final scriptFontList = scriptFonts[localeCode];
    if (scriptFontList != null) {
      return [baseFontFamily, ...scriptFontList];
    }

    // Latin script languages use base font
    return [baseFontFamily, systemFallback];
  }

  /// Get primary font family for a locale
  static String? getPrimaryFontFamily(String localeCode) {
    final scriptFontList = scriptFonts[localeCode];
    if (scriptFontList != null && scriptFontList.isNotEmpty) {
      return scriptFontList.first;
    }
    return null;
  }

  /// Check if locale requires complex script font
  static bool needsComplexScriptFont(String localeCode) {
    return scriptFonts.containsKey(localeCode);
  }

  /// Create TextTheme with locale-appropriate fonts
  static TextTheme createLocalizedTextTheme(
    TextTheme baseTheme,
    String localeCode,
  ) {
    final fontFamilyFallback = getFontFamilyFallback(localeCode);
    final primaryFont = getPrimaryFontFamily(localeCode);

    if (primaryFont != null) {
      return baseTheme.copyWith(
        displayLarge: baseTheme.displayLarge?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        displayMedium: baseTheme.displayMedium?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        displaySmall: baseTheme.displaySmall?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        headlineLarge: baseTheme.headlineLarge?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        headlineMedium: baseTheme.headlineMedium?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        headlineSmall: baseTheme.headlineSmall?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        titleLarge: baseTheme.titleLarge?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        titleMedium: baseTheme.titleMedium?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        titleSmall: baseTheme.titleSmall?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        bodyLarge: baseTheme.bodyLarge?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        bodyMedium: baseTheme.bodyMedium?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        bodySmall: baseTheme.bodySmall?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        labelLarge: baseTheme.labelLarge?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        labelMedium: baseTheme.labelMedium?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
        labelSmall: baseTheme.labelSmall?.copyWith(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFamilyFallback,
        ),
      );
    }

    // For Latin scripts, just apply fallback
    return baseTheme.apply(fontFamilyFallback: fontFamilyFallback);
  }

  /// Get Google Fonts CDN URL for dynamic font loading
  /// Used for web platform to load fonts on demand
  static String? getGoogleFontsCdnUrl(String localeCode) {
    switch (localeCode) {
      case 'zh':
        return 'https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@400;500;600;700&display=swap';
      case 'ta':
        return 'https://fonts.googleapis.com/css2?family=Noto+Sans+Tamil:wght@400;500;600;700&display=swap';
      case 'th':
        return 'https://fonts.googleapis.com/css2?family=Noto+Sans+Thai:wght@400;500;600;700&display=swap';
      case 'my':
        return 'https://fonts.googleapis.com/css2?family=Noto+Sans+Myanmar:wght@400;500;600;700&display=swap';
      case 'km':
        return 'https://fonts.googleapis.com/css2?family=Noto+Sans+Khmer:wght@400;500;600;700&display=swap';
      case 'ne':
        return 'https://fonts.googleapis.com/css2?family=Noto+Sans+Devanagari:wght@400;500;600;700&display=swap';
      case 'bn':
        return 'https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;500;600;700&display=swap';
      default:
        return null;
    }
  }
}

/// Mixin for StatefulWidgets that need locale-aware fonts
mixin LocaleAwareFontMixin<T extends StatefulWidget> on State<T> {
  /// Apply locale-appropriate font to a text style
  TextStyle applyLocaleFont(TextStyle style) {
    final locale = Localizations.localeOf(context);
    final fontFamilyFallback = KFFontConfig.getFontFamilyFallback(
      locale.languageCode,
    );
    final primaryFont = KFFontConfig.getPrimaryFontFamily(locale.languageCode);

    if (primaryFont != null) {
      return style.copyWith(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFamilyFallback,
      );
    }

    return style.copyWith(fontFamilyFallback: fontFamilyFallback);
  }

  /// Get the primary font family for current locale
  String? get localeFontFamily {
    final locale = Localizations.localeOf(context);
    return KFFontConfig.getPrimaryFontFamily(locale.languageCode);
  }

  /// Check if current locale needs complex script font
  bool get needsComplexFont {
    final locale = Localizations.localeOf(context);
    return KFFontConfig.needsComplexScriptFont(locale.languageCode);
  }
}
