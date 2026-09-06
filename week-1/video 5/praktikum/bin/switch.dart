import 'package:praktikum/praktikum.dart' as praktikum;
import 'dart:io';
void main(List<String> arguments) {
  print('Masukkan nama Anda:');
  String? name = stdin.readLineSync();  
  //switch digunakan untuk mengecek beberapa kondisi, jika ada yang sesuai maka akan dieksekusi
  switch (name) {
    case null:
      print("Nama saya adalah tidak diketahui");
      break;
    case "":
      print("Nama saya adalah tidak diketahui");
      break;
    default:
      print("Nama anda adalah $name");
  }
}