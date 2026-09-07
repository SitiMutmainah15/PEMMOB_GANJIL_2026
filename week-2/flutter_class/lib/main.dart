import 'package:flutter/material.dart';
import 'mahasiswa.dart';
import 'lirik.dart';

void main() {
  runApp(const Iin());
}

class Iin extends StatelessWidget {
  const Iin({super.key});

  @override
  Widget build(BuildContext context) {

    final mahasiswa = Mahasiswa(
      nama: 'Iin',
      umur: 20,
      kelas: 'TI-3C',
    );

    final lirik = lagBertaut;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),

      home: Scaffold(

        appBar: AppBar(
          title: const Text(
            'Lirik Lagu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),


        body: Container(
          padding: const EdgeInsets.all(20),

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                // ICON MUSIK
                const Icon(
                  Icons.music_note,
                  size: 20,
                  color: Colors.blue,
                ),


                const SizedBox(height: 10),


                // JUDUL
                Text(
                  lirik.judul,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                const SizedBox(height: 5),


                // ARTIS
                Text(
                  lirik.artis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),


                const SizedBox(height: 20),


                // LIRIK
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Text(
                        lirik.lirikLagu,

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}