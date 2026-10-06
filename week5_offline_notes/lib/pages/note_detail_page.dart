import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/note_providers.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
      ),
      body: noteAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(
            'Gagal membaca catatan: $e',
          ),
        ),
        data: (note) {
          if (note == null) {
            return const Center(
              child: Text('Catatan tidak ditemukan'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  note.body.isEmpty
                      ? '(tanpa isi)'
                      : note.body,
                ),
                const SizedBox(height: 20),
                Text(
                  'Terakhir diperbarui: ${note.updatedAt}',
                ),
                const SizedBox(height: 8),
                Text(
                  note.dirty
                      ? 'Status: Belum tersinkron'
                      : 'Status: Sudah tersinkron',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}