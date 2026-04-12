import 'package:supabase_flutter/supabase_flutter.dart';

class DataQualityFlag {
  DataQualityFlag({
    required this.id,
    required this.clusterKey,
    required this.reason,
    required this.payload,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String clusterKey;
  final String reason;
  final Map<String, dynamic> payload;
  final String status;
  final DateTime createdAt;

  static DataQualityFlag? fromMap(Map<String, dynamic> row) {
    final id = row['id']?.toString();
    if (id == null) return null;
    final createdRaw = row['created_at'];
    DateTime createdAt;
    if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }
    final payload = row['payload'];
    return DataQualityFlag(
      id: id,
      clusterKey: row['cluster_key'] as String? ?? '',
      reason: row['reason'] as String? ?? '',
      payload: payload is Map<String, dynamic>
          ? payload
          : Map<String, dynamic>.from(payload as Map? ?? {}),
      status: row['status'] as String? ?? 'open',
      createdAt: createdAt,
    );
  }
}

class DataQualityService {
  DataQualityService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<DataQualityFlag>> fetchOpen({int limit = 100}) async {
    try {
      final rows = await _client
          .from('data_quality_flags')
          .select('id, cluster_key, reason, payload, status, created_at')
          .eq('status', 'open')
          .order('created_at', ascending: false)
          .limit(limit);
      final out = <DataQualityFlag>[];
      for (final row in (rows as List<dynamic>)) {
        final f = DataQualityFlag.fromMap(Map<String, dynamic>.from(row as Map));
        if (f != null) out.add(f);
      }
      return out;
    } catch (_) {
      return [];
    }
  }
}
