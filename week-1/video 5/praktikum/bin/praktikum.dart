import 'package:praktikum/praktikum.dart' as praktikum;
import 'dart:io';
void main(List<String> arguments) {
  //print('Hello world: ${praktikum.calculate()}!');
  //String? name;
  //name="Iin";
  //print(name);
  //diijinkan tidak error karena ada ?
  //berlaku di semua tipe data

  //print("Nama saya adalah ${name ?? "tidak diketahui"}");
  //?? untuk mengecek apakah name null atau tidak
  //jika null maka akan menampilkan tidak diketahui

  print('Masukkan nama Anda:');
  String? name = stdin.readLineSync();
  //print("Nama saya adalah ${name ?? "tidak diketahui"}");
  print(
    "nama anda adalah : ${name == null || name.isEmpty ? "tidak diketahui" : name}"
    );
    //gunakan operator ternary untuk mengecek apakah name null atau kosong
    //jika null maka akan menampilkan tidak diketahui, jika tidak maka akan menampilkan name
}
