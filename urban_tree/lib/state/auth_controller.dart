import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends ChangeNotifier {
  AuthController({SupabaseClient? client}) : _client = client ?? Supabase.instance.client {
    _session = _client.auth.currentSession;
    _syncFromSession();
    _authSub = _client.auth.onAuthStateChange.listen((data) async {
      _session = data.session;
      _syncFromSession();
      if (_user != null) {
        await ensureProfileRow();
      }
      notifyListeners();
    });
  }

  final SupabaseClient _client;
  StreamSubscription<AuthState>? _authSub;
  Session? _session;
  User? _user;
  bool _loading = false;
  String? _error;

  Session? get session => _session;
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _runAuthAction(() async {
      await _client.auth.signInWithPassword(email: email, password: password);
    });
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _runAuthAction(() async {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      await ensureProfileRow(displayNameFallback: displayName);
    });
  }

  Future<void> signInWithGoogle() async {
    await _runAuthAction(() async {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback/',
      );
    });
  }

  Future<void> signOut() async {
    await _runAuthAction(() async {
      await _client.auth.signOut();
    });
  }

  Future<void> ensureProfileRow({String? displayNameFallback}) async {
    final current = _user;
    if (current == null) return;

    final metadata = current.userMetadata ?? const <String, dynamic>{};
    final displayName = (metadata['display_name'] as String?)?.trim();
    final avatarUrl = (metadata['avatar_url'] as String?)?.trim();
    await _client.from('profiles').upsert({
      'id': current.id,
      'display_name': _coalesceDisplayName(displayName, displayNameFallback),
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _session = _client.auth.currentSession;
      _syncFromSession();
      if (_user != null) {
        await ensureProfileRow();
      }
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _syncFromSession() {
    _user = _session?.user;
  }

  String _coalesceDisplayName(String? metadataName, String? fallback) {
    if (metadataName != null && metadataName.isNotEmpty) return metadataName;
    if (fallback != null && fallback.trim().isNotEmpty) return fallback.trim();
    final email = _user?.email;
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return 'Guardian';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
