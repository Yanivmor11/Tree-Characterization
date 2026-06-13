import 'package:shared_preferences/shared_preferences.dart';

/// Persists species ids bookmarked from species detail / map.
class SavedSpeciesService {
  static const _key = 'saved_species_ids';

  Future<Set<String>> loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  Future<bool> isSaved(String speciesId) async {
    final ids = await loadIds();
    return ids.contains(speciesId);
  }

  Future<bool> toggle(String speciesId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key)?.toSet() ?? {};
    final added = !ids.remove(speciesId);
    if (added) ids.add(speciesId);
    await prefs.setStringList(_key, ids.toList());
    return added;
  }
}
