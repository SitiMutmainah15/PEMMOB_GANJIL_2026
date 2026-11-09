import '../entities/campus_notification.dart';

abstract interface class NotificationRepository {
  List<CampusNotification> get items;
  int get unreadCount;

  Future<void> load();
  Future<void> add(CampusNotification notification);
  Future<void> markAsRead(String id);
  Future<void> clear();
}
