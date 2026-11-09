import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/entities/campus_notification.dart';

class CampusNotificationModel {
  const CampusNotificationModel({
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

  factory CampusNotificationModel.fromEntity(CampusNotification entity) =>
      CampusNotificationModel(
        id: entity.id,
        title: entity.title,
        body: entity.body,
        route: entity.route,
        receivedAt: entity.receivedAt,
      );

  factory CampusNotificationModel.fromJson(Map<String, dynamic> data) =>
      CampusNotificationModel(
        id: data['id'] as String,
        title: data['title'] as String,
        body: data['body'] as String,
        route: data['route'] as String,
        receivedAt: DateTime.parse(data['receivedAt'] as String),
      );

  factory CampusNotificationModel.fromMessage(RemoteMessage message) =>
      CampusNotificationModel(
        id: message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}',
        title:
            message.notification?.title ??
            message.data['title'] ??
            'Pengumuman baru',
        body: message.notification?.body ?? message.data['body'] ?? '',
        route: routeFromMessage(message.data),
        receivedAt: DateTime.now(),
      );

  CampusNotification toEntity() => CampusNotification(
    id: id,
    title: title,
    body: body,
    route: route,
    receivedAt: receivedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'route': route,
    'receivedAt': receivedAt.toIso8601String(),
  };
}

String routeFromMessage(Map<String, dynamic> data) {
  final raw = data['route'];
  if (raw is String && raw.trim().isNotEmpty) {
    final route = raw.trim();
    return route.startsWith('/') ? route : '/$route';
  }
  final id = data['id'];
  if (id is String && id.isNotEmpty) return '/pengumuman/$id';
  return '/';
}
