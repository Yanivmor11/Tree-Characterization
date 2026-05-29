import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/botanical_widgets.dart';
import 'photo_gallery_screen.dart';
import 'photo_guide_screen.dart';

class IdentifyHubScreen extends StatelessWidget {
  const IdentifyHubScreen({super.key, this.onMenuTap, this.embedded = false});

  final VoidCallback? onMenuTap;
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
                Expanded(
                  flex: 8,
                  child: _HeroPanel(l10n: l10n),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: _DropZone(l10n: l10n),
                ),
              ],
            )
          else ...[
            _HeroPanel(l10n: l10n),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const PhotoGalleryScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.collections),
                    label: Text(l10n.identifyFromGallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const PhotoGuideScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.help_outline),
                    label: Text(l10n.identifyPhotoGuide),
                  ),
                ),
              ],
            ),
          ],
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
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      backgroundColor: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.identifyHubTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.identifyHubBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: l10n.identifyStartCamera,
            icon: Icons.photo_camera,
            onPressed: () => AppRoutes.pushIdentifyCamera(context),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const PhotoGalleryScreen(),
              ),
            ),
            icon: const Icon(Icons.collections),
            label: Text(l10n.identifyFromGallery),
          ),
        ],
      ),
    );
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (_) => kIsWeb,
      onAcceptWithDetails: (_) {
        AppRoutes.pushIdentifyCamera(context);
      },
      builder: (context, candidate, rejected) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: AppRadii.card,
            border: Border.all(
              color: candidate.isNotEmpty
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, size: 48, color: AppColors.primary.withValues(alpha: 0.6)),
              const SizedBox(height: 12),
              Text(l10n.identifyFromGallery, style: Theme.of(context).textTheme.titleMedium),
              Text(
                'JPG, PNG',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
