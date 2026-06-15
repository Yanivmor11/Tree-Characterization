import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../models/land_use.dart';
import 'gis_fallback_service.dart';

/// GIS land-use classification for the **Private Land Black Box** problem.
///
/// Municipal inventories cover public ROW trees; private-garden specimens are
/// largely invisible to urban forest science. This service auto-tags each
/// report's tenure (`public`, `private`, `kkl`, `abandoned`) from Supabase
/// `land_zones` bounding boxes at GPS capture time.
///
/// **Important:** Zones are axis-aligned bounding boxes, not cadastral polygons.
/// Overlapping boxes are resolved by layered priority (see [classify]).
///
/// **Headless GIS (demo):** Classification runs at GPS capture and submit;
/// map overlays are hidden via [kShowLandUseMapOverlays] for clean presentation UI.
class LandUseService {
  LandUseService({
    SupabaseClient? client,
    GisFallbackService? fallbackService,
  })  : _client = client ?? Supabase.instance.client,
        _fallback = fallbackService ?? GisFallbackService();

  final SupabaseClient _client;
  final GisFallbackService _fallback;

  /// Loads all land-use zones ordered by descending [LandZone.layerPriority].
  ///
  /// Returns an empty list on network or permission errors so reporting can
  /// continue with manual land-type selection (no +5 auto-match points).
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

  /// Classifies a GPS point against overlapping land-use bounding boxes.
  ///
  /// **Parsing / hierarchy rules** (applied when multiple boxes contain the point):
  /// 1. Keep only zones whose bbox contains [point].
  /// 2. Sort by **highest `layer_priority`** — administrative overlays (e.g.
  ///    private enclave at priority 10) beat base corridors (priority 0).
  /// 3. On equal priority, prefer **smallest bounding-box area** (`areaDegrees2`)
  ///    — the most specific parcel wins over a large parent zone.
  ///
  /// Returns `automatic: true` so gamification awards +5 land-use points and
  /// the wizard shows the GIS suggestion hint.
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
      source: LandUseSource.localZone,
    );
  }

  /// Classifies a point using local zones, then OSM fallback, then `public` default.
  Future<LandUseClassification> classifyWithFallback(
    LatLng point,
    List<LandZone> zones,
  ) async {
    final local = classify(point, zones);
    if (local != null) return local;

    final osmType = await _fallback.resolve(point);
    if (osmType != null) {
      return LandUseClassification(
        type: osmType,
        automatic: true,
        source: LandUseSource.osm,
      );
    }

    return LandUseClassification(
      type: LandUseType.public,
      automatic: false,
      source: LandUseSource.defaultSource,
    );
  }
}
