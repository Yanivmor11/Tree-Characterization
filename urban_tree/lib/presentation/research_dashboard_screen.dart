import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../models/land_use.dart';
import '../models/tree_report_row.dart';
import '../services/data_quality_service.dart';
import '../services/tree_report_repository.dart';
import 'report/report_detail_screen.dart';

enum _ResearchMode { reports, quality }

class ResearchDashboardScreen extends StatefulWidget {
  const ResearchDashboardScreen({super.key});

  @override
  State<ResearchDashboardScreen> createState() => _ResearchDashboardScreenState();
}

class _ResearchDashboardScreenState extends State<ResearchDashboardScreen> {
  final _repo = TreeReportRepository();
  final _quality = DataQualityService();
  _ResearchMode _mode = _ResearchMode.reports;
  List<TreeReportRow> _rows = [];
  List<DataQualityFlag> _flags = [];
  bool _loading = true;
  String? _error;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _speciesFilter = '';
  LandUseType? _landUseFilter;
  int? _healthScoreFilter;
  final _speciesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_mode == _ResearchMode.reports) {
        final list = await _repo.fetchFilteredReports(
          limit: 500,
          fromDate: _fromDate,
          toDate: _toDate,
          speciesEnglish: _speciesFilter,
          landType: _landUseFilter?.storageValue,
          healthScore: _healthScoreFilter,
        );
        if (!mounted) return;
        setState(() {
          _rows = list;
          _loading = false;
        });
      } else {
        final f = await _quality.fetchOpen(limit: 200);
        if (!mounted) return;
        setState(() {
          _flags = f;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context);
    if (_rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noReportsYet)),
      );
      return;
    }
    final csv = _repo.reportsToCsv(_rows);
    final fileName = _buildExportFileName();

    if (kIsWeb) {
      await Share.share(csv, subject: fileName);
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$fileName';
    final file = File(path);
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile(path, mimeType: 'text/csv', name: fileName)],
      subject: l10n.shareCsvSubject,
    );
  }

  Future<void> _openReportDetail(String reportId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReportDetailScreen(reportId: reportId),
      ),
    );
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
    );
    if (picked == null) return;
    setState(() => _fromDate = picked);
    _load();
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _toDate ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _toDate = picked.add(const Duration(hours: 23, minutes: 59)));
    _load();
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _speciesFilter = '';
      _landUseFilter = null;
      _healthScoreFilter = null;
    });
    _speciesController.clear();
    _load();
  }

  @override
  void dispose() {
    _speciesController.dispose();
    super.dispose();
  }

  String _buildExportFileName() {
    final datePart = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final segments = <String>[
      if (_landUseFilter != null) _landUseFilter!.storageValue,
      if (_healthScoreFilter != null) 'h$_healthScoreFilter',
      if (_speciesFilter.trim().isNotEmpty)
        _speciesFilter.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
    ];
    final suffix = segments.isEmpty ? 'all' : segments.join('_');
    return 'urban_tree_export_${datePart}_$suffix.csv';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat.yMMMd(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.researchDashboardTitle),
        actions: [
          if (_mode == _ResearchMode.reports)
            IconButton(
              tooltip: l10n.exportCsv,
              onPressed: _exportCsv,
              icon: const Icon(Icons.ios_share_outlined),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              l10n.researchDashboardSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedButton<_ResearchMode>(
              segments: [
                ButtonSegment(
                  value: _ResearchMode.reports,
                  label: Text(l10n.navResearch),
                ),
                ButtonSegment(
                  value: _ResearchMode.quality,
                  label: Text(l10n.researchQualityTab),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) {
                setState(() => _mode = s.first);
                _load();
              },
            ),
          ),
          if (_mode == _ResearchMode.reports)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Research Window',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _pickFromDate,
                              child: Text(
                                _fromDate == null
                                    ? 'From date'
                                    : 'From: ${dateFmt.format(_fromDate!)}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _pickToDate,
                              child: Text(
                                _toDate == null
                                    ? 'To date'
                                    : 'To: ${dateFmt.format(_toDate!)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _speciesController,
                        decoration: const InputDecoration(
                          labelText: 'Species (normalized English)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (v) {
                          setState(() => _speciesFilter = v.trim());
                          _load();
                        },
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 3.2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          DropdownButtonFormField<LandUseType?>(
                            initialValue: _landUseFilter,
                            decoration: const InputDecoration(
                              labelText: 'Land-use',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem<LandUseType?>(
                                value: null,
                                child: Text('All'),
                              ),
                              DropdownMenuItem<LandUseType?>(
                                value: LandUseType.public,
                                child: Text('Public'),
                              ),
                              DropdownMenuItem<LandUseType?>(
                                value: LandUseType.private,
                                child: Text('Private'),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() => _landUseFilter = v);
                              _load();
                            },
                          ),
                          DropdownButtonFormField<int?>(
                            initialValue: _healthScoreFilter,
                            decoration: const InputDecoration(
                              labelText: 'Health score',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('All'),
                              ),
                              ...List.generate(
                                5,
                                (i) => DropdownMenuItem<int?>(
                                  value: i + 1,
                                  child: Text('${i + 1}'),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() => _healthScoreFilter = v);
                              _load();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.loadReportsError),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _load,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            )
          else if (_mode == _ResearchMode.reports)
            _buildReportsList(l10n, dateFmt)
          else
            _buildQualityList(l10n, dateFmt),
        ],
      ),
    );
  }

  Widget _buildReportsList(AppLocalizations l10n, DateFormat dateFmt) {
    if (_rows.isEmpty) {
      return Expanded(
        child: Center(child: Text(l10n.noReportsYet)),
      );
    }
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _rows.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final r = _rows[i];
          return Card(
            child: ListTile(
              onTap: () => _openReportDetail(r.id),
              title: Text(
                l10n.reportListItemSubtitle(
                  dateFmt.format(r.createdAt.toLocal()),
                  l10n.landUseTypeLabel(r.landType),
                  r.healthScore,
                ),
              ),
              subtitle: Text(
                '${r.latitude.toStringAsFixed(5)}, ${r.longitude.toStringAsFixed(5)}'
                '${r.species != null ? ' · ${r.species}' : ''}',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQualityList(AppLocalizations l10n, DateFormat dateFmt) {
    if (_flags.isEmpty) {
      return Expanded(
        child: Center(child: Text(l10n.qualityFlagsEmpty)),
      );
    }
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _flags.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final f = _flags[i];
          return Card(
            child: ListTile(
              title: Text(
                l10n.qualityFlagSubtitle(f.reason, f.clusterKey),
              ),
              subtitle: Text(dateFmt.format(f.createdAt.toLocal())),
            ),
          );
        },
      ),
    );
  }
}
