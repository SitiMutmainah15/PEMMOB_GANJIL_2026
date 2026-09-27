import 'package:flutter/material.dart';

class SongCard extends StatelessWidget {
  final String judul;
  final String artis;

  const SongCard({super.key, required this.judul, required this.artis});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/Nadin.jpg',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 60,
                  height: 60,
                  child: Icon(Icons.album, size: 40),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(artis),
                ],
              ),
            ),
            const Icon(Icons.play_arrow_rounded),
          ],
        ),
      ),
    );
  }
}
