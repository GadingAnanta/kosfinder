import 'package:material_ui/material_ui.dart';

import 'config/supabase_config.dart';

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KosFinder',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const BootstrapPage(),
    );
  }
}

/// Halaman sementara untuk T01.
/// T04 akan menggantinya dengan daftar kos.
class BootstrapPage extends StatelessWidget {
  const BootstrapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KosFinder')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Fondasi Supabase dan model Kos sudah siap.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                SupabaseConfig.isConfigured
                    ? 'Mode: Supabase aktif'
                    : 'Mode: Supabase belum dikonfigurasi',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Berikutnya: daftar dan detail kos (Slice 1).',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
