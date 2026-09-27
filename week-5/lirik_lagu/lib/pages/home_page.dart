import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../lirik.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  // =========================
  // PLAY / PAUSE
  // =========================

  Future<void> putarLagu() async {
    if (sedangDiputar) {
      await audioPlayer.pause();

      if (mounted) {
        setState(() {
          sedangDiputar = false;
        });
      }
    } else {
      if (posisi == Duration.zero) {
        await audioPlayer.play(
          AssetSource('bertaut.mp3'),
        );
      } else {
        await audioPlayer.resume();
      }

      if (mounted) {
        setState(() {
          sedangDiputar = true;
        });
      }
    }
  }

  // =========================
  // STOP
  // =========================

  Future<void> stopLagu() async {
    await audioPlayer.stop();

    if (mounted) {
      setState(() {
        sedangDiputar = false;
        posisi = Duration.zero;
      });
    }
  }

  // =========================
  // MUNDUR 10 DETIK
  // =========================

  Future<void> mundur10Detik() async {
    Duration posisiBaru =
        posisi - const Duration(seconds: 10);

    if (posisiBaru < Duration.zero) {
      posisiBaru = Duration.zero;
    }

    await audioPlayer.seek(posisiBaru);
  }

  // =========================
  // MAJU 10 DETIK
  // =========================

  Future<void> maju10Detik() async {
    Duration posisiBaru =
        posisi + const Duration(seconds: 10);

    if (durasi > Duration.zero &&
        posisiBaru > durasi) {
      posisiBaru = durasi;
    }

    await audioPlayer.seek(posisiBaru);
  }

  // =========================
  // FORMAT WAKTU
  // =========================

  String formatWaktu(Duration waktu) {
    String menit =
        waktu.inMinutes.toString().padLeft(2, '0');

    String detik =
        (waktu.inSeconds % 60)
            .toString()
            .padLeft(2, '0');

    return '$menit:$detik';
  }

  // =========================
  // DETAIL LAGU
  // =========================

  void tampilkanInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.album_rounded,
                  size: 50,
                  color: Color(0xffA94B72),
                ),

                const SizedBox(height: 10),

                Text(
                  lirik.judul,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  lirik.artis,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Sedang diputar di My Music Space.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // KONFIRMASI STOP
  // =========================

  void konfirmasiStop() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Stop Lagu'),
          content: const Text(
            'Apakah kamu ingin menghentikan lagu?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                stopLagu();
              },
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );
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
      backgroundColor:
          const Color(0xffFFF8FB),

      // =========================
      // APP BAR
      // =========================

      appBar: AppBar(
        title: const Text(
          'My Music Space',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            const Color(0xffFFF8FB),

        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menu',
            onSelected: (value) {
              if (value == 'info') {
                tampilkanInfo();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Informasi Lagu',
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),

      // =========================
      // DRAWER
      // =========================

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xffA94B72),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.headphones_rounded,
                    color: Colors.white,
                    size: 40,
                  ),

                  SizedBox(height: 10),

                  Text(
                    'My Music Space',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    'Enjoy your music',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: Color(0xffA94B72),
              ),
              title: const Text(
                'Tentang Aplikasi',
              ),
              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'My Music Space - Praktikum Flutter',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // =========================
      // BODY
      // =========================

      body: Container(
        width: double.infinity,

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
                constraints:
                    const BoxConstraints(
                  maxWidth: 620,
                ),

                child: Column(
                  children: [
                    // =========================
                    // COVER
                    // =========================

                    Stack(
                      children: [
                        Hero(
                          tag: 'cover',

                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              25,
                            ),

                            child: Image.asset(
                              'assets/Nadin.jpg',
                              width: 270,
                              height: 270,
                              fit: BoxFit.cover,

                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  width: 270,
                                  height: 270,
                                  color: Colors.white,

                                  child:
                                      const Icon(
                                    Icons
                                        .album_rounded,
                                    size: 100,
                                    color: Color(
                                      0xffA94B72,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        if (favorit)
                          const Positioned(
                            top: 12,
                            right: 12,

                            child:
                                CircleAvatar(
                              backgroundColor:
                                  Colors.white,

                              child: Icon(
                                Icons.favorite,
                                color: Color(
                                  0xffA94B72,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // =========================
                    // JUDUL
                    // =========================

                    Text(
                      lirik.judul,
                      textAlign:
                          TextAlign.center,

                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xff3D2932),
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      lirik.artis,
                      textAlign:
                          TextAlign.center,

                      style: const TextStyle(
                        fontSize: 16,
                        color:
                            Color(0xff8C6B78),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // =========================
                    // SLIDER
                    // =========================

                    Slider(
                      value: nilaiSlider,
                      max: nilaiMaksimal,

                      activeColor:
                          const Color(
                        0xffA94B72,
                      ),

                      inactiveColor:
                          const Color(
                        0xffE8CBD6,
                      ),

                      onChanged: (value) {
                        audioPlayer.seek(
                          Duration(
                            milliseconds:
                                value.toInt(),
                          ),
                        );
                      },
                    ),

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          Text(
                            formatWaktu(
                              posisi,
                            ),
                          ),

                          Text(
                            formatWaktu(
                              durasi,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // =========================
                    // PLAYER CONTROL
                    // =========================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [
                        // FAVORIT
                        IconButton(
                          tooltip: 'Favorit',

                          onPressed: () {
                            setState(() {
                              favorit =
                                  !favorit;
                            });

                            ScaffoldMessenger
                                    .of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  favorit
                                      ? 'Ditambahkan ke favorit'
                                      : 'Dihapus dari favorit',
                                ),
                              ),
                            );
                          },

                          icon: Icon(
                            favorit
                                ? Icons
                                    .favorite
                                : Icons
                                    .favorite_border,
                          ),

                          color:
                              const Color(
                            0xffA94B72,
                          ),

                          iconSize: 27,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        // MUNDUR
                        IconButton(
                          tooltip:
                              'Mundur 10 detik',

                          onPressed:
                              mundur10Detik,

                          icon: const Icon(
                            Icons
                                .replay_10_rounded,
                          ),

                          color:
                              const Color(
                            0xffA94B72,
                          ),

                          iconSize: 32,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        // PLAY / PAUSE
                        AnimatedContainer(
                          duration:
                              const Duration(
                            milliseconds: 300,
                          ),

                          width:
                              sedangDiputar
                                  ? 75
                                  : 70,

                          height:
                              sedangDiputar
                                  ? 75
                                  : 70,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xffA94B72,
                            ),

                            shape:
                                BoxShape.circle,

                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(
                                  0xffA94B72,
                                ).withValues(
                                  alpha: 0.30,
                                ),

                                blurRadius: 18,

                                offset:
                                    const Offset(
                                  0,
                                  8,
                                ),
                              ),
                            ],
                          ),

                          child:
                              IconButton(
                            tooltip:
                                sedangDiputar
                                    ? 'Pause'
                                    : 'Play',

                            onPressed:
                                putarLagu,

                            icon:
                                AnimatedSwitcher(
                              duration:
                                  const Duration(
                                milliseconds:
                                    250,
                              ),

                              child: Icon(
                                sedangDiputar
                                    ? Icons
                                        .pause_rounded
                                    : Icons
                                        .play_arrow_rounded,

                                key: ValueKey(
                                  sedangDiputar,
                                ),

                                color:
                                    Colors.white,

                                size: 42,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        // MAJU
                        IconButton(
                          tooltip:
                              'Maju 10 detik',

                          onPressed:
                              maju10Detik,

                          icon: const Icon(
                            Icons
                                .forward_10_rounded,
                          ),

                          color:
                              const Color(
                            0xffA94B72,
                          ),

                          iconSize: 32,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        // STOP
                        IconButton(
                          tooltip: 'Stop',

                          onPressed:
                              konfirmasiStop,

                          icon: const Icon(
                            Icons
                                .stop_circle_outlined,
                          ),

                          color:
                              const Color(
                            0xffA94B72,
                          ),

                          iconSize: 29,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // =========================
                    // LIRIK
                    // =========================

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.85,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),

                        border: Border.all(
                          color:
                              const Color(
                            0xffF0D6E0,
                          ),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                              alpha: 0.04,
                            ),

                            blurRadius: 15,

                            offset:
                                const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          InkWell(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),

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
                                    color:
                                        Color(
                                      0xffA94B72,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  const Expanded(
                                    child: Text(
                                      'Lirik Lagu',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            18,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),

                                  Icon(
                                    lirikTampil
                                        ? Icons
                                            .keyboard_arrow_up_rounded
                                        : Icons
                                            .keyboard_arrow_down_rounded,

                                    color:
                                        const Color(
                                      0xffA94B72,
                                    ),

                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (lirikTampil) ...[
                            const SizedBox(
                              height: 20,
                            ),

                            SizedBox(
                              height: 270,

                              child:
                                  Scrollbar(
                                thumbVisibility:
                                    true,

                                child:
                                    SingleChildScrollView(
                                  child:
                                      SizedBox(
                                    width:
                                        double.infinity,

                                    child:
                                        SelectableText(
                                      lirik
                                          .lirikLagu
                                          .trim(),

                                      textAlign:
                                          TextAlign
                                              .center,

                                      style:
                                          const TextStyle(
                                        fontSize:
                                            17,
                                        height: 1.9,
                                        color:
                                            Color(
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
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // =========================
                    // DETAIL
                    // =========================

                    OutlinedButton.icon(
                      onPressed:
                          tampilkanInfo,

                      icon: const Icon(
                        Icons.info_outline,
                      ),

                      label: const Text(
                        'Detail Lagu',
                      ),
                    ),

                    const SizedBox(
                      height: 25,
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