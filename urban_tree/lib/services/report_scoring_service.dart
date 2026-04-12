import '../models/tree_report_draft.dart';

/// Mirrors server scoring in `tree_report_gamification_after_insert` for UI hints.
class ReportScoringService {
  static int pointsForDraft(TreeReportDraft draft) {
    var total = 10;
    if (draft.flowerImages.isNotEmpty) total += 15;
    if (draft.leavesImages.length >= 2) total += 10;
    if (draft.landTypeAuto) total += 5;
    return total;
  }
}
