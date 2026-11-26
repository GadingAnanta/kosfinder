import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../config/supabase_config.dart';
import '../providers/kos_provider.dart';
import 'about_page.dart';
import 'auth_page.dart';
import 'kos_detail_page.dart';

class KosListPage extends StatefulWidget {
  const KosListPage({super.key});

  @override
  State<KosListPage> createState() => _KosListPageState();
}

class _KosListPageState extends State<KosListPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<KosProvider>().loadKos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<KosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Masuk pemilik',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AuthPage(),
                ),
              );
            },
          ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: state.setSearchQuery,
              decoration: InputDecoration(
                labelText: 'Cari area',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          state.clearSearch();
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              onChanged: state.setMaxPrice,
              decoration: InputDecoration(
                labelText: 'Harga maksimum',
                prefixIcon: const Icon(Icons.attach_money),
                helperText: state.hasInvalidMaxPrice
                    ? 'Harga maksimum harus angka'
                    : null,
                suffixIcon: state.maxPriceInput.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _priceController.clear();
                          state.clearMaxPrice();
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
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

    if (state.visibleItems.isEmpty) {
      final hasSearch = state.searchQuery.trim().isNotEmpty;
      final hasPrice = state.maxHarga != null;

      final message = !hasSearch && !hasPrice
          ? 'Belum ada kos yang tersedia'
          : hasSearch && !hasPrice
          ? 'Tidak ada kos di area tersebut'
          : !hasSearch && hasPrice
          ? 'Tidak ada kos dengan harga tersebut'
          : 'Tidak ada kos yang cocok dengan filter';

      return Center(child: Text(message));
    }

    return RefreshIndicator(
      onRefresh: state.loadKos,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.visibleItems.length,
        itemBuilder: (context, index) {
          final kos = state.visibleItems[index];
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
