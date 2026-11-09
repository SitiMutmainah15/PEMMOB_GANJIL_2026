import '../entities/campus_notification.dart';
import '../repositories/notification_repository.dart';

class ManageNotifications {
  const ManageNotifications(this._repository);

  final NotificationRepository _repository;

  Future<void> load() => _repository.load();
  Future<void> add(CampusNotification notification) =>
      _repository.add(notification);
  Future<void> markAsRead(String id) => _repository.markAsRead(id);
  Future<void> clear() => _repository.clear();
}
