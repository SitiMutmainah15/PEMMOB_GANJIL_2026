import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../messaging/notification_inbox.dart';
import '../routes.dart';

/// Daftar hanya menampilkan notifikasi BELUM dibaca.
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: AnimatedBuilder(
        animation: notificationInbox,
        builder: (context, _) {
          final notices = notificationInbox.items;
          if (notices.isEmpty) {
            return const Center(
              child: Text('Belum ada notifikasi baru.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text(notice.title),
                  subtitle: Text(notice.body),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await notificationInbox.markAsRead(notice.id);
                    if (context.mounted) {
                      context.push(
                        notice.route == '/' ? Routes.announcementOf(notice.id) : notice.route,
                        extra: notice,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
