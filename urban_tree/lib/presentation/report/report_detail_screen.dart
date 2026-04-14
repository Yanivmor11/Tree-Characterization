import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/tree_report_row.dart';
import '../../services/tree_report_repository.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.reportId,
  });

  final String reportId;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _repo = TreeReportRepository();
  TreeReportRow? _report;
  List<TreeReportRow> _timeline = const [];
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
      final report = await _repo.fetchReportById(widget.reportId);
      if (report == null) {
        setState(() {
          _error = 'Report not found';
          _loading = false;
        });
        return;
      }
      final timeline = await _repo.fetchHistoryForAsset(report);
      if (!mounted) return;
      setState(() {
        _report = report;
        _timeline = timeline;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    return Scaffold(
      appBar: AppBar(title: const Text('Full Report Detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(context, dateFmt),
    );
  }

  Widget _buildBody(BuildContext context, DateFormat dateFmt) {
    final report = _report!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.species ?? 'Unknown species',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (report.speciesScientific != null &&
                    report.speciesScientific!.isNotEmpty)
                  Text(
                    report.speciesScientific!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 8),
                Text('Land-use: ${report.landType.storageValue.toUpperCase()}'),
                Text('Health score: ${report.healthScore}/5'),
                if (report.phenologicalStage != null)
                  Text('Phenology: ${report.phenologicalStage}'),
                if (report.stressSymptoms.isNotEmpty)
                  Text('Stress symptoms: ${report.stressSymptoms.join(', ')}'),
                Text(
                  'Coordinates: ${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}',
                ),
              ],
            ),
          ),
        ),
        if (report.insightsText != null && report.insightsText!.isNotEmpty)
          Card(
            child: ListTile(
              title: const Text('AI Insight'),
              subtitle: Text(report.insightsText!),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Longitudinal History',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ..._timeline.map(
          (row) => Card(
            child: ListTile(
              title: Text(dateFmt.format(row.createdAt.toLocal())),
              subtitle: Text(
                'Health ${row.healthScore}/5 · ${row.landType.storageValue.toUpperCase()}'
                '${row.phenologicalStage != null ? ' · ${row.phenologicalStage}' : ''}',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
