import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/campus_notification.dart';
import '../providers/notification_provider.dart';
import '../routes.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(notificationRepositoryProvider).items;
    final notifications = ref.read(manageNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: notices.isEmpty
          ? const Center(child: Text('Belum ada notifikasi baru.'))
          : ListView.builder(
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
                      await notifications.markAsRead(notice.id);
                      if (context.mounted) {
                        context.push(_routeFor(notice), extra: notice);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  String _routeFor(CampusNotification notice) =>
      notice.route == '/' ? Routes.announcementOf(notice.id) : notice.route;
}
