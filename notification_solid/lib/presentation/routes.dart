abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const notifications = '/notifikasi';
  static const announcement = '/pengumuman/:id';

  static String announcementOf(String id) => '/pengumuman/$id';
}
