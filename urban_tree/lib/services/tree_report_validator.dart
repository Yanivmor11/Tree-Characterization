import '../core/constants.dart';
import '../core/env.dart';
import '../models/tree_report_draft.dart';

enum ReportSubmitBlockReason {
  needsWholeTreePhoto,
  needsLeavesPhoto,
  needsFlowerMeta,
  gpsAccuracyTooLow,
}

/// Client-side checks aligned with the project mapping protocol (see repository `MAPPING_PROTOCOL.md`).
abstract final class TreeReportValidator {
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
