import 'package:praktikum/praktikum.dart' as praktikum;

late int a; //var di atas tidak ada nilai awal,a ada di main
void main(List<String> arguments) {
  int a = 10;
  double b = 3.14;
  String c = 'Hello, Dart!';
  bool d = true;

  print(a);
  print(b);
  print(c);
  print(d);

  String e = '12';
  int f = a+int.parse(e);
  print(f); //jika string ini harus di parse agar bisa punya nilai int

  List<String> name = ['Iin', 'Theo', 'Yesa'];
  //index 0,1,2

  print(name); 
  //jika mencetak semua

  print('nama yang kedua adalah: ${name[2]}'); 
  //jika ingin menuju ke index ke berapa

  List<int> angka = [1,2,3]; 
  //jika list harus memiliki 1 tipe data saja

  print(angka);
  print('jumlah elemen list angka: ${angka.length}'); 
  //untuk menghitung jumlah data .length

  Map<String, int> Umur = {
    'Iin' : 20,
    'Theo' : 23,
    'Yesa' : 20,
  }; 
  print(Umur);
  /* ini bisa digabungkan beberapa tipe data
  jika ingin menampilkan salah satu array
  bisa dengan ${umur['Iin']} */

  dynamic g = 'Hello';
  print(g);
  g = 42;
  print(g);
  g = true;
  print(g);
  g = [1,2,3];
  print(g);
  g = {'name': 'John', 'age': 30};
  print(g);
  /*dynamic bisa menggunakan banyak tipe data (otomatis)
  tetapi akan membebani memori*/

}