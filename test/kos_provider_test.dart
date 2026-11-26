import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MutableKosDataSource implements KosDataSource {
  MutableKosDataSource(this.rows);

  List<Map<String, dynamic>> rows;
  Object? error;

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async {
    final currentError = error;
    if (currentError != null) throw currentError;
    return rows;
  }
}

Map<String, dynamic> _row(String nama) {
  return {
    'id': 'k1',
    'owner_id': 'owner-1',
    'nama': nama,
    'area': 'Singaraja',
    'harga': 900000,
    'fasilitas': 'WiFi',
    'jumlah_kamar': 2,
    'created_at': '2026-11-21T00:00:00Z',
  };
}

KosProvider _makeProvider(MutableKosDataSource source) {
  return KosProvider(repository: KosRepository(source: source));
}

void main() {
  test('loadKos mengisi items dan status loading berubah', () async {
    final source = MutableKosDataSource([_row('Kos Melati')]);
    final provider = _makeProvider(source);
    final loadingStates = <bool>[];

    provider.addListener(() => loadingStates.add(provider.isLoading));

    await provider.loadKos();

    expect(loadingStates, <bool>[true, false]);
    expect(provider.items, hasLength(1));
    expect(provider.items.single.nama, 'Kos Melati');
    expect(provider.hasError, isFalse);
  });

  test('daftar kosong bukan error', () async {
    final provider = _makeProvider(MutableKosDataSource([]));

    await provider.loadKos();

    expect(provider.items, isEmpty);
    expect(provider.errorMessage, isNull);
    expect(provider.isLoading, isFalse);
  });

  test('error koneksi tersimpan dan tidak melempar', () async {
    final source = MutableKosDataSource([])..error = 'offline';
    final provider = _makeProvider(source);

    await provider.loadKos();

    expect(provider.hasError, isTrue);
    expect(
      provider.errorMessage,
      contains('Gagal memuat daftar kos'),
    );
    expect(provider.items, isEmpty);
    expect(provider.isLoading, isFalse);
  });

  test('setelah error, load ulang mengembalikan daftar', () async {
    final source = MutableKosDataSource([])..error = 'offline';
    final provider = _makeProvider(source);

    await provider.loadKos();
    expect(provider.hasError, isTrue);

    source
      ..error = null
      ..rows = [_row('Kos Anggrek')];
    await provider.loadKos();

    expect(provider.hasError, isFalse);
    expect(provider.items.single.nama, 'Kos Anggrek');
  });
}
