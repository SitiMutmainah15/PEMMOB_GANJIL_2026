import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/playlist_page.dart';
import 'pages/profile_page.dart';
import 'widgets/app_theme.dart';

void main() {
  runApp(
    const AppTheme(
      warnaUtama: Color(0xffA94B72),
      child: MusicApp(),
    ),
  );
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Music Space',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffA94B72),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int halamanAktif = 0;

  final List<Widget> halaman = const [
    HomePage(),
    PlaylistPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: halaman[halamanAktif],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: halamanAktif,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xffA94B72),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            halamanAktif = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded),
            label: 'Playlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
