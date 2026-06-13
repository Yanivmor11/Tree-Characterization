import 'package:shared_preferences/shared_preferences.dart';

/// Local notification toggles until push infrastructure is available.
class NotificationPreferencesService {
  static const _prefix = 'notification_pref_';

  static const nearbyTrees = '${_prefix}nearby_trees';
  static const pestAlerts = '${_prefix}pest_alerts';
  static const weeklyDigest = '${_prefix}weekly_digest';

  Future<Map<String, bool>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      nearbyTrees: prefs.getBool(nearbyTrees) ?? true,
      pestAlerts: prefs.getBool(pestAlerts) ?? true,
      weeklyDigest: prefs.getBool(weeklyDigest) ?? false,
    };
  }

  Future<void> setEnabled(String key, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, enabled);
  }
}
