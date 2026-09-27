class Lirik {
  String judul;
  String lirikLagu;
  String artis;

  Lirik({
    required this.judul,
    required this.artis,
    required this.lirikLagu,
  });

  void tampilkanInfo() {
    print('Judul Lagu: $judul');
    print('Lirik Lagu: $lirikLagu');
    print('Artis: $artis');
  }
}

final Lirik lagBertaut = Lirik(
  judul: 'Bertaut',
  artis: 'Nadin Amizah',
  lirikLagu: '''
Bun, hidup berjalan seperti bajingan
Seperti landak yang tak punya teman
Ia menggonggong bak suara hujan
Dan kau pangeranku mengambil peran
Bun, kalau saat hancur, ku disayang
Apalagi saat ku jadi juara
Saat tak tahu arah, kau di sana
Menjadi gagah saat ku tak bisa
Sedikit kujelaskan tentangku dan kamu
Agar seisi dunia tahu
Keras kepalaku sama denganmu
Caraku marah, caraku tersenyum
Seperti detak jantung yang bertaut
Nyawaku nyala kar'na denganmu
Aku masih ada sampai di sini
Melihatmu kuat setengah mati
Seperti detak jantung yang bertaut
Nyawaku nyala kar'na denganmu
Bun, aku masih tak mengerti banyak hal
Semuanya berenang di kepala
Dan kau, dan semua yang kau tahu tentangnya
Menjadi jawab saat ku bertanya
Sedikit kujelaskan tentangku dan kamu
Agar seisi dunia tahu
Keras kepalaku sama denganmu
Caraku marah, caraku tersenyum
Seperti detak jantung yang bertaut
Nyawaku nyala kar'na denganmu
Aku masih ada sampai di sini
Melihatmu kuat setengah mati
Seperti detak jantung yang bertaut
Nyawaku nyala kar'na denganmu
Semoga lama hidupmu di sini
Melihatku berjuang sampai akhir
Seperti detak jantung yang bertaut
Nyawaku nyala kar'na denganmu
Hu-oh-oh, hu-uh-ho, hu-oh
''',
);