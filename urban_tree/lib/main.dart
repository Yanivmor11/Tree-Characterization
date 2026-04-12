import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_locale_controller.dart';
import 'core/app_log.dart';
import 'core/env.dart';
import 'l10n/app_localizations.dart';
import 'presentation/splash_screen.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  appLogDebug('Bootstrap APP_ENV=${AppEnv.appEnv}');
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );

  final localeController = AppLocaleController();
  await localeController.load();

  runApp(UrbanTreeApp(localeController: localeController));
}

Locale _matchSupportedLanguage(String languageCode, Iterable<Locale> supported) {
  for (final s in supported) {
    if (s.languageCode == languageCode) return s;
  }
  return const Locale('en');
}

Locale _resolveDeviceLocale(List<Locale>? deviceLocales, Iterable<Locale> supported) {
  if (deviceLocales != null) {
    for (final d in deviceLocales) {
      for (final s in supported) {
        if (s.languageCode == d.languageCode) return s;
      }
    }
  }
  return const Locale('en');
}

class UrbanTreeApp extends StatelessWidget {
  const UrbanTreeApp({super.key, required this.localeController});

  final AppLocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'UrbanTree',
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: (deviceLocales, supported) {
            if (localeController.locale != null) {
              return _matchSupportedLanguage(
                localeController.locale!.languageCode,
                supported,
              );
            }
            return _resolveDeviceLocale(deviceLocales, supported);
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: buildUrbanTreeTheme(brightness: Brightness.light),
          darkTheme: buildUrbanTreeTheme(brightness: Brightness.dark),
          themeMode: ThemeMode.system,
          home: SplashScreen(localeController: localeController),
        );
      },
    );
  }
}
