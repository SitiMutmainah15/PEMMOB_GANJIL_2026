import 'package:dio/dio.dart';

import 'api_config.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  Future<AuthSessionModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password, 'expiresInMins': 30},
    );
    return AuthSessionModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<AuthSessionModel> refresh(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return AuthSessionModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
