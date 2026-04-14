import '../models/tree_report_draft.dart';

/// Mirrors server scoring in `tree_report_gamification_after_insert` for UI hints.
class ReportScoringService {
  static const int kFullReportPoints = 25;

  static int pointsForDraft(TreeReportDraft _) {
    return kFullReportPoints;
  }
}
