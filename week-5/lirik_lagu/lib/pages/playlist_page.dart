import 'package:flutter/material.dart';
import '../widgets/song_card.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List<String> playlist = ['Bertaut', 'Sorai', 'Rumpang', 'Rayuan Perempuan Gila'];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  static Widget albumPage(String nama, IconData icon) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60),
            Text(nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  static Widget albumCard(String nama) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.album_rounded, size: 55, color: Color(0xffA94B72)),
          const SizedBox(height: 8),
          Text(nama),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Library'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Lagu'),
            Tab(text: 'Album'),
            Tab(text: 'Playlist'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              SongCard(judul: 'Bertaut', artis: 'Nadin Amizah'),
              SongCard(judul: 'Sorai', artis: 'Nadin Amizah'),
              SongCard(judul: 'Rumpang', artis: 'Nadin Amizah'),
            ],
          ),
          Column(
            children: [
              SizedBox(
                height: 180,
                child: PageView(
                  children: [
                    albumPage('Bertaut', Icons.album),
                    albumPage('Selamat Ulang Tahun', Icons.music_note),
                  ],
                ),
              ),
              const Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('Pop')),
                  Chip(label: Text('Indie')),
                  Chip(label: Text('Acoustic')),
                  Chip(label: Text('Favorite')),
                ],
              ),
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  children: [
                    albumCard('Bertaut'),
                    albumCard('Sorai'),
                    albumCard('Rumpang'),
                    albumCard('Taruh'),
                  ],
                ),
              ),
            ],
          ),
          ReorderableListView(
            padding: const EdgeInsets.all(16),
            onReorder: (lama, baru) {
              setState(() {
                if (baru > lama) baru--;
                final item = playlist.removeAt(lama);
                playlist.insert(baru, item);
              });
            },
            children: [
              for (final lagu in playlist)
                ListTile(
                  key: ValueKey(lagu),
                  leading: const Icon(Icons.drag_handle),
                  title: Text(lagu),
                  trailing: const Icon(Icons.music_note),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
