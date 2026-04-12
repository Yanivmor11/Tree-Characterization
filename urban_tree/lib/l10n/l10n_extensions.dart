import '../models/land_use.dart';
import '../models/tree_report_draft.dart';
import 'app_localizations.dart';

extension UrbanTreeL10n on AppLocalizations {
  String landUseTypeLabel(LandUseType t) => switch (t) {
        LandUseType.public => landUsePublic,
        LandUseType.private => landUsePrivate,
        LandUseType.kkl => landUseKkl,
        LandUseType.abandoned => landUseAbandoned,
      };

  String layerTintName(LandUseType t) => switch (t) {
        LandUseType.public => tintBlue,
        LandUseType.private => tintAmber,
        LandUseType.kkl => tintGreen,
        LandUseType.abandoned => tintBrown,
      };

  String structuralIssueLabel(StructuralIssue i) => switch (i) {
        StructuralIssue.deadBranches => structuralDeadBranches,
        StructuralIssue.leaning => structuralLeaning,
        StructuralIssue.cracks => structuralCracks,
        StructuralIssue.exposedRoots => structuralExposedRoots,
        StructuralIssue.cavity => structuralCavity,
        StructuralIssue.other => structuralOther,
      };

  String canopyDensityLabel(CanopyDensity d) => switch (d) {
        CanopyDensity.sparse => canopySparse,
        CanopyDensity.moderate => canopyModerate,
        CanopyDensity.dense => canopyDense,
      };

  String phenologicalStageLabel(PhenologicalStage s) => switch (s) {
        PhenologicalStage.bud => stageBud,
        PhenologicalStage.open => stageOpen,
        PhenologicalStage.fruit => stageFruit,
      };

  String flowerAbundanceLabel(FlowerAbundance a) => switch (a) {
        FlowerAbundance.low => abundanceLow,
        FlowerAbundance.medium => abundanceMedium,
        FlowerAbundance.high => abundanceHigh,
      };

  String leafConditionLabel(LeafCondition c) => switch (c) {
        LeafCondition.healthy => conditionHealthy,
        LeafCondition.stressed => conditionStressed,
      };

  String damageExtentLabel(DamageExtent e) => switch (e) {
        DamageExtent.minimal => damageMinimal,
        DamageExtent.low => damageLow,
        DamageExtent.moderate => damageModerate,
        DamageExtent.high => damageHigh,
      };
}
