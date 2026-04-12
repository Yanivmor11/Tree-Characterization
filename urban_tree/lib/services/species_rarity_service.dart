import 'package:supabase_flutter/supabase_flutter.dart';

/// Loads [species_report_counts] for “rare species” map hints.
class SpeciesRarityService {
  SpeciesRarityService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Key: lowercased trimmed species label from reports.
  Future<Map<String, int>> fetchCounts() async {
    try {
      final rows = await _client
          .from('species_report_counts')
          .select('species_key, report_count');
      final map = <String, int>{};
      for (final row in (rows as List<dynamic>)) {
        final m = Map<String, dynamic>.from(row as Map);
        final k = m['species_key'] as String?;
        final c = m['report_count'];
        if (k == null || c == null) continue;
        map[k] = (c as num).toInt();
      }
      return map;
    } catch (_) {
      return {};
    }
  }
}
