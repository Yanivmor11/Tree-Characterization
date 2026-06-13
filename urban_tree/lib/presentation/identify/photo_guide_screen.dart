import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../widgets/botanical_widgets.dart';

class PhotoGuideScreen extends StatelessWidget {
  const PhotoGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          BotanicalGlassHeader(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close, color: cs.primary),
            ),
            title: Text(
              l10n.identifyPhotoGuide,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              children: [
                SpeciesBadge(label: l10n.photoGuideBadge),
                const SizedBox(height: 16),
                Text(
                  l10n.photoGuideTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.photoGuideIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),
                BentoCard(
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.eco, color: cs.primary, size: 32),
                          Text(
                            l10n.photoGuideStepLabel(1),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.photoGuideStep1,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.photoGuideStep1Body),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BentoCard(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.photoGuideBarkTitle,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.photoGuideBarkBody),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.texture, size: 40),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: BentoCard(
                        backgroundColor: cs.primaryContainer,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.light_mode, color: cs.onPrimaryContainer),
                            const SizedBox(height: 8),
                            Text(
                              l10n.photoGuideLighting,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.photoGuideLightingBody,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BentoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.center_focus_strong, color: AppColors.secondary),
                            const SizedBox(height: 8),
                            Text(
                              l10n.photoGuideFocus,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              l10n.photoGuideFocusBody,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.photoGuideAvoidTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                _AvoidRow(
                  icon: Icons.blur_on,
                  title: l10n.photoGuideBlur,
                  body: l10n.photoGuideBlurBody,
                ),
                const SizedBox(height: 12),
                _AvoidRow(
                  icon: Icons.social_distance,
                  title: l10n.photoGuideDistance,
                  body: l10n.photoGuideDistanceBody,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: l10n.photoGuideCta,
                  icon: Icons.photo_camera,
                  onPressed: () {
                    Navigator.of(context).pop();
                    AppRoutes.startIdentifyFlow(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvoidRow extends StatelessWidget {
  const _AvoidRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: cs.errorContainer,
          child: Icon(icon, color: cs.error),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
