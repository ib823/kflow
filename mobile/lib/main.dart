import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import 'core/config/app_config.dart';
import 'core/localization/locale_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/fonts.dart';
import 'shared/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'providers/hms_providers.dart';
import 'services/hms/analytics_observer.dart';

// Import generated localizations (run 'flutter gen-l10n' to generate)
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final _logger = Logger();

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

  _logger.i('KerjaFlow starting...');

  runApp(
    const ProviderScope(
      child: KerjaFlowApp(),
    ),
  );
}

class KerjaFlowApp extends ConsumerStatefulWidget {
  const KerjaFlowApp({super.key});

  @override
  ConsumerState<KerjaFlowApp> createState() => _KerjaFlowAppState();
}

class _KerjaFlowAppState extends ConsumerState<KerjaFlowApp> {
  @override
  void initState() {
    super.initState();
    _initializeHms();
  }

  /// Initialize HMS services (Push Kit, Analytics Kit)
  Future<void> _initializeHms() async {
    try {
      _logger.i('Initializing HMS services...');

      // Initialize HMS services
      final hmsNotifier = ref.read(hmsInitializationProvider.notifier);
      await hmsNotifier.initialize();

      final hmsState = ref.read(hmsInitializationProvider);
      if (hmsState.isFullyInitialized) {
        _logger.i('HMS services initialized successfully');
        _logger.i('Push token: ${hmsState.pushToken?.substring(0, 20)}...');
      } else if (hmsState.errorMessage != null) {
        _logger.w('HMS initialization warning: ${hmsState.errorMessage}');
      } else {
        _logger.i('HMS not available on this device (likely non-Huawei)');
      }
    } catch (e) {
      _logger.e('Failed to initialize HMS services: $e');
      // Non-fatal - app continues without HMS
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);
    final analyticsObserver = ref.watch(analyticsGoRouterObserverProvider);

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
      routerConfig: router,
    );
  }

  /// Build theme with locale-specific font configuration
  ThemeData _buildTheme(
      BuildContext context, Locale locale, ThemeData baseTheme) {
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
final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
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
      final previousLocale = state;
      state = locale;
      ref.read(localeProvider.notifier).state = locale;

      // Track language change in analytics
      final tracker = ref.read(analyticsTrackerProvider);
      await tracker.trackEvent('language_changed', params: {
        'from_language': previousLocale.languageCode,
        'to_language': locale.languageCode,
      });

      // TODO: Persist to secure storage
      // await SecureStorage.setLocale(locale);
    }
  }

  /// Get current locale metadata
  LocaleMetadata? get currentMetadata {
    return LocaleConfig.getMetadata(state.languageCode);
  }
}
