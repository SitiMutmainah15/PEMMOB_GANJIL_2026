# Lirik Lagu - Week 5

Project Flutter sederhana untuk menampilkan lirik dan mencoba pemutar audio lokal.

## Menjalankan project

1. Jalankan `flutter pub get`.
2. Jalankan project dengan `flutter run`.
3. Tombol play akan memainkan `assets/demo_audio.wav` sebagai audio demo.

## Mengganti audio demo

Jika mempunyai file audio yang boleh digunakan, simpan file tersebut di folder `assets`.
Contoh nama file: `lagu_saya.mp3`.

Tambahkan file ke bagian `assets` pada `pubspec.yaml`, lalu ubah bagian berikut pada `main.dart`:

`AssetSource('demo_audio.wav')`

menjadi:

`AssetSource('lagu_saya.mp3')`

Setelah mengganti asset, jalankan kembali `flutter pub get`.
