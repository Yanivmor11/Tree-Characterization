import 'package:supabase_flutter/supabase_flutter.dart';

class PestHotspot {
  PestHotspot({
    required this.id,
    required this.pestCode,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    required this.severity,
  });

  final String id;
  final String pestCode;
  final String label;
  final double latitude;
  final double longitude;
  final double radiusM;
  final int severity;

  static PestHotspot? fromRow(Map<String, dynamic> row) {
    final id = row['id']?.toString();
    if (id == null) return null;
    return PestHotspot(
      id: id,
      pestCode: row['pest_code'] as String? ?? '',
      label: row['label'] as String? ?? '',
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      radiusM: (row['radius_m'] as num?)?.toDouble() ?? 500,
      severity: (row['severity'] as num?)?.toInt() ?? 1,
    );
  }
}

class PestHotspotService {
  PestHotspotService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<PestHotspot>> fetchActive() async {
    try {
      final rows = await _client
          .from('pest_hotspots')
          .select(
            'id, pest_code, label, latitude, longitude, radius_m, severity',
          )
          .eq('active', true);
      final out = <PestHotspot>[];
      for (final row in (rows as List<dynamic>)) {
        final h = PestHotspot.fromRow(Map<String, dynamic>.from(row as Map));
        if (h != null) out.add(h);
      }
      return out;
    } catch (_) {
      return [];
    }
  }
}
