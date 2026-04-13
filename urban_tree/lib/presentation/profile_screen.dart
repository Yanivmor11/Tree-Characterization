import 'package:flutter/material.dart';

import '../core/app_locale_controller.dart';
import '../l10n/app_localizations.dart';
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
