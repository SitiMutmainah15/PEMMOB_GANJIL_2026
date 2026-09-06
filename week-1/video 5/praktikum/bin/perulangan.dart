import 'package:praktikum/praktikum.dart' as praktikum;
import 'dart:io';
void main(List<String> arguments) {
  int i = 0;
 // while (i < 5) {
// print("Perulangan ke-${i+1}");
//    i++;
  //}
  //mencetak sebanyak 5 kali 
  /*do {
    print("Perulangan ke-${i+1}");
    i++;
  } while (i == 5);
  */
  //menjalankan min 1 kali walaupun kondisi tidak terpenuhi 
  for (i = 0; i < 5; i++) {
    print("Perulangan");
  }

  for (int j = 0; j < 5; j++) {
    if (j % 2 == 0) {
      continue; //skip perulangan ke-3
    }
    print("j adalah $j");
  }
}