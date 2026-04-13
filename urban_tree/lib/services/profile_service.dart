import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileSnapshot {
  UserProfileSnapshot({
    required this.displayName,
    required this.totalPoints,
    required this.trustScore,
    this.avatarUrl,
    this.cityLabel,
    this.citySlug,
  });

  final String displayName;
  final int totalPoints;
  final double trustScore;
  final String? avatarUrl;
  final String? cityLabel;
  final String? citySlug;

  static UserProfileSnapshot? fromRow(Map<String, dynamic>? row) {
    if (row == null) return null;
    return UserProfileSnapshot(
      displayName: row['display_name'] as String? ?? 'Guardian',
      totalPoints: (row['total_points'] as num?)?.toInt() ?? 0,
      trustScore: (row['trust_score'] as num?)?.toDouble() ?? 0,
      avatarUrl: row['avatar_url'] as String?,
      cityLabel: row['city_label'] as String?,
      citySlug: row['city_slug'] as String?,
    );
  }
}

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

  Future<UserProfileSnapshot?> myProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('profiles')
        .select('display_name, avatar_url, city_label, city_slug, total_points, trust_score')
        .eq('id', uid)
        .maybeSingle();
    return UserProfileSnapshot.fromRow(row);
  }
}
