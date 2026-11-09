import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/campus_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';
import '../models/campus_notification_model.dart';

class NotificationRepositoryImpl extends ChangeNotifier
    implements NotificationRepository {
  NotificationRepositoryImpl({InboxStorage? storage})
    : _storage = storage ?? NotificationLocalDataSource();

  final InboxStorage _storage;
  List<CampusNotification> _items = [];

  @override
  List<CampusNotification> get items => List.unmodifiable(_items);

  @override
  int get unreadCount => _items.length;

  @override
  Future<void> load() async {
    final raw = await _storage.read();
    if (raw == null) {
      _items = [];
    } else {
      try {
        final data = jsonDecode(raw) as List;
        _items = data
            .map(
              (item) => CampusNotificationModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ).toEntity(),
            )
            .toList();
      } on FormatException catch (error) {
        debugPrint('[Inbox] data notifikasi tidak valid: $error');
        _items = [];
      } on TypeError catch (error) {
        debugPrint('[Inbox] format data notifikasi tidak valid: $error');
        _items = [];
      }
    }
    notifyListeners();
  }

  @override
  Future<void> add(CampusNotification notification) async {
    if (_items.any((item) => item.id == notification.id)) return;
    _items = [notification, ..._items];
    notifyListeners();
    await _save();
  }

  @override
  Future<void> markAsRead(String id) async {
    _items = _items.where((item) => item.id != id).toList();
    notifyListeners();
    await _save();
  }

  @override
  Future<void> clear() async {
    _items = [];
    notifyListeners();
    await _storage.delete();
  }

  Future<void> _save() => _storage.write(
    jsonEncode(
      _items
          .map((item) => CampusNotificationModel.fromEntity(item).toJson())
          .toList(),
    ),
  );
}
