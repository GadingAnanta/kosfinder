import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'config/supabase_config.dart';
import 'providers/kos_provider.dart';
import 'repositories/kos_repository.dart';
import 'screens/kos_list_page.dart';

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KosFinder',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: ChangeNotifierProvider<KosProvider>(
        create: (_) => KosProvider(repository: _createRepository()),
        child: const KosListPage(),
      ),
    );
  }

  /// Tanpa --dart-define, pakai sumber kosong agar aplikasi tetap terbuka.
  /// Saat Supabase aktif, repository memakai client Supabase bawaan.
  static KosRepository _createRepository() {
    final source = SupabaseConfig.isConfigured
        ? null
        : const _EmptyKosDataSource();
    return KosRepository(source: source);
  }
}

class _EmptyKosDataSource implements KosDataSource {
  const _EmptyKosDataSource();

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async {
    return const <Map<String, dynamic>>[];
  }
}
