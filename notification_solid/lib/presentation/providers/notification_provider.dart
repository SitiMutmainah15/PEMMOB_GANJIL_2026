import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notification_local_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/usecases/manage_notifications.dart';

final notificationRepositoryProvider =
    ChangeNotifierProvider<NotificationRepositoryImpl>(
      (ref) =>
          NotificationRepositoryImpl(storage: NotificationLocalDataSource()),
    );

final manageNotificationsProvider = Provider<ManageNotifications>(
  (ref) => ManageNotifications(ref.watch(notificationRepositoryProvider)),
);
