import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'debug_dotenv.dart';

/// Compile-time and optional debug-time configuration.
///
/// **Decoupled key extraction** — secrets never ship in source code. Resolution
/// order per key:
/// 1. `--dart-define` / `--dart-define-from-file=secrets.json` (release, CI, Vercel)
/// 2. `urban_tree/.env` via [loadDotenvFromProjectRootIfPresent] (debug/profile only)
///
/// Release builds must use dart-define; see `docs/DEPLOYMENT_CHECKLIST.md`.
///
/// [blockSubmitIfLowAccuracy] gates Tier-1 client GPS rejection at 2 m. The
/// server always enforces the same limit independently.
abstract final class AppEnv {
  static const String appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  /// When true, [TreeReportValidator] blocks submit if GPS uncertainty > 2 m.
  /// Default `true` for citizen-science integrity; `secrets.json.example` uses
  /// `false` for easier local testing.
  static const bool blockSubmitIfLowAccuracy = bool.fromEnvironment(
    'BLOCK_SUBMIT_IF_LOW_ACCURACY',
    defaultValue: true,
  );

  static bool get isProd => appEnv == 'prod';

  static late final String supabaseUrl;
  static late final String supabaseAnonKey;

  /// Optional on mobile — when empty, [AIService] routes through Edge Functions.
  /// Web builds must leave this empty; OpenAI calls go through Supabase only.
  static late final String openAiApiKey;

  /// Loads and validates required configuration. Call once before [Supabase.initialize].
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
