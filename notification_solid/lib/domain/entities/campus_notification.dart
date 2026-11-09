class CampusNotification {
  const CampusNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    required this.receivedAt,
  });

  final String id;
  final String title;
  final String body;
  final String route;
  final DateTime receivedAt;
}
