import 'package:uuid/uuid.dart';

import 'ai_service.dart';

/// Graceful degradation for live presentation demos.
///
/// When Supabase, OpenAI, or network calls fail under venue Wi‑Fi latency,
/// injects pre-compiled high-fidelity mock payloads so the UI flow continues
/// without visible errors to the audience.
abstract final class PresentationFallbackService {
  static const _uuid = Uuid();

  /// Enable fail-safe mocks during the presentation release.
  static const bool enabled = true;

  static bool shouldUseFallback(Object error) {
    if (!enabled) return false;
    final msg = error.toString().toLowerCase();
    return msg.contains('timeout') ||
        msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('failed host lookup') ||
        msg.contains('openai') ||
        msg.contains('edge') ||
        msg.contains('function') ||
        msg.contains('postgrest') ||
        msg.contains('gps accuracy') ||
        msg.contains('exceeds required maximum');
  }

  /// Mock report id when Supabase insert or storage upload fails.
  static String mockReportId() => _uuid.v4();

  /// High-fidelity species/health suggestion for vision or text AI failures.
  static CharacterizationSuggestion mockCharacterizationSuggestion() {
    return CharacterizationSuggestion(
      speciesCommon: 'London Plane',
      speciesScientific: 'Platanus x acerifolia',
      translatedDisplayName: 'London Plane',
      sourceLanguage: 'en',
      speciesConfidence: 0.82,
      healthScore: 4,
      stressSymptoms: const ['none'],
      phenologicalStage: 'open',
      notes: 'Presentation fallback — typical urban street tree, moderate canopy.',
    );
  }

  /// Post-submit insight when openai-tree-insights fails.
  static String mockInsightTip() {
    return 'Monitor soil moisture during dry weeks; consult an arborist if canopy '
        'thinning accelerates.';
  }
}
