import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../config/supabase_config.dart';
import '../providers/kos_provider.dart';
import 'about_page.dart';
import 'kos_detail_page.dart';

class KosListPage extends StatefulWidget {
  const KosListPage({super.key});

  @override
  State<KosListPage> createState() => _KosListPageState();
}

class _KosListPageState extends State<KosListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<KosProvider>().loadKos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<KosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang aplikasi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!SupabaseConfig.isConfigured)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text('Mode: Supabase belum dikonfigurasi'),
            ),
          Expanded(child: _buildBody(context, state)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, KosProvider state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Gagal memuat daftar kos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: state.loadKos,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(child: Text('Belum ada kos yang tersedia'));
    }

    return RefreshIndicator(
      onRefresh: state.loadKos,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final kos = state.items[index];
          return ListTile(
            title: Text(kos.nama),
            subtitle: Text('${kos.area} - Rp${kos.harga}'),
            trailing: kos.isPenuh
                ? const Chip(label: Text('Penuh'))
                : Text('${kos.jumlahKamar} kamar'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => KosDetailPage(kos: kos),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
