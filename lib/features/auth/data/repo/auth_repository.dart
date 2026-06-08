import '../model/admin_user.dart';
import '../remote/auth_data_source.dart';

class AuthRepository {
  final AuthDataSource _dataSource;
  AuthRepository(this._dataSource);

  Future<AdminUser> signIn({required String email, required String password}) =>
      _dataSource.signIn(email: email, password: password);

  Future<void> signOut() => _dataSource.signOut();

  Future<AdminUser?> getCurrentAdmin() => _dataSource.getCurrentAdmin();
}
