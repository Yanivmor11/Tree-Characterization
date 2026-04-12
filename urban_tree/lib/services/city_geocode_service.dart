import 'dart:convert';

import 'package:http/http.dart' as http;

/// Reverse geocode for profile city (Nominatim — respect usage policy in production).
class CityGeocodeService {
  CityGeocodeService({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  static final _uri = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=jsonv2',
  );

  Future<CityGeocodeResult?> reverse(double latitude, double longitude) async {
    final uri = _uri.replace(queryParameters: {
      ..._uri.queryParameters,
      'lat': latitude.toString(),
      'lon': longitude.toString(),
    });
    final res = await _http.get(
      uri,
      headers: const {
        'User-Agent': 'UrbanTree/1.0 (https://github.com/)',
      },
    );
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    final map = jsonDecode(res.body) as Map<String, dynamic>?;
    if (map == null) return null;
    final addr = map['address'] as Map<String, dynamic>?;
    if (addr == null) return null;
    final label = addr['city'] as String? ??
        addr['town'] as String? ??
        addr['village'] as String? ??
        addr['municipality'] as String? ??
        addr['state'] as String?;
    if (label == null || label.isEmpty) return null;
    final slug = _slug(label);
    return CityGeocodeResult(cityLabel: label, citySlug: slug);
  }

  void dispose() {
    _http.close();
  }

  static String _slug(String label) {
    final lower = label.toLowerCase().trim();
    return lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

class CityGeocodeResult {
  CityGeocodeResult({required this.cityLabel, required this.citySlug});

  final String cityLabel;
  final String citySlug;
}
