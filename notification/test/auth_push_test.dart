import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/messaging/notification_inbox.dart';
import 'package:campus_notify/messaging/push_service.dart';
import 'package:campus_notify/messaging/route_parser.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenStore extends TokenStore {
  String? access;
  String? refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => access;
  @override
  Future<String?> readRefresh() async => refresh;
  @override
  Future<void> clear() async => access = refresh = null;
}

class FakeAuthRepository extends AuthRepository {
  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    if (username != 'emilys' || password != 'emilyspass') {
      final opts = RequestOptions(path: '/auth/login');
      throw DioException(
        requestOptions: opts,
        response: Response(requestOptions: opts, statusCode: 400),
        type: DioExceptionType.badResponse,
      );
    }
    return const AuthSession(access: 'demo-access', refresh: 'demo-refresh');
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    if (refreshToken.isEmpty) throw Exception('Refresh token kosong');
    return const AuthSession(access: 'renewed-access', refresh: 'renewed-refresh');
  }
}

void main() {
  group('routeFromMessage', () {
    test('route kosong dan tanpa slash', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'id': '7'}), '/pengumuman/7');
    });
  });

  test('token FCM ditampilkan terpotong', () {
    expect(maskToken('abcdefghijklmnopqrstuvwxyz'), 'abcdefghijkl...');
    expect(maskToken(null), '-');
  });

  test('model notifikasi bisa disimpan sebagai JSON', () {
    final notice = CampusNotification(
      id: 'abc', title: 'Ujian', body: 'Besok pukul 9',
      route: '/pengumuman/abc', receivedAt: DateTime(2026, 11, 2),
    );
    final restored = CampusNotification.fromJson(notice.toJson());
    expect(restored.id, 'abc');
    expect(restored.title, 'Ujian');
    expect(restored.route, '/pengumuman/abc');
  });

  group('sesi auth (tanpa mengakses internet)', () {
    late FakeTokenStore store;
    late ProviderContainer container;

    setUp(() {
      store = FakeTokenStore();
      container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );
    });
    tearDown(() => container.dispose());

    test('login menyimpan token dari respons API', () async {
      expect(await container.read(authStateProvider.future), isFalse);
      await container.read(authStateProvider.notifier)
          .login('emilys', 'emilyspass');
      expect(container.read(authStateProvider).value, isTrue);
      expect(store.access, 'demo-access');
      expect(store.refresh, 'demo-refresh');
    });

    test('login salah tidak menyimpan token', () async {
      await container.read(authStateProvider.notifier).login('salah', '123');
      final state = container.read(authStateProvider);
      expect(state.hasError, isTrue);
      expect(friendlyErrorMessage(state.error!),
          'Username atau kata sandi salah.');
      expect(store.access, isNull);
    });
  });

  test('refresh kosong ditolak', () async {
    expect(FakeAuthRepository().refresh(''), throwsException);
  });
}
