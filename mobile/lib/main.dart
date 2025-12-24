import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/app_config.dart';
import 'core/localization/app_localizations.dart';
import 'shared/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    final authState = ref.watch(authStateProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'KerjaFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ms', ''),
        Locale('id', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}

// Locale provider
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en', '');
});

// Router provider - will be implemented with go_router
final routerProvider = Provider((ref) {
  // TODO: Implement go_router configuration
  throw UnimplementedError('Router not yet implemented');
});
