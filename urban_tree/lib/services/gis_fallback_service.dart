import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/land_use.dart';

/// Nationwide Israel GIS fallback when Supabase `land_zones` bboxes miss a point.
///
/// Uses OpenStreetMap Overpass (nearby features) then Nominatim reverse geocode.
/// Best-effort only — never blocks reporting on network failure.
class GisFallbackService {
  GisFallbackService({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  static final _overpassUri = Uri.parse('https://overpass-api.de/api/interpreter');
  static final _nominatimBase = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=jsonv2',
  );
  static const _userAgent = 'UrbanTree/1.0 (https://github.com/)';
  static const _requestTimeout = Duration(seconds: 8);

  /// Israel territory bounding box (approximate, includes Golan and Eilat).
  static const double israelMinLat = 29.4;
  static const double israelMaxLat = 33.4;
  static const double israelMinLon = 34.2;
  static const double israelMaxLon = 35.9;

  static bool isInIsrael(LatLng point) =>
      point.latitude >= israelMinLat &&
      point.latitude <= israelMaxLat &&
      point.longitude >= israelMinLon &&
      point.longitude <= israelMaxLon;

  /// Resolves land use from OSM when local zones miss. Returns `null` on failure.
  Future<LandUseType?> resolve(LatLng point) async {
    if (!isInIsrael(point)) return null;

    try {
      final overpassType = await _resolveFromOverpass(point);
      if (overpassType != null) return overpassType;

      return await _resolveFromNominatim(point);
    } catch (_) {
      return null;
    }
  }

  void dispose() => _http.close();

  Future<LandUseType?> _resolveFromOverpass(LatLng point) async {
    final lat = point.latitude;
    final lon = point.longitude;
    final query = '''
[out:json][timeout:8];
(
  way(around:75,$lat,$lon)["landuse"];
  way(around:75,$lat,$lon)["leisure"];
  way(around:75,$lat,$lon)["natural"];
  way(around:75,$lat,$lon)["boundary"];
  way(around:75,$lat,$lon)["operator"];
  node(around:75,$lat,$lon)["landuse"];
  node(around:75,$lat,$lon)["leisure"];
  node(around:75,$lat,$lon)["natural"];
  relation(around:75,$lat,$lon)["boundary"];
);
out tags;
''';

    final response = await _http
        .post(
          _overpassUri,
          headers: const {'User-Agent': _userAgent},
          body: {'data': query},
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final elements = decoded['elements'];
    if (elements is! List<dynamic> || elements.isEmpty) return null;

    final tagMaps = <Map<String, String>>[];
    for (final element in elements) {
      if (element is! Map<String, dynamic>) continue;
      final tags = element['tags'];
      if (tags is Map<String, dynamic>) {
        tagMaps.add(tags.map((k, v) => MapEntry(k.toString(), v.toString())));
      }
    }

    return _classifyFromTags(tagMaps);
  }

  Future<LandUseType?> _resolveFromNominatim(LatLng point) async {
    final uri = _nominatimBase.replace(queryParameters: {
      ..._nominatimBase.queryParameters,
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'extratags': '1',
    });

    final response = await _http
        .get(uri, headers: const {'User-Agent': _userAgent})
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    final map = jsonDecode(response.body);
    if (map is! Map<String, dynamic>) return null;

    final tags = <Map<String, String>>[];
    final extratags = map['extratags'];
    if (extratags is Map<String, dynamic>) {
      tags.add(extratags.map((k, v) => MapEntry(k.toString(), v.toString())));
    }
    final type = map['type']?.toString();
    final category = map['category']?.toString();
    if (type != null && category != null) {
      tags.add({category: type});
    }

    final classified = _classifyFromTags(tags);
    return classified ?? LandUseType.public;
  }

  static LandUseType? _classifyFromTags(List<Map<String, String>> tagMaps) {
    if (tagMaps.isEmpty) return null;

    var sawAbandoned = false;
    var sawKkl = false;
    var sawPrivate = false;
    var sawPublic = false;

    for (final tags in tagMaps) {
      if (_isAbandoned(tags)) sawAbandoned = true;
      if (_isKkl(tags)) sawKkl = true;
      if (_isPrivate(tags)) sawPrivate = true;
      if (_isPublic(tags)) sawPublic = true;
    }

    if (sawAbandoned) return LandUseType.abandoned;
    if (sawKkl) return LandUseType.kkl;
    if (sawPrivate) return LandUseType.private;
    if (sawPublic) return LandUseType.public;
    return null;
  }

  static bool _isAbandoned(Map<String, String> tags) {
    final landuse = tags['landuse']?.toLowerCase();
    if (landuse == 'brownfield' || landuse == 'greenfield') return true;
    if (tags.containsKey('disused') || tags.containsKey('abandoned')) return true;
    return tags['abandoned:landuse'] != null;
  }

  static bool _isKkl(Map<String, String> tags) {
    final operator = (tags['operator'] ?? '').toLowerCase();
    if (operator.contains('kkl') ||
        operator.contains('jnf') ||
        operator.contains('קק') ||
        operator.contains('jewish national fund')) {
      return true;
    }

    final landuse = tags['landuse']?.toLowerCase();
    if (landuse == 'forest') return true;

    final natural = tags['natural']?.toLowerCase();
    if (natural == 'wood' || natural == 'scrub') return true;

    final leisure = tags['leisure']?.toLowerCase();
    if (leisure == 'nature_reserve') return true;

    final boundary = tags['boundary']?.toLowerCase();
    return boundary == 'national_park' || boundary == 'protected_area';
  }

  static bool _isPrivate(Map<String, String> tags) {
    if (tags.containsKey('building')) return true;

    const privateLanduse = {
      'residential',
      'farmland',
      'farmyard',
      'orchard',
      'vineyard',
      'greenhouse_horticulture',
      'commercial',
      'industrial',
      'retail',
      'construction',
    };
    final landuse = tags['landuse']?.toLowerCase();
    return landuse != null && privateLanduse.contains(landuse);
  }

  static bool _isPublic(Map<String, String> tags) {
    const publicLanduse = {
      'grass',
      'recreation_ground',
      'allotments',
      'cemetery',
      'religious',
      'village_green',
      'public',
    };
    final landuse = tags['landuse']?.toLowerCase();
    if (landuse != null && publicLanduse.contains(landuse)) return true;

    const publicLeisure = {
      'park',
      'garden',
      'playground',
      'pitch',
      'dog_park',
      'track',
    };
    final leisure = tags['leisure']?.toLowerCase();
    if (leisure != null && publicLeisure.contains(leisure)) return true;

    final boundary = tags['boundary']?.toLowerCase();
    return boundary == 'administrative' || boundary == 'political';
  }
}
