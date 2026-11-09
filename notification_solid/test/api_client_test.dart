import 'dart:convert';

import 'package:campus_notify/data/datasources/api_client.dart';
import 'package:campus_notify/data/datasources/auth_remote_data_source.dart';
import 'package:campus_notify/data/models/auth_session_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_push_test.dart' show FakeTokenStore;

class _WorkingRefreshDataSource extends AuthRemoteDataSource {
  @override
  Future<AuthSessionModel> refresh(String refreshToken) async =>
      const AuthSessionModel(
        accessToken: 'renewed-access',
        refreshToken: 'renewed-refresh',
      );
}

class _FailingRefreshDataSource extends AuthRemoteDataSource {
  @override
  Future<AuthSessionModel> refresh(String refreshToken) async =>
      throw Exception('refresh kedaluwarsa');
}

class _FakeAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? _,
    Future<void>? _,
  ) async {
    calls++;
    final authorized =
        options.headers['Authorization'] == 'Bearer renewed-access';
    return ResponseBody.fromString(
      authorized ? '{"ok":true}' : '{}',
      authorized ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _LoginAdapter implements HttpClientAdapter {
  Map<String, dynamic>? submitted;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? _,
    Future<void>? _,
  ) async {
    submitted = options.data is String
        ? Map<String, dynamic>.from(jsonDecode(options.data as String) as Map)
        : Map<String, dynamic>.from(options.data as Map);
    return ResponseBody.fromString(
      '{"accessToken":"api-access","refreshToken":"api-refresh"}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('data source mengirim kredensial ke POST /auth/login', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));
    final adapter = _LoginAdapter();
    dio.httpClientAdapter = adapter;
    final session = await AuthRemoteDataSource(
      dio: dio,
    ).login(username: 'emilys', password: 'emilyspass');
    expect(adapter.submitted?['username'], 'emilys');
    expect(adapter.submitted?['password'], 'emilyspass');
    expect(session.accessToken, 'api-access');
    expect(session.refreshToken, 'api-refresh');
  });

  test(
    '401 memicu refresh sekali lalu mengulang request dengan Bearer token',
    () async {
      final store = FakeTokenStore()
        ..access = 'old'
        ..refresh = 'old-refresh';
      final dio = buildApiClient(store, _WorkingRefreshDataSource());
      final adapter = _FakeAdapter();
      dio.httpClientAdapter = adapter;

      final response = await dio.get('/auth/me');
      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
      expect(store.access, 'renewed-access');
      expect(store.refresh, 'renewed-refresh');
    },
  );

  test('refresh gagal menghapus token dan meminta login ulang', () async {
    final store = FakeTokenStore()
      ..access = 'old'
      ..refresh = 'old-refresh';
    var expired = false;
    final dio = buildApiClient(
      store,
      _FailingRefreshDataSource(),
      onSessionExpired: () => expired = true,
    );
    dio.httpClientAdapter = _FakeAdapter();

    await expectLater(dio.get('/auth/me'), throwsA(isA<DioException>()));
    expect(store.access, isNull);
    expect(store.refresh, isNull);
    expect(expired, isTrue);
  });
}
