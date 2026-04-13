import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_locale_controller.dart';
import 'core/app_log.dart';
import 'core/env.dart';
import 'l10n/app_localizations.dart';
import 'presentation/auth/auth_gate_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'state/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppEnv.load();
    appLogDebug('Bootstrap APP_ENV=${AppEnv.appEnv}');
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    ).timeout(const Duration(seconds: 25));

    final localeController = AppLocaleController();
    await localeController.load();

    runApp(UrbanTreeApp(localeController: localeController));
  } catch (e, st) {
    assert(() {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(exception: e, stack: st),
      );
      return true;
    }());
    runApp(_BootstrapFailureApp(error: e));
  }
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

/// Shown when startup fails; avoids an endless native web splash (solid green).
class _BootstrapFailureApp extends StatelessWidget {
  const _BootstrapFailureApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final webHint = kIsWeb
        ? '\n\nWeb: .env is not loaded in the browser. Run with:\n'
            'flutter run -d chrome --dart-define-from-file=secrets.json\n'
            '(JSON with SUPABASE_URL and SUPABASE_ANON_KEY), or try:\n'
            'flutter run -d chrome --web-renderer html'
        : '';
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'Startup failed.\n\n$error$webHint',
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}

class UrbanTreeApp extends StatelessWidget {
  const UrbanTreeApp({super.key, required this.localeController});

  final AppLocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: ListenableBuilder(
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
            home: AuthGateScreen(localeController: localeController),
          );
        },
      ),
    );
  }
}
