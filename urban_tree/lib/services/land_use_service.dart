import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/land_use.dart';

/// Loads GIS boxes from Supabase and classifies a point using layered priority.
class LandUseService {
  LandUseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<LandZone>> fetchZones() async {
    try {
      final rows = await _client
          .from('land_zones')
          .select(
            'id, land_type, label, min_lat, max_lat, min_lon, max_lon, layer_priority',
          )
          .order('layer_priority', ascending: false);
      final list = <LandZone>[];
      for (final row in (rows as List<dynamic>)) {
        final zone = LandZone.fromRow(Map<String, dynamic>.from(row as Map));
        if (zone != null) list.add(zone);
      }
      return list;
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Smart layering: highest `layer_priority`, then smallest bounding box (specific parcel).
  LandUseClassification? classify(LatLng point, List<LandZone> zones) {
    final matches = zones.where((z) => z.contains(point)).toList();
    if (matches.isEmpty) return null;

    matches.sort((a, b) {
      final p = b.layerPriority.compareTo(a.layerPriority);
      if (p != 0) return p;
      return a.areaDegrees2.compareTo(b.areaDegrees2);
    });

    final best = matches.first;
    return LandUseClassification(
      type: best.type,
      automatic: true,
      zoneLabel: best.label,
    );
  }
}
