import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/push_data_source.dart';
import 'notification_provider.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);

enum PushStatus { firebaseNotConfigured, permissionDenied, ready }

String maskFcmToken(String? token) {
  if (token == null || token.isEmpty) return '-';
  return token.length <= 12 ? '$token...' : '${token.substring(0, 12)}...';
}

final pushDataSourceProvider = Provider<PushDataSource>(
  (ref) => PushDataSource(
    notificationRepository: ref.watch(notificationRepositoryProvider),
  ),
);

final pushSetupProvider = FutureProvider<PushStatus>((ref) async {
  if (!ref.watch(firebaseReadyProvider)) {
    return PushStatus.firebaseNotConfigured;
  }

  final push = ref.watch(pushDataSourceProvider);
  final granted = await push.requestNotificationPermission();
  if (!granted) return PushStatus.permissionDenied;

  await push.initFcmToken(onToken: (_) async {});
  return PushStatus.ready;
});
