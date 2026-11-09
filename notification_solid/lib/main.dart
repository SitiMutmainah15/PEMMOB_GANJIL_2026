import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'domain/entities/campus_notification.dart';
import 'data/datasources/push_data_source.dart';
import 'presentation/pages/announcement_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/notification_page.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/push_provider.dart';
import 'presentation/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await PushDataSource.initializeFirebase();
    firebaseReady = true;
  } catch (error) {
    debugPrint('[Firebase] belum dikonfigurasi, FCM dinonaktifkan: $error');
  }

  final container = ProviderContainer(
    overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
  );
  await container.read(notificationRepositoryProvider).load();
  final push = container.read(pushDataSourceProvider);
  try {
    await push.initLocalNotifications();
  } catch (error) {
    debugPrint('[LocalNotification] tidak dapat diinisialisasi: $error');
  }

  final router = buildRouter(container);
  push.setNotificationNavigator(router.go);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: CampusNotifyApp(router: router),
    ),
  );

  if (firebaseReady) {
    push.listenForeground(router.go);
    await push.handleTerminated(router.go);
  } else {
    push.openPendingLocalNotification();
  }
}

GoRouter buildRouter(ProviderContainer container) {
  final authChanges = ValueNotifier<int>(0);
  container.listen(authStateProvider, (_, _) => authChanges.value++);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final auth = container.read(authStateProvider);
      if (auth.isLoading && !auth.hasValue) return null;
      final loggedIn = auth.value ?? false;
      final goingLogin = state.matchedLocation == Routes.login;
      if (!loggedIn && !goingLogin) return Routes.login;
      if (loggedIn && goingLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
      GoRoute(
        path: Routes.notifications,
        builder: (_, _) => const NotificationPage(),
      ),
      GoRoute(
        path: Routes.announcement,
        builder: (_, state) => AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
          notice: state.extra is CampusNotification
              ? state.extra as CampusNotification
              : null,
        ),
      ),
    ],
  );
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key, required this.router});

  final GoRouter router;

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp>
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
      ref.read(notificationRepositoryProvider).load();
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
