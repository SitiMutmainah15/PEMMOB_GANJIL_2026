import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_inbox.dart';
import 'route_parser.dart';

const topicPengumuman = 'pengumuman-kampus';

// Channel BARU khusus banner/pop-up di atas layar.
// Android tidak memperbolehkan aplikasi menaikkan importance channel lama.
// Karena itu ID dibuat berbeda agar pengguna versi sebelumnya ikut mendapat
// channel prioritas tinggi (sesuai pengaturan izin di HP masing-masing).
const _channel = AndroidNotificationChannel(
  'pengumuman_popup_v2',
  'Pengumuman Kampus (Pop-up)',
  description: 'Pesan masuk ditampilkan sebagai banner pop-up dan berbunyi',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

final _local = FlutterLocalNotificationsPlugin();
final latestFcmToken = ValueNotifier<String?>(null);
String? pendingDeepLink;
void Function(String route)? _navigate;

String maskToken(String? token) {
  if (token == null || token.isEmpty) return '-';
  return token.length <= 12 ? '$token...' : '${token.substring(0, 12)}...';
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Simpan ke storage dari isolate latar belakang, tanpa menyentuh UI.
  await NotificationInbox.saveInBackground(
    CampusNotification.fromMessage(message),
  );
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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

/// Notifikasi lokal bisa dipakai bahkan sebelum Firebase dikonfigurasi.
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
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);

  final launch = await _local.getNotificationAppLaunchDetails();
  if (launch?.didNotificationLaunchApp ?? false) {
    final payload = launch!.notificationResponse?.payload;
    if (payload != null) {
      final separator = payload.indexOf('|');
      if (separator != -1) {
        final id = payload.substring(0, separator);
        await notificationInbox.markAsRead(id);
        pendingDeepLink = payload.substring(separator + 1);
      } else {
        pendingDeepLink = payload;
      }
    }
  }
}

Future<void> configureFcmForeground() => FirebaseMessaging.instance
    .setForegroundNotificationPresentationOptions(
  alert: false, badge: true, sound: false,
);

Future<void> _requestLocalPermission() async {
  await _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  await _local
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
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

/// Tombol demo di beranda: untuk memeriksa pop-up atas, list, badge, bunyi.
Future<void> sendDemoNotification() async {
  final id = DateTime.now().microsecondsSinceEpoch.toString();
  final notification = CampusNotification(
    id: id,
    title: 'Pengumuman baru',
    body: 'Contoh notifikasi tugas Flutter minggu depan.',
    route: '/pengumuman/$id',
    receivedAt: DateTime.now(),
  );
  await notificationInbox.add(notification);
  await _showBanner(notification);
}

StreamSubscription<String>? _tokenRefreshSub;

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  Future<void> handle(String token) async {
    latestFcmToken.value = token;
    debugPrint('[FCM] token=${maskToken(token)}');
    try {
      await onToken(token);
    } catch (e) {
      debugPrint('[FCM] gagal mengirim token: $e');
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
    final notice = CampusNotification.fromMessage(message);
    await notificationInbox.add(notice);
    await _showBanner(notice);
  });

  // User membuka notif sistem = dianggap sudah membaca.
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    final notice = CampusNotification.fromMessage(message);
    await notificationInbox.load();
    await notificationInbox.markAsRead(notice.id);
    go(notice.route);
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  _navigate = go;
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    final notice = CampusNotification.fromMessage(initial);
    await notificationInbox.load();
    await notificationInbox.markAsRead(notice.id);
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
  notificationInbox.markAsRead(id);
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
