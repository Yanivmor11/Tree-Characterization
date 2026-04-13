import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardEntry {
  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.totalPoints,
    required this.trustScore,
    required this.leaderboardScore,
    this.cityLabel,
    this.citySlug,
    this.avatarUrl,
  });

  final String userId;
  final String displayName;
  final int totalPoints;
  final double trustScore;
  final double leaderboardScore;
  final String? cityLabel;
  final String? citySlug;
  final String? avatarUrl;

  static LeaderboardEntry? fromMap(Map<String, dynamic> row) {
    final id = row['user_id']?.toString();
    if (id == null) return null;
    return LeaderboardEntry(
      userId: id,
      displayName: row['display_name'] as String? ?? 'Guardian',
      totalPoints: (row['total_points'] as num?)?.toInt() ?? 0,
      trustScore: (row['trust_score'] as num?)?.toDouble() ?? 0,
      leaderboardScore: (row['leaderboard_score'] as num?)?.toDouble() ?? 0,
      cityLabel: row['city_label'] as String?,
      citySlug: row['city_slug'] as String?,
      avatarUrl: row['avatar_url'] as String?,
    );
  }
}

class LeaderboardService {
  LeaderboardService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<LeaderboardEntry>> fetchNational({int limit = 50}) async {
    try {
      final rows = await _client
          .from('leaderboard_national')
          .select(
            'user_id, display_name, avatar_url, city_label, city_slug, '
            'total_points, trust_score, leaderboard_score',
          )
          .limit(limit);
      final out = <LeaderboardEntry>[];
      for (final row in (rows as List<dynamic>)) {
        final e = LeaderboardEntry.fromMap(Map<String, dynamic>.from(row as Map));
        if (e != null) out.add(e);
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<List<LeaderboardEntry>> fetchCity(String citySlug, {int limit = 50}) async {
    try {
      final rows = await _client
          .from('leaderboard_city')
          .select(
            'user_id, display_name, avatar_url, city_label, city_slug, '
            'total_points, trust_score, leaderboard_score',
          )
          .eq('city_slug', citySlug)
          .limit(limit);
      final out = <LeaderboardEntry>[];
      for (final row in (rows as List<dynamic>)) {
        final e = LeaderboardEntry.fromMap(Map<String, dynamic>.from(row as Map));
        if (e != null) out.add(e);
      }
      return out;
    } catch (_) {
      return [];
    }
  }
}
