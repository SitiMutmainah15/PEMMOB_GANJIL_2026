import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../messaging/push_service.dart';
import 'auth_provider.dart';

/// false bila google-services.json / GoogleService-Info.plist belum dipasang.
/// Login + secure storage tetap berjalan; fitur FCM dinonaktifkan.
/// Nilai sebenarnya di-override di main().
final firebaseReadyProvider = Provider<bool>((ref) => false);

/// Status inisialisasi FCM setelah login: izin + token + topik.
enum PushStatus { firebaseNotConfigured, permissionDenied, ready }

final pushSetupProvider = FutureProvider<PushStatus>((ref) async {
  if (!ref.watch(firebaseReadyProvider)) return PushStatus.firebaseNotConfigured;

  final granted = await requestNotificationPermission();
  if (!granted) return PushStatus.permissionDenied;

  // DummyJSON menyediakan login, BUKAN endpoint POST /devices.
  // Token FCM tetap ditampilkan (terpotong) untuk uji Firebase Console.
  await initFcmToken(onToken: (_) async {});
  return PushStatus.ready;
});
