import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'messaging/notification_inbox.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/notification_page.dart';
import 'providers/auth_provider.dart';
import 'providers/push_provider.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notificationInbox.load();

  // Fitur simulasi notifikasi tetap berjalan tanpa Firebase.
  try {
    await initLocalNotifications();
  } catch (e) {
    debugPrint('[LocalNotification] tidak dapat diinisialisasi: $e');
  }

  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    registerBackgroundHandler();
    await configureFcmForeground();
    firebaseReady = true;
  } catch (e) {
    debugPrint('[Firebase] belum dikonfigurasi, FCM dinonaktifkan: $e');
  }

  final container = ProviderContainer(
    overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
  );
  final router = buildRouter(container);
  setNotificationNavigator(router.go);

  runApp(UncontrolledProviderScope(
    container: container,
    child: CampusNotifyApp(router: router),
  ));

  if (firebaseReady) {
    listenForeground(router.go);
    await handleTerminated(router.go);
  } else {
    openPendingLocalNotification();
  }
}

GoRouter buildRouter(ProviderContainer container) {
  // Router dievaluasi ulang setiap status auth berubah (login/logout/expired).
  final authChanges = ValueNotifier<int>(0);
  container.listen(authStateProvider, (_, _) => authChanges.value++);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final auth = container.read(authStateProvider);
      if (auth.isLoading && !auth.hasValue) return null; // tunggu baca token
      final loggedIn = auth.value ?? false;
      final goingLogin = state.matchedLocation == Routes.login;
      if (!loggedIn && !goingLogin) return Routes.login;
      if (loggedIn && goingLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
      GoRoute(path: Routes.notifications, builder: (_, _) => const NotificationPage()),
      GoRoute(
        path: Routes.announcement,
        builder: (_, s) => AnnouncementPage(
          id: s.pathParameters['id'] ?? '',
          notice: s.extra is CampusNotification ? s.extra as CampusNotification : null,
        ),
      ),
    ],
  );
}

class CampusNotifyApp extends StatefulWidget {
  const CampusNotifyApp({super.key, required this.router});

  final GoRouter router;

  @override
  State<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends State<CampusNotifyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      notificationInbox.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: widget.router,
    );
  }
}
