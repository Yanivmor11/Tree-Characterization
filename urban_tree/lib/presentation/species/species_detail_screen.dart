import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/species_monograph.dart';
import '../../services/saved_species_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/botanical_widgets.dart';

class SpeciesDetailScreen extends StatefulWidget {
  const SpeciesDetailScreen({super.key, required this.speciesId});

  final String speciesId;

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  SpeciesMonograph? _species;
  bool _saved = false;
  final _savedSpecies = SavedSpeciesService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await SpeciesMonographRepository.instance.byId(widget.speciesId);
    final saved = await _savedSpecies.isSaved(widget.speciesId);
    if (mounted) {
      setState(() {
        _species = s;
        _saved = saved;
      });
    }
  }

  Future<void> _toggleSaved() async {
    final added = await _savedSpecies.toggle(widget.speciesId);
    if (!mounted) return;
    setState(() => _saved = added);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.speciesSavedToCollection)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final species = _species;
    final isWide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final lang = Localizations.localeOf(context).languageCode;

    if (species == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final content = species.contentFor(lang);
    final displayName = species.displayNameFor(lang);
    final familyLabel = species.familyLabelFor(lang);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isWide ? 500 : 320,
            pinned: true,
            backgroundColor: AppColors.background.withValues(alpha: 0.9),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              tooltip: l10n.back,
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  BotanicalNetworkImage(
                    url: species.heroImageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: l10n.imageOf(displayName),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.background,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SpeciesBadge(
                          label: '${species.family} • $familyLabel',
                          tint: SpeciesBadgeTint.tertiary,
                        ),
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          species.scientificName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.secondary,
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
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                GradientButton(
                  label: l10n.speciesSaveCollection,
                  icon: _saved ? Icons.bookmark : Icons.bookmark_border,
                  onPressed: _toggleSaved,
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.speciesMorphology,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _MorphCard(section: content.morphology.leaves)),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: _MorphCard(section: content.morphology.fruit)),
                    ],
                  )
                else ...[
                  _MorphCard(section: content.morphology.leaves),
                  const SizedBox(height: 12),
                  _MorphCard(section: content.morphology.fruit),
                ],
                const SizedBox(height: 12),
                _MorphCard(section: content.morphology.bark),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _StatBox(label: l10n.statMaxHeight, value: content.stats.maxHeight, color: AppColors.primaryContainer)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatBox(label: l10n.statLifespan, value: content.stats.lifespan, color: AppColors.secondaryContainer)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatBox(label: l10n.statPhotosynthesis, value: content.stats.photosynthesis, color: AppColors.tertiaryContainer)),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.speciesDistribution,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Text(content.distribution.description),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: content.distribution.regions
                      .map((r) => SpeciesBadge(label: r, tint: SpeciesBadgeTint.neutral))
                      .toList(),
                ),
                const SizedBox(height: 16),
                BotanicalNetworkImage(
                  url: content.distribution.mapImageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.map_rounded,
                  semanticLabel: l10n.distributionMapLabel,
                  borderRadius: BorderRadius.circular(24),
                ),
                const SizedBox(height: 32),
                BentoCard(
                  backgroundColor: AppColors.surfaceContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.speciesUsesTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      for (final use in content.uses) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surfaceContainerLowest,
                            child: const Icon(Icons.eco, color: AppColors.secondary),
                          ),
                          title: Text(use.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(use.body),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        l10n.speciesDidYouKnow,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      for (final fact in content.funFacts)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                              Expanded(child: Text(fact)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (isWide) ...[
                  const SizedBox(height: 32),
                  Text(
                    l10n.speciesAnatomy(displayName),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: content.anatomyCards
                        .map(
                          (c) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _AnatomyCard(card: c),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MorphCard extends StatelessWidget {
  const _MorphCard({required this.section});

  final MorphologySection section;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(section.body),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.card,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnatomyCard extends StatelessWidget {
  const _AnatomyCard({required this.card});

  final AnatomyCard card;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BotanicalNetworkImage(
            url: card.imageUrl,
            height: 160,
            fit: BoxFit.cover,
            semanticLabel: AppLocalizations.of(context).imageOf(card.title),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(card.body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
