import 'package:dio/dio.dart';

import 'api_config.dart';
import 'auth_remote_data_source.dart';
import 'token_local_data_source.dart';

Dio buildApiClient(
  TokenLocalDataSource store,
  AuthRemoteDataSource auth, {
  void Function()? onSessionExpired,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccessToken();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final alreadyRetried = error.requestOptions.extra['retried'] == true;
        if (error.response?.statusCode == 401 && !alreadyRetried) {
          final refresh = await store.readRefreshToken();
          if (refresh == null) return handler.next(error);
          try {
            final renewed = await auth.refresh(refresh);
            await store.save(
              accessToken: renewed.accessToken,
              refreshToken: renewed.refreshToken,
            );
            final retry = await dio.fetch(
              error.requestOptions
                ..headers['Authorization'] = 'Bearer ${renewed.accessToken}'
                ..extra['retried'] = true,
            );
            return handler.resolve(retry);
          } catch (_) {
            await store.clear();
            onSessionExpired?.call();
          }
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}
