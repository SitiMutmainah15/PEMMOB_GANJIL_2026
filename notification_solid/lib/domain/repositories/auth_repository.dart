import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String username,
    required String password,
  });

  Future<bool> hasSession();
  Future<void> logout();
}
