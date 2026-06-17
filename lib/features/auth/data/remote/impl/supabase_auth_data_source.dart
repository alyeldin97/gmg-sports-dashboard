import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../model/admin_user.dart';
import '../auth_data_source.dart';

/// Authentication is only granted to users whose profile has `is_admin = true`.
class SupabaseAuthDataSource implements AuthDataSource {
  static const _tag = 'AuthDataSource';
  final SupabaseClient _client;
  SupabaseAuthDataSource(this._client);

  @override
  Future<AdminUser> signIn({required String email, required String password}) async {
    AppLogger.net(_tag, 'signIn attempt', email);
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      AppLogger.d(_tag, 'signInWithPassword response: user=${response.user?.id}, session=${response.session != null}');

      final uid = response.user?.id;
      if (uid == null) {
        AppLogger.e(_tag, 'signIn failed: response.user is null');
        throw Exception('Sign-in failed');
      }

      AppLogger.i(_tag, 'auth ok uid=$uid, fetching profile...');
      final admin = await _fetchAdmin(uid, response.user!.email ?? email);

      AppLogger.d(_tag, 'fetchAdmin result: admin=$admin, isAdmin=${admin?.isAdmin}');
      if (admin == null || !admin.isAdmin) {
        AppLogger.w(_tag, 'access denied — is_admin=${admin?.isAdmin} for uid=$uid');
        await _client.auth.signOut();
        throw const _AccessDenied();
      }

      AppLogger.i(_tag, 'signIn success: ${admin.email}');
      return admin;
    } on _AccessDenied {
      rethrow;
    } catch (e, st) {
      AppLogger.e(_tag, 'signIn error', e, st);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    AppLogger.i(_tag, 'signOut');
    await _client.auth.signOut();
  }

  @override
  Future<AdminUser?> getCurrentAdmin() async {
    final user = _client.auth.currentUser;
    AppLogger.d(_tag, 'getCurrentAdmin uid=${user?.id}');
    if (user == null) return null;
    final admin = await _fetchAdmin(user.id, user.email ?? '');
    AppLogger.d(_tag, 'getCurrentAdmin result isAdmin=${admin?.isAdmin}');
    return (admin != null && admin.isAdmin) ? admin : null;
  }

  Future<AdminUser?> _fetchAdmin(String uid, String email) async {
    AppLogger.net(_tag, 'fetchAdmin from profiles uid=$uid');
    try {
      final data = await _client.from('profiles').select().eq('id', uid).single();
      AppLogger.d(_tag, 'profiles row: $data');
      return AdminUser.fromJson({'id': uid, 'email': email, ...Map<String, dynamic>.from(data)});
    } catch (e, st) {
      AppLogger.e(_tag, 'fetchAdmin failed uid=$uid', e, st);
      return null;
    }
  }
}

class _AccessDenied implements Exception {
  const _AccessDenied();
  @override
  String toString() => 'access_denied';
}
