import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // =========================
  // DATA PROFILE
  // =========================

  String nama = 'Siti Mutmainah';
  String username = '@sitimutmainah';
  String email = 'sitimutmainah@gmail.com';
  String genre = 'Pop / Indie';

  bool notifikasi = true;
  bool tampilkanLirik = true;

  // =========================
  // KAMERA
  // =========================

  final ImagePicker picker = ImagePicker();
  Uint8List? fotoProfile;

  // =========================
  // GPS
  // =========================

  double? latitude;
  double? longitude;

  bool mengambilLokasi = false;

  // =========================
  // PILIH FOTO
  // =========================

  Future<void> pilihFoto(ImageSource source) async {
    final XFile? hasil = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (hasil != null) {
      final bytes = await hasil.readAsBytes();

      setState(() {
        fotoProfile = bytes;
      });
    }
  }

  // =========================
  // BOTTOM SHEET FOTO
  // =========================

  void pilihanFoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ubah Foto Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xffA94B72),
                  ),
                  title: const Text(
                    'Ambil dari Kamera',
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    pilihFoto(
                      ImageSource.camera,
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xffA94B72),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    pilihFoto(
                      ImageSource.gallery,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // GPS
  // =========================

  Future<void> ambilLokasi() async {
    setState(() {
      mengambilLokasi = true;
    });

    try {
      bool gpsAktif =
          await Geolocator.isLocationServiceEnabled();

      if (!gpsAktif) {
        throw Exception(
          'GPS belum diaktifkan',
        );
      }

      LocationPermission izin =
          await Geolocator.checkPermission();

      if (izin == LocationPermission.denied) {
        izin =
            await Geolocator.requestPermission();
      }

      if (izin ==
              LocationPermission.denied ||
          izin ==
              LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi tidak diberikan',
        );
      }

      Position posisi =
          await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        latitude = posisi.latitude;
        longitude = posisi.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lokasi berhasil diambil',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        mengambilLokasi = false;
      });
    }
  }

  // =========================
  // EDIT PROFILE
  // =========================

  void editProfile() {
    final namaController =
        TextEditingController(
      text: nama,
    );

    final emailController =
        TextEditingController(
      text: email,
    );

    final formKey =
        GlobalKey<FormState>();

    String genreBaru = genre;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        24,
              ),

              child: Form(
                key: formKey,

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      TextFormField(
                        controller:
                            namaController,

                        decoration:
                            const InputDecoration(
                          labelText: 'Nama',
                          prefixIcon: Icon(
                            Icons.person_outline,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      TextFormField(
                        controller:
                            emailController,

                        keyboardType:
                            TextInputType
                                .emailAddress,

                        decoration:
                            const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      DropdownButtonFormField<
                          String>(
                        value: genreBaru,

                        decoration:
                            const InputDecoration(
                          labelText:
                              'Genre Favorit',
                          prefixIcon: Icon(
                            Icons.music_note,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),

                        items: const [
                          DropdownMenuItem(
                            value:
                                'Pop / Indie',
                            child: Text(
                              'Pop / Indie',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Pop',
                            child: Text('Pop'),
                          ),
                          DropdownMenuItem(
                            value: 'Indie',
                            child:
                                Text('Indie'),
                          ),
                          DropdownMenuItem(
                            value: 'Jazz',
                            child: Text('Jazz'),
                          ),
                          DropdownMenuItem(
                            value: 'Rock',
                            child: Text('Rock'),
                          ),
                        ],

                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              genreBaru =
                                  value;
                            });
                          }
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 50,

                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            if (formKey
                                .currentState!
                                .validate()) {
                              setState(() {
                                nama =
                                    namaController
                                        .text;

                                email =
                                    emailController
                                        .text;

                                genre =
                                    genreBaru;
                              });

                              Navigator.pop(
                                context,
                              );

                              ScaffoldMessenger
                                      .of(this
                                          .context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile berhasil diperbarui',
                                  ),
                                ),
                              );
                            }
                          },

                          icon: const Icon(
                            Icons.save_outlined,
                          ),

                          label: const Text(
                            'Simpan Perubahan',
                          ),

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                const Color(
                              0xffA94B72,
                            ),
                            foregroundColor:
                                Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF9FB),

      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor:
            const Color(0xffFFF9FB),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 650,
            ),

            child: Column(
              children: [
                // =========================
                // FOTO PROFILE
                // =========================

                Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor:
                          const Color(
                        0xffF2D4E0,
                      ),

                      backgroundImage:
                          fotoProfile != null
                              ? MemoryImage(
                                  fotoProfile!,
                                )
                              : const AssetImage(
                                  'assets/Nadin.jpg',
                                )
                                  as ImageProvider,
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,

                      child:
                          GestureDetector(
                        onTap:
                            pilihanFoto,

                        child: Container(
                          width: 38,
                          height: 38,

                          decoration:
                              const BoxDecoration(
                            color: Color(
                              0xffA94B72,
                            ),
                            shape:
                                BoxShape.circle,
                          ),

                          child:
                              const Icon(
                            Icons.camera_alt,
                            color:
                                Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xff3D2932),
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // =========================
                // STATISTIK
                // =========================

                Card(
                  elevation: 0,
                  color:
                      const Color(
                    0xffFCECF2,
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 20,
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly,

                      children: [
                        statistik(
                          '4',
                          'Playlist',
                        ),

                        garis(),

                        statistik(
                          '1',
                          'Favorit',
                        ),

                        garis(),

                        statistik(
                          '3',
                          'Album',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // =========================
                // INFORMASI AKUN
                // =========================

                const Align(
                  alignment:
                      Alignment.centerLeft,

                  child: Text(
                    'Informasi Akun',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Card(
                  elevation: 0,

                  child: Column(
                    children: [
                      ListTile(
                        leading:
                            const Icon(
                          Icons
                              .person_outline,
                          color: Color(
                            0xffA94B72,
                          ),
                        ),

                        title:
                            const Text(
                          'Nama',
                        ),

                        subtitle:
                            Text(nama),
                      ),

                      const Divider(
                        height: 1,
                      ),

                      ListTile(
                        leading:
                            const Icon(
                          Icons
                              .email_outlined,
                          color: Color(
                            0xffA94B72,
                          ),
                        ),

                        title:
                            const Text(
                          'Email',
                        ),

                        subtitle:
                            Text(email),
                      ),

                      const Divider(
                        height: 1,
                      ),

                      ListTile(
                        leading:
                            const Icon(
                          Icons.music_note,
                          color: Color(
                            0xffA94B72,
                          ),
                        ),

                        title:
                            const Text(
                          'Genre Favorit',
                        ),

                        subtitle:
                            Text(genre),
                      ),

                      const Divider(
                        height: 1,
                      ),

                      // =========================
                      // GPS
                      // =========================

                      ListTile(
                        leading:
                            const Icon(
                          Icons
                              .location_on_outlined,
                          color: Color(
                            0xffA94B72,
                          ),
                        ),

                        title:
                            const Text(
                          'Lokasi Saya',
                        ),

                        subtitle: Text(
                          latitude == null
                              ? 'Belum mengambil lokasi'
                              : 'Latitude: '
                                  '${latitude!.toStringAsFixed(6)}\n'
                                  'Longitude: '
                                  '${longitude!.toStringAsFixed(6)}',
                        ),

                        trailing:
                            mengambilLokasi
                                ? const SizedBox(
                                    width:
                                        22,
                                    height:
                                        22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : IconButton(
                                    tooltip:
                                        'Ambil Lokasi',
                                    onPressed:
                                        ambilLokasi,
                                    icon:
                                        const Icon(
                                      Icons
                                          .my_location,
                                      color:
                                          Color(
                                        0xffA94B72,
                                      ),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // =========================
                // PREFERENSI
                // =========================

                const Align(
                  alignment:
                      Alignment.centerLeft,

                  child: Text(
                    'Preferensi',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Card(
                  elevation: 0,

                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary:
                            const Icon(
                          Icons
                              .notifications_outlined,
                          color: Color(
                            0xffA94B72,
                          ),
                        ),

                        title:
                            const Text(
                          'Notifikasi Musik',
                        ),

                        subtitle:
                            const Text(
                          'Aktifkan notifikasi aplikasi',
                        ),

                        value:
                            notifikasi,

                        onChanged:
                            (value) {
                          setState(() {
                            notifikasi =
                                value;
                          });
                        },
                      ),

                      const Divider(
                        height: 1,
                      ),

                      SwitchListTile(
                        secondary:
                            const Icon(
                          Icons
                              .lyrics_outlined,
                          color: Color(
                            0xffA94B72,
                          ),
                        ),

                        title:
                            const Text(
                          'Tampilkan Lirik',
                        ),

                        subtitle:
                            const Text(
                          'Tampilkan lirik saat memutar lagu',
                        ),

                        value:
                            tampilkanLirik,

                        onChanged:
                            (value) {
                          setState(() {
                            tampilkanLirik =
                                value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // =========================
                // EDIT PROFILE
                // =========================

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child:
                      ElevatedButton.icon(
                    onPressed:
                        editProfile,

                    icon: const Icon(
                      Icons.edit_outlined,
                    ),

                    label: const Text(
                      'Edit Profile',
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xffA94B72,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // WIDGET STATISTIK
  // =========================

  Widget statistik(
    String jumlah,
    String nama,
  ) {
    return Column(
      children: [
        Text(
          jumlah,
          style: const TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xffA94B72),
          ),
        ),
        Text(
          nama,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget garis() {
    return Container(
      height: 35,
      width: 1,
      color:
          Colors.grey.shade300,
    );
  }
}