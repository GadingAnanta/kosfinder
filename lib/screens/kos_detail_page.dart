import 'package:material_ui/material_ui.dart';

import '../models/kos.dart';

class KosDetailPage extends StatelessWidget {
  const KosDetailPage({super.key, required this.kos});

  final Kos kos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kos.nama)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailRow(label: 'Nama', value: kos.nama),
          _DetailRow(label: 'Area', value: kos.area),
          _DetailRow(label: 'Harga', value: 'Rp${kos.harga}'),
          _DetailRow(
            label: 'Fasilitas',
            value: kos.fasilitas.isEmpty ? '-' : kos.fasilitas,
          ),
          _DetailRow(label: 'Jumlah kamar', value: '${kos.jumlahKamar}'),
          if (kos.isPenuh)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Chip(label: Text('Penuh')),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
