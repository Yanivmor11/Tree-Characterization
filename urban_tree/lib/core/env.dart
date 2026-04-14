import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'debug_dotenv.dart';

/// Compile-time and optional debug-time configuration. Release builds must use
/// `--dart-define` / `--dart-define-from-file` (see `docs/DEPLOYMENT_CHECKLIST.md`).
abstract final class AppEnv {
  static const String appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static const bool blockSubmitIfLowAccuracy = bool.fromEnvironment(
    'BLOCK_SUBMIT_IF_LOW_ACCURACY',
    defaultValue: true,
  );

  static bool get isProd => appEnv == 'prod';

  static late final String supabaseUrl;
  static late final String supabaseAnonKey;
  static late final String openAiApiKey;

  static Future<void> load() async {
    var url = const String.fromEnvironment('SUPABASE_URL', defaultValue: '').trim();
    var anon =
        const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '').trim();
    var openai =
        const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '').trim();

    if (kDebugMode || kProfileMode) {
      await loadDotenvFromProjectRootIfPresent();
      if (dotenv.isInitialized) {
        if (url.isEmpty) {
          url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
        }
        if (anon.isEmpty) {
          anon = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
        }
        if (openai.isEmpty) {
          openai = dotenv.env['OPENAI_API_KEY']?.trim() ?? '';
        }
      }
    }

    if (url.isEmpty || anon.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY. '
        'For release: pass --dart-define-from-file=secrets.json (see secrets.json.example). '
        'For local debug: create urban_tree/.env from .env.example or use dart-define.',
      );
    }

    supabaseUrl = url;
    supabaseAnonKey = anon;
    openAiApiKey = openai;
  }
}
