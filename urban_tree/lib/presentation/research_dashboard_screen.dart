import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../models/land_use.dart';
import '../models/tree_report_row.dart';
import '../services/data_quality_service.dart';
import '../services/tree_report_repository.dart';
import '../state/journal_research_controller.dart';
import 'report/report_detail_screen.dart';

class ResearchDashboardScreen extends StatelessWidget {
  const ResearchDashboardScreen({super.key, this.embedded = false});

  final bool embedded;

  Future<void> _pickFromDate(
    BuildContext context,
    JournalResearchController research,
  ) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: research.fromDate ??
          DateTime.now().subtract(const Duration(days: 30)),
    );
    if (picked == null) return;
    await research.setFromDate(picked);
  }

  Future<void> _pickToDate(
    BuildContext context,
    JournalResearchController research,
  ) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: research.toDate ?? DateTime.now(),
    );
    if (picked == null) return;
    await research.setToDate(picked);
  }

  Future<void> _exportCsv(
    BuildContext context,
    JournalResearchController research,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (research.filteredReports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noReportsYet)),
      );
      return;
    }
    final repo = TreeReportRepository();
    final csv = repo.reportsToCsv(research.filteredReports);
    final fileName = _buildExportFileName(research);

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

  String _buildExportFileName(JournalResearchController research) {
    final exportDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final segments = <String>[
      if (research.fromDate != null)
        'from_${DateFormat('yyyy-MM-dd').format(research.fromDate!)}',
      if (research.toDate != null)
        'to_${DateFormat('yyyy-MM-dd').format(research.toDate!)}',
      if (research.landUseFilter != null)
        research.landUseFilter!.storageValue,
      if (research.healthScoreFilter != null)
        'h${research.healthScoreFilter}',
      if (research.speciesFilter.trim().isNotEmpty)
        research.speciesFilter
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
    ];
    final suffix = segments.isEmpty ? 'all' : segments.join('_');
    return 'urban_tree_export_${exportDate}_$suffix.csv';
  }

  Future<void> _openReportDetail(BuildContext context, String reportId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReportDetailScreen(reportId: reportId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat.yMMMd(lang);
    final research = context.watch<JournalResearchController>();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!embedded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              l10n.researchDashboardSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedButton<JournalResearchMode>(
            segments: [
              ButtonSegment(
                value: JournalResearchMode.reports,
                label: Text(l10n.navResearch),
              ),
              ButtonSegment(
                value: JournalResearchMode.quality,
                label: Text(l10n.researchQualityTab),
              ),
            ],
            selected: {research.mode},
            onSelectionChanged: (selection) {
              research.setMode(selection.first);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.researchWindowTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (research.hasDateRangeError) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.researchDateRangeError,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickFromDate(context, research),
                            child: Text(
                              research.fromDate == null
                                  ? l10n.researchFromDate
                                  : l10n.researchFromDateValue(
                                      dateFmt.format(research.fromDate!),
                                    ),
                            ),
                          ),
                        ),
                        if (research.fromDate != null) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: l10n.researchClearFromDate,
                            onPressed: research.clearFromDate,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickToDate(context, research),
                            child: Text(
                              research.toDate == null
                                  ? l10n.researchToDate
                                  : l10n.researchToDateValue(
                                      dateFmt.format(research.toDate!),
                                    ),
                            ),
                          ),
                        ),
                        if (research.toDate != null) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: l10n.researchClearToDate,
                            onPressed: research.clearToDate,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ],
                    ),
                    if (research.mode == JournalResearchMode.reports) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: research.speciesController,
                        decoration: InputDecoration(
                          labelText: l10n.researchSpeciesLabel,
                          border: const OutlineInputBorder(),
                        ),
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
                            // ignore: deprecated_member_use — controlled field; `initialValue` is not suitable here
                            value: research.landUseFilter,
                            decoration: InputDecoration(
                              labelText: l10n.researchLandUseLabel,
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem<LandUseType?>(
                                value: null,
                                child: Text(l10n.researchFilterAll),
                              ),
                              ...LandUseType.values.map(
                                (t) => DropdownMenuItem<LandUseType?>(
                                  value: t,
                                  child: Text(l10n.landUseTypeLabel(t)),
                                ),
                              ),
                            ],
                            onChanged: research.setLandUseFilter,
                          ),
                          DropdownButtonFormField<int?>(
                            // ignore: deprecated_member_use — controlled field; `initialValue` is not suitable here
                            value: research.healthScoreFilter,
                            decoration: InputDecoration(
                              labelText: l10n.researchHealthScoreLabel,
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem<int?>(
                                value: null,
                                child: Text(l10n.researchFilterAll),
                              ),
                              ...List.generate(
                                5,
                                (i) => DropdownMenuItem<int?>(
                                  value: i + 1,
                                  child: Text('${i + 1}'),
                                ),
                              ),
                            ],
                            onChanged: research.setHealthScoreFilter,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: research.clearAllFilters,
                          child: Text(l10n.researchClearFilters),
                        ),
                        const Spacer(),
                        if (embedded &&
                            research.mode == JournalResearchMode.reports)
                          TextButton.icon(
                            onPressed: () => _exportCsv(context, research),
                            icon: const Icon(Icons.ios_share_outlined),
                            label: Text(l10n.exportCsv),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (research.refreshing)
          const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 8),
        if (research.loading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: embedded ? 24 : 48),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (research.error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.loadReportsError),
                const SizedBox(height: 8),
                Text(
                  research.error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: research.reload,
                  child: Text(l10n.retry),
                ),
              ],
            ),
          )
        else if (research.hasDateRangeError)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                l10n.researchDateRangeError,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          )
        else if (research.mode == JournalResearchMode.reports)
          _ReportsList(
            embedded: embedded,
            rows: research.filteredReports,
            dateFmt: dateFmt,
            l10n: l10n,
            onOpen: (id) => _openReportDetail(context, id),
          )
        else
          _QualityList(
            embedded: embedded,
            flags: research.filteredQualityFlags,
            dateFmt: dateFmt,
            l10n: l10n,
          ),
      ],
    );

    if (embedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.researchDashboardTitle),
        actions: [
          if (research.mode == JournalResearchMode.reports)
            IconButton(
              tooltip: l10n.exportCsv,
              onPressed: () => _exportCsv(context, research),
              icon: const Icon(Icons.ios_share_outlined),
            ),
        ],
      ),
      body: content,
    );
  }
}

