import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/botanical_widgets.dart';
import 'botanical_bottom_nav.dart';

class BotanicalSideNav extends StatelessWidget {
  const BotanicalSideNav({
    super.key,
    required this.current,
    required this.onChanged,
    required this.labels,
    required this.appTitle,
    required this.appSubtitle,
    required this.onIdentifyNew,
    required this.userName,
    required this.userSubtitle,
    this.avatarUrl,
    this.onHelpTap,
    this.onProfileTap,
    this.helpLabel,
    this.innerEdgeAtStart = false,
  });

  final AppTab current;
  final ValueChanged<AppTab> onChanged;
  final Map<AppTab, String> labels;
  final String appTitle;
  final String appSubtitle;
  final VoidCallback onIdentifyNew;
  final String userName;
  final String userSubtitle;
  final String? avatarUrl;
  final VoidCallback? onHelpTap;
  final VoidCallback? onProfileTap;
  final String? helpLabel;
  /// When true, the border/selection accent faces the start edge (sidebar on the end side in RTL).
  final bool innerEdgeAtStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      width: kSideNavWidth,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: BorderDirectional(
          start: innerEdgeAtStart
              ? BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2))
              : BorderSide.none,
          end: innerEdgeAtStart
              ? BorderSide.none
              : BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                appSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              ..._sideItems(context),
              if (onHelpTap != null && helpLabel != null)
                _SideLink(
                  icon: Icons.help_outline,
                  label: helpLabel!,
                  onTap: onHelpTap!,
                ),
              const Spacer(),
              GradientButton(
                label: labels[AppTab.identify] ?? 'Identify',
                icon: Icons.add_circle_outline,
                onPressed: onIdentifyNew,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.secondaryContainer,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            userSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _sideItems(BuildContext context) {
    final items = <(AppTab, IconData, String)>[
      (AppTab.home, Icons.home_outlined, labels[AppTab.home]!),
      (AppTab.identify, Icons.visibility_outlined, labels[AppTab.identify]!),
      (AppTab.collection, Icons.park_outlined, labels[AppTab.collection]!),
      (AppTab.map, Icons.map_outlined, labels[AppTab.map]!),
      (AppTab.journal, Icons.menu_book_outlined, labels[AppTab.journal]!),
    ];

    return items.map((item) {
      final (tab, icon, label) = item;
      final selected = tab == current;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: selected
              ? AppColors.surfaceContainerHighest.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onChanged(tab),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: selected
                  ? BoxDecoration(
                      border: BorderDirectional(
                        start: innerEdgeAtStart
                            ? const BorderSide(color: AppColors.primary, width: 4)
                            : BorderSide.none,
                        end: innerEdgeAtStart
                            ? BorderSide.none
                            : const BorderSide(color: AppColors.primary, width: 4),
                      ),
                    )
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _SideLink extends StatelessWidget {
  const _SideLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: cs.onSurface),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: cs.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
