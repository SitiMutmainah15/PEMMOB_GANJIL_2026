import 'package:campus_notify/data/datasources/token_local_data_source.dart';
import 'package:campus_notify/data/models/auth_session_model.dart';
import 'package:campus_notify/data/models/campus_notification_model.dart';
import 'package:campus_notify/domain/entities/auth_session.dart';
import 'package:campus_notify/domain/entities/campus_notification.dart';
import 'package:campus_notify/domain/repositories/auth_repository.dart';
import 'package:campus_notify/presentation/providers/api_errors.dart';
import 'package:campus_notify/presentation/providers/auth_provider.dart';
import 'package:campus_notify/presentation/providers/push_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenStore extends TokenLocalDataSource {
  String? access;
  String? refresh;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class FakeAuthRepository implements AuthRepository {
  bool loggedIn = false;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    if (username != 'emilys' || password != 'emilyspass') {
      final options = RequestOptions(path: '/auth/login');
      throw DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 400),
        type: DioExceptionType.badResponse,
      );
    }
    loggedIn = true;
    return const AuthSession(
      accessToken: 'demo-access',
      refreshToken: 'demo-refresh',
    );
  }

  @override
  Future<bool> hasSession() async => loggedIn;

  @override
  Future<void> logout() async {
    loggedIn = false;
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
    expect(maskFcmToken('abcdefghijklmnopqrstuvwxyz'), 'abcdefghijkl...');
    expect(maskFcmToken(null), '-');
  });

  test('model notifikasi bisa disimpan sebagai JSON', () {
    final notice = CampusNotification(
      id: 'abc',
      title: 'Ujian',
      body: 'Besok pukul 9',
      route: '/pengumuman/abc',
      receivedAt: DateTime(2026, 11, 2),
    );
    final model = CampusNotificationModel.fromEntity(notice);
    final restored = CampusNotificationModel.fromJson(
      model.toJson(),
    ).toEntity();
    expect(restored.id, 'abc');
    expect(restored.title, 'Ujian');
    expect(restored.route, '/pengumuman/abc');
  });

  group('sesi auth (tanpa mengakses internet)', () {
    late FakeTokenStore store;
    late FakeAuthRepository repository;
    late ProviderContainer container;

    setUp(() {
      store = FakeTokenStore();
      repository = FakeAuthRepository();
      container = ProviderContainer(
        overrides: [
          tokenLocalDataSourceProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });
    tearDown(() => container.dispose());

    test('login menyimpan token dari respons API', () async {
      expect(await container.read(authStateProvider.future), isFalse);
      await container
          .read(authStateProvider.notifier)
          .login('emilys', 'emilyspass');
      expect(container.read(authStateProvider).value, isTrue);
      expect(repository.loggedIn, isTrue);
    });

    test('login salah tidak mengubah status login', () async {
      await container.read(authStateProvider.notifier).login('salah', '123');
      final state = container.read(authStateProvider);
      expect(state.hasError, isTrue);
      expect(
        friendlyErrorMessage(state.error!),
        'Username atau kata sandi salah.',
      );
      expect(repository.loggedIn, isFalse);
    });
  });

  test('auth session model memvalidasi token respons', () {
    expect(() => AuthSessionModel.fromJson({}), throwsFormatException);
  });
}
