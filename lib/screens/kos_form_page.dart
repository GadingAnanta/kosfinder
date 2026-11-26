import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';

class KosFormPage extends StatefulWidget {
  const KosFormPage({super.key});

  @override
  State<KosFormPage> createState() => _KosFormPageState();
}

class _KosFormPageState extends State<KosFormPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _fasilitasController = TextEditingController();
  final TextEditingController _kamarController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _namaController.dispose();
    _areaController.dispose();
    _hargaController.dispose();
    _fasilitasController.dispose();
    _kamarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kosState = context.watch<KosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'Area',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fasilitasController,
              decoration: const InputDecoration(
                labelText: 'Fasilitas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kamarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah kamar',
                border: OutlineInputBorder(),
              ),
            ),
            if (_validationError != null) ...[
              const SizedBox(height: 12),
              Text(_validationError!, textAlign: TextAlign.center),
            ],
            if (kosState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(kosState.errorMessage!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: kosState.isSaving ? null : _submit,
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _validationError = null);
    context.read<KosProvider>().clearError();

    final nama = _namaController.text.trim();
    final area = _areaController.text.trim();
    final fasilitas = _fasilitasController.text.trim();
    final harga = int.tryParse(
      _hargaController.text.replaceAll(RegExp(r'\D'), ''),
    );
    final jumlahKamar = int.tryParse(_kamarController.text.trim());

    if (nama.isEmpty || area.isEmpty) {
      _showValidation('Nama dan area wajib diisi.');
      return;
    }
    if (harga == null) {
      _showValidation('Harga harus angka.');
      return;
    }
    if (jumlahKamar == null || jumlahKamar < 0) {
      _showValidation('Jumlah kamar harus angka dan tidak negatif.');
      return;
    }

    final ownerId = context.read<AuthProvider>().session?.userId;
    if (ownerId == null) {
      _showValidation('Login pemilik diperlukan.');
      return;
    }

    final saved = await context.read<KosProvider>().createKos(
      ownerId: ownerId,
      nama: nama,
      area: area,
      harga: harga,
      fasilitas: fasilitas,
      jumlahKamar: jumlahKamar,
    );

    if (saved && mounted) Navigator.of(context).maybePop();
  }

  void _showValidation(String message) {
    setState(() => _validationError = message);
  }
}
