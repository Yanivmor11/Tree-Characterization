import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  ProfileService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> updateCityIfEmpty({
    required String cityLabel,
    required String citySlug,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    final row = await _client
        .from('profiles')
        .select('city_slug')
        .eq('id', uid)
        .maybeSingle();

    if (row != null && row['city_slug'] != null) {
      final existing = row['city_slug'] as String?;
      if (existing != null && existing.isNotEmpty) return;
    }

    await _client.from('profiles').update({
      'city_label': cityLabel,
      'city_slug': citySlug,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', uid);
  }

  Future<String?> citySlug() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('profiles')
        .select('city_slug')
        .eq('id', uid)
        .maybeSingle();
    return row?['city_slug'] as String?;
  }
}
