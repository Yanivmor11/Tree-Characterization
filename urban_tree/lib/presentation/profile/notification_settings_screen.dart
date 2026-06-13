import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/notification_preferences_service.dart';
import '../widgets/botanical_widgets.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _prefs = NotificationPreferencesService();
  Map<String, bool> _values = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final values = await _prefs.loadAll();
    if (!mounted) return;
    setState(() {
      _values = values;
      _loading = false;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    await _prefs.setEnabled(key, value);
    if (!mounted) return;
    setState(() => _values = {..._values, key: value});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BotanicalAppBar(
            title: l10n.profileNotifications,
            showMenu: false,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      SwitchListTile(
                        title: Text(l10n.notificationNearbyTrees),
                        value: _values[NotificationPreferencesService.nearbyTrees] ??
                            true,
                        onChanged: (v) => _setPref(
                          NotificationPreferencesService.nearbyTrees,
                          v,
                        ),
                      ),
                      SwitchListTile(
                        title: Text(l10n.notificationPestAlerts),
                        value: _values[NotificationPreferencesService.pestAlerts] ??
                            true,
                        onChanged: (v) => _setPref(
                          NotificationPreferencesService.pestAlerts,
                          v,
                        ),
                      ),
                      SwitchListTile(
                        title: Text(l10n.notificationWeeklyDigest),
                        value:
                            _values[NotificationPreferencesService.weeklyDigest] ??
                                false,
                        onChanged: (v) => _setPref(
                          NotificationPreferencesService.weeklyDigest,
                          v,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
