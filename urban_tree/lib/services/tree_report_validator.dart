import '../models/tree_report_draft.dart';

/// Reasons the client blocks report submission before reaching the server.
enum ReportSubmitBlockReason {
  needsWholeTreePhoto,
  needsFlowerMeta,
}

/// **Tier 1** client-side validation — only step 1 (whole-tree photo) is required.
/// Steps 2 (flower/fruit) and 3 (leaves) are optional; flower metadata is required
/// only when flower photos were added.
abstract final class TreeReportValidator {
  static ReportSubmitBlockReason? firstBlock(TreeReportDraft draft) {
    if (draft.wholeTreeImages.isEmpty) {
      return ReportSubmitBlockReason.needsWholeTreePhoto;
    }
    if (draft.flowerImages.isNotEmpty &&
        (draft.phenologicalStage == null || draft.flowerAbundance == null)) {
      return ReportSubmitBlockReason.needsFlowerMeta;
    }
    return null;
  }
}
