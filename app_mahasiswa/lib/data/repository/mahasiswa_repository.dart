import 'package:dio/dio.dart';
import '../../models/mahasiswa.dart';

class MahasiswaRepository {
  final Dio _dio;

  MahasiswaRepository(this._dio);

  // GET - mengambil semua mahasiswa
  Future<List<Mahasiswa>> getAll() async {
    final response = await _dio.get('/mahasiswa');

    final List<dynamic> data =
        response.data['data'] ?? [];

    return data
        .map(
          (json) => Mahasiswa.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // POST - menambahkan mahasiswa
  Future<Mahasiswa> create(Mahasiswa mahasiswa) async {
    final response = await _dio.post(
      '/mahasiswa',
      data: mahasiswa.toJson(),
    );

    return Mahasiswa.fromJson(
      Map<String, dynamic>.from(
        response.data['data'],
      ),
    );
  }

  // PUT - mengubah mahasiswa
  Future<Mahasiswa> update(
    int id,
    Mahasiswa mahasiswa,
  ) async {
    final response = await _dio.put(
      '/mahasiswa/$id',
      data: mahasiswa.toJson(),
    );

    return Mahasiswa.fromJson(
      Map<String, dynamic>.from(
        response.data['data'],
      ),
    );
  }

  // DELETE - menghapus mahasiswa
  Future<void> delete(int id) async {
    await _dio.delete('/mahasiswa/$id');
  }
}