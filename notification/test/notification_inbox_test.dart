import 'package:campus_notify/messaging/notification_inbox.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeInboxStorage implements InboxStorage {
  String? saved;

  @override
  Future<String?> read() async => saved;
  @override
  Future<void> write(String value) async => saved = value;
  @override
  Future<void> delete() async => saved = null;
}

void main() {
  test('notif masuk list, badge bertambah, dibaca hilang, tetap tersimpan', () async {
    final storage = FakeInboxStorage();
    final inbox = NotificationInbox(storage: storage);
    await inbox.load();

    final first = CampusNotification(
      id: '1', title: 'Tugas', body: 'Kumpulkan laporan',
      route: '/pengumuman/1', receivedAt: DateTime(2026, 11, 2),
    );
    final second = CampusNotification(
      id: '2', title: 'Kelas', body: 'Pindah ruangan',
      route: '/pengumuman/2', receivedAt: DateTime(2026, 11, 2),
    );

    await inbox.add(first);
    await inbox.add(second);
    await inbox.add(first); // pesan sama tidak masuk dua kali
    expect(inbox.unreadCount, 2);

    await inbox.markAsRead(first.id);
    expect(inbox.unreadCount, 1);
    expect(inbox.items.single.id, '2');

    final afterRestart = NotificationInbox(storage: storage);
    await afterRestart.load();
    expect(afterRestart.unreadCount, 1);

    await afterRestart.markAsRead(second.id);
    expect(afterRestart.unreadCount, 0);
    expect(afterRestart.items, isEmpty);
  });
}
