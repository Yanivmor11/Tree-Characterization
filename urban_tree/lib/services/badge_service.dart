import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EarnedBadge {
  EarnedBadge({
    required this.code,
    required this.displayName,
    required this.description,
    required this.earnedAt,
  });

  final String code;
  final String displayName;
  final String description;
  final DateTime earnedAt;

  IconData get icon => switch (code) {
        'first_blossom_reporter' => Icons.local_florist,
        'private_land_pioneer' => Icons.fence,
        'first_bloom_hunter' => Icons.spa,
        'neighborhood_watch' => Icons.groups,
        _ => Icons.military_tech,
      };
}

class BadgeService {
  BadgeService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<EarnedBadge>> myBadges() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    final rows = await _client
        .from('user_badges')
        .select('badge_code, earned_at')
        .eq('user_id', uid)
        .order('earned_at', ascending: false);

    if (rows.isEmpty) return [];

    final codes = rows
        .map((r) => r['badge_code'] as String)
        .toSet()
        .toList(growable: false);

    final definitions = await _client
        .from('badge_definitions')
        .select('code, display_name, description')
        .inFilter('code', codes);

    final defByCode = {
      for (final d in definitions)
        d['code'] as String: d,
    };

    return [
      for (final row in rows)
        EarnedBadge(
          code: row['badge_code'] as String,
          displayName:
              defByCode[row['badge_code']]?['display_name'] as String? ??
                  row['badge_code'] as String,
          description:
              defByCode[row['badge_code']]?['description'] as String? ?? '',
          earnedAt: DateTime.parse(row['earned_at'] as String),
        ),
    ];
  }
}
