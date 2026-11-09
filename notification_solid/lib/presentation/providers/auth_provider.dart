import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/api_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/token_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_state.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import 'notification_provider.dart';

final tokenLocalDataSourceProvider = Provider<TokenLocalDataSource>(
  (ref) => TokenLocalDataSource(),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(tokenLocalDataSourceProvider),
  ),
);

final loginProvider = Provider<Login>(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);

final checkAuthStateProvider = Provider<CheckAuthState>(
  (ref) => CheckAuthState(ref.watch(authRepositoryProvider)),
);

final logoutProvider = Provider<Logout>(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

final apiClientProvider = Provider<Dio>((ref) {
  return buildApiClient(
    ref.watch(tokenLocalDataSourceProvider),
    ref.watch(authRemoteDataSourceProvider),
    onSessionExpired: () => ref.invalidate(authStateProvider),
  );
});

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(checkAuthStateProvider)();

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(loginProvider)(username: username, password: password);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(logoutProvider)();
    await ref.read(manageNotificationsProvider).clear();
    ref.invalidateSelf();
  }
}
