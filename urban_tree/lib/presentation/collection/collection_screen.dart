import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/land_use.dart';
import '../../models/species_monograph.dart';
import '../../models/tree_report_row.dart';
import '../../state/report_feed_controller.dart';
import '../species/species_detail_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/botanical_widgets.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, this.onMenuTap, this.embedded = false});

  final VoidCallback? onMenuTap;
  final bool embedded;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  LandUseType? _landFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _landLabel(AppLocalizations l10n, LandUseType type) => switch (type) {
        LandUseType.public => l10n.landUsePublic,
        LandUseType.private => l10n.landUsePrivate,
        LandUseType.kkl => l10n.landUseKkl,
        LandUseType.abandoned => l10n.landUseAbandoned,
      };

  List<TreeReportRow> _filtered(List<TreeReportRow> rows) {
    final query = _query.trim().toLowerCase();
    return rows.where((row) {
      if (_landFilter != null && row.landType != _landFilter) return false;
      if (query.isEmpty) return true;
      final species = (row.species ?? '').toLowerCase();
      final scientific = (row.speciesScientific ?? '').toLowerCase();
      return species.contains(query) || scientific.contains(query);
    }).toList();
  }

  Future<void> _openSpecies(String? scientific) async {
    final species =
        await SpeciesMonographRepository.instance.byScientificName(scientific);
    if (!mounted || species == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SpeciesDetailScreen(speciesId: species.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feed = context.watch<ReportFeedController>();
    final reports = _filtered(feed.recentReports);
    final crossAxis = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint ? 4 : 1;

    final body = ListView(
      padding: EdgeInsets.fromLTRB(24, widget.embedded ? 16 : 8, 24, 120),
      children: [
        Text(
          l10n.collectionArchive,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        Text(
          l10n.collectionTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: l10n.collectionSearchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: l10n.collectionFilterAll,
                selected: _landFilter == null,
                onTap: () => setState(() => _landFilter = null),
              ),
              for (final type in LandUseType.values)
                _FilterChip(
                  label: _landLabel(l10n, type),
                  selected: _landFilter == type,
                  onTap: () => setState(() => _landFilter = type),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (reports.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.forest, size: 56, color: AppColors.outlineVariant),
                  const SizedBox(height: 12),
                  Text(
                    l10n.collectionEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxis,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: crossAxis > 1 ? 0.72 : 0.85,
            ),
            itemCount: reports.length,
            itemBuilder: (context, i) {
              final row = reports[i];
              return _ReportCollectionCard(
                row: row,
                landLabel: _landLabel(l10n, row.landType),
                onTap: () => _openSpecies(row.speciesScientific),
              );
            },
          ),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => feed.loadInitial(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.collectionLoadMore),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BotanicalAppBar(title: l10n.appBrandTitle, onMenuTap: widget.onMenuTap),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.tertiaryContainer,
        labelStyle: TextStyle(
          color: selected ? AppColors.onTertiaryContainer : AppColors.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _ReportCollectionCard extends StatelessWidget {
  const _ReportCollectionCard({
    required this.row,
    required this.landLabel,
    required this.onTap,
  });

  final TreeReportRow row;
  final String landLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumb = row.wholeTreeImageUrls.isNotEmpty ? row.wholeTreeImageUrls.first : null;
    final title = row.species ?? row.speciesScientific ?? '—';
    return BentoCard(
      leafCorner: true,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BotanicalNetworkImage(
              url: thumb,
              fit: BoxFit.cover,
              fallbackIcon: Icons.park_rounded,
              semanticLabel: thumb != null
                  ? AppLocalizations.of(context).imageOf(title)
                  : null,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.species ?? row.speciesScientific ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  row.speciesScientific ?? landLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
