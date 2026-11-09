import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'route_parser.dart';

/// Satu notifikasi yang belum dibaca.
class CampusNotification {
  const CampusNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    required this.receivedAt,
  });

  final String id;
  final String title;
  final String body;
  final String route;
  final DateTime receivedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'route': route,
    'receivedAt': receivedAt.toIso8601String(),
  };

  factory CampusNotification.fromJson(Map<String, dynamic> data) =>
      CampusNotification(
        id: data['id'] as String,
        title: data['title'] as String,
        body: data['body'] as String,
        route: data['route'] as String,
        receivedAt: DateTime.parse(data['receivedAt'] as String),
      );

  factory CampusNotification.fromMessage(RemoteMessage message) =>
      CampusNotification(
        id: message.messageId ??
            '${DateTime.now().microsecondsSinceEpoch}',
        title: message.notification?.title ??
            message.data['title'] ?? 'Pengumuman baru',
        body: message.notification?.body ?? message.data['body'] ?? '',
        route: routeFromMessage(message.data),
        receivedAt: DateTime.now(),
      );
}

/// Penyimpanan dipisah agar alur list dapat diuji tanpa perangkat HP.
abstract class InboxStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class SecureInboxStorage implements InboxStorage {
  static const _key = 'campus_unread_notifications';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
  @override
  Future<void> delete() => _storage.delete(key: _key);
}

/// Data notifikasi disimpan di perangkat agar tidak hilang saat app ditutup.
/// Notifikasi yang sudah dibaca dihapus dari list, bukan dari Firebase Console.
class NotificationInbox extends ChangeNotifier {
  NotificationInbox({InboxStorage? storage})
      : _storage = storage ?? SecureInboxStorage();

  final InboxStorage _storage;
  List<CampusNotification> _items = [];

  List<CampusNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.length;

  Future<void> load() async {
    try {
      final raw = await _storage.read();
      final data = raw == null ? <dynamic>[] : jsonDecode(raw) as List;
      _items = data.map((item) => CampusNotification.fromJson(
        Map<String, dynamic>.from(item as Map),
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('[Inbox] gagal membaca data: $e');
      _items = [];
      notifyListeners();
    }
  }

  Future<void> add(CampusNotification item) async {
    // Hindari notifikasi ganda ketika pesan yang sama diproses ulang.
    if (_items.any((existing) => existing.id == item.id)) return;
    _items = [item, ..._items];
    notifyListeners();
    await _save();
  }

  Future<void> markAsRead(String id) async {
    _items = _items.where((item) => item.id != id).toList();
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _items = [];
    notifyListeners();
    await _storage.delete();
  }

  Future<void> _save() => _storage.write(
    jsonEncode(_items.map((item) => item.toJson()).toList()),
  );

  /// Dipanggil dari isolate background (tidak memanggil notifyListeners).
  /// Saat aplikasi aktif lagi, halaman memanggil load().
  static Future<void> saveInBackground(CampusNotification item) async {
    final inbox = NotificationInbox();
    await inbox.load();
    await inbox.add(item);
  }
}

final notificationInbox = NotificationInbox();
