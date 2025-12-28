import 'package:flutter/material.dart';

/// Locale configuration for KerjaFlow.
///
/// Supports 12 languages for ASEAN workforce management:
/// - 5 Latin-script languages (English, Malay, Indonesian, Vietnamese, Filipino)
/// - 1 Han-script language (Chinese Simplified)
/// - 6 Complex-script languages (Thai, Tamil, Khmer, Myanmar, Bengali, Nepali)
///
/// Each language is mapped to its primary market and provides:
/// - Locale information
/// - Native name for display
/// - Text direction (LTR for all supported languages)
/// - Country flags for visual identification
class LocaleConfig {
  LocaleConfig._();

  /// All supported locales in KerjaFlow
  ///
  /// Order reflects display priority in language selector:
  /// 1. English (universal baseline)
  /// 2. Primary ASEAN country languages by market size
  /// 3. Migrant worker languages
  static const List<Locale> supportedLocales = [
    Locale('en'),          // English (universal)
    Locale('ms'),          // Bahasa Malaysia
    Locale('id'),          // Bahasa Indonesia
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),  // Chinese Simplified
    Locale('ta'),          // Tamil
    Locale('th'),          // Thai
    Locale('vi'),          // Vietnamese
    Locale('tl'),          // Filipino/Tagalog
    Locale('km'),          // Khmer
    Locale('my'),          // Burmese/Myanmar
    Locale('bn'),          // Bengali
    Locale('ne'),          // Nepali
  ];

  /// Default locale when user preference is not set
  static const Locale defaultLocale = Locale('en');

  /// Fallback locale when requested locale is not supported
  static const Locale fallbackLocale = Locale('en');

  /// Detailed locale metadata for UI display and configuration
  static const Map<String, LocaleMetadata> localeMetadata = {
    'en': LocaleMetadata(
      code: 'en',
      nativeName: 'English',
      englishName: 'English',
      flag: '🇬🇧',
      scriptType: ScriptType.latin,
      primaryCountries: ['MY', 'SG', 'PH', 'BN'],
      textDirection: TextDirection.ltr,
    ),
    'ms': LocaleMetadata(
      code: 'ms',
      nativeName: 'Bahasa Malaysia',
      englishName: 'Malay',
      flag: '🇲🇾',
      scriptType: ScriptType.latin,
      primaryCountries: ['MY', 'BN'],
      textDirection: TextDirection.ltr,
    ),
    'id': LocaleMetadata(
      code: 'id',
      nativeName: 'Bahasa Indonesia',
      englishName: 'Indonesian',
      flag: '🇮🇩',
      scriptType: ScriptType.latin,
      primaryCountries: ['ID'],
      textDirection: TextDirection.ltr,
    ),
    'zh_Hans': LocaleMetadata(
      code: 'zh_Hans',
      nativeName: '简体中文',
      englishName: 'Chinese (Simplified)',
      flag: '🇨🇳',
      scriptType: ScriptType.han,
      primaryCountries: ['SG', 'MY'],
      textDirection: TextDirection.ltr,
    ),
    'ta': LocaleMetadata(
      code: 'ta',
      nativeName: 'தமிழ்',
      englishName: 'Tamil',
      flag: '🇮🇳',
      scriptType: ScriptType.tamil,
      primaryCountries: ['MY', 'SG'],
      textDirection: TextDirection.ltr,
    ),
    'th': LocaleMetadata(
      code: 'th',
      nativeName: 'ภาษาไทย',
      englishName: 'Thai',
      flag: '🇹🇭',
      scriptType: ScriptType.thai,
      primaryCountries: ['TH'],
      textDirection: TextDirection.ltr,
    ),
    'vi': LocaleMetadata(
      code: 'vi',
      nativeName: 'Tiếng Việt',
      englishName: 'Vietnamese',
      flag: '🇻🇳',
      scriptType: ScriptType.latin,
      primaryCountries: ['VN'],
      textDirection: TextDirection.ltr,
    ),
    'tl': LocaleMetadata(
      code: 'tl',
      nativeName: 'Filipino',
      englishName: 'Filipino/Tagalog',
      flag: '🇵🇭',
      scriptType: ScriptType.latin,
      primaryCountries: ['PH'],
      textDirection: TextDirection.ltr,
    ),
    'km': LocaleMetadata(
      code: 'km',
      nativeName: 'ភាសាខ្មែរ',
      englishName: 'Khmer',
      flag: '🇰🇭',
      scriptType: ScriptType.khmer,
      primaryCountries: ['KH'],
      textDirection: TextDirection.ltr,
    ),
    'my': LocaleMetadata(
      code: 'my',
      nativeName: 'မြန်မာ',
      englishName: 'Burmese',
      flag: '🇲🇲',
      scriptType: ScriptType.myanmar,
      primaryCountries: ['MM'],
      textDirection: TextDirection.ltr,
    ),
    'bn': LocaleMetadata(
      code: 'bn',
      nativeName: 'বাংলা',
      englishName: 'Bengali',
      flag: '🇧🇩',
      scriptType: ScriptType.bengali,
      primaryCountries: ['BD'],
      textDirection: TextDirection.ltr,
      isMigrantWorkerLanguage: true,
    ),
    'ne': LocaleMetadata(
      code: 'ne',
      nativeName: 'नेपाली',
      englishName: 'Nepali',
      flag: '🇳🇵',
      scriptType: ScriptType.devanagari,
      primaryCountries: ['NP'],
      textDirection: TextDirection.ltr,
      isMigrantWorkerLanguage: true,
    ),
  };

  /// Check if a locale is supported
  static bool isSupported(Locale locale) {
    return supportedLocales.any((supported) =>
        supported.languageCode == locale.languageCode);
  }

  /// Get metadata for a locale
  static LocaleMetadata? getMetadata(String localeCode) {
    // Try exact match first
    if (localeMetadata.containsKey(localeCode)) {
      return localeMetadata[localeCode];
    }
    // Try language code only
    final languageCode = localeCode.split('_').first;
    return localeMetadata[languageCode];
  }

  /// Get the best matching supported locale for a given locale
  static Locale resolveLocale(Locale locale) {
    // Exact match
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode &&
          supported.scriptCode == locale.scriptCode) {
        return supported;
      }
    }
    // Language code match
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    // Fallback
    return fallbackLocale;
  }

  /// Get locales grouped by script type for UI organization
  static Map<ScriptType, List<LocaleMetadata>> getLocalesByScriptType() {
    final grouped = <ScriptType, List<LocaleMetadata>>{};

    for (final metadata in localeMetadata.values) {
      grouped.putIfAbsent(metadata.scriptType, () => []).add(metadata);
    }

    return grouped;
  }

  /// Get locales for a specific country
  static List<LocaleMetadata> getLocalesForCountry(String countryCode) {
    return localeMetadata.values
        .where((m) => m.primaryCountries.contains(countryCode))
        .toList();
  }

  /// Get migrant worker languages
  static List<LocaleMetadata> getMigrantWorkerLanguages() {
    return localeMetadata.values
        .where((m) => m.isMigrantWorkerLanguage)
        .toList();
  }
}

