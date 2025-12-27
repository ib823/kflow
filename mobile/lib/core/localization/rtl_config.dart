import 'package:flutter/material.dart';

/// RTL (Right-to-Left) configuration for Jawi and Arabic locales
/// Jawi is Arabic-script Malay used in Malaysia
class RTLConfig {
  /// List of locale codes that use RTL text direction
  static const List<String> rtlLocales = ['ms_Arab', 'ar'];

  /// Check if a locale uses RTL text direction
  static bool isRTL(Locale locale) {
    final localeString = locale.toString();
    final languageCode = locale.languageCode;

    return rtlLocales.contains(localeString) ||
           rtlLocales.contains(languageCode) ||
           (locale.scriptCode == 'Arab');
  }

  /// Get the appropriate TextDirection for a locale
  static TextDirection getTextDirection(Locale locale) {
    return isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get text alignment based on locale direction
  static TextAlign getTextAlign(Locale locale, {TextAlign defaultAlign = TextAlign.start}) {
    if (isRTL(locale)) {
      switch (defaultAlign) {
        case TextAlign.left:
          return TextAlign.right;
        case TextAlign.right:
          return TextAlign.left;
        case TextAlign.start:
          return TextAlign.start;
        case TextAlign.end:
          return TextAlign.end;
        default:
          return defaultAlign;
      }
    }
    return defaultAlign;
  }

  /// Get appropriate alignment for RTL/LTR layouts
  static Alignment getAlignment(Locale locale, {Alignment defaultAlignment = Alignment.centerLeft}) {
    if (isRTL(locale)) {
      if (defaultAlignment == Alignment.centerLeft) return Alignment.centerRight;
      if (defaultAlignment == Alignment.centerRight) return Alignment.centerLeft;
      if (defaultAlignment == Alignment.topLeft) return Alignment.topRight;
      if (defaultAlignment == Alignment.topRight) return Alignment.topLeft;
      if (defaultAlignment == Alignment.bottomLeft) return Alignment.bottomRight;
      if (defaultAlignment == Alignment.bottomRight) return Alignment.bottomLeft;
    }
    return defaultAlignment;
  }
}

/// Extension to easily check RTL on BuildContext
extension RTLExtension on BuildContext {
  bool get isRTL {
    final locale = Localizations.localeOf(this);
    return RTLConfig.isRTL(locale);
  }

  TextDirection get textDirection {
    final locale = Localizations.localeOf(this);
    return RTLConfig.getTextDirection(locale);
  }
}
