import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import 'presentation_fallback_service.dart';

/// AI characterization output — suggestions only; reporter must confirm.
///
/// Canonical fields ([speciesCommon], [speciesScientific]) are normalized to
/// English common name and Latin binomial for cross-locale research queries.
/// [translatedDisplayName] preserves the reporter's UI language; [sourceLanguage]
/// records BCP-47 origin for audit. Stored in `tree_reports.ai_suggestion_json`.
class CharacterizationSuggestion {
  CharacterizationSuggestion({
    this.speciesCommon,
    this.speciesScientific,
    this.translatedDisplayName,
    this.sourceLanguage,
    this.speciesConfidence,
    this.healthScore,
    this.hazardAssessment,
    this.canopyDensity,
    this.structuralIssues,
    this.stressSymptoms,
    this.phenologicalStage,
    this.notes,
  });

  final String? speciesCommon;
  final String? speciesScientific;
  final String? translatedDisplayName;
  final String? sourceLanguage;
  final double? speciesConfidence;
  final int? healthScore;
  /// One of: `low`, `medium`, `high`.
  final String? hazardAssessment;
  /// One of: `sparse`, `moderate`, `dense`.
  final String? canopyDensity;
  /// Storage values: `dead_branches`, `leaning`, `cracks`, `exposed_roots`, `cavity`, `other`.
  final List<String>? structuralIssues;
  final List<String>? stressSymptoms;
  final String? phenologicalStage;
  final String? notes;

  /// Whether the suggestion contains fields usable in the wizard UI.
  bool hasStructuredFields({required bool flowerStepOnly}) {
    if (flowerStepOnly) {
      return phenologicalStage != null ||
          (notes != null && notes!.trim().isNotEmpty);
    }
    return healthScore != null ||
        hazardAssessment != null ||
        canopyDensity != null ||
        (structuralIssues != null && structuralIssues!.isNotEmpty) ||
        speciesCommon != null ||
        speciesScientific != null ||
        (translatedDisplayName != null && translatedDisplayName!.isNotEmpty) ||
        (stressSymptoms != null && stressSymptoms!.isNotEmpty) ||
        phenologicalStage != null ||
        (notes != null && notes!.trim().isNotEmpty);
  }

  Map<String, dynamic> toAuditJson() {
    return {
      if (speciesCommon != null) 'species_common': speciesCommon,
      if (speciesScientific != null) 'species_scientific': speciesScientific,
      if (speciesCommon != null) 'species_common_en': speciesCommon,
      if (speciesScientific != null) 'species_scientific_latin': speciesScientific,
      if (translatedDisplayName != null)
        'translated_display_name': translatedDisplayName,
      if (sourceLanguage != null) 'source_language': sourceLanguage,
      if (speciesConfidence != null) 'species_confidence': speciesConfidence,
      if (healthScore != null) 'health_score': healthScore,
      if (hazardAssessment != null) 'hazard_assessment': hazardAssessment,
      if (canopyDensity != null) 'canopy_density': canopyDensity,
      if (structuralIssues != null) 'structural_issues': structuralIssues,
      if (stressSymptoms != null) 'stress_symptoms': stressSymptoms,
      if (phenologicalStage != null) 'phenological_stage': phenologicalStage,
      if (notes != null) 'notes': notes,
    };
  }
}

/// Vision and text AI for species/health/phenology characterization.
///
/// **Platform routing matrix** (keeps OpenAI keys off web clients):
/// | Platform | Vision / text suggest | Post-submit insight |
/// |----------|----------------------|---------------------|
/// | Web | Edge `openai-suggest` | Edge `openai-tree-insights` |
/// | Mobile + `OPENAI_API_KEY` | Direct OpenAI gpt-4o-mini | Edge insights |
/// | Mobile, no key | Edge suggest (fallback) | Edge insights |
///
/// Images are resized to max 896 px before upload to balance diagnostic detail
/// against token cost. Multilingual input is normalized to English/Latin in the
/// model system prompt and [_parseOpenAiJsonObject].
class AIService {
  AIService({http.Client? httpClient, SupabaseClient? supabase})
      : _http = httpClient ?? http.Client(),
        _supabase = supabase ?? Supabase.instance.client;

  final http.Client _http;
  final SupabaseClient _supabase;

