import '../core/constants.dart';
import '../core/env.dart';
import '../models/tree_report_draft.dart';

/// Reasons the client blocks report submission before reaching the server.
enum ReportSubmitBlockReason {
  needsWholeTreePhoto,
  needsLeavesPhoto,
  needsFlowerMeta,
  gpsAccuracyTooLow,
}

/// **Tier 1** client-side validation — hard submit blocks aligned with
/// [MAPPING_PROTOCOL.md] physiological completeness requirements.
///
/// This validator enforces the minimum data granularity needed for urban
/// forest physiology research: whole-tree context, leaf detail, and coherent
/// flower metadata when reproductive structures are photographed.
///
/// **GPS note (demo):** [kTargetLocationAccuracyMeters] is **50 m** for the
/// presentation release (production target: [kProductionLocationAccuracyMeters]).
/// When [AppEnv.blockSubmitIfLowAccuracy] is true, submissions above that
/// threshold are blocked here. Server still enforces 2 m; [PresentationFallbackService]
/// provides mock submit on failure during live demos.
abstract final class TreeReportValidator {
  /// Returns the first blocking reason, or null if submit may proceed.
  ///
  /// Checks run in protocol order: whole tree → flower metadata → leaves → GPS.
  static ReportSubmitBlockReason? firstBlock(TreeReportDraft draft) {
    if (draft.wholeTreeImages.isEmpty) {
      return ReportSubmitBlockReason.needsWholeTreePhoto;
    }
    if (draft.flowerImages.isNotEmpty &&
        (draft.phenologicalStage == null || draft.flowerAbundance == null)) {
      return ReportSubmitBlockReason.needsFlowerMeta;
    }
    if (draft.leavesImages.isEmpty) {
      return ReportSubmitBlockReason.needsLeavesPhoto;
    }
    if (AppEnv.blockSubmitIfLowAccuracy &&
        draft.accuracyMeters != null &&
        draft.accuracyMeters! > kTargetLocationAccuracyMeters) {
      return ReportSubmitBlockReason.gpsAccuracyTooLow;
    }
    return null;
  }
}
