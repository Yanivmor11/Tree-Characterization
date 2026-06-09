import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../identify/photo_guide_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/botanical_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          BotanicalAppBar(
            title: l10n.helpCenterTitle,
            showMenu: false,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_forward, color: cs.primary),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _HeroText(l10n: l10n)),
                      const SizedBox(width: 24),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: AppRadii.leafCorner(accent: 32),
                          child: Container(
                            height: 280,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.menu_book,
                                size: 96,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  _HeroText(l10n: l10n),
                const SizedBox(height: 32),
                Text(
                  l10n.helpGuidesTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                _GuideCard(
                  title: l10n.helpGuideLeaves,
                  body: l10n.photoGuideStep1Body,
                  icon: Icons.menu_book,
                  borderColor: AppColors.primary,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(builder: (_) => const PhotoGuideScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _GuideCard(
                  title: l10n.helpGuideBark,
                  body: l10n.photoGuideBarkBody,
                  icon: Icons.texture,
                  borderColor: AppColors.secondary,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(builder: (_) => const PhotoGuideScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _GuideCard(
                  title: l10n.helpGuideAi,
                  body: l10n.photoGuideIntro,
                  icon: Icons.psychology,
                  borderColor: AppColors.onTertiaryContainer,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(builder: (_) => const PhotoGuideScreen()),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.helpFaqTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                _FaqItem(
                  question: l10n.helpFaq1Question,
                  answer: l10n.helpFaq1Answer,
                ),
                _FaqItem(
                  question: l10n.helpFaq2Question,
                  answer: l10n.helpFaq2Answer,
                ),
                _FaqItem(
                  question: l10n.helpFaq3Question,
                  answer: l10n.helpFaq3Answer,
                ),
                const SizedBox(height: 24),
                BentoCard(
                  backgroundColor: cs.primaryContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.helpContactTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.helpContactBody,
                        style: TextStyle(color: cs.onPrimaryContainer.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.helpContactBody)),
                        ),
                        child: Text(l10n.helpContactCta),
                      ),
                    ],
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

class _HeroText extends StatelessWidget {
  const _HeroText({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.helpHeroTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.helpHeroBody,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.borderColor,
    required this.onTap,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: onTap,
      backgroundColor: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, size: 36, color: borderColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w700)),
        children: [Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(answer))],
      ),
    );
  }
}
