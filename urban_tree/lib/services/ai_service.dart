import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';

/// Suggestions for data quality; user must confirm before applying.
class CharacterizationSuggestion {
  CharacterizationSuggestion({
    this.speciesCommon,
    this.speciesScientific,
    this.speciesConfidence,
    this.healthScore,
    this.phenologicalStage,
    this.notes,
  });

  final String? speciesCommon;
  final String? speciesScientific;
  final double? speciesConfidence;
  final int? healthScore;
  final String? phenologicalStage;
  final String? notes;

  Map<String, dynamic> toAuditJson() {
    return {
      if (speciesCommon != null) 'species_common': speciesCommon,
      if (speciesScientific != null) 'species_scientific': speciesScientific,
      if (speciesConfidence != null) 'species_confidence': speciesConfidence,
      if (healthScore != null) 'health_score': healthScore,
      if (phenologicalStage != null) 'phenological_stage': phenologicalStage,
      if (notes != null) 'notes': notes,
    };
  }
}

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

  Future<CharacterizationSuggestion> suggestFromTreeImage({
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    final prepared = _resizeForVision(imageBytes);
    final b64 = base64Encode(prepared);

    if (kIsWeb) {
      return _suggestVisionViaEdge(b64, mimeType);
    }

    final key = AppEnv.openAiApiKey.trim();
    if (key.isEmpty) {
      return _suggestVisionViaEdge(b64, mimeType);
    }

    return _suggestVisionDirect(b64, mimeType, key);
  }

  Future<CharacterizationSuggestion> suggestFromResidentText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return CharacterizationSuggestion();
    }

    if (kIsWeb) {
      return _suggestTextViaEdge(trimmed);
    }

    final key = AppEnv.openAiApiKey.trim();
    if (key.isEmpty) {
      return _suggestTextViaEdge(trimmed);
    }

    return _suggestTextDirect(trimmed, key);
  }

  Future<String> treeInsightTip({
    required Map<String, dynamic> context,
  }) async {
    try {
      final res = await _supabase.functions.invoke(
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
    } on FunctionException catch (e) {
      throw StateError('Insights failed: ${e.details ?? e.reasonPhrase}');
    }
    return '';
  }

  Future<CharacterizationSuggestion> _suggestVisionViaEdge(
    String b64,
    String mimeType,
  ) async {
    try {
      final res = await _supabase.functions.invoke(
        _edgeSuggest,
        body: {'image_base64': b64, 'mime_type': mimeType},
      );
      if (res.status != 200) {
        throw StateError('Assistant proxy HTTP ${res.status}: ${res.data}');
      }
      return _parseSuggestionPayload(res.data);
    } on FunctionException catch (e) {
      throw StateError('Assistant proxy failed: ${e.details ?? e.reasonPhrase}');
    }
  }

  Future<CharacterizationSuggestion> _suggestTextViaEdge(String trimmed) async {
    try {
      final res = await _supabase.functions.invoke(
        _edgeSuggest,
        body: {'text': trimmed},
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
  ) async {
    final dataUrl = 'data:$mimeType;base64,$b64';
    final body = jsonEncode({
      'model': _model,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content':
              'You assist urban tree citizen science. Output ONLY valid JSON with keys: '
              'species_common (short common name or null), species_scientific (Latin binomial or null), '
              'species_confidence (number 0-1 or null), health_score (integer 1-5 or null), '
              'phenological_stage (string "bud", "open", "fruit", or null), '
              'notes (short Hebrew summary of reasoning or null). '
              'Use null when uncertain.',
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': dataUrl, 'detail': 'low'},
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

  Future<CharacterizationSuggestion> _suggestTextDirect(
    String trimmed,
    String apiKey,
  ) async {
    final body = jsonEncode({
      'model': _model,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content':
              'You assist urban tree citizen science. Given a resident description in any language, '
              'output ONLY valid JSON with keys: species_common (or null), species_scientific (or null), '
              'species_confidence (0-1 or null), health_score (integer 1-5 or null), '
              'phenological_stage (string "bud", "open", "fruit", or null), '
              'notes (short Hebrew summary of reasoning or null). '
              'Use null when uncertain.',
        },
        {'role': 'user', 'content': trimmed},
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

  static CharacterizationSuggestion _parseOpenAiJsonObject(
    Map<String, dynamic> obj,
  ) {
    int? health;
    final hs = obj['health_score'];
    if (hs is int) {
      health = hs.clamp(1, 5);
    } else if (hs is num) {
      health = hs.toInt().clamp(1, 5);
    }

    String? stage;
    final st = obj['phenological_stage'];
    if (st is String) {
      const allowed = {'bud', 'open', 'fruit'};
      if (allowed.contains(st)) stage = st;
    }

    final notes = obj['notes'];

    String? common = obj['species_common'] is String
        ? obj['species_common'] as String
        : null;
    if (common != null && common.isEmpty) common = null;

    String? scientific = obj['species_scientific'] is String
        ? obj['species_scientific'] as String
        : null;
    if (scientific != null && scientific.isEmpty) scientific = null;

    double? conf;
    final c = obj['species_confidence'];
    if (c is num) {
      conf = c.toDouble().clamp(0, 1);
    }

    return CharacterizationSuggestion(
      speciesCommon: common,
      speciesScientific: scientific,
      speciesConfidence: conf,
      healthScore: health,
      phenologicalStage: stage,
      notes: notes is String ? notes : null,
    );
  }

  void dispose() {
    _http.close();
  }
}
