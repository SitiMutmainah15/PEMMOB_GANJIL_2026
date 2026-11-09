import 'package:dio/dio.dart';

import 'api_config.dart';

class AuthSession {
  const AuthSession({required this.access, required this.refresh});

  final String access;
  final String refresh;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final access = json['accessToken'];
    final refresh = json['refreshToken'];
    if (access is! String || access.isEmpty ||
        refresh is! String || refresh.isEmpty) {
      throw const FormatException('Token tidak ditemukan di respons API');
    }
    return AuthSession(access: access, refresh: refresh);
  }
}

/// Login SUNGGUHAN melalui POST /auth/login, bukan data mock.
/// Akun demo: emilys / emilyspass (lihat dokumentasi DummyJSON).
class AuthRepository {
  AuthRepository({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  final Dio _dio;

  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
      'expiresInMins': 30,
    });
    return AuthSession.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _dio.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    return AuthSession.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
