> **Baru: Notifikasi pop-up seperti WhatsApp.** Saat aplikasi dibuka, notifikasi tampil sebagai banner lokal dengan channel prioritas maksimum. Saat aplikasi di-background, Firebase menggunakan channel default yang sama. Lihat `docs/PANDUAN_NOTIFIKASI_POPUP.md` untuk panduan khusus HP Samsung.

# Campus Notify — Tugas Notifikasi (Flutter Semester 5)

Project ini merupakan **pengembangan dari ZIP awal**. Fokusnya empat tugas:

1. **Login dari API**: `POST https://dummyjson.com/auth/login`, memakai Dio dan token asli dari API (bukan login mock).
2. **Notifikasi masuk list dan hilang saat dibaca**: pesan belum dibaca disimpan di perangkat; ketika ditekan, daftar berkurang dan halaman detail terbuka.
3. **Notifikasi pada ikon**: ikon lonceng di kanan atas menampilkan badge merah jumlah notifikasi yang belum dibaca.
4. **Bonus suara**: ketika notifikasi masuk, aplikasi mencoba menampilkan banner notifikasi dengan suara bawaan HP.

FCM dari project awal tetap dipertahankan. Ada tombol **Kirim notifikasi contoh** untuk menguji list, badge, dan suara, meski belum mengirim FCM sungguhan.

## Cara menjalankan

Buka folder `notification` pada VS Code / Android Studio:

```bash
flutter pub get
flutter run
```

Login dengan akun publik demo DummyJSON:

```text
Username : emilys
Password : emilyspass
```

**Internet diperlukan untuk login**. Login terhubung ke API DummyJSON, bukan backend kampus. Tekan **Cek login API** setelah masuk: aplikasi memanggil `GET /auth/me` menggunakan token yang tersimpan. API ini hanya menyediakan autentikasi demo, **bukan API penyimpanan notifikasi**.

## Cara demo ke dosen

1. Login memakai username/password di atas.
2. Di beranda, tekan **Kirim notifikasi contoh** dua kali.
3. Perhatikan **badge lonceng jadi 2**, dua item masuk list; HP bisa membunyikan suara notifikasi (jika tidak mode senyap dan izin diaktifkan).
4. Ketuk lonceng, lalu buka salah satu item: halaman detail tampil dan item tersebut **hilang dari list belum dibaca**.
5. Kembali ke beranda: badge berkurang menjadi 1. Buka item terakhir: badge hilang.
6. Untuk mendemonstrasikan dari Firebase sungguhan, kirim pesan FCM memakai Firebase Console atau backend yang punya akses ke proyek Firebase tersebut.

> **Catatan:** tombol demo hanya membuat notifikasi lokal di HP yang menjalankan aplikasi, bukan mengirim pesan ke perangkat lain. FCM background memerlukan Firebase yang sudah dikonfigurasi dan koneksi internet.

## Bagian kode penting

| File | Fungsi |
|---|---|
| `lib/data/auth_repository.dart` | POST login/refresh ke API DummyJSON |
| `lib/data/api_client.dart` | Kirim bearer token dan refresh bila 401 |
| `lib/data/token_store.dart` | Simpan token di secure storage |
| `lib/messaging/notification_inbox.dart` | Model + daftar notifikasi belum dibaca + penyimpanan |
| `lib/messaging/push_service.dart` | Terima FCM, banner dan suara, tombol simulasi |
| `lib/pages/home_page.dart` | Beranda, badge lonceng, tombol demo |
| `lib/pages/notification_page.dart` | Daftar notifikasi; klik = tandai dibaca |
| `lib/pages/announcement_page.dart` | Detail notifikasi yang dibuka |

### Firebase (untuk pengiriman asli)

- Di project awal ada `android/app/google-services.json`; pastikan file tersebut milik Firebase project yang dipakai saat mengirim FCM, dengan application ID `id.ac.polinema.campus_notify`.
- FCM menerima pesan berdasarkan token perangkat / topik `pengumuman-kampus`.
- Data yang dikirim bisa menggunakan format `docs/fcm-payload.json`.
- **DummyJSON tidak punya `POST /devices`**, sehingga pendaftaran token ke backend sengaja *tidak* dilakukan. Token ditampilkan terpotong demi keamanan, tetapi bisa disalin lengkap melalui tombol **Salin token FCM** pada halaman beranda. Untuk pengiriman FCM lewat server sungguhan, perlu backend Firebase yang terpisah.
- Jika suara tidak terdengar, periksa izin notifikasi, volume/mode senyap, dan pengaturan channel **Pengumuman Kampus** pada Android. HP menentukan apakah suara diputar.
- Jika aplikasi sedang ditutup sepenuhnya, perilaku background dipengaruhi oleh perangkat dan pengaturan sistem. Daftar disinkronkan ulang ketika aplikasi aktif.

## Pengujian

```bash
flutter analyze
flutter test
```

Uji login memakai HTTP adapter palsu pada `test/api_client_test.dart`, dan uji model/route/auth pada `test/auth_push_test.dart`. **Catatan: status pengujian di mesin pengembang perlu dijalankan lagi karena Flutter SDK tidak tersedia di lingkungan pengeditan ZIP ini.**

## Penyesuaian API sendiri (opsional)

Jika dosen memberi API kampus, ubah endpoint pada `lib/data/auth_repository.dart` dan base URL lewat:

```bash
flutter run --dart-define=API_BASE_URL=https://contoh-api-kampus.id
```

Respons API kampus harus disesuaikan dengan field token dan struktur permintaan yang ditentukan backend kampus; aplikasi default masih memakai format DummyJSON.


## Menguji notifikasi asli dari Firebase Console

Lihat juga `docs/PANDUAN_UJI_FIREBASE.md` untuk langkah terurut. Ringkasnya:

1. Jalankan aplikasi **di HP Android** (bukan Chrome), izinkan notifikasi, dan login.
2. Di beranda, tunggu **Status FCM: siap** dan token FCM muncul. Tekan **Salin token FCM**.
3. Buka Firebase Console dengan akun yang punya akses ke project `notification-3e3fc`.
4. Buka menu **Messaging** > buat campaign **Notifications**, isi judul/isi, lalu pilih **Send test message**. Tempel token yang disalin dan klik **Test**.
5. Sebelum mengirim, pindahkan aplikasi ke **background** dengan tombol Home di HP; **jangan** Force stop aplikasi.
6. Notifikasi sungguhan semestinya muncul di panel notifikasi HP. Buka lagi aplikasi untuk memeriksa daftar dan ikon lonceng.

Jika tidak memiliki akses ke project Firebase yang tercantum, buat project Firebase sendiri, daftarkan aplikasi Android dengan package `id.ac.polinema.campus_notify`, unduh `google-services.json`, lalu ganti file `android/app/google-services.json` dalam project. Pengiriman dari Firebase Console hanya dapat diuji pada project yang sesuai dengan file konfigurasi Android.

Jangan bagikan token perangkat secara publik. Token dapat berubah setelah reinstall atau reset data aplikasi.
