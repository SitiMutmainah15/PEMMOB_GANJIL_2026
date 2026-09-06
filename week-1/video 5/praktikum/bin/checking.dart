import 'package:praktikum/praktikum.dart' as praktikum;
import 'dart:io';
void main(List<String> arguments) {
  int a = 10;
  int b = 20;

  print(a!=b); 
  print(identical(a, b)); 

  String nama1 = "Iin";
  String nama2 = "Iin";
  print(nama1==nama2);
  print(identical(nama1, nama2));
}