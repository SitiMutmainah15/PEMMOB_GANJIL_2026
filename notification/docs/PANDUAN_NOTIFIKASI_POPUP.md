# Cara Menampilkan Notifikasi Pop-up seperti WhatsApp (Android)

## Apa yang diubah?
- Channel Android baru: `pengumuman_popup_v2` dengan `Importance.max`, suara, dan getar.
- `AndroidManifest.xml` menetapkan channel tersebut sebagai default untuk Firebase Cloud Messaging.
- Pesan **saat aplikasi terbuka** ditampilkan oleh `flutter_local_notifications` agar banner dapat muncul.
- Pesan **saat aplikasi di-background** yang menggunakan payload `notification` ditampilkan Android/FCM melalui channel default.
- List notifikasi, angka di lonceng, dan login API tetap seperti sebelumnya.

## Menjalankan di Android Studio
1. Extract ZIP, buka folder `notification` yang berisi `pubspec.yaml`.
2. Di terminal, jalankan `flutter pub get`.
3. Sambungkan Samsung Android dan aktifkan USB Debugging.
4. Periksa `flutter devices` untuk melihat ID perangkat.
5. Jalankan `flutter run -d ID_PERANGKAT`.
6. Login `emilys` / `emilyspass`, izinkan notifikasi saat diminta.
7. Tekan **Tes notifikasi pop-up** sambil aplikasi terbuka. Jika izin dan kategori benar, banner akan terlihat dari bagian atas layar.

## Jika notifikasi masuk tetapi tidak muncul dari atas (Samsung One UI)
1. Buka **Pengaturan > Notifikasi > Notifikasi aplikasi > campus_notify** lalu aktifkan **Izinkan notifikasi**.
2. Aktifkan kategori **Pengumuman Kampus (Pop-up)**, dan aktifkan **Tampilkan sebagai pop-up / Show as pop-up** serta suara jika opsi tersedia.
3. Bila menu kategori tidak terlihat, buka **Pengaturan > Notifikasi > Pengaturan lanjutan** lalu aktifkan **Kelola kategori notifikasi untuk setiap aplikasi**, setelah itu kembali ke pengaturan aplikasi. Nama menu dapat berbeda menurut One UI.
4. Cek **Jangan Ganggu**, mode senyap, dan volume notifikasi.
5. Jika memakai ZIP baru tetapi belum muncul, lakukan **stop aplikasi** kemudian `flutter run` ulang (perubahan AndroidManifest dan channel tidak cukup lewat hot reload).
6. Pengaturan notifikasi Android adalah pilihan pengguna, aplikasi tidak dapat memaksa semua perangkat menampilkan banner.

## Tes Firebase Console asli
1. Di halaman utama aplikasi, pastikan `Status FCM: siap` dan klik **Salin token FCM**.
2. Buka https://console.firebase.google.com/ > project `notification-3e3fc` > **Messaging**.
3. Buat notifikasi berjudul `Tes banner Firebase`, isi `Halo, notifikasi dari Firebase!`.
4. Klik **Send test message**, tempel token yang tadi disalin, lalu **Test**.
5. **Tes 1: foreground**: biarkan aplikasi terbuka di HP. Kode Flutter menampilkan notifikasi lokal sebagai banner.
6. **Tes 2: background**: tekan tombol Home tanpa force-stop aplikasi, kirim pesan tes baru. FCM/Android akan menampilkan pemberitahuan pada channel pop-up.
7. Periksa angka pada ikon lonceng, daftar pesan, dan penghapusan dari daftar setelah dibaca.

## Catatan teknis
- Jika Anda pernah menonaktifkan kategori notifikasi di Android, periksa ulang pengaturannya setelah memasang versi baru.
- Channel baru memakai ID baru karena importance pada channel Android yang sudah dibuat tidak dapat ditingkatkan lewat kode.
- Bunyi dan tampilan banner bergantung pada izin serta setelan notifikasi perangkat.
- ZIP ini tidak mengubah project Firebase ataupun akun login demo.
