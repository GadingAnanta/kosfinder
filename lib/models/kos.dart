/// Model satu baris tabel public.kos.
class Kos {
  const Kos({
    required this.id,
    required this.ownerId,
    required this.nama,
    required this.area,
    required this.harga,
    required this.fasilitas,
    required this.jumlahKamar,
    this.createdAt,
  });

  final String id;
  final String ownerId;
  final String nama;
  final String area;
  final int harga;
  final String fasilitas;
  final int jumlahKamar;
  final DateTime? createdAt;

  bool get isPenuh => jumlahKamar == 0;

  factory Kos.fromMap(Map<String, dynamic> map) {
    return Kos(
      id: map['id'] as String? ?? '',
      ownerId: map['owner_id'] as String? ?? '',
      nama: map['nama'] as String? ?? '',
      area: map['area'] as String? ?? '',
      harga: _asInt(map['harga']),
      fasilitas: map['fasilitas'] as String? ?? '',
      jumlahKamar: _asInt(map['jumlah_kamar']),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'owner_id': ownerId,
      'nama': nama,
      'area': area,
      'harga': harga,
      'fasilitas': fasilitas,
      'jumlah_kamar': jumlahKamar,
    };
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
