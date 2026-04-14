import 'package:image_picker/image_picker.dart';

import '../core/constants.dart';
import 'land_use.dart';

enum CanopyDensity { sparse, moderate, dense }

enum StructuralIssue {
  deadBranches,
  leaning,
  cracks,
  exposedRoots,
  cavity,
  other,
}

extension StructuralIssueLabel on StructuralIssue {
  String get label => switch (this) {
        StructuralIssue.deadBranches => 'Dead branches',
        StructuralIssue.leaning => 'Leaning',
        StructuralIssue.cracks => 'Cracks / splits',
        StructuralIssue.exposedRoots => 'Exposed roots',
        StructuralIssue.cavity => 'Cavity / decay',
        StructuralIssue.other => 'Other',
      };

  String get storageValue => switch (this) {
        StructuralIssue.deadBranches => 'dead_branches',
        StructuralIssue.leaning => 'leaning',
        StructuralIssue.cracks => 'cracks',
        StructuralIssue.exposedRoots => 'exposed_roots',
        StructuralIssue.cavity => 'cavity',
        StructuralIssue.other => 'other',
      };
}

enum PhenologicalStage { bud, open, fruit }

extension PhenologicalStageStorage on PhenologicalStage {
  String get storageValue => switch (this) {
        PhenologicalStage.bud => 'bud',
        PhenologicalStage.open => 'open',
        PhenologicalStage.fruit => 'fruit',
      };
}

enum FlowerAbundance { low, medium, high }

extension FlowerAbundanceStorage on FlowerAbundance {
  String get storageValue => switch (this) {
        FlowerAbundance.low => 'low',
        FlowerAbundance.medium => 'medium',
        FlowerAbundance.high => 'high',
      };
}

enum LeafCondition { healthy, stressed }

enum DamageExtent { minimal, low, moderate, high }
enum HazardAssessment { low, medium, high }

extension DamageExtentLabel on DamageExtent {
  String get label => switch (this) {
        DamageExtent.minimal => 'Minimal (<5%)',
        DamageExtent.low => 'Low',
        DamageExtent.moderate => 'Moderate',
        DamageExtent.high => 'High (>50%)',
      };

  String get storageValue => switch (this) {
        DamageExtent.minimal => 'minimal',
        DamageExtent.low => 'low',
        DamageExtent.moderate => 'moderate',
        DamageExtent.high => 'high',
      };
}

extension HazardAssessmentStorage on HazardAssessment {
  String get storageValue => switch (this) {
        HazardAssessment.low => 'low',
        HazardAssessment.medium => 'medium',
        HazardAssessment.high => 'high',
      };
}

enum StressSymptom {
  chlorosis,
  necrosis,
  wilting,
  leafSpot,
  defoliation,
  gummosis,
  pestDamage,
  none,
  other,
}

extension StressSymptomStorage on StressSymptom {
  String get storageValue => switch (this) {
        StressSymptom.chlorosis => 'chlorosis',
        StressSymptom.necrosis => 'necrosis',
        StressSymptom.wilting => 'wilting',
        StressSymptom.leafSpot => 'leaf_spot',
        StressSymptom.defoliation => 'defoliation',
        StressSymptom.gummosis => 'gummosis',
        StressSymptom.pestDamage => 'pest_damage',
        StressSymptom.none => 'none',
        StressSymptom.other => 'other',
      };
}

extension CanopyDensityStorage on CanopyDensity {
  String get storageValue => switch (this) {
        CanopyDensity.sparse => 'sparse',
        CanopyDensity.moderate => 'moderate',
        CanopyDensity.dense => 'dense',
      };
}

/// In-memory state for the 3-step protocol (MAPPING_PROTOCOL.md).
class TreeReportDraft {
  TreeReportDraft({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.landType,
    required this.landTypeAuto,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  LandUseType landType;
  bool landTypeAuto;

  final List<XFile> wholeTreeImages = [];
  /// Localized/common display value for UI text fields.
  String? speciesDisplayName;
  /// Canonical English common name persisted to database.
  String? speciesCommon;
  /// Canonical Latin scientific name persisted to database.
  String? speciesScientific;
  double? speciesConfidence;
  /// Optional audit payload persisted with the report (vision/text AI output).
  Map<String, dynamic>? aiSuggestionAudit;
  int healthScore = 3;
  CanopyDensity canopyDensity = CanopyDensity.moderate;
  final Set<StructuralIssue> structuralIssues = {};

  final List<XFile> flowerImages = [];
  PhenologicalStage? phenologicalStage;
  FlowerAbundance? flowerAbundance;

  final List<XFile> leavesImages = [];
  LeafCondition leafCondition = LeafCondition.healthy;
  DamageExtent damageExtent = DamageExtent.minimal;
  HazardAssessment hazardAssessment = HazardAssessment.low;
  final Set<StressSymptom> stressSymptoms = {};

  bool get hasLowAccuracyWarning =>
      accuracyMeters != null &&
      accuracyMeters! > kTargetLocationAccuracyMeters;
}
