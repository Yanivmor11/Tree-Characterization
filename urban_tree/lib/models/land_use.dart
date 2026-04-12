import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum LandUseType {
  public('public'),
  private('private'),
  kkl('kkl'),
  abandoned('abandoned');

  const LandUseType(this.storageValue);
  final String storageValue;

  static LandUseType? fromStorage(String? value) {
    if (value == null) return null;
    for (final t in LandUseType.values) {
      if (t.storageValue == value) return t;
    }
    return null;
  }

  String get displayLabel => switch (this) {
        LandUseType.public => 'Public',
        LandUseType.private => 'Private',
        LandUseType.kkl => 'KKL',
        LandUseType.abandoned => 'Abandoned',
      };

  Color layerColor(double opacity) => switch (this) {
        LandUseType.public => Colors.blue.withValues(alpha: opacity),
        LandUseType.private => Colors.amber.withValues(alpha: opacity),
        LandUseType.kkl => Colors.green.withValues(alpha: opacity),
        LandUseType.abandoned => Colors.brown.withValues(alpha: opacity),
      };
}

/// Axis-aligned zone from Supabase `land_zones` (smart layering via priority + area).
class LandZone {
  LandZone({
    required this.id,
    required this.type,
    required this.label,
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
    required this.layerPriority,
  });

  final String id;
  final LandUseType type;
  final String? label;
  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;
  final int layerPriority;

  double get areaDegrees2 =>
      (maxLat - minLat).abs() * (maxLon - minLon).abs();

  bool contains(LatLng p) =>
      p.latitude >= minLat &&
      p.latitude <= maxLat &&
      p.longitude >= minLon &&
      p.longitude <= maxLon;

  List<LatLng> get boundingPolygon => [
        LatLng(minLat, minLon),
        LatLng(minLat, maxLon),
        LatLng(maxLat, maxLon),
        LatLng(maxLat, minLon),
      ];

  static LandZone? fromRow(Map<String, dynamic> row) {
    final type = LandUseType.fromStorage(row['land_type'] as String?);
    if (type == null) return null;
    final id = row['id']?.toString();
    if (id == null) return null;
    return LandZone(
      id: id,
      type: type,
      label: row['label'] as String?,
      minLat: (row['min_lat'] as num).toDouble(),
      maxLat: (row['max_lat'] as num).toDouble(),
      minLon: (row['min_lon'] as num).toDouble(),
      maxLon: (row['max_lon'] as num).toDouble(),
      layerPriority: (row['layer_priority'] as num?)?.toInt() ?? 0,
    );
  }
}

class LandUseClassification {
  LandUseClassification({
    required this.type,
    required this.automatic,
    this.zoneLabel,
  });

  final LandUseType type;
  final bool automatic;
  final String? zoneLabel;
}
