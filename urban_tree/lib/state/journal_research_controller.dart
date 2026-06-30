import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/land_use.dart';
import '../models/tree_report_row.dart';
import '../services/data_quality_service.dart';
import '../services/tree_report_repository.dart';

enum JournalResearchMode { reports, quality }

class JournalResearchController extends ChangeNotifier {
  JournalResearchController({
    TreeReportRepository? repository,
    DataQualityService? qualityService,
  })  : _repository = repository ?? TreeReportRepository(),
        _quality = qualityService ?? DataQualityService() {
    speciesController.addListener(_onSpeciesTextChanged);
  }

  final TreeReportRepository _repository;
  final DataQualityService _quality;
  final speciesController = TextEditingController();

  JournalResearchMode mode = JournalResearchMode.reports;
  DateTime? fromDate;
  DateTime? toDate;
  String speciesFilter = '';
  LandUseType? landUseFilter;
  int? healthScoreFilter;

  List<TreeReportRow> filteredReports = [];
  List<DataQualityFlag> qualityFlags = [];
  bool loading = false;
  bool refreshing = false;
  String? error;

  Timer? _speciesDebounce;
  int _loadGeneration = 0;

  bool get hasDateRangeError =>
      fromDate != null &&
      toDate != null &&
      fromDate!.isAfter(toDate!);

  int get observationCount => filteredReports.length;

  int get distinctSpeciesCount => filteredReports
      .map((r) => r.speciesScientific ?? r.species)
      .whereType<String>()
      .where((s) => s.trim().isNotEmpty)
      .toSet()
      .length;

  List<DataQualityFlag> get filteredQualityFlags {
    return qualityFlags.where((flag) {
      final created = flag.createdAt.toLocal();
      if (fromDate != null && created.isBefore(fromDate!)) return false;
      if (toDate != null && created.isAfter(toDate!)) return false;
      return true;
    }).toList();
  }

  Future<void> loadInitial() => _load(initial: true);

  Future<void> reload() => _load(initial: false);

  Future<void> setMode(JournalResearchMode next) async {
    if (mode == next) return;
    mode = next;
    notifyListeners();
    await _load(initial: false);
  }

  Future<void> setFromDate(DateTime date) async {
    fromDate = _startOfDay(date);
    notifyListeners();
    await _load(initial: false);
  }

  Future<void> setToDate(DateTime date) async {
    toDate = _endOfDay(date);
    notifyListeners();
    await _load(initial: false);
  }

  Future<void> clearFromDate() async {
    fromDate = null;
    notifyListeners();
    await _load(initial: false);
  }

  Future<void> clearToDate() async {
    toDate = null;
    notifyListeners();
    await _load(initial: false);
  }

  Future<void> setLandUseFilter(LandUseType? value) async {
    landUseFilter = value;
    notifyListeners();
    await _load(initial: false);
  }

  Future<void> setHealthScoreFilter(int? value) async {
    healthScoreFilter = value;
    notifyListeners();
    await _load(initial: false);
  }

  Future<void> clearAllFilters() async {
    _speciesDebounce?.cancel();
    fromDate = null;
    toDate = null;
    speciesFilter = '';
    landUseFilter = null;
    healthScoreFilter = null;
    speciesController.clear();
    notifyListeners();
    await _load(initial: false);
  }

  void _onSpeciesTextChanged() {
    _speciesDebounce?.cancel();
    _speciesDebounce = Timer(const Duration(milliseconds: 400), () async {
      final next = speciesController.text.trim();
      if (next == speciesFilter) return;
      speciesFilter = next;
      notifyListeners();
      await _load(initial: false);
    });
  }

  Future<void> _load({required bool initial}) async {
    if (hasDateRangeError) {
      error = null;
      loading = false;
      refreshing = false;
      notifyListeners();
      return;
    }

    final generation = ++_loadGeneration;
    error = null;
    if (initial || filteredReports.isEmpty && mode == JournalResearchMode.reports) {
      loading = true;
    } else {
      refreshing = true;
    }
    notifyListeners();

    try {
      if (!hasDateRangeError) {
        final list = await _repository.fetchFilteredReports(
          limit: 500,
          fromDate: fromDate,
          toDate: toDate,
          speciesQuery: speciesFilter,
          landType: landUseFilter?.storageValue,
          healthScore: healthScoreFilter,
        );
        if (generation != _loadGeneration) return;
        filteredReports = list;
      }
      if (mode == JournalResearchMode.quality) {
        final flags = await _quality.fetchOpen(limit: 200);
        if (generation != _loadGeneration) return;
        qualityFlags = flags;
      }
      if (generation != _loadGeneration) return;
      error = null;
    } catch (e) {
      if (generation != _loadGeneration) return;
      error = e.toString();
    }

    if (generation != _loadGeneration) return;
    loading = false;
    refreshing = false;
    notifyListeners();
  }

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  @override
  void dispose() {
    _speciesDebounce?.cancel();
    speciesController.removeListener(_onSpeciesTextChanged);
    speciesController.dispose();
    super.dispose();
  }
}
