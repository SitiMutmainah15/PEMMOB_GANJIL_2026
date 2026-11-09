# Campus Notify

Project praktikum Flutter yang menerapkan **Layer-first Architecture**. Folder
dibagi berdasarkan tanggung jawab lapisan, bukan berdasarkan fitur.

## Struktur `lib/`

```text
lib/
├── data/
│   ├── datasources/  # DummyJSON, secure storage, Firebase dan notifikasi lokal
│   ├── models/       # Konversi JSON/FCM ke entitas domain
│   └── repositories/ # Implementasi kontrak repository domain
├── domain/
│   ├── entities/     # AuthSession dan CampusNotification
│   ├── repositories/# Kontrak yang tidak bergantung pada Flutter/plugin
│   └── usecases/     # Login, cek sesi, logout, dan operasi notifikasi
├── presentation/
│   ├── pages/        # Halaman login, beranda, daftar dan detail notifikasi
│   ├── providers/    # Dependency injection serta state dengan Riverpod
│   └── widgets/      # Widget badge lonceng
└── main.dart         # Komposisi aplikasi dan inisialisasi plugin
```

## SOLID dalam project

- **SRP:** data source menangani satu jenis sumber data; repository
  mengoordinasikan sumber data; halaman hanya menyajikan UI.
- **OCP/DIP:** provider menyuntikkan implementasi melalui kontrak
  `AuthRepository` dan `NotificationRepository`. Implementasi dapat diganti
  dengan fake saat pengujian tanpa mengubah use case.
- **ISP:** kontrak repository hanya memuat operasi sesi atau operasi notifikasi
  yang relevan.
- **LSP:** implementasi repository dan fake test dapat digunakan melalui
  kontrak yang sama.

Domain hanya memakai Dart dan entitas aplikasi. Dependensi Dio, Firebase,
secure storage, serta Flutter UI berada di luar domain.

## Fitur

- Login DummyJSON menggunakan `emilys` / `emilyspass`.
- Penyimpanan token melalui secure storage dan refresh token saat respons 401.
- FCM foreground/background, notifikasi lokal pop-up, suara, dan topik
  `pengumuman-kampus`.
- Notifikasi belum dibaca disimpan lokal; daftar dan badge diperbarui saat
  notifikasi diterima dan notifikasi dihapus dari daftar setelah dibaca.
- Tombol notifikasi contoh dapat digunakan tanpa Firebase.

Jalankan pemeriksaan dengan `flutter analyze` dan `flutter test`.