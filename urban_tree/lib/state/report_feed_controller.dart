import 'package:flutter/foundation.dart';

import '../models/tree_report_row.dart';
import '../services/tree_report_repository.dart';

class ReportFeedController extends ChangeNotifier {
  ReportFeedController({TreeReportRepository? repository})
      : _repository = repository ?? TreeReportRepository();

  final TreeReportRepository _repository;

  List<TreeReportRow> _recentReports = [];
  int _totalReports = 0;
  bool _loading = false;

  List<TreeReportRow> get recentReports => _recentReports;
  int get totalReports => _totalReports;
  bool get loading => _loading;

  Future<void> loadInitial({int limit = 500}) async {
    _loading = true;
    final rows = await _repository.fetchRecentReports(limit: limit);
    final total = await _repository.countReports();
    _recentReports = rows;
    _totalReports = total;
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshCount() async {
    _totalReports = await _repository.countReports();
    notifyListeners();
  }

  Future<void> recordSubmittedReport(String reportId) async {
    final row = await _repository.fetchReportById(reportId);
    if (row != null) {
      _mergeReport(row);
    }
    _totalReports += 1;
    notifyListeners();
  }

  void mergeRealtimeReport(TreeReportRow row) {
    _mergeReport(row);
    notifyListeners();
  }

  void _mergeReport(TreeReportRow row) {
    _recentReports = [row, ..._recentReports.where((r) => r.id != row.id)];
  }
}
