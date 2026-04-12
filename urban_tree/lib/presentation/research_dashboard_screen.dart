import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../models/tree_report_row.dart';
import '../services/data_quality_service.dart';
import '../services/tree_report_repository.dart';

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
        final list = await _repo.fetchRecentReports(limit: 500);
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

    if (kIsWeb) {
      await Share.share(csv, subject: l10n.shareCsvSubject);
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/urban_tree_reports_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile(path, mimeType: 'text/csv', name: 'urban_tree_reports.csv')],
      subject: l10n.shareCsvSubject,
    );
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
