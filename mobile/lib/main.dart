import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/localization/locale_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/fonts.dart';
import 'shared/theme/app_theme.dart';
import 'core/network/dio_client.dart';

// Import generated localizations (run 'flutter gen-l10n' to generate)
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage (offline support)
  await Hive.initFlutter();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize app configuration
  await AppConfig.initialize();

  // Initialize Dio client
  await DioClient.initialize();

  runApp(
    const ProviderScope(
      child: KerjaFlowApp(),
    ),
  );
}

class KerjaFlowApp extends ConsumerWidget {
  const KerjaFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'KerjaFlow',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(context, locale, AppTheme.lightTheme),
      darkTheme: _buildTheme(context, locale, AppTheme.darkTheme),
      themeMode: ThemeMode.light,
      locale: locale,
      // 12 supported locales for ASEAN workforce management
      supportedLocales: LocaleConfig.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Resolve locale with fallback support
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return LocaleConfig.defaultLocale;
        return LocaleConfig.resolveLocale(locale);
      },
      routerConfig: ref.watch(appRouterProvider),
    );
  }

  /// Build theme with locale-specific font configuration
  ThemeData _buildTheme(BuildContext context, Locale locale, ThemeData baseTheme) {
    final localeCode = locale.languageCode;

    // Apply locale-specific font if needed
    if (KerjaFlowFonts.requiresSpecialFont(localeCode)) {
      return baseTheme.copyWith(
        textTheme: KerjaFlowFonts.getTextTheme(
          localeCode,
          baseTheme: baseTheme.textTheme,
        ),
      );
    }

    return baseTheme;
  }
}

/// Locale provider for app-wide locale state management
///
/// Defaults to English. User preference is persisted via secure storage.
final localeProvider = StateProvider<Locale>((ref) {
  return LocaleConfig.defaultLocale;
});

/// Provider for changing locale
final localeNotifierProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

/// Notifier for managing locale changes with persistence
class LocaleNotifier extends StateNotifier<Locale> {
  final Ref ref;

  LocaleNotifier(this.ref) : super(LocaleConfig.defaultLocale) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    // TODO: Load from secure storage when implemented
    // final savedLocale = await SecureStorage.getLocale();
    // if (savedLocale != null) {
    //   state = savedLocale;
    // }
  }

  Future<void> setLocale(Locale locale) async {
    if (LocaleConfig.isSupported(locale)) {
      state = locale;
      ref.read(localeProvider.notifier).state = locale;
      // TODO: Persist to secure storage
      // await SecureStorage.setLocale(locale);
    }
  }

  /// Get current locale metadata
  LocaleMetadata? get currentMetadata {
    return LocaleConfig.getMetadata(state.languageCode);
  }
}
