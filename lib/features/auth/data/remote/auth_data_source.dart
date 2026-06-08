import '../model/admin_user.dart';

abstract class AuthDataSource {
  Future<AdminUser> signIn({required String email, required String password});
  Future<void> signOut();
  Future<AdminUser?> getCurrentAdmin();
}
