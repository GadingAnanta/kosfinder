import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';

void main() {
  test('fromMap membaca harga dan jumlah kamar sebagai angka', () {
    final kos = Kos.fromMap({
      'id': 'k1',
      'owner_id': 'u1',
      'nama': 'Kos Melati',
      'area': 'Singaraja',
      'harga': 900000,
      'fasilitas': 'WiFi, AC',
      'jumlah_kamar': 0,
      'created_at': '2026-11-21T00:00:00Z',
    });

    expect(kos.harga, 900000);
    expect(kos.jumlahKamar, 0);
    expect(kos.isPenuh, isTrue);
    expect(kos.area, 'Singaraja');
  });

  test('toMap memakai nama kolom database', () {
    const kos = Kos(
      id: 'k2',
      ownerId: 'u1',
      nama: 'Kos Mawar',
      area: 'Tabanan',
      harga: 2500000,
      fasilitas: 'WiFi',
      jumlahKamar: 2,
    );

    final map = kos.toMap();

    expect(map['owner_id'], 'u1');
    expect(map['harga'], 2500000);
    expect(map['jumlah_kamar'], 2);
    expect(map.containsKey('id'), isFalse);
  });
}
