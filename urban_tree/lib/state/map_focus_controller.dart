import 'package:flutter/foundation.dart';

import '../models/tree_report_row.dart';

/// Coordinates cross-tab navigation to a tree pin on [MapScreen].
class MapFocusController extends ChangeNotifier {
  TreeReportRow? _pending;

  TreeReportRow? get pending => _pending;

  void focusOn(TreeReportRow row) {
    _pending = row;
    notifyListeners();
  }

  void clear() {
    if (_pending == null) return;
    _pending = null;
    notifyListeners();
  }
}
