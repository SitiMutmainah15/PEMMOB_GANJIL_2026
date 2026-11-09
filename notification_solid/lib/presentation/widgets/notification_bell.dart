import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notificationRepositoryProvider).unreadCount;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          tooltip: 'Lihat notifikasi',
          icon: const Icon(Icons.notifications_outlined),
          onPressed: onPressed,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 3,
            top: 1,
            child: IgnorePointer(
              child: CircleAvatar(
                radius: 9,
                backgroundColor: Colors.red,
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
