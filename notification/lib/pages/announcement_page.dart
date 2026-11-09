import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../messaging/notification_inbox.dart';
import '../routes.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id, this.notice});

  final String id;
  final CampusNotification? notice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.home),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notice?.title ?? 'Pengumuman #$id',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(notice?.body ?? 'Pengumuman telah dibuka dari notifikasi.'),
            const SizedBox(height: 20),
            const Text('Notifikasi sudah dibaca dan dihapus dari daftar belum dibaca.'),
          ],
        ),
      ),
    );
  }
}
