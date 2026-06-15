import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/botanical_widgets.dart';
import 'photo_guide_screen.dart';

class IdentifyHubScreen extends StatelessWidget {
  const IdentifyHubScreen({
    super.key,
    this.onMenuTap,
    this.onProfileTap,
    this.embedded = false,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _HeroPanel(l10n: l10n, isDesktop: isWide)),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: _GuidePanel(l10n: l10n),
                ),
              ],
            )
          else
            _HeroPanel(l10n: l10n, isDesktop: isWide),
        ],
      ),
    );

    if (embedded) return content;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BotanicalAppBar(
            title: l10n.appBrandTitle,
            onMenuTap: onMenuTap,
            onProfileTap: onProfileTap,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.l10n, required this.isDesktop});

  final AppLocalizations l10n;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (isDesktop) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [botanicalTheme(context).primaryShadow],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.identifyHubTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.identifyHubBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => AppRoutes.startIdentifyFlow(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLowest,
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.upload_file),
              label: Text(l10n.identifyUploadPhoto),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const PhotoGuideScreen(),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onPrimary,
                side: BorderSide(
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                  width: 2,
                ),
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.help_outline),
              label: Text(l10n.identifyPhotoGuide),
            ),
          ],
        ),
      );
    }

    return BentoCard(
      backgroundColor: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.identifyHubTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.identifyHubBody,
            style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: l10n.identifyStartCamera,
            icon: Icons.photo_camera,
            onPressed: () => AppRoutes.startIdentifyFlow(context),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const PhotoGuideScreen(),
              ),
            ),
            icon: const Icon(Icons.help_outline),
            label: Text(l10n.identifyPhotoGuide),
          ),
        ],
      ),
    );
  }
}

class _GuidePanel extends StatelessWidget {
  const _GuidePanel({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BentoCard(
      backgroundColor: AppColors.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.camera_enhance, size: 48, color: cs.primary.withValues(alpha: 0.8)),
          const SizedBox(height: 12),
          Text(
            l10n.identifyHubTipsTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.identifyHubTipsBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
