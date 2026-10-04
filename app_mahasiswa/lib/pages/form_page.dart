import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';
import '../data/api_client.dart';
import '../data/repository/mahasiswa_repository.dart';

class FormPage extends StatefulWidget {
  // null = mode tambah, terisi = mode edit
  final Mahasiswa? mahasiswa;

  const FormPage({
    super.key,
    this.mahasiswa,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  late final MahasiswaRepository repository;

  late final TextEditingController nimC;
  late final TextEditingController namaC;
  late final TextEditingController prodiC;
  late final TextEditingController emailC;

  bool _loading = false;

  bool get isEdit => widget.mahasiswa != null;

  @override
  void initState() {
    super.initState();

    // Repository menggunakan Dio
    repository = MahasiswaRepository(
      createDio(),
    );

    // Isi awal form
    final m = widget.mahasiswa;

    nimC = TextEditingController(
      text: m?.nim,
    );

    namaC = TextEditingController(
      text: m?.nama,
    );

    prodiC = TextEditingController(
      text: m?.prodi,
    );

    emailC = TextEditingController(
      text: m?.email,
    );
  }

  @override
  void dispose() {
    nimC.dispose();
    namaC.dispose();
    prodiC.dispose();
    emailC.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final data = Mahasiswa(
      nim: nimC.text.trim(),
      nama: namaC.text.trim(),
      prodi: prodiC.text.trim(),
      email: emailC.text.trim(),
    );

    try {
      if (isEdit) {
        // PUT
        await repository.update(
          widget.mahasiswa!.id!,
          data,
        );
      } else {
        // POST
        await repository.create(data);
      }

      if (!mounted) return;

      // Memberi tahu halaman list bahwa data berubah
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan data: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _field(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return '$label wajib diisi';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Edit Mahasiswa'
              : 'Tambah Mahasiswa',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(nimC, 'NIM'),
            _field(namaC, 'Nama'),
            _field(prodiC, 'Prodi'),
            _field(emailC, 'Email'),

            const SizedBox(height: 8),

            FilledButton(
              onPressed:
                  _loading ? null : _simpan,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}