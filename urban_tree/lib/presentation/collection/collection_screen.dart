import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/land_use.dart';
import '../../models/tree_report_row.dart';
import '../../state/report_feed_controller.dart';
import '../../state/vote_controller.dart';
import '../widgets/report_social_card.dart';
import '../widgets/tree_report_actions.dart';
import '../theme/app_theme.dart';
import '../widgets/botanical_widgets.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({
    super.key,
    this.onMenuTap,
    this.onProfileTap,
    this.embedded = false,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;
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

  Future<void> _openSpecies(TreeReportRow row) async {
    await TreeReportActions.openTree(context, row: row);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final feed = context.watch<ReportFeedController>();
    final reports = _filtered(feed.recentReports);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= kDesktopBreakpoint;
    final crossAxisCount = isDesktop ? (width >= 1280 ? 3 : 2) : 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || reports.isEmpty) return;
      context.read<VoteController>().hydrateFromReports(reports);
    });

    final body = ListView(
      padding: EdgeInsets.fromLTRB(24, widget.embedded ? 16 : 8, 24, 120),
      children: [
        Text(
          l10n.collectionArchive,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        Text(
          l10n.feedTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: cs.primary,
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
                  label: landUseLabel(l10n, type),
                  selected: _landFilter == type,
                  onTap: () => setState(() => _landFilter = type),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (feed.loading && reports.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (reports.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.forest, size: 56, color: cs.outline),
                  const SizedBox(height: 12),
                  Text(
                    l10n.socialFeedEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          )
        else if (crossAxisCount == 1)
          ...reports.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ReportSocialCard(
                row: row,
                landLabel: landUseLabel(l10n, row.landType),
                onTap: () => _openSpecies(row),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: reports.length,
            itemBuilder: (context, i) {
              final row = reports[i];
              return ReportSocialCard(
                row: row,
                landLabel: landUseLabel(l10n, row.landType),
                onTap: () => _openSpecies(row),
              );
            },
          ),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            onPressed: feed.loading ? null : () => feed.loadInitial(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.collectionLoadMore),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          BotanicalAppBar(
            title: l10n.appBrandTitle,
            onMenuTap: widget.onMenuTap,
            onProfileTap: widget.onProfileTap,
          ),
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: cs.tertiaryContainer,
        labelStyle: TextStyle(
          color: selected ? cs.onTertiaryContainer : cs.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
