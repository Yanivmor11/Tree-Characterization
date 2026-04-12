import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

const Distance _distance = Distance();

double metersBetween(LatLng a, LatLng b) {
  return _distance.as(LengthUnit.Meter, a, b);
}

/// Haversine distance in meters (consistent with latlong2 for single points).
double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  const earth = 6371000.0;
  final p1 = lat1 * math.pi / 180;
  final p2 = lat2 * math.pi / 180;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final s1 = math.sin(dLat / 2);
  final s2 = math.sin(dLon / 2);
  final h = s1 * s1 + math.cos(p1) * math.cos(p2) * s2 * s2;
  return 2 * earth * math.asin(math.min(1, math.sqrt(h)));
}
