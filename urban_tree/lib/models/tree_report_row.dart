import 'land_use.dart';

/// Row from `tree_reports` for lists, map pins, and CSV export.
class TreeReportRow {
  TreeReportRow({
    required this.id,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.landType,
    required this.landTypeAuto,
    required this.healthScore,
    required this.canopyDensity,
    required this.structuralIssues,
    required this.wholeTreeImageUrls,
    required this.flowerImageUrls,
    this.phenologicalStage,
    this.flowerAbundance,
    required this.leavesImageUrls,
    required this.leafCondition,
    required this.damageExtent,
    this.species,
    this.speciesScientific,
  });

  final String id;
  final DateTime createdAt;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final LandUseType landType;
  final bool landTypeAuto;
  final int healthScore;
  final String canopyDensity;
  final List<String> structuralIssues;
  final List<String> wholeTreeImageUrls;
  final List<String> flowerImageUrls;
  final String? phenologicalStage;
  final String? flowerAbundance;
  final List<String> leavesImageUrls;
  final String leafCondition;
  final String damageExtent;
  final String? species;
  final String? speciesScientific;

  static TreeReportRow? fromMap(Map<String, dynamic> row) {
    final id = row['id']?.toString();
    if (id == null) return null;
    final land = LandUseType.fromStorage(row['land_type'] as String?);
    if (land == null) return null;
    final createdRaw = row['created_at'];
    DateTime createdAt;
    if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }
    return TreeReportRow(
      id: id,
      createdAt: createdAt,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      accuracyMeters: (row['accuracy_meters'] as num?)?.toDouble(),
      landType: land,
      landTypeAuto: row['land_type_auto'] as bool? ?? false,
      healthScore: (row['health_score'] as num).toInt(),
      canopyDensity: row['canopy_density'] as String? ?? '',
      structuralIssues: _stringList(row['structural_issues']),
      wholeTreeImageUrls: _stringList(row['whole_tree_image_urls']),
      flowerImageUrls: _stringList(row['flower_image_urls']),
      phenologicalStage: row['phenological_stage'] as String?,
      flowerAbundance: row['flower_abundance'] as String?,
      leavesImageUrls: _stringList(row['leaves_image_urls']),
      leafCondition: row['leaf_condition'] as String? ?? '',
      damageExtent: row['damage_extent'] as String? ?? '',
      species: row['species'] as String?,
      speciesScientific: row['species_scientific'] as String?,
    );
  }

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
