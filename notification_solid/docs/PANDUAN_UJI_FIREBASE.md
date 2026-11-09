# Panduan Uji Firebase Cloud Messaging (FCM)

## Tujuan
Mendemonstrasikan bahwa notifikasi benar-benar dikirim dari Firebase Console ke aplikasi Flutter di HP Android. Tombol **Kirim notifikasi contoh** hanya simulasi lokal, **bukan** pesan Firebase.

## A. Persiapan di HP
1. Hubungkan HP dengan kabel data dan aktifkan USB Debugging.
2. Dari folder project `notification`, jalankan `flutter devices`; pastikan HP muncul sebagai Android.
3. Jalankan `flutter run -d ID_PERANGKAT`, dengan ID dari hasil `flutter devices`.
4. Pastikan internet aktif dan Google Play services tersedia pada HP.
5. Login dengan API demo (username `emilys`, password `emilyspass`).
6. Setujui izin notifikasi. Di halaman utama, cek `Status FCM: siap`.
7. Token yang panjang akan ditampilkan terpotong. Tekan **Salin token FCM** untuk menyalin token lengkap.

## B. Pengujian dari Firebase Console
1. Buka https://console.firebase.google.com/ dan pilih project **notification-3e3fc**. Akun Google harus mempunyai akses ke project tersebut.
2. Buka **Messaging** (terkadang di menu *DevOps & Engagement*), lalu buat campaign **Notifications** / **Firebase Notification messages**.
3. Isi judul misalnya `Pengumuman Baru` dan deskripsi `Jadwal kuliah diganti ke jam 13.00`.
4. Pilih **Send test message**; tempel token FCM lengkap dari HP.
5. Tekan tombol **Home** pada HP supaya aplikasi berada di latar belakang, bukan ditutup paksa.
6. Klik **Test** di Firebase Console. Periksa panel notifikasi HP.
7. Buka aplikasi kembali; periksa apakah pesan tampil pada daftar notifikasi dan badge lonceng bertambah. Ketuk satu entri untuk menghapusnya dari daftar belum dibaca.

## C. Pengujian bonus suara
- Aktifkan izin notifikasi untuk aplikasi.
- Periksa volume notifikasi dan mode senyap / Do Not Disturb HP.
- Di pengaturan notifikasi aplikasi, periksa channel **Pengumuman Kampus**.
- Suara diatur oleh channel dan pengaturan HP; keberhasilan suara tidak dapat dipastikan tanpa uji langsung.

## D. Jika status FCM gagal
- Pastikan `android/app/google-services.json` berasal dari project Firebase yang akan dipakai mengirim, dan Android package name-nya `id.ac.polinema.campus_notify`.
- Pastikan HP terhubung internet dan memiliki Google Play services.
- Periksa izin notifikasi di pengaturan Android.
- Tekan **Ulangi setup FCM** di aplikasi.
- Jika token kosong, periksa log Flutter di terminal (`flutter run`) untuk pesan `[Firebase]` atau error FCM.
- Jika Firebase Console tidak bisa membuka project `notification-3e3fc`, kamu perlu akses dari pemilik project atau mendaftarkan aplikasi ke project Firebase milikmu sendiri dan mengunduh file konfigurasi baru.

## E. Perbedaan jenis pengujian
| Uji | Asal pesan | Membutuhkan Firebase? |
|---|---|---|
| **Kirim notifikasi contoh** | Aplikasi Flutter (lokal) | Tidak |
| **Send test message** | Firebase Console melalui FCM | Ya |

Panduan resmi: https://firebase.google.com/docs/cloud-messaging/flutter/get-started
