import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum AppTab { home, identify, collection, map, journal }

class BotanicalBottomNav extends StatelessWidget {
  const BotanicalBottomNav({
    super.key,
    required this.current,
    required this.onChanged,
    required this.labels,
  });

  final AppTab current;
  final ValueChanged<AppTab> onChanged;
  final Map<AppTab, String> labels;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [botanicalTheme(context).navShadow],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: AppTab.values.map((tab) {
                final selected = tab == current;
                return _NavItem(
                  icon: _iconFor(tab, selected),
                  label: labels[tab] ?? tab.name,
                  selected: selected,
                  onTap: () => onChanged(tab),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AppTab tab, bool selected) {
    return switch (tab) {
      AppTab.home => selected ? Icons.home_rounded : Icons.home_outlined,
      AppTab.identify =>
        selected ? Icons.center_focus_strong_rounded : Icons.center_focus_weak_rounded,
      AppTab.collection =>
        selected ? Icons.local_florist_rounded : Icons.local_florist_outlined,
      AppTab.map => selected ? Icons.map_rounded : Icons.map_outlined,
      AppTab.journal =>
        selected ? Icons.menu_book_rounded : Icons.menu_book_outlined,
    };
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
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
    final theme = Theme.of(context);
    if (selected) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.onPrimary, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
