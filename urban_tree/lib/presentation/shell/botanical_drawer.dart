import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/auth_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/botanical_widgets.dart';
import 'botanical_bottom_nav.dart';

class BotanicalDrawer extends StatelessWidget {
  const BotanicalDrawer({
    super.key,
    required this.current,
    required this.onTabSelected,
    required this.onClose,
    this.onHelpTap,
    this.onProfileTap,
    this.onSignOut,
  });

  final AppTab current;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onClose;
  final VoidCallback? onHelpTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = context.watch<AuthController>();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: AppColors.onSurface.withValues(alpha: 0.4)),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.85,
              constraints: const BoxConstraints(maxWidth: 384),
              color: AppColors.surfaceContainerLowest,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: AppRadii.leafCorner(
                                base: 16,
                                accent: 24,
                              ),
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: AppColors.onPrimaryContainer,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.drawerTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.drawerSubtitle,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _DrawerNavItem(
                            icon: Icons.home_rounded,
                            label: l10n.navHome,
                            selected: current == AppTab.home,
                            onTap: () => _go(context, AppTab.home),
                          ),
                          _DrawerNavItem(
                            icon: Icons.map_outlined,
                            label: l10n.navMap,
                            selected: current == AppTab.map,
                            onTap: () => _go(context, AppTab.map),
                          ),
                          _DrawerNavItem(
                            icon: Icons.local_florist_outlined,
                            label: l10n.navCollection,
                            selected: current == AppTab.collection,
                            onTap: () => _go(context, AppTab.collection),
                          ),
                          _DrawerNavItem(
                            icon: Icons.menu_book_outlined,
                            label: l10n.navJournal,
                            selected: current == AppTab.journal,
                            onTap: () => _go(context, AppTab.journal),
                          ),
                          _DrawerNavItem(
                            icon: Icons.info_outline,
                            label: l10n.navHelp,
                            selected: false,
                            onTap: () {
                              onClose();
                              onHelpTap?.call();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: BentoCard(
                        backgroundColor: AppColors.surfaceContainerLow,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onProfileTap == null
                                    ? null
                                    : () {
                                        onClose();
                                        onProfileTap?.call();
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      child: Icon(Icons.person),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            auth.user?.email?.split('@').first ??
                                                l10n.defaultUserName,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              color: cs.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            l10n.userRoleBotanist,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (onProfileTap != null)
                                      Icon(
                                        Icons.chevron_left,
                                        color: cs.outline,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: onSignOut,
                              icon: const Icon(Icons.logout, color: AppColors.error),
                              label: Text(
                                l10n.signOut,
                                style: const TextStyle(color: AppColors.error),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                backgroundColor:
                                    AppColors.errorContainer.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, AppTab tab) {
    onClose();
    onTabSelected(tab);
  }
}

class _DrawerNavItem extends StatelessWidget {
  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: selected
                ? BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected
                            ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
