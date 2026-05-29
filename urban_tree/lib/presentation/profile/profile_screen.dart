import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_locale_controller.dart';
import '../../l10n/app_localizations.dart';
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
    final profileService = ProfileService();
    final badges = <({String label, IconData icon})>[
      (label: l10n.badgeForestGuardian, icon: Icons.eco),
      (label: l10n.badgeMountainResearcher, icon: Icons.landscape),
      (label: l10n.badgeStreamsExpert, icon: Icons.water_drop),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BotanicalAppBar(
            title: l10n.appBrandTitle,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
            ),
            showMenu: false,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              children: [
                FutureBuilder<UserProfileSnapshot?>(
                  future: profileService.myProfile(),
                  builder: (context, snapshot) {
                    final profile = snapshot.data;
                    final points = profile?.totalPoints ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BentoCard(
                          child: Row(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: AppColors.surfaceContainer,
                                ),
                                child: const Icon(Icons.person, size: 48),
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
                                        color: AppColors.primary,
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
                                    const Icon(Icons.local_florist, color: AppColors.primaryFixed),
                                    Text(
                                      '$points',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      l10n.profileTreesIdentified,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.white70,
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
                                    const Icon(Icons.verified, color: AppColors.tertiaryContainer),
                                    Text(
                                      '${badges.length}',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(l10n.profileBadgesEarned),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.profileBadgesTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(l10n.homeViewAll, style: const TextStyle(color: AppColors.secondary)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final badge in badges)
                        _BadgeTile(label: badge.label, icon: badge.icon),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.profileSettingsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
                    trailing: selected ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () => localeController.setLocale(locale),
                  );
                }),
                ListTile(
                  title: Text(l10n.useDeviceLanguage),
                  trailing: localeController.locale == null
                      ? const Icon(Icons.check, color: AppColors.primary)
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
  const _BadgeTile({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: destructive ? AppColors.error : AppColors.primary),
          title: Text(
            label,
            style: TextStyle(
              color: destructive ? AppColors.error : AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.chevron_left,
            color: AppColors.outlineVariant,
          ),
        ),
      ),
    );
  }
}
