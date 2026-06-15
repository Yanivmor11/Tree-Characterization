import 'package:supabase_flutter/supabase_flutter.dart';

/// Community vote direction on a tree report.
enum VoteType {
  up('up'),
  down('down');

  const VoteType(this.storageValue);
  final String storageValue;

  static VoteType? fromStorage(String? value) {
    if (value == null) return null;
    for (final v in VoteType.values) {
      if (v.storageValue == value) return v;
    }
    return null;
  }
}

/// Persists upvote/downvote actions to Supabase `report_votes`.
class VoteService {
  VoteService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> castVote({
    required String reportId,
    required VoteType voteType,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Must be signed in to vote');
    }

    await _client.from('report_votes').upsert(
      {
        'user_id': uid,
        'report_id': reportId,
        'vote_type': voteType.storageValue,
      },
      onConflict: 'user_id,report_id',
    );
  }

  Future<void> clearVote(String reportId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Must be signed in to vote');
    }

    await _client
        .from('report_votes')
        .delete()
        .eq('user_id', uid)
        .eq('report_id', reportId);
  }

  Future<Map<String, VoteType>> fetchMyVotes(List<String> reportIds) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || reportIds.isEmpty) return {};

    try {
      final rows = await _client
          .from('report_votes')
          .select('report_id, vote_type')
          .eq('user_id', uid)
          .inFilter('report_id', reportIds);

      final out = <String, VoteType>{};
      for (final row in (rows as List<dynamic>)) {
        final map = Map<String, dynamic>.from(row as Map);
        final reportId = map['report_id']?.toString();
        final vote = VoteType.fromStorage(map['vote_type'] as String?);
        if (reportId != null && vote != null) {
          out[reportId] = vote;
        }
      }
      return out;
    } on PostgrestException {
      return {};
    } catch (_) {
      return {};
    }
  }
}
