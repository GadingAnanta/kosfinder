import 'package:kosfinder/models/kos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstraksi kecil agar repository bisa diuji tanpa Supabase nyata.
abstract class KosDataSource {
  Future<List<Map<String, dynamic>>> fetchRows();
}

abstract class KosWriteDataSource {
  Future<void> insertKos(Map<String, dynamic> row);
}

abstract class KosUpdateDataSource {
  Future<void> updateKos(String id, Map<String, dynamic> row);
}

abstract class KosDeleteDataSource {
  Future<void> deleteKos(String id, String ownerId);
}

/// Implementasi sumber data memakai tabel public.kos di Supabase.
class SupabaseKosDataSource
    implements
        KosDataSource,
        KosWriteDataSource,
        KosUpdateDataSource,
        KosDeleteDataSource {
  SupabaseKosDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async {
    final rows = await _client
        .from('kos')
        .select('id, owner_id, nama, area, harga, fasilitas, jumlah_kamar, created_at')
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> insertKos(Map<String, dynamic> row) async {
    await _client.from('kos').insert(row);
  }

  @override
  Future<void> updateKos(String id, Map<String, dynamic> row) async {
    await _client
        .from('kos')
        .update(row)
        .eq('id', id)
        .eq('owner_id', row['owner_id'] as String);
  }

  @override
  Future<void> deleteKos(String id, String ownerId) async {
    await _client.from('kos').delete().eq('id', id).eq('owner_id', ownerId);
  }
}

class KosRepository {
  KosRepository({KosDataSource? source, this.writeSource})
    : _source = source ?? SupabaseKosDataSource();

  final KosDataSource _source;
  final KosWriteDataSource? writeSource;

  /// Mengambil seluruh kos. Tabel kosong mengembalikan list kosong.
  /// Kegagalan jaringan diterjemahkan menjadi [KosRepositoryException]
  /// agar layer provider cukup menangkap satu jenis error.
  Future<List<Kos>> getKosList() async {
    try {
      final rows = await _source.fetchRows();
      return rows.map(Kos.fromMap).toList(growable: false);
    } catch (error) {
      throw KosRepositoryException('Gagal memuat daftar kos: $error');
    }
  }

  /// Filter area case-insensitive. Query kosong mengembalikan semua kos.
  List<Kos> filterByArea(List<Kos> items, String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) return items;
    return items
        .where((kos) => kos.area.toLowerCase().contains(keyword))
        .toList(growable: false);
  }

  /// Filter harga maksimum. Null berarti tidak ada batas harga.
  List<Kos> filterByMaxHarga(List<Kos> items, int? maxHarga) {
    if (maxHarga == null) return items;
    return items
        .where((kos) => kos.harga <= maxHarga)
        .toList(growable: false);
  }

  /// Menyimpan kos baru. owner_id diambil dari sesi pemilik yang login.
  Future<void> createKos({
    required String ownerId,
    required String nama,
    required String area,
    required int harga,
    required String fasilitas,
    required int jumlahKamar,
  }) async {
    try {
      final writer =
          writeSource ??
          (_source is KosWriteDataSource
              ? _source as KosWriteDataSource
              : SupabaseKosDataSource());
      await writer.insertKos({
        'owner_id': ownerId,
        'nama': nama,
        'area': area,
        'harga': harga,
        'fasilitas': fasilitas,
        'jumlah_kamar': jumlahKamar,
      });
    } catch (error) {
      throw KosRepositoryException('Gagal menyimpan kos: $error');
    }
  }

  /// Mengubah kos milik sendiri. Pemeriksaan owner_id dilakukan di aplikasi
  /// dan RLS Supabase tetap menjadi penegak hak akses utama.
  Future<void> updateKos({
    required String id,
    required String ownerId,
    required String nama,
    required String area,
    required int harga,
    required String fasilitas,
    required int jumlahKamar,
  }) async {
    if (id.trim().isEmpty || ownerId.trim().isEmpty) {
      throw const KosRepositoryException('Login pemilik diperlukan.');
    }

    try {
      await _requireOwnedRow(id, ownerId);

      await _updater().updateKos(id, {
        'owner_id': ownerId,
        'nama': nama.trim(),
        'area': area.trim(),
        'harga': harga,
        'fasilitas': fasilitas.trim(),
        'jumlah_kamar': jumlahKamar,
      });
    } on KosRepositoryException {
      rethrow;
    } catch (error) {
      throw KosRepositoryException('Gagal mengubah kos: $error');
    }
  }

  /// Menghapus kos milik sendiri. RLS Supabase tetap menjadi penegak
  /// hak akses utama meskipun aplikasi sudah memeriksa owner_id.
  Future<void> deleteKos({
    required String id,
    required String ownerId,
  }) async {
    if (id.trim().isEmpty || ownerId.trim().isEmpty) {
      throw const KosRepositoryException('Login pemilik diperlukan.');
    }

    try {
      await _requireOwnedRow(id, ownerId);
      await _deleter().deleteKos(id, ownerId);
    } on KosRepositoryException {
      rethrow;
    } catch (error) {
      throw KosRepositoryException('Gagal menghapus kos: $error');
    }
  }

  Future<Map<String, dynamic>> _requireOwnedRow(
    String id,
    String ownerId,
  ) async {
    final rows = await _source.fetchRows();
    final current = rows.cast<Map<String, dynamic>?>().firstWhere(
      (row) => row?['id'] == id,
      orElse: () => null,
    );
    if (current == null) {
      throw const KosRepositoryException('Kos tidak ditemukan.');
    }
    if (current['owner_id'] != ownerId) {
      throw const KosRepositoryException('Kos ini bukan milik Anda.');
    }
    return current;
  }

  KosDeleteDataSource _deleter() {
    final writer = writeSource;
    if (writer is KosDeleteDataSource) {
      return writer as KosDeleteDataSource;
    }
    if (_source is KosDeleteDataSource) return _source as KosDeleteDataSource;
    return SupabaseKosDataSource();
  }

  KosUpdateDataSource _updater() {
    final writer = writeSource;
    if (writer is KosUpdateDataSource) {
      return writer as KosUpdateDataSource;
    }
    if (_source is KosUpdateDataSource) return _source as KosUpdateDataSource;
    return SupabaseKosDataSource();
  }
}

class KosRepositoryException implements Exception {
  const KosRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
