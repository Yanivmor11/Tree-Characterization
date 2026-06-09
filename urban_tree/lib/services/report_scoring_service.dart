import '../models/tree_report_draft.dart';

/// Mirrors server scoring in `tree_report_gamification_after_insert` for UI hints.
class ReportScoringService {
  static const int kBasePoints = 10;
  static const int kFlowerPoints = 15;
  static const int kLeafPoints = 10;
  static const int kLandUsePoints = 5;

  static int pointsForDraft(TreeReportDraft draft) {
    var total = kBasePoints;
    if (draft.flowerImages.isNotEmpty) total += kFlowerPoints;
    if (draft.leavesImages.isNotEmpty) total += kLeafPoints;
    if (draft.landTypeAuto) total += kLandUsePoints;
    return total;
  }
}
