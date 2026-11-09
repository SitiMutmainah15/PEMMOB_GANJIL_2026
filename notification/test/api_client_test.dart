import 'dart:convert';

import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_push_test.dart' show FakeTokenStore;

class _WorkingRefreshRepo extends AuthRepository {
  @override
  Future<AuthSession> refresh(String refreshToken) async =>
      const AuthSession(access: 'renewed-access', refresh: 'renewed-refresh');
}

class _FailingRefreshRepo extends AuthRepository {
  @override
  Future<AuthSession> refresh(String refreshToken) async =>
      throw Exception('refresh kedaluwarsa');
}

class _FakeAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? _,
      Future<void>? __) async {
    calls++;
    final auth = options.headers['Authorization'] as String?;
    final ok = auth == 'Bearer renewed-access';
    return ResponseBody.fromString(ok ? '{"ok":true}' : '{}', ok ? 200 : 401,
        headers: {Headers.contentTypeHeader: ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

class _LoginAdapter implements HttpClientAdapter {
  Map<String, dynamic>? submitted;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? _,
      Future<void>? __) async {
    submitted = options.data is String
        ? Map<String, dynamic>.from(jsonDecode(options.data as String) as Map)
        : Map<String, dynamic>.from(options.data as Map);
    return ResponseBody.fromString(
        '{"accessToken":"api-access","refreshToken":"api-refresh"}',
        200,
        headers: {Headers.contentTypeHeader: ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('repository mengirim username/password ke POST /auth/login', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));
    final adapter = _LoginAdapter();
    dio.httpClientAdapter = adapter;
    final session = await AuthRepository(dio: dio)
        .login(username: 'emilys', password: 'emilyspass');
    expect(adapter.submitted?['username'], 'emilys');
    expect(adapter.submitted?['password'], 'emilyspass');
    expect(session.access, 'api-access');
    expect(session.refresh, 'api-refresh');
  });

  test('401 memicu refresh sekali lalu mengulang request', () async {
    final store = FakeTokenStore()
      ..access = 'old'
      ..refresh = 'old-refresh';
    final dio = buildApiClient(store, _WorkingRefreshRepo());
    final adapter = _FakeAdapter();
    dio.httpClientAdapter = adapter;

    final response = await dio.get('/auth/me');
    expect(response.statusCode, 200);
    expect(adapter.calls, 2);
    expect(store.access, 'renewed-access');
    expect(store.refresh, 'renewed-refresh');
  });

  test('refresh gagal -> hapus token dan minta login ulang', () async {
    final store = FakeTokenStore()
      ..access = 'old'
      ..refresh = 'old-refresh';
    var expired = false;
    final dio = buildApiClient(store, _FailingRefreshRepo(),
        onSessionExpired: () => expired = true);
    dio.httpClientAdapter = _FakeAdapter();

    await expectLater(dio.get('/auth/me'), throwsA(isA<DioException>()));
    expect(store.access, isNull);
    expect(store.refresh, isNull);
    expect(expired, isTrue);
  });
}
