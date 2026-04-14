import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../services/profile_service.dart';
import '../state/auth_controller.dart';
import 'top_guardians_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.localeController});

  final AppLocaleController localeController;

  static const _fixedLocales = [
    Locale('en'),
    Locale('he'),
    Locale('ar'),
    Locale('ru'),
  ];

  /// Native names — recognizable in any UI language.
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
    final current = localeController.locale;
    final auth = context.watch<AuthController>();
    final profileService = ProfileService();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const TopGuardiansScreen(),
                ),
              );
            },
            child: Text(l10n.openLeaderboard),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FutureBuilder<UserProfileSnapshot?>(
            future: profileService.myProfile(),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.displayName ?? auth.user?.email ?? 'Guardian',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        auth.user?.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Points: ${profile?.totalPoints ?? 0} · מדד אמינות: ${(profile?.trustScore ?? 0).toStringAsFixed(1)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Tooltip(
                            message: 'Score based on validated reports',
                            child: Icon(
                              Icons.info_outline,
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.emoji_events_outlined),
            title: Text(l10n.openLeaderboard),
            subtitle: Text(l10n.leaderboardTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const TopGuardiansScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: auth.loading ? null : auth.signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.appLanguageTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.profilePlaceholder,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            selected: current == null,
            selectedTileColor: theme.colorScheme.secondaryContainer.withValues(
              alpha: 0.35,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(l10n.useDeviceLanguage),
            trailing: current == null ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
            onTap: () => localeController.setLocale(null),
          ),
          const SizedBox(height: 8),
          ..._fixedLocales.map((locale) {
            final selected = current?.languageCode == locale.languageCode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                selected: selected,
                selectedTileColor: theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.35,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(_nativeNames[locale.languageCode] ?? locale.languageCode),
                trailing: selected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () => localeController.setLocale(locale),
              ),
            );
          }),
        ],
      ),
    );
  }
}
