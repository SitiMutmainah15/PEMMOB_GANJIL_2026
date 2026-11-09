import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/campus_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/campus_notification_model.dart';
import '../repositories/notification_repository_impl.dart';

const topicPengumuman = 'pengumuman-kampus';

const _channel = AndroidNotificationChannel(
  'pengumuman_popup_v2',
  'Pengumuman Kampus (Pop-up)',
  description: 'Pesan masuk ditampilkan sebagai banner pop-up dan berbunyi',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

final _local = FlutterLocalNotificationsPlugin();
StreamSubscription<String>? _tokenRefreshSub;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final repository = NotificationRepositoryImpl();
  await repository.load();
  await repository.add(CampusNotificationModel.fromMessage(message).toEntity());
}

class PushDataSource {
  PushDataSource({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository;

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: false,
          badge: true,
          sound: false,
        );
  }

  final NotificationRepository _notificationRepository;
  final latestFcmToken = ValueNotifier<String?>(null);

  String get topicName => topicPengumuman;

  String? pendingDeepLink;
  void Function(String route)? _navigate;

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        _openLocalPayload(response.payload);
      },
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final payload = launch!.notificationResponse?.payload;
      if (payload != null) {
        final separator = payload.indexOf('|');
        if (separator != -1) {
          final id = payload.substring(0, separator);
          await _notificationRepository.markAsRead(id);
          pendingDeepLink = payload.substring(separator + 1);
        } else {
          pendingDeepLink = payload;
        }
      }
    }
  }

  Future<bool> requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _requestLocalPermission() async {
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _local
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _showBanner(CampusNotification notification) async {
    await _requestLocalPermission();
    await _local.show(
      id: notification.id.hashCode & 0x7fffffff,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      ),
      payload: '${notification.id}|${notification.route}',
    );
  }

  Future<void> sendDemoNotification() async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final notification = CampusNotification(
      id: id,
      title: 'Pengumuman baru',
      body: 'Contoh notifikasi tugas Flutter minggu depan.',
      route: '/pengumuman/$id',
      receivedAt: DateTime.now(),
    );
    await _notificationRepository.add(notification);
    await _showBanner(notification);
  }

  Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
  }) async {
    Future<void> handle(String token) async {
      latestFcmToken.value = token;
      debugPrint('[FCM] token diterima');
      try {
        await onToken(token);
      } catch (error) {
        debugPrint('[FCM] gagal mengirim token: $error');
      }
    }

    // ignore: deprecated_member_use
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await handle(token);

    await _tokenRefreshSub?.cancel();
    // ignore: deprecated_member_use
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(handle);
    await subscribeTopic();
  }

  Future<void> subscribeTopic() =>
      FirebaseMessaging.instance.subscribeToTopic(topicPengumuman);

  Future<void> unsubscribeTopic() =>
      FirebaseMessaging.instance.unsubscribeFromTopic(topicPengumuman);

  void setNotificationNavigator(void Function(String route) go) {
    _navigate = go;
  }

  void openPendingLocalNotification() {
    final route = pendingDeepLink;
    if (route == null) return;
    pendingDeepLink = null;
    _goOrQueue(route);
  }

  void listenForeground(void Function(String route) go) {
    _navigate = go;

    FirebaseMessaging.onMessage.listen((message) async {
      final notice = CampusNotificationModel.fromMessage(message).toEntity();
      await _notificationRepository.add(notice);
      await _showBanner(notice);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final notice = CampusNotificationModel.fromMessage(message).toEntity();
      await _notificationRepository.load();
      await _notificationRepository.markAsRead(notice.id);
      go(notice.route);
    });
  }

  Future<void> handleTerminated(void Function(String route) go) async {
    _navigate = go;
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      final notice = CampusNotificationModel.fromMessage(initial).toEntity();
      await _notificationRepository.load();
      await _notificationRepository.markAsRead(notice.id);
      go(notice.route);
    }
    final pending = pendingDeepLink;
    if (pending != null) {
      pendingDeepLink = null;
      go(pending);
    }
  }

  void _openLocalPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final separator = payload.indexOf('|');
    if (separator == -1) {
      _goOrQueue(payload);
      return;
    }
    final id = payload.substring(0, separator);
    final route = payload.substring(separator + 1);
    unawaited(_notificationRepository.markAsRead(id));
    _goOrQueue(route);
  }

  void _goOrQueue(String route) {
    final go = _navigate;
    if (go != null) {
      go(route);
    } else {
      pendingDeepLink = route;
    }
  }
}
