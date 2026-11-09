// API demo untuk tugas. Bisa diganti saat dosen menyediakan backend kampus:
// flutter run --dart-define=API_BASE_URL=https://alamat-api-kampus.com
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://dummyjson.com',
);
