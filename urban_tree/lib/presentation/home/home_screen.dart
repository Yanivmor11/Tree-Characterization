import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/species_monograph.dart';
import '../../state/auth_controller.dart';
import '../../state/report_feed_controller.dart';
import '../routes/app_routes.dart';
import '../species/species_detail_screen.dart';
import '../widgets/tree_report_actions.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/botanical_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.refreshTick,
    required this.onReportComplete,
    this.onMenuTap,
    this.onProfileTap,
    this.onViewAll,
    this.embedded = false,
  });

  final int refreshTick;
  final VoidCallback onReportComplete;
  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;

  /// Switches the shell to the collection tab when the user taps "view all".
  final VoidCallback? onViewAll;
  final bool embedded;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _maxSuggestions = 6;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<SpeciesMonograph> _allSpecies = const [];
  List<SpeciesMonograph> _suggestions = const [];
  List<SpeciesMonograph>? _committedResults;
  String _committedQuery = '';
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
    _searchController.addListener(_onSearchTextChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) {
      context.read<ReportFeedController>().refreshCount();
    }
  }

  Future<void> _loadFeatured() async {
    final species = await SpeciesMonographRepository.instance.loadAll();
    if (mounted) {
      setState(() {
        _allSpecies = species;
      });
    }
  }

  void _onSearchFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      setState(() => _showSuggestions = false);
    }
  }

  void _onSearchTextChanged() {
    final query = _searchController.text;
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = const [];
        _committedResults = null;
        _committedQuery = '';
        _showSuggestions = false;
      });
      return;
    }

    final matches = SpeciesMonographRepository.instance.filterByQuery(
      _allSpecies,
      query,
    );
    setState(() {
      _suggestions = matches;
      _committedResults = null;
      _committedQuery = '';
      _showSuggestions = _searchFocusNode.hasFocus && matches.isNotEmpty;
    });
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final matches = SpeciesMonographRepository.instance.filterByQuery(
      _allSpecies,
      trimmed,
    );

    setState(() {
      _showSuggestions = false;
      _committedQuery = trimmed;
      _committedResults = matches;
    });
    _searchFocusNode.unfocus();

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.searchNoResults(trimmed))),
      );
    }
  }

  void _selectSuggestion(SpeciesMonograph species) {
    setState(() {
      _showSuggestions = false;
      _committedResults = null;
      _committedQuery = '';
    });
    _searchFocusNode.unfocus();
    _openSpeciesById(species.id);
  }

  Future<void> _startIdentify() async {
    await AppRoutes.startIdentifyFlow(context);
  }

  String _greetingName(BuildContext context, AppLocalizations l10n) {
    final auth = context.watch<AuthController>();
    final metadata = auth.user?.userMetadata ?? const <String, dynamic>{};
    final displayName = (metadata['display_name'] as String?)?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = auth.user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return l10n.defaultUserName;
  }


  void _openSpeciesById(String id) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SpeciesDetailScreen(speciesId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final feed = context.watch<ReportFeedController>();
    final isWide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final recent = feed.recentReports.take(6).toList();

    final body = ListView(
      padding: EdgeInsets.fromLTRB(24, widget.embedded ? 16 : 8, 24, 120),
      children: [
        Text(
          l10n.homeGreeting,
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          l10n.homeHello(_greetingName(context, l10n)),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 24),
        _HomeSpeciesSearch(
          controller: _searchController,
          focusNode: _searchFocusNode,
          hintText: l10n.homeSearchHint,
          suggestions: _showSuggestions
              ? _suggestions.take(_maxSuggestions).toList()
              : const [],
          onSubmitted: _submitSearch,
          onSuggestionSelected: _selectSuggestion,
          onTap: () {
            final query = _searchController.text.trim();
            if (query.isEmpty) return;
            final matches = SpeciesMonographRepository.instance.filterByQuery(
              _allSpecies,
              query,
            );
            setState(() {
              _suggestions = matches;
              _showSuggestions = matches.isNotEmpty;
            });
          },
        ),
        if (_committedResults != null) ...[
          const SizedBox(height: 16),
          Text(
            l10n.searchResultsFor(_committedQuery),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (_committedResults!.isEmpty)
            Text(
              l10n.searchNoResults(_committedQuery),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            )
          else
            for (final species in _committedResults!) ...[
              _FeaturedCard(
                title: species.displayNameFor(
                  Localizations.localeOf(context).languageCode,
                ),
                subtitle: species.scientificName,
                tag:
                    '${species.familyLabelFor(Localizations.localeOf(context).languageCode)} • ${species.scientificName}',
                imageUrl: species.thumbnailUrl,
                onTap: () => _openSpeciesById(species.id),
              ),
              const SizedBox(height: 12),
            ],
        ],
        const SizedBox(height: 32),
        _IdentifyCtaCard(
          title: l10n.homeIdentifyTitle,
          body: l10n.homeIdentifyBody,
          cta: isWide ? l10n.identifyUploadPhoto : l10n.homeIdentifyCta,
          ctaIcon: isWide ? Icons.upload_file : Icons.photo_camera,
          onTap: _startIdentify,
          isWide: isWide,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.homeRecentTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.onViewAll != null && recent.isNotEmpty)
              TextButton(
                onPressed: widget.onViewAll,
                child: Text(l10n.homeViewAll),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: recent.isEmpty
              ? Center(child: Text(l10n.noReportsYet))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, i) {
                    final row = recent[i];
                    return _RecentCard(
                      title: row.species ?? row.speciesScientific ?? '—',
                      subtitle: row.speciesScientific ?? '',
                      imageUrl: row.wholeTreeImageUrls.isNotEmpty
                          ? row.wholeTreeImageUrls.first
                          : null,
                      healthScore: row.healthScore,
                      onTap: () => TreeReportActions.openTree(context, row: row),
                    );
                  },
                ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.homeFeaturedTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        for (final species in _allSpecies) ...[
          _FeaturedCard(
            title: species.displayNameFor(Localizations.localeOf(context).languageCode),
            subtitle: species.scientificName,
            tag:
                '${species.familyLabelFor(Localizations.localeOf(context).languageCode)} • ${species.scientificName}',
            imageUrl: species.thumbnailUrl,
            onTap: () => _openSpeciesById(species.id),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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

class _HomeSpeciesSearch extends StatelessWidget {
  const _HomeSpeciesSearch({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.suggestions,
    required this.onSubmitted,
    required this.onSuggestionSelected,
    required this.onTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final List<SpeciesMonograph> suggestions;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<SpeciesMonograph> onSuggestionSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final lang = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(Icons.search, color: cs.outline),
          ),
        ),
        if (suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              elevation: 4,
              shadowColor: Colors.black26,
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < suggestions.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: cs.outlineVariant),
                    InkWell(
                      onTap: () => onSuggestionSelected(suggestions[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.eco_outlined, color: cs.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestions[i].displayNameFor(lang),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    suggestions[i].scientificName,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _IdentifyCtaCard extends StatelessWidget {
  const _IdentifyCtaCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.ctaIcon,
    required this.onTap,
    required this.isWide,
  });

  final String title;
  final String body;
  final String cta;
  final IconData ctaIcon;
  final VoidCallback onTap;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [botanicalTheme(context).primaryShadow],
      ),
      padding: const EdgeInsets.all(32),
      child: isWide
          ? Row(
              children: [
                Expanded(
                  child: _CtaText(
                    title: title,
                    body: body,
                    cta: cta,
                    ctaIcon: ctaIcon,
                    onTap: onTap,
                  ),
                ),
                const SizedBox(width: 32),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 120,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            )
          : _CtaText(
              title: title,
              body: body,
              cta: cta,
              ctaIcon: ctaIcon,
              onTap: onTap,
            ),
    );
  }
}

class _CtaText extends StatelessWidget {
  const _CtaText({
    required this.title,
    required this.body,
    required this.cta,
    required this.ctaIcon,
    required this.onTap,
  });

  final String title;
  final String body;
  final String cta;
  final IconData ctaIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerLowest,
            foregroundColor: AppColors.primary,
          ),
          icon: Icon(ctaIcon),
          label: Text(cta),
        ),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.healthScore,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final int healthScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 180,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BotanicalNetworkImage(
                    url: imageUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.park_rounded,
                    semanticLabel: imageUrl != null ? l10n.imageOf(title) : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _HealthChip(score: healthScore),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small overlay badge that conveys a report's health score (0–5) at a glance.
class _HealthChip extends StatelessWidget {
  const _HealthChip({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Color color = score >= 4
        ? AppColors.primary
        : score >= 2
            ? AppColors.secondary
            : AppColors.error;
    return Semantics(
      label: l10n.healthScoreLabel(score),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              '$score/5',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BentoCard(
      onTap: onTap,
      leafCorner: true,
      child: Row(
        children: [
          BotanicalNetworkImage(
            url: imageUrl,
            width: 96,
            height: 96,
            semanticLabel: AppLocalizations.of(context).imageOf(title),
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.secondary,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: cs.outline),
        ],
      ),
    );
  }
}
