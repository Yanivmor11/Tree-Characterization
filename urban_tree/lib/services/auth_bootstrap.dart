import 'package:supabase_flutter/supabase_flutter.dart';

/// Ensures a stable [user id] for gamification (anonymous session is enough).
Future<void> ensureSupabaseSignedIn() async {
  final client = Supabase.instance.client;
  final session = client.auth.currentSession;
  if (session != null) return;

  await client.auth.signInAnonymously();
}
