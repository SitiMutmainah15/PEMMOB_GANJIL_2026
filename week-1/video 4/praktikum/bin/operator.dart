import 'package:praktikum/praktikum.dart' as praktikum;
import 'dart:io';
/*import dart:io untuk bisa menggunakan stdin.readLineSync()
untuk membaca input dari user di terminal*/
void main(List<String> arguments) {
  print('Masukkan angka pertama:');
  String? input1 = stdin.readLineSync();
  /*kenapa ada tanda ? karena input bisa null, 
  jadi harus di cek dulu*/

  print('Masukkan angka kedua:');
  String? input2 = stdin.readLineSync();  

  if (input1 != null && input2 != null) {
    int angka1 = int.parse(input1);
    int angka2 = int.parse(input2);

    int penjumlahan = angka1 + angka2;
    int pengurangan = angka1 - angka2;
    int perkalian = angka1 * angka2;
    double pembagian = angka1 / angka2;

    print('Hasil penjumlahan: $penjumlahan');
    print('Hasil pengurangan: $pengurangan');
    print('Hasil perkalian: $perkalian');
    print('Hasil pembagian: $pembagian');
  } else {
    print('Input tidak valid.');
  }
}