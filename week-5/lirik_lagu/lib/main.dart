import 'package:audioplayers/audioplayers.dart';
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffA94B72),
        ),
      ),
      home: const MusicHome(),
    );
  }
}

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});

  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final lirik = lagBertaut;

  bool sedangDiputar = false;
  bool favorit = false;
  bool lirikTampil = false;

  Duration posisi = Duration.zero;
  Duration durasi = Duration.zero;

  @override
  void initState() {
    super.initState();

    audioPlayer.onDurationChanged.listen((nilai) {
      if (mounted) {
        setState(() {
          durasi = nilai;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((nilai) {
      if (mounted) {
        setState(() {
          posisi = nilai;
        });
      }
    });

    audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          sedangDiputar = false;
          posisi = Duration.zero;
        });
      }
    });
  }

  // Play dan Pause
  Future<void> putarLagu() async {
    if (sedangDiputar) {
      await audioPlayer.pause();

      setState(() {
        sedangDiputar = false;
      });
    } else {
      if (posisi == Duration.zero) {
        await audioPlayer.play(
          AssetSource('bertaut.mp3'),
        );
      } else {
        await audioPlayer.resume();
      }

      setState(() {
        sedangDiputar = true;
      });
    }
  }

  // Stop lagu
  Future<void> stopLagu() async {
    await audioPlayer.stop();

    setState(() {
      sedangDiputar = false;
      posisi = Duration.zero;
    });
  }

  // Mundur 10 detik
  Future<void> mundur10Detik() async {
    Duration posisiBaru =
        posisi - const Duration(seconds: 10);

    if (posisiBaru < Duration.zero) {
      posisiBaru = Duration.zero;
    }

    await audioPlayer.seek(posisiBaru);
  }

  // Maju 10 detik
  Future<void> maju10Detik() async {
    Duration posisiBaru =
        posisi + const Duration(seconds: 10);

    if (posisiBaru > durasi) {
      posisiBaru = durasi;
    }

    await audioPlayer.seek(posisiBaru);
  }

  // Mengubah waktu menjadi menit:detik
  String formatWaktu(Duration waktu) {
    String menit =
        waktu.inMinutes.toString().padLeft(2, '0');

    String detik =
        (waktu.inSeconds % 60).toString().padLeft(2, '0');

    return '$menit:$detik';
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double nilaiSlider =
        posisi.inMilliseconds.toDouble();

    double nilaiMaksimal =
        durasi.inMilliseconds.toDouble();

    if (nilaiMaksimal <= 0) {
      nilaiMaksimal = 1;
    }

    if (nilaiSlider > nilaiMaksimal) {
      nilaiSlider = nilaiMaksimal;
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFF8FB),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffF8DDE8),
              Color(0xffFDF1F6),
              Color(0xffFFF9FB),
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 620,
                ),

                child: Column(
                  children: [

                    // Header
                    const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          color: Color(0xffA94B72),
                          size: 26,
                        ),

                        SizedBox(width: 7),

                        Text(
                          'My Music Space',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3D2932),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Cover lagu
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.18),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),

                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(28),

                        child: Image.asset(
                          'assets/Nadin.jpg',
                          width: 270,
                          height: 270,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Judul lagu
                    Text(
                      lirik.judul,
                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff3D2932),
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Nama artis
                    Text(
                      lirik.artis,

                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xff8C6B78),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Slider lagu
                    SliderTheme(
                      data:
                          SliderTheme.of(context).copyWith(
                        trackHeight: 4,

                        thumbShape:
                            const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),

                        overlayShape:
                            const RoundSliderOverlayShape(
                          overlayRadius: 15,
                        ),
                      ),

                      child: Slider(
                        value: nilaiSlider,
                        max: nilaiMaksimal,

                        activeColor:
                            const Color(0xffA94B72),

                        inactiveColor:
                            const Color(0xffE6C4D2),

                        onChanged: (value) async {
                          await audioPlayer.seek(
                            Duration(
                              milliseconds:
                                  value.toInt(),
                            ),
                          );
                        },
                      ),
                    ),

                    // Waktu lagu
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          Text(
                            formatWaktu(posisi),

                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff8C6B78),
                            ),
                          ),

                          Text(
                            formatWaktu(durasi),

                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff8C6B78),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Tombol player
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        // Favorite
                        IconButton(
                          tooltip: 'Favorit',

                          onPressed: () {
                            setState(() {
                              favorit = !favorit;
                            });
                          },

                          icon: Icon(
                            favorit
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),

                          color:
                              const Color(0xffA94B72),

                          iconSize: 27,
                        ),

                        const SizedBox(width: 8),

                        // Mundur 10 detik
                        IconButton(
                          tooltip: 'Mundur 10 detik',

                          onPressed: mundur10Detik,

                          icon: const Icon(
                            Icons.replay_10_rounded,
                          ),

                          color:
                              const Color(0xffA94B72),

                          iconSize: 32,
                        ),

                        const SizedBox(width: 8),

                        // Play / Pause
                        Container(
                          width: 70,
                          height: 70,

                          decoration: BoxDecoration(
                            color:
                                const Color(0xffA94B72),

                            shape: BoxShape.circle,

                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xffA94B72,
                                ).withValues(
                                  alpha: 0.30,
                                ),

                                blurRadius: 18,

                                offset:
                                    const Offset(0, 8),
                              ),
                            ],
                          ),

                          child: IconButton(
                            tooltip: sedangDiputar
                                ? 'Pause'
                                : 'Play',

                            onPressed: putarLagu,

                            icon: Icon(
                              sedangDiputar
                                  ? Icons.pause_rounded
                                  : Icons
                                      .play_arrow_rounded,

                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Maju 10 detik
                        IconButton(
                          tooltip: 'Maju 10 detik',

                          onPressed: maju10Detik,

                          icon: const Icon(
                            Icons.forward_10_rounded,
                          ),

                          color:
                              const Color(0xffA94B72),

                          iconSize: 32,
                        ),

                        const SizedBox(width: 8),

                        // Stop
                        IconButton(
                          tooltip: 'Stop',

                          onPressed: stopLagu,

                          icon: const Icon(
                            Icons
                                .stop_circle_outlined,
                          ),

                          color:
                              const Color(0xffA94B72),

                          iconSize: 29,
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // Card lirik
                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 18,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.82),

                        borderRadius:
                            BorderRadius.circular(25),

                        border: Border.all(
                          color:
                              const Color(0xffF0D6E0),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.05),

                            blurRadius: 20,

                            offset:
                                const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [

                          // Tombol buka/tutup lirik
                          InkWell(
                            borderRadius:
                                BorderRadius.circular(15),

                            onTap: () {
                              setState(() {
                                lirikTampil =
                                    !lirikTampil;
                              });
                            },

                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 5,
                              ),

                              child: Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .lyrics_rounded,

                                    color: Color(
                                      0xffA94B72,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  const Expanded(
                                    child: Text(
                                      'Lirik Lagu',

                                      style: TextStyle(
                                        fontSize: 19,

                                        fontWeight:
                                            FontWeight
                                                .bold,

                                        color: Color(
                                          0xff3D2932,
                                        ),
                                      ),
                                    ),
                                  ),

                                  Icon(
                                    lirikTampil
                                        ? Icons
                                            .keyboard_arrow_up_rounded
                                        : Icons
                                            .keyboard_arrow_down_rounded,

                                    color: const Color(
                                      0xffA94B72,
                                    ),

                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Isi lirik
                          if (lirikTampil) ...[
                            const SizedBox(
                              height: 20,
                            ),

                            SizedBox(
                              height: 270,

                              child:
                                  SingleChildScrollView(
                                child: SizedBox(
                                  width:
                                      double.infinity,

                                  child: Text(
                                    lirik.lirikLagu
                                        .trim(),

                                    textAlign:
                                        TextAlign.center,

                                    style:
                                        const TextStyle(
                                      fontSize: 17,

                                      height: 1.9,

                                      color: Color(
                                        0xff624F57,
                                      ),

                                      fontWeight:
                                          FontWeight
                                              .w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
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