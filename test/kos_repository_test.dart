import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class FakeKosDataSource implements KosDataSource {
  const FakeKosDataSource(this.rows);

  final List<Map<String, dynamic>> rows;

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async => rows;
}

class ErrorKosDataSource implements KosDataSource {
  const ErrorKosDataSource(this.error);

  final Object error;

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async => throw error;
}

Map<String, dynamic> _row({
  required String id,
  required String nama,
  required int harga,
  required int jumlahKamar,
}) {
  return {
    'id': id,
    'owner_id': 'owner-1',
    'nama': nama,
    'area': 'Singaraja',
    'harga': harga,
    'fasilitas': 'WiFi',
    'jumlah_kamar': jumlahKamar,
    'created_at': '2026-11-21T00:00:00Z',
  };
}

void main() {
  test('getKosList memetakan baris Supabase ke model Kos', () async {
    final repository = KosRepository(
      source: FakeKosDataSource([
        _row(id: 'k1', nama: 'Kos Melati', harga: 900000, jumlahKamar: 2),
        _row(id: 'k2', nama: 'Kos Mawar', harga: 2500000, jumlahKamar: 0),
      ]),
    );

    final result = await repository.getKosList();

    expect(result, hasLength(2));
    expect(result.first.nama, 'Kos Melati');
    expect(result.first.harga, 900000);
    expect(result.last.isPenuh, isTrue);
  });

  test('tabel kosong mengembalikan list kosong', () async {
    final repository = KosRepository(source: const FakeKosDataSource([]));

    expect(await repository.getKosList(), isEmpty);
  });

  test('error sumber data dibungkus KosRepositoryException', () async {
    final repository = KosRepository(
      source: const ErrorKosDataSource('socket closed'),
    );

    expect(
      repository.getKosList(),
      throwsA(
        isA<KosRepositoryException>().having(
          (error) => error.message,
          'message',
          contains('Gagal memuat daftar kos'),
        ),
      ),
    );
  });
}
