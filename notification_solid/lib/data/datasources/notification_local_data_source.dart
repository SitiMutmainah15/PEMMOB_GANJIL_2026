import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class InboxStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class NotificationLocalDataSource implements InboxStorage {
  NotificationLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'campus_unread_notifications';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}
