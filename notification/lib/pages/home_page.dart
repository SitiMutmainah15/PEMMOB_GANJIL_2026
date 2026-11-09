import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/api_errors.dart';
import '../messaging/notification_inbox.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../providers/push_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _subscribed = true;
  String? _apiMessage;

  Future<void> _toggleTopic(bool value) async {
    try {
      value ? await subscribeTopic() : await unsubscribeTopic();
      if (mounted) setState(() => _subscribed = value);
    } catch (e) {
      _snack('Gagal mengubah topik: ${friendlyErrorMessage(e)}');
    }
  }

  Future<void> _callApi() async {
    setState(() => _apiMessage = 'Memanggil API...');
    try {
      final response = await ref.read(apiClientProvider).get('/auth/me');
      final data = Map<String, dynamic>.from(response.data as Map);
      if (mounted) setState(() =>
          _apiMessage = 'Login API berhasil: ${data['username']}');
    } catch (e) {
      if (mounted) setState(() => _apiMessage = friendlyErrorMessage(e));
    }
  }

  Future<void> _sendDemo() async {
    try {
      await sendDemoNotification();
      _snack('Notifikasi contoh terkirim. Periksa banner dari atas layar.');
    } catch (e) {
      // Meski izin banner ditolak, entri list masih tersimpan.
      _snack('Notifikasi tersimpan, banner belum tampil: ${friendlyErrorMessage(e)}');
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final push = ref.watch(pushSetupProvider);
    final ready = push.value == PushStatus.ready;

    return AnimatedBuilder(
      animation: notificationInbox,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Pengumuman Kampus'),
          actions: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  tooltip: 'Lihat notifikasi',
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push(Routes.notifications),
                ),
                if (notificationInbox.unreadCount > 0)
                  Positioned(
                    right: 3,
                    top: 1,
                    child: IgnorePointer(
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          notificationInbox.unreadCount > 9
                              ? '9+'
                              : '${notificationInbox.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Selamat datang!',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Notifikasi yang belum dibaca akan muncul pada ikon lonceng.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _sendDemo,
              icon: const Icon(Icons.add_alert),
              label: const Text('Tes notifikasi pop-up'),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Notifikasi belum dibaca (${notificationInbox.unreadCount})',
                  style: Theme.of(context).textTheme.titleMedium),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.notifications),
            ),
            if (notificationInbox.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada notifikasi masuk.'),
              )
            else
              for (final notice in notificationInbox.items.take(3))
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(notice.title),
                    subtitle: Text(notice.body),
                    onTap: () async {
                      await notificationInbox.markAsRead(notice.id);
                      if (context.mounted) {
                        context.push(
                          notice.route == '/'
                              ? Routes.announcementOf(notice.id)
                              : notice.route,
                          extra: notice,
                        );
                      }
                    },
                  ),
                ),
            const SizedBox(height: 20),
            Text('Pengujian API & Firebase',
                style: Theme.of(context).textTheme.titleMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status FCM: ${push.when(
                      data: (s) => switch (s) {
                        PushStatus.ready => 'siap',
                        PushStatus.permissionDenied => 'izin notifikasi ditolak',
                        PushStatus.firebaseNotConfigured =>
                          'Firebase belum dikonfigurasi',
                      },
                      loading: () => 'menyiapkan...',
                      error: (e, _) => 'gagal: ${friendlyErrorMessage(e)}',
                    )}'),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<String?>(
                      valueListenable: latestFcmToken,
                      builder: (context, token, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FCM token: ${maskToken(token)}'),
                          const SizedBox(height: 4),
                          OutlinedButton.icon(
                            onPressed: token == null || token.isEmpty
                                ? null
                                : () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: token),
                                    );
                                    _snack('Token FCM lengkap sudah disalin.');
                                  },
                            icon: const Icon(Icons.copy),
                            label: const Text('Salin token FCM'),
                          ),
                        ],
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Topik $topicPengumuman'),
                      value: _subscribed,
                      onChanged: ready ? _toggleTopic : null,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: _callApi,
                          child: const Text('Cek login API'),
                        ),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(pushSetupProvider),
                          child: const Text('Ulangi setup FCM'),
                        ),
                      ],
                    ),
                    if (_apiMessage != null) Text('API: $_apiMessage'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
