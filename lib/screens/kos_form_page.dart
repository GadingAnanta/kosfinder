import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/kos.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';

class KosFormPage extends StatefulWidget {
  const KosFormPage({super.key, this.kos});

  /// Kos yang akan diubah. Null berarti mode tambah kos.
  final Kos? kos;

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
  Kos? _selectedKos;

  @override
  void initState() {
    super.initState();
    if (widget.kos != null) _selectKos(widget.kos);
  }

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
    final auth = context.watch<AuthProvider>();
    final ownedKos = kosState.items
        .where((item) => item.ownerId == auth.session?.userId)
        .toList(growable: false);
    final isEditing = _selectedKos != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Ubah Kos' : 'Tambah Kos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.kos == null && ownedKos.isNotEmpty) ...[
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Kos saya',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButton<String?>(
                  value: _selectedKos?.id,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tambah kos baru'),
                    ),
                    ...ownedKos.map(
                      (item) => DropdownMenuItem<String?>(
                        value: item.id,
                        child: Text(item.nama),
                      ),
                    ),
                  ],
                  onChanged: (id) {
                    final selected = id == null
                        ? null
                        : ownedKos.firstWhere(
                            (item) => item.id == id,
                            orElse: () => _selectedKos ?? ownedKos.first,
                          );
                    setState(() => _selectKos(selected));
                    kosState.clearError();
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
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

    final kosState = context.read<KosProvider>();
    final editing = _selectedKos;
    final bool saved;
    if (editing == null) {
      saved = await kosState.createKos(
        ownerId: ownerId,
        nama: nama,
        area: area,
        harga: harga,
        fasilitas: fasilitas,
        jumlahKamar: jumlahKamar,
      );
    } else {
      saved = await kosState.updateKos(
        kosId: editing.id,
        ownerId: ownerId,
        nama: nama,
        area: area,
        harga: harga,
        fasilitas: fasilitas,
        jumlahKamar: jumlahKamar,
      );
    }

    if (saved && mounted) Navigator.of(context).maybePop();
  }

  void _selectKos(Kos? kos) {
    _selectedKos = kos;
    _namaController.text = kos?.nama ?? '';
    _areaController.text = kos?.area ?? '';
    _hargaController.text = kos == null ? '' : '${kos.harga}';
    _fasilitasController.text = kos?.fasilitas ?? '';
    _kamarController.text = kos == null ? '' : '${kos.jumlahKamar}';
    _validationError = null;
  }

  void _showValidation(String message) {
    setState(() => _validationError = message);
  }
}
