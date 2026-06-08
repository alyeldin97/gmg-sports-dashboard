import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/admin_user.dart';
import '../../data/repo/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState()) {
    _check();
  }

  Future<void> _check() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final admin = await _repository.getCurrentAdmin();
      emit(admin != null
          ? state.copyWith(status: AuthStatus.authenticated, user: admin)
          : state.copyWith(status: AuthStatus.unauthenticated));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final admin = await _repository.signIn(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: admin));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: _parse(e)));
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  String _parse(Object e) {
    final msg = e.toString();
    if (msg.contains('access_denied')) return 'access_denied';
    if (msg.contains('Invalid login credentials')) return 'Invalid email or password';
    return 'Something went wrong. Please try again';
  }
}
