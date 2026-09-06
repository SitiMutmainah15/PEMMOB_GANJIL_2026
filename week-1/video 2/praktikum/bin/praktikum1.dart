import 'package:praktikum1/praktikum1.dart' as praktikum1;

void main(List<String> arguments) {
  //print('Hello world: ${praktikum1.calculate()}!');
  var nama = "iin";
  var umur = 20;
  var tinggi = "170"; //ini ditambahkan umur dengan angka tetap terbaca string
  var alamat = "Villa Bukit Tidar";

  //var iseng = umur+tinggi; error karena berbeda yang satu string satu int
  var iseng = umur + int.parse(tinggi);
  print("Nama: $nama");
  print("Nama: $umur");
  print("Nama: $alamat");
  print("Hasil iseng: $iseng");

}