class _ReportsList extends StatelessWidget {
  const _ReportsList({
    required this.embedded,
    required this.rows,
    required this.dateFmt,
    required this.l10n,
    required this.onOpen,
  });

  final bool embedded;
  final List<TreeReportRow> rows;
  final DateFormat dateFmt;
  final AppLocalizations l10n;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text(l10n.noReportsYet)),
      );
    }

    final listView = ListView.separated(
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: rows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = rows[i];
        return Card(
          child: ListTile(
            onTap: () => onOpen(r.id),
            title: Text(
              l10n.reportListItemSubtitle(
                dateFmt.format(r.createdAt.toLocal()),
                l10n.landUseTypeLabel(r.landType),
                r.healthScore,
              ),
            ),
            subtitle: Text(
              '${r.latitude.toStringAsFixed(5)}, ${r.longitude.toStringAsFixed(5)}'
              '${r.species != null ? ' · ${r.species}' : ''}'
              '${r.speciesScientific != null ? ' · ${r.speciesScientific}' : ''}',
            ),
          ),
        );
      },
    );

    if (embedded) return listView;

    return Expanded(child: listView);
  }
}

class _QualityList extends StatelessWidget {
  const _QualityList({
    required this.embedded,
    required this.flags,
    required this.dateFmt,
    required this.l10n,
  });

  final bool embedded;
  final List<DataQualityFlag> flags;
  final DateFormat dateFmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (flags.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text(l10n.qualityFlagsEmpty)),
      );
    }

    final listView = ListView.separated(
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: flags.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final f = flags[i];
        return Card(
          child: ListTile(
            title: Text(
              l10n.qualityFlagSubtitle(f.reason, f.clusterKey),
            ),
            subtitle: Text(dateFmt.format(f.createdAt.toLocal())),
          ),
        );
      },
    );

    if (embedded) return listView;

    return Expanded(child: listView);
  }
}
