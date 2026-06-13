import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/species_monograph.dart';
import '../../models/tree_report_row.dart';
import '../../state/report_feed_controller.dart';
import '../research_dashboard_screen.dart';
import '../widgets/tree_report_actions.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/botanical_widgets.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({
    super.key,
    this.onMenuTap,
    this.onProfileTap,
    this.embedded = false,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;
  final bool embedded;

  Future<void> _openEntry(BuildContext context, TreeReportRow row) async {
    await TreeReportActions.openTree(context, row: row);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final feed = context.watch<ReportFeedController>();
    final isWide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final crossAxis = isWide ? 3 : 1;
    final entries = feed.recentReports.take(12).toList();
    final distinctSpecies = feed.recentReports
        .map((r) => r.speciesScientific ?? r.species)
        .whereType<String>()
        .toSet()
        .length;

    final body = CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(24, embedded ? 16 : 8, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.journalObservations,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.secondary,
                      ),
                ),
                Text(
                  l10n.journalTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        if (entries.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text(l10n.noReportsYet)),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxis,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 0.75 : 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _JournalCard(
                  row: entries[i],
                  l10n: l10n,
                  onTap: () => _openEntry(context, entries[i]),
                ),
                childCount: entries.length,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(
            child: BentoCard(
              backgroundColor: AppColors.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.journalWeeklySummary,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.journalWeeklyBody),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _MiniStat(
                        value: '${feed.totalReports}',
                        label: l10n.journalObservations,
                      ),
                      const SizedBox(width: 24),
                      _MiniStat(
                        value: '$distinctSpecies',
                        label: l10n.mapRareSpecies,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.journalResearchSection,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(l10n.researchDashboardSubtitle),
                const SizedBox(height: 16),
                SizedBox(
                  height: 520,
                  child: ClipRRect(
                    borderRadius: AppRadii.card,
                    child: const ResearchDashboardScreen(embedded: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BotanicalAppBar(
            title: l10n.appBrandTitle,
            onMenuTap: onMenuTap,
            onProfileTap: onProfileTap,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.row, required this.l10n, required this.onTap});

  final TreeReportRow row;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final materialL10n = MaterialLocalizations.of(context);
    final dateLabel = materialL10n.formatMediumDate(row.createdAt);
    final title = row.species ?? row.speciesScientific ?? '—';
    final bodyText = row.insightsText?.trim().isNotEmpty == true
        ? row.insightsText!.trim()
        : l10n.reportListItemSubtitle(
            dateLabel,
            row.landType.displayLabel,
            row.healthScore,
          );
    final image = row.wholeTreeImageUrls.isNotEmpty ? row.wholeTreeImageUrls.first : null;

    return FutureBuilder<SpeciesMonograph?>(
      future: SpeciesMonographRepository.instance.resolveForReport(
        scientific: row.speciesScientific,
        common: row.species,
      ),
      builder: (context, snapshot) {
        final canReadMore = snapshot.data != null;

        return BentoCard(
          padding: EdgeInsets.zero,
          onTap: onTap,
          backgroundColor: AppColors.surfaceContainerLowest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: BotanicalNetworkImage(
                      url: image,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.park_rounded,
                      semanticLabel:
                          image != null ? l10n.reportPhotoLabel : null,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: SpeciesBadge(
                      label: dateLabel,
                      tint: SpeciesBadgeTint.neutral,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bodyText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (canReadMore) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.journalReadMore,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.journalNavigateInstead,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