  static const _model = 'gpt-4o-mini';
  static const _openAiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const _edgeSuggest = 'openai-suggest';
  static const _edgeInsights = 'openai-tree-insights';

  Future<dynamic> _invokeEdgeFunction(
    String functionName, {
    required Map<String, dynamic> body,
  }) async {
    final accessToken = _supabase.auth.currentSession?.accessToken;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'apikey': AppEnv.supabaseAnonKey,
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
    try {
      return await _supabase.functions.invoke(
        functionName,
        body: body,
        headers: headers,
      );
    } on FunctionException catch (e) {
      final details = e.details?.toString().trim() ?? '';
      if (kIsWeb && details.isEmpty) {
        throw StateError(
          'Edge call failed in browser (likely CORS/origin issue). '
          'Confirm OPTIONS handling in the function and allow your web origin in Supabase API settings.',
        );
      }
      rethrow;
    }
  }

  /// Downscales large photos to ≤896 px — sufficient for species/phenology cues
  /// while reducing vision-token cost and upload latency on mobile networks.
  Uint8List _resizeForVision(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    if (decoded.width <= 896 && decoded.height <= 896) return bytes;
    final resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? 896 : null,
      height: decoded.height > decoded.width ? 896 : null,
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: 82));
  }

  /// Vision-based characterization from a whole-tree or detail photo.
  ///
  /// Presentation fail-safe: returns [PresentationFallbackService] mock on
  /// OpenAI/Edge/network errors so the live demo UI keeps functioning.
  Future<CharacterizationSuggestion> suggestFromTreeImage({
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
    String? locale,
  }) async {
    try {
      final prepared = _resizeForVision(imageBytes);
      final b64 = base64Encode(prepared);
      final languageCode = _normalizeLocale(locale);

      if (kIsWeb) {
        return await _suggestVisionViaEdge(b64, mimeType, languageCode);
      }

      final key = AppEnv.openAiApiKey.trim();
      if (key.isEmpty) {
        return await _suggestVisionViaEdge(b64, mimeType, languageCode);
      }

      return await _suggestVisionDirect(b64, mimeType, key, languageCode);
    } catch (e) {
      if (PresentationFallbackService.shouldUseFallback(e)) {
        return PresentationFallbackService.mockCharacterizationSuggestion();
      }
      rethrow;
    }
  }

  /// Text-based characterization from free-form resident description (any language).
  ///
  /// [step] hints the model: `whole_tree` or `flower_fruit`. Optional [imageBytes]
  /// adds vision context (e.g. flower/fruit photos on step 2).
  Future<CharacterizationSuggestion> suggestFromResidentText(
    String text, {
    String? step,
    Uint8List? imageBytes,
    String mimeType = 'image/jpeg',
    String? locale,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && imageBytes == null) {
      return CharacterizationSuggestion();
    }

    final languageCode = _normalizeLocale(locale);

    try {
      if (kIsWeb) {
        return await _suggestTextViaEdge(
          trimmed,
          step: step,
          imageBytes: imageBytes,
          mimeType: mimeType,
          locale: languageCode,
        );
      }

      final key = AppEnv.openAiApiKey.trim();
      if (key.isEmpty) {
        return await _suggestTextViaEdge(
          trimmed,
          step: step,
          imageBytes: imageBytes,
          mimeType: mimeType,
          locale: languageCode,
        );
      }

      return await _suggestTextDirect(
        trimmed,
        key,
        step: step,
        imageBytes: imageBytes,
        mimeType: mimeType,
        locale: languageCode,
      );
    } catch (e) {
      if (PresentationFallbackService.shouldUseFallback(e)) {
        return PresentationFallbackService.mockCharacterizationSuggestion();
      }
      rethrow;
    }
  }

  /// Short actionable tip after successful submit (always via Edge Function).
  Future<String> treeInsightTip({
    required Map<String, dynamic> context,
  }) async {
    try {
      final res = await _invokeEdgeFunction(
        _edgeInsights,
        body: {'context': context},
      );
      if (res.status != 200) {
        throw StateError('Insights HTTP ${res.status}: ${res.data}');
      }
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final tip = data['tip'];
        if (tip is String && tip.isNotEmpty) return tip;
      }
      if (data is String && data.isNotEmpty) {
        final obj = jsonDecode(data) as Map<String, dynamic>;
        final tip = obj['tip'];
        if (tip is String) return tip;
      }
      return '';
    } on FunctionException catch (e) {
      if (PresentationFallbackService.shouldUseFallback(e)) {
        return PresentationFallbackService.mockInsightTip();
      }
      throw StateError('Insights failed: ${e.details ?? e.reasonPhrase}');
    } catch (e) {
      if (PresentationFallbackService.shouldUseFallback(e)) {
        return PresentationFallbackService.mockInsightTip();
      }
      rethrow;
    }
  }

  static String _normalizeLocale(String? locale) {
    final code = locale?.trim().toLowerCase();
    if (code == null || code.isEmpty) return 'en';
    const supported = {'he', 'en', 'ar', 'ru'};
    return supported.contains(code) ? code : 'en';
  }

  static String _characterizationSystemPrompt({
    required String languageCode,
    String? step,
    bool vision = false,
  }) {
    final langName = switch (languageCode) {
      'he' => 'Hebrew',
      'ar' => 'Arabic',
      'ru' => 'Russian',
      _ => 'English',
    };

    var prompt =
        'You assist urban tree citizen science. The user interface language is '
        '"$languageCode" ($langName). '
        'Output ONLY valid JSON with keys: '
        'species_common_en (canonical English common name or null), '
        'species_scientific_latin (canonical Latin binomial or null), '
        'translated_display_name (species common name in $langName for the UI — required when identifiable), '
        'species_common (same as species_common_en), species_scientific (same as species_scientific_latin), '
        'source_language (BCP-47 code "$languageCode"), '
        'species_confidence (number 0-1 or null), '
        'health_score (integer 1-5 — provide your best estimate when the tree is visible; typical healthy urban trees are 3-5), '
        'hazard_assessment (exactly one of: "low", "medium", "high" — structural/public safety risk from visible defects), '
        'canopy_density (exactly one of: "sparse", "moderate", "dense"), '
        'structural_issues (array with any of: "dead_branches","leaning","cracks","exposed_roots","cavity","other", or empty array if none visible), '
        'stress_symptoms (array with any of: "chlorosis","necrosis","wilting","leaf_spot","defoliation","gummosis","pest_damage","none","other", or null), '
        'phenological_stage (exactly one of: "bud", "open", "fruit", or null), '
        'notes (10-20 words in $langName describing the tree: species cues, crown, leaf condition, and visible health — required when the image or text is usable). '
        'Write translated_display_name and notes ONLY in $langName. '
        'Keep species_common_en and species_scientific_latin in English/Latin. '
        'Fill every field you can infer; use null only when truly uncertain or not visible. '
        'If user mentions flowers or blooming, set phenological_stage to "open". '
        'If buds only, use "bud". If fruit visible, use "fruit".';

    if (vision) {
      prompt +=
          ' Analyze the tree photo carefully: identify species from leaves, bark, crown, and fruit if visible; '
          'assess overall health (1=very poor, 5=excellent), hazard_assessment, canopy_density, and visible structural_issues; '
          'note stress symptoms; infer phenological stage when clear. '
          'Always fill species, notes, health_score, hazard_assessment, and canopy_density when the tree is visible.';
    }

    if (step == 'flower_fruit') {
      prompt +=
          ' Focus on phenological_stage and notes; infer stage from visible flowers, buds, or fruit.';
    }

    return prompt;
  }

  Future<CharacterizationSuggestion> _suggestVisionViaEdge(
    String b64,
    String mimeType,
    String languageCode,
  ) async {
    try {
      final res = await _invokeEdgeFunction(
        _edgeSuggest,
        body: {
          'image_base64': b64,
          'mime_type': mimeType,
          'locale': languageCode,
        },
      );
      if (res.status != 200) {
        throw StateError('Assistant proxy HTTP ${res.status}: ${res.data}');
      }
      return _parseSuggestionPayload(res.data);
    } on FunctionException catch (e) {
      throw StateError('Assistant proxy failed: ${e.details ?? e.reasonPhrase}');
    }
  }

  Future<CharacterizationSuggestion> _suggestTextViaEdge(
    String trimmed, {
    String? step,
    Uint8List? imageBytes,
    String mimeType = 'image/jpeg',
    String locale = 'en',
  }) async {
    try {
      final body = <String, dynamic>{
        'text': trimmed,
        'locale': locale,
        if (step != null && step.isNotEmpty) 'step': step,
      };
      if (imageBytes != null) {
        final prepared = _resizeForVision(imageBytes);
        body['image_base64'] = base64Encode(prepared);
        body['mime_type'] = mimeType;
      }
      final res = await _invokeEdgeFunction(
        _edgeSuggest,
        body: body,
      );
      if (res.status != 200) {
        throw StateError(
          'Assistant proxy HTTP ${res.status}: ${res.data}',
        );
      }
      return _parseSuggestionPayload(res.data);
    } on FunctionException catch (e) {
      throw StateError('Assistant proxy failed: ${e.details ?? e.reasonPhrase}');
    }
  }

  Future<CharacterizationSuggestion> _suggestVisionDirect(
    String b64,
    String mimeType,
    String apiKey,
    String languageCode,
  ) async {
    final dataUrl = 'data:$mimeType;base64,$b64';
    final body = jsonEncode({
      'model': _model,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content': _characterizationSystemPrompt(
            languageCode: languageCode,
            vision: true,
          ),
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': dataUrl, 'detail': 'high'},
            },
          ],
        },
      ],
    });

    final response = await _http.post(
      Uri.parse(_openAiEndpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('OpenAI HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw StateError('Empty OpenAI response');
    }
    final message = choices.first as Map<String, dynamic>;
    final content =
        (message['message'] as Map<String, dynamic>)['content'] as String?;
    if (content == null || content.isEmpty) {
      throw StateError('No message content');
    }

    final obj = jsonDecode(content) as Map<String, dynamic>;
    return _parseOpenAiJsonObject(obj);
  }

  static String _textSystemPrompt({String? step, String languageCode = 'en'}) {
    return _characterizationSystemPrompt(
      languageCode: languageCode,
      step: step,
    );
  }

  Future<CharacterizationSuggestion> _suggestTextDirect(
    String trimmed,
    String apiKey, {
    String? step,
    Uint8List? imageBytes,
    String mimeType = 'image/jpeg',
    String locale = 'en',
  }) async {
    final userContent = <Map<String, dynamic>>[];
    if (trimmed.isNotEmpty) {
      userContent.add({'type': 'text', 'text': trimmed});
    }
    if (imageBytes != null) {
      final prepared = _resizeForVision(imageBytes);
      final dataUrl = 'data:$mimeType;base64,${base64Encode(prepared)}';
      userContent.add({
        'type': 'image_url',
        'image_url': {'url': dataUrl, 'detail': 'high'},
      });
    }

    final body = jsonEncode({
      'model': _model,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content': _textSystemPrompt(step: step, languageCode: locale),
        },
        {
          'role': 'user',
          'content': userContent.length == 1 && userContent.first['type'] == 'text'
              ? trimmed
              : userContent,
        },
      ],
    });

    final response = await _http.post(
      Uri.parse(_openAiEndpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('OpenAI HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw StateError('Empty OpenAI response');
    }
    final message = choices.first as Map<String, dynamic>;
    final content =
        (message['message'] as Map<String, dynamic>)['content'] as String?;
    if (content == null || content.isEmpty) {
      throw StateError('No message content');
    }

    final obj = jsonDecode(content) as Map<String, dynamic>;
    return _parseOpenAiJsonObject(obj);
  }

  CharacterizationSuggestion _parseSuggestionPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _parseOpenAiJsonObject(data);
    }
    if (data is String && data.isNotEmpty) {
      final obj = jsonDecode(data) as Map<String, dynamic>;
      return _parseOpenAiJsonObject(obj);
    }
    throw StateError('Unexpected assistant response shape');
  }

  /// Normalizes model JSON into typed fields; prefers `species_common_en` /
  /// `species_scientific_latin` aliases for multilingual pipeline consistency.
  static String? _normalizePhenologicalStage(dynamic raw) {
    if (raw == null) return null;
    final normalized = raw.toString().trim().toLowerCase().replaceAll(' ', '_');
    const synonyms = {
      'bud': 'bud',
      'buds': 'bud',
      'budding': 'bud',
      'ניצן': 'bud',
      'open': 'open',
      'flower': 'open',
      'flowers': 'open',
      'flowering': 'open',
      'bloom': 'open',
      'blooming': 'open',
      'פרח': 'open',
      'פריחה': 'open',
      'fruit': 'fruit',
      'fruits': 'fruit',
      'פרי': 'fruit',
      'פירות': 'fruit',
    };
    return synonyms[normalized];
  }

  static int? _parseHealthScore(dynamic hs) {
    if (hs is int) return hs.clamp(1, 5);
    if (hs is num) return hs.toInt().clamp(1, 5);
    if (hs is String) {
      final parsed = int.tryParse(hs.trim());
      if (parsed != null) return parsed.clamp(1, 5);
    }
    return null;
  }

  static String? _normalizeHazardAssessment(dynamic raw) {
    if (raw == null) return null;
    final normalized = raw.toString().trim().toLowerCase();
    const allowed = {'low', 'medium', 'high'};
    return allowed.contains(normalized) ? normalized : null;
  }

  static String? _normalizeCanopyDensity(dynamic raw) {
    if (raw == null) return null;
    final normalized = raw.toString().trim().toLowerCase();
    const allowed = {'sparse', 'moderate', 'dense'};
    return allowed.contains(normalized) ? normalized : null;
  }

  static List<String>? _parseStructuralIssues(dynamic raw) {
    if (raw is! List) return null;
    const allowed = {
      'dead_branches',
      'leaning',
      'cracks',
      'exposed_roots',
      'cavity',
      'other',
    };
    final normalized = raw
        .map((e) => e.toString().trim().toLowerCase().replaceAll(' ', '_'))
        .where(allowed.contains)
        .toSet()
        .toList();
    return normalized.isEmpty ? null : normalized;
  }

  static CharacterizationSuggestion _parseOpenAiJsonObject(
    Map<String, dynamic> obj,
  ) {
    final health = _parseHealthScore(obj['health_score']);
    final stage = _normalizePhenologicalStage(obj['phenological_stage']);
    final hazard = _normalizeHazardAssessment(obj['hazard_assessment']);
    final canopy = _normalizeCanopyDensity(obj['canopy_density']);
    final structuralIssues = _parseStructuralIssues(obj['structural_issues']);

    final notes = obj['notes'];
    List<String>? stressSymptoms;
    final symptomsRaw = obj['stress_symptoms'];
    if (symptomsRaw is List) {
      const allowed = {
        'chlorosis',
        'necrosis',
        'wilting',
        'leaf_spot',
        'defoliation',
        'gummosis',
        'pest_damage',
        'none',
        'other',
      };
      final normalized = symptomsRaw
          .map((e) => e.toString().trim().toLowerCase())
          .where(allowed.contains)
          .toSet()
          .toList();
      if (normalized.isNotEmpty) {
        stressSymptoms = normalized;
      }
    }

    String? common = obj['species_common_en'] is String
        ? obj['species_common_en'] as String
        : obj['species_common'] is String
        ? obj['species_common'] as String
        : null;
    if (common != null && common.isEmpty) common = null;

    String? scientific = obj['species_scientific_latin'] is String
        ? obj['species_scientific_latin'] as String
        : obj['species_scientific'] is String
        ? obj['species_scientific'] as String
        : null;
    if (scientific != null && scientific.isEmpty) scientific = null;

    String? translated = obj['translated_display_name'] is String
        ? obj['translated_display_name'] as String
        : null;
    if (translated != null && translated.isEmpty) translated = null;

    String? sourceLanguage = obj['source_language'] is String
        ? obj['source_language'] as String
        : null;
    if (sourceLanguage != null && sourceLanguage.isEmpty) sourceLanguage = null;

    double? conf;
    final c = obj['species_confidence'];
    if (c is num) {
      conf = c.toDouble().clamp(0, 1);
    }

    return CharacterizationSuggestion(
      speciesCommon: common,
      speciesScientific: scientific,
      translatedDisplayName: translated,
      sourceLanguage: sourceLanguage,
      speciesConfidence: conf,
      healthScore: health,
      hazardAssessment: hazard,
      canopyDensity: canopy,
      structuralIssues: structuralIssues,
      stressSymptoms: stressSymptoms,
      phenologicalStage: stage,
      notes: notes is String ? notes : null,
    );
  }

  void dispose() {
    _http.close();
  }
}
