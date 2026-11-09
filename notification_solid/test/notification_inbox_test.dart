import 'package:campus_notify/data/datasources/notification_local_data_source.dart';
import 'package:campus_notify/data/repositories/notification_repository_impl.dart';
import 'package:campus_notify/domain/entities/campus_notification.dart';
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
  test('notifikasi masuk list, badge berubah dan dibaca hilang', () async {
    final storage = FakeInboxStorage();
    final inbox = NotificationRepositoryImpl(storage: storage);
    await inbox.load();

    final first = CampusNotification(
      id: '1',
      title: 'Tugas',
      body: 'Kumpulkan laporan',
      route: '/pengumuman/1',
      receivedAt: DateTime(2026, 11, 2),
    );
    final second = CampusNotification(
      id: '2',
      title: 'Kelas',
      body: 'Pindah ruangan',
      route: '/pengumuman/2',
      receivedAt: DateTime(2026, 11, 2),
    );

    await inbox.add(first);
    await inbox.add(second);
    await inbox.add(first);
    expect(inbox.unreadCount, 2);

    await inbox.markAsRead(first.id);
    expect(inbox.unreadCount, 1);
    expect(inbox.items.single.id, '2');

    final afterRestart = NotificationRepositoryImpl(storage: storage);
    await afterRestart.load();
    expect(afterRestart.unreadCount, 1);

    await afterRestart.markAsRead(second.id);
    expect(afterRestart.unreadCount, 0);
    expect(afterRestart.items, isEmpty);
  });
}