/// Script type classification for rendering optimization
enum ScriptType {
  latin,       // English, Malay, Indonesian, Vietnamese, Filipino
  han,         // Chinese
  thai,        // Thai
  khmer,       // Khmer/Cambodian
  myanmar,     // Burmese
  tamil,       // Tamil
  bengali,     // Bengali
  devanagari,  // Nepali
}

/// Metadata for a supported locale
class LocaleMetadata {
  final String code;
  final String nativeName;
  final String englishName;
  final String flag;
  final ScriptType scriptType;
  final List<String> primaryCountries;
  final TextDirection textDirection;
  final bool isMigrantWorkerLanguage;

  const LocaleMetadata({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flag,
    required this.scriptType,
    required this.primaryCountries,
    required this.textDirection,
    this.isMigrantWorkerLanguage = false,
  });

  /// Get the Flutter Locale object
  Locale get locale {
    if (code.contains('_')) {
      final parts = code.split('_');
      return Locale.fromSubtags(
        languageCode: parts[0],
        scriptCode: parts.length > 1 ? parts[1] : null,
      );
    }
    return Locale(code);
  }

  /// Display name showing both native and English names
  String get displayName => '$nativeName ($englishName)';

  /// Whether this script requires special font rendering
  bool get requiresComplexRendering =>
      scriptType != ScriptType.latin && scriptType != ScriptType.han;
}

/// Extension for easy locale resolution from BuildContext
extension LocaleContextExtension on BuildContext {
  /// Get the current locale's metadata
  LocaleMetadata? get localeMetadata {
    final locale = Localizations.localeOf(this);
    return LocaleConfig.getMetadata(locale.languageCode);
  }

  /// Check if the current locale requires complex script rendering
  bool get requiresComplexScriptRendering {
    return localeMetadata?.requiresComplexRendering ?? false;
  }

  /// Get the current locale's native name
  String get localeNativeName {
    return localeMetadata?.nativeName ?? 'English';
  }

  /// Get the current locale's flag emoji
  String get localeFlag {
    return localeMetadata?.flag ?? '🇬🇧';
  }
}
