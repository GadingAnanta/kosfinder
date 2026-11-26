import 'package:kosfinder/models/kos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstraksi kecil agar repository bisa diuji tanpa Supabase nyata.
abstract class KosDataSource {
  Future<List<Map<String, dynamic>>> fetchRows();
}

/// Implementasi sumber data memakai tabel public.kos di Supabase.
class SupabaseKosDataSource implements KosDataSource {
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
}

class KosRepository {
  KosRepository({KosDataSource? source})
    : _source = source ?? SupabaseKosDataSource();

  final KosDataSource _source;

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
}

class KosRepositoryException implements Exception {
  const KosRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
