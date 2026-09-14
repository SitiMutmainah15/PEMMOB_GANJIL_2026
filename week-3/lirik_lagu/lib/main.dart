import 'package:flutter/material.dart';
import 'lirik.dart';

void main() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      ),
      home: const MusicHome(),
    );
  }
}

class MusicHome extends StatelessWidget {
  const MusicHome({super.key});

  @override
  Widget build(BuildContext context) {
    final lirik = lagBertaut; // ambil data dari lirik.dart

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade50,
        title: const Text(
          "My Music Space",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffFCE4EC), Color(0xffFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          // FIX OVERFLOW: bungkus seluruh Card dengan scroll
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Gambar sampul lagu dari assets
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/Nadin.jpg',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 15),
                    Text(
                      lirik.judul,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      lirik.artis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lirik lagu - bisa discroll sendiri (tinggi tetap 200)
                    Container(
                      height: 200,
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          lirik.lirikLagu,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Slider(
                      value: 40,
                      max: 100,
                      activeColor: Colors.pink,
                      onChanged: (value) {},
                    ),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("01:20"), Text("03:45")],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite),
                          color: Colors.pink,
                          iconSize: 35,
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 55,
                          height: 55,
                          child: FloatingActionButton(
                            backgroundColor: Colors.pink,
                            onPressed: () {},
                            child: const Icon(Icons.play_arrow),
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                          color: Colors.pink,
                          iconSize: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}