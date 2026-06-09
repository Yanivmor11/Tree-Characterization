import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_locale_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../services/badge_service.dart';
import '../../services/profile_service.dart';
import '../../state/auth_controller.dart';
import '../theme/app_colors.dart';
import '../top_guardians_screen.dart';
import '../widgets/botanical_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.localeController});

  final AppLocaleController localeController;

  static const _fixedLocales = [
    Locale('en'),
    Locale('he'),
    Locale('ar'),
    Locale('ru'),
  ];

  static const _nativeNames = {
    'en': 'English',
    'he': 'עברית',
    'ar': 'العربية',
    'ru': 'Русский',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final profileFuture = Future.wait([
      ProfileService().myProfile(),
      BadgeService().myBadges(),
    ]);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          BotanicalAppBar(
            title: l10n.appBrandTitle,
            leading: IconButton(
              tooltip: l10n.a11yProfileBack,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
            ),
            showMenu: false,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              children: [
                FutureBuilder<List<Object?>>(
                  future: profileFuture,
                  builder: (context, snapshot) {
                    final profile = snapshot.data?[0] as UserProfileSnapshot?;
                    final badges =
                        snapshot.data?[1] as List<EarnedBadge>? ?? const [];
                    final points = profile?.totalPoints ?? 0;
                    final trustScore = profile?.trustScore ?? 0;
                    final avatarUrl = profile?.avatarUrl;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BentoCard(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: avatarUrl != null && avatarUrl.isNotEmpty
                                      ? Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(
                                            Icons.person,
                                            size: 48,
                                            color: theme.colorScheme.primary,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 48,
                                          color: theme.colorScheme.primary,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.profileExplorerRank,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    Text(
                                      l10n.profileFieldResearcher,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      profile?.displayName ??
                                          auth.user?.email ??
                                          l10n.defaultUserName,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
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
                                backgroundColor: AppColors.primaryContainer,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.stars_rounded,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                    Text(
                                      '$points',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: theme.colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      l10n.profileGamificationPoints,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: BentoCard(
                                backgroundColor: AppColors.surfaceContainerHigh,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.verified_user,
                                      color: AppColors.tertiaryContainer,
                                    ),
                                    Text(
                                      trustScore.toStringAsFixed(1),
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      l10n.profileTrustScore,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        BentoCard(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.emoji_events_outlined,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${badges.length}',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      l10n.profileBadgesEarned,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.profileBadgesTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (badges.isEmpty)
                          BentoCard(
                            child: Text(
                              l10n.profileNoBadgesYet,
                              style: theme.textTheme.bodyMedium,
                            ),
                          )
                        else
                          SizedBox(
                            height: 140,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (final badge in badges)
                                  _BadgeTile(
                                    label: badge.displayName,
                                    icon: badge.icon,
                                    tooltip: badge.description,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.profileSettingsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsTile(icon: Icons.person_outline, label: l10n.profileAccount),
                _SettingsTile(icon: Icons.notifications_active, label: l10n.profileNotifications),
                _SettingsTile(icon: Icons.description, label: l10n.profileFieldJournals),
                _SettingsTile(
                  icon: Icons.emoji_events_outlined,
                  label: l10n.openLeaderboard,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const TopGuardiansScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.logout,
                  label: l10n.signOut,
                  destructive: true,
                  onTap: auth.loading ? null : auth.signOut,
                ),
                const SizedBox(height: 24),
                Text(l10n.appLanguageTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._fixedLocales.map((locale) {
                  final selected =
                      localeController.locale?.languageCode == locale.languageCode;
                  return ListTile(
                    title: Text(_nativeNames[locale.languageCode] ?? locale.languageCode),
                    trailing: selected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                    onTap: () => localeController.setLocale(locale),
                  );
                }),
                ListTile(
                  title: Text(l10n.useDeviceLanguage),
                  trailing: localeController.locale == null
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => localeController.setLocale(null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.label,
    required this.icon,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: 128,
      margin: const EdgeInsets.only(left: 12),
      child: BentoCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.tertiaryFixed,
              radius: 28,
              child: Icon(icon, color: AppColors.onTertiaryFixedVariant),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: tile);
    }
    return tile;
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            icon,
            color: destructive ? AppColors.error : theme.colorScheme.primary,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: destructive ? AppColors.error : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.chevron_left,
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
