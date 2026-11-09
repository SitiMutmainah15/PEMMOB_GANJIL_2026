import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/token_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenLocalDataSource _localDataSource;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      username: username,
      password: password,
    );
    await _localDataSource.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    return session.toEntity();
  }

  @override
  Future<bool> hasSession() async =>
      await _localDataSource.readAccessToken() != null;

  @override
  Future<void> logout() => _localDataSource.clear();
}
