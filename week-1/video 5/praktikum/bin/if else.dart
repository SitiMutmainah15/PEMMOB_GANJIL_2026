import 'package:praktikum/praktikum.dart' as praktikum;
import 'dart:io';
void main(List<String> arguments) {

  //jika hanya 1 variabel maka bisa menggunakan if else
  print('Masukkan nama Anda:');
  String? name = stdin.readLineSync();  
  if (name == null || name.isNotEmpty) {
    print("Nama anda adalah $name");
  } else {
    print("Nama saya adalah tidak diketahui");
  }

  //disederhanakan
  String status = name != null && name.isNotEmpty ? "Nama anda adalah $name" : "Nama saya adalah tidak diketahui";
  print("Nama anda adalah $status");

  
}