import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/admin_user.dart';
import '../auth_data_source.dart';

/// Authentication is only granted to users whose profile has `is_admin = true`.
class SupabaseAuthDataSource implements AuthDataSource {
  final SupabaseClient _client;
  SupabaseAuthDataSource(this._client);

  @override
  Future<AdminUser> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    final uid = response.user?.id;
    if (uid == null) throw Exception('Sign-in failed');

    final admin = await _fetchAdmin(uid, response.user!.email ?? email);
    if (admin == null || !admin.isAdmin) {
      await _client.auth.signOut();
      throw const _AccessDenied();
    }
    return admin;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<AdminUser?> getCurrentAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final admin = await _fetchAdmin(user.id, user.email ?? '');
    return (admin != null && admin.isAdmin) ? admin : null;
  }

  Future<AdminUser?> _fetchAdmin(String uid, String email) async {
    try {
      final data = await _client.from('profiles').select().eq('id', uid).single();
      return AdminUser.fromJson({'id': uid, 'email': email, ...Map<String, dynamic>.from(data)});
    } catch (_) {
      return null;
    }
  }
}

class _AccessDenied implements Exception {
  const _AccessDenied();
  @override
  String toString() => 'access_denied';
}
